import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/data/api/server_api.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/client_join_info_model.dart';
import 'package:queue_management_system_client/domain/models/queue/add_client_info.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/ui/widgets/client_item_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../router/routes_config.dart';
import 'add_client_dialog.dart';


class QueueWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;
  final QueueConfig config;

  QueueWidget({super.key, required this.config, required this.emitConfig});

  @override
  State<QueueWidget> createState() => _QueueState();
}

class _QueueState extends State<QueueWidget> {
  final titleStart = 'Очередь: ';
  final linkCopied = 'Ссылка скопирована';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QueueCubit>(
      create: (context) => statesAssembler.getQueueCubit(widget.config)..onStart(),
      child: BlocConsumer<QueueCubit, QueueLogicState>(

        listener: (context, state) {
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(
                state.queueState.name.isEmpty ? '' : titleStart + state.queueState.name
            ),
            actions: state.queueState.ownerUsername != null
              ? [
                IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: BlocProvider.of<QueueCubit>(context).downloadQrCode
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => BlocProvider.of<QueueCubit>(context).share(linkCopied),
                ),
              ]
              : null,
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              return ClientItemWidget(
                client: state.queueState.clients![index],
                onNotify: BlocProvider.of<QueueCubit>(context).notify,
                onServe: BlocProvider.of<QueueCubit>(context).serve,
              );
            },
            itemCount: state.queueState.clients!.length,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => const AddClientWidget()
            ).then((result) {
              if (result is AddClientResult) {
                BlocProvider.of<QueueCubit>(context).addClient(result);
              }
            }),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class QueueLogicState {

  final QueueConfig config;

  final QueueModel queueState;

  final String? snackBar;
  final bool loading;
  
  QueueLogicState({
    required this.config,
    required this.queueState,
    required this.snackBar,
    required this.loading,
  });

  QueueLogicState copyWith({
    QueueModel? queueState,
    String? snackBar,
    bool? loading,
  }) => QueueLogicState(
      config: config,
      queueState: queueState ?? this.queueState,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class QueueCubit extends Cubit<QueueLogicState> {

  static String _queueTopic = '/topic/queues/';

  final QueueInteractor queueInteractor;
  final SocketInteractor socketInteractor;


  QueueCubit(
    this.queueInteractor,
    this.socketInteractor,
    @factoryParam QueueConfig config
  ) : super(
      QueueLogicState(
          config: config,
          queueState: QueueModel(
            id: config.queueId,
            name: '',
            description: '',
            clients: []
          ),
          snackBar: null,
          loading: false
      )
  );

  Future<void> onStart() async {
    emit(state.copyWith(loading: true));
    await queueInteractor.getQueueState(state.config.queueId)..onSuccess((result) {
      emit(state.copyWith(loading: false, queueState: result.data));
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
      emit(state.copyWith(snackBar: null));
    });

    socketInteractor.connectToSocket<QueueModel>(
      _queueTopic + state.config.queueId.toString(),
      () => { /* Do nothing */ },
      (queue) => {
        emit(state.copyWith(queueState: queue))
      },
      (error) => { /* Do nothing */ }
    );
  }

  Future<void> notify(ClientInQueueModel client) async {
    await queueInteractor.notifyClientInQueue(state.config.queueId, client.id)
      ..onError((result) {
        emit(state.copyWith(snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future<void> serve(ClientInQueueModel client) async {
    await queueInteractor.serveClientInQueue(state.config.queueId, client.id)
      ..onError((result) {
        emit(state.copyWith(snackBar: result.description));
        emit(state.copyWith(snackBar: null));
    });
  }

  Future<void> share(String notificationText) async {
    String username = state.queueState.ownerUsername!;
    int locationId = state.config.locationId;
    int queueId = state.config.queueId;
    await Clipboard.setData(
        ClipboardData(
            text: '${ServerApi.clientUrl}/$username/locations/$locationId/queues/$queueId/client'
        )
    );
    emit(state.copyWith(snackBar: notificationText));
    emit(state.copyWith(snackBar: null));
  }

  Future<void> downloadQrCode() async {
    String username = state.queueState.ownerUsername!;
    int locationId = state.config.locationId;
    int queueId = state.config.queueId;
    String url = '${ServerApi.clientUrl}/$username/locations/$locationId/queues/$queueId/client';

    final image = await QrPainter(
      data: url,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImageData(1024);

    if (image != null) {
      await FileSaver.instance.saveFile(
          url,
          image.buffer.asUint8List(),
          'png',
          mimeType: MimeType.PNG
      );
    }
  }

  @override
  Future<void> close() async {
    socketInteractor.disconnectFromSocket(_queueTopic + state.config.queueId.toString());
    return super.close();
  }

  Future<void> addClient(AddClientResult addClientResult) async {
    emit(state.copyWith(loading: true));
    await queueInteractor.addClientToQueue(
        state.config.queueId,
        AddClientInfo(
            firstName: addClientResult.firstName,
            lastName: addClientResult.lastName
        )
    )
        ..onSuccess((result) async {
          if (addClientResult.save) {
            await downloadClientState(
                state.queueState.name,
                result.data.publicCode.toString(),
                addClientResult.firstName,
                addClientResult.lastName,
                result.data.accessKey
            );
          }
        })
        ..onError((result) {
          emit(state.copyWith(loading: false, snackBar: result.description));
          emit(state.copyWith(snackBar: null));
        });
  }

  Future<void> downloadClientState(
      String queueName,
      String publicKey,
      String firstName,
      String lastName,
      String accessKey
  ) async {
    final pdf = pw.Document();
    final font = await rootBundle.load("fonts/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
        pw.Page(
            pageFormat: const PdfPageFormat(60 * PdfPageFormat.mm, 58 * PdfPageFormat.mm),
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text(
                              queueName,
                              style: pw.TextStyle(font: ttf, fontSize: 18)
                          ),
                          pw.Text(
                              publicKey,
                              style: pw.TextStyle(font: ttf, fontSize: 18)
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                              '$firstName $lastName',
                              style: pw.TextStyle(font: ttf, fontSize: 18)
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                              accessKey,
                              style: pw.TextStyle(font: ttf, fontSize: 18)
                          )
                        ]
                    )
                )
              );
            }
        )
    );

    await FileSaver.instance.saveFile(
        '$firstName $lastName $queueName',
        await pdf.save(),
        'pdf',
        mimeType: MimeType.PDF
    );
  }
}