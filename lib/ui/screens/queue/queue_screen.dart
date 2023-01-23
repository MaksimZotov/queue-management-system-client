import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/data/api/server_api.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_model.dart';
import 'package:queue_management_system_client/ui/widgets/client_item_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../router/routes_config.dart';
import '../base.dart';
import 'add_client_dialog.dart';


class QueueWidget extends BaseWidget<QueueConfig> {

  const QueueWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<QueueWidget> createState() => _QueueState();
}

class _QueueState extends BaseState<QueueWidget, QueueLogicState, QueueCubit> {

  @override
  Widget getWidget(
      BuildContext context,
      QueueLogicState state,
      QueueWidget widget
  ) => Scaffold(
    appBar: AppBar(
      title: Text(
          state.queueState.name.isEmpty
              ? ''
              : getLocalizations(context).queuePattern(state.queueState.name)
      ),
      actions: state.queueState.ownerUsername != null
          ? [
            IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: BlocProvider.of<QueueCubit>(context).downloadQrCode
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => BlocProvider.of<QueueCubit>(context).share(
                  getLocalizations(context).linkCopied
              ),
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
          builder: (context) => AddClientWidget(
              config: AddClientConfig(
                queueId: state.config.queueId,
                queueName: state.queueState.name
              ),
          )
      ),
      child: const Icon(Icons.add),
    ),
  );

  @override
  QueueCubit getCubit() => statesAssembler.getQueueCubit(widget.config);
}

class QueueLogicState extends BaseLogicState {

  final QueueConfig config;
  final QueueModel queueState;
  
  QueueLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.queueState,
  });

  QueueLogicState copyWith({
    QueueModel? queueState,
    BaseConfig? nextConfig,
  }) => QueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      queueState: queueState ?? this.queueState,
  );

  @override
  QueueLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => QueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      queueState: queueState
  );
}

@injectable
class QueueCubit extends BaseCubit<QueueLogicState> {

  static const String _queueTopic = '/topic/queues/';

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
      )
  );

  @override
  Future<void> onStart() async {
    await queueInteractor.getQueueState(
        state.config.queueId
    )..onSuccess((result) {
      emit(state.copyWith(queueState: result.data));
    })..onError((result) {
      showError(result);
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
        showError(result);
      });
  }

  Future<void> serve(ClientInQueueModel client) async {
    await queueInteractor.serveClientInQueue(state.config.queueId, client.id)
      ..onError((result) {
        showError(result);
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
    showSnackBar(notificationText);
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
    socketInteractor.disconnectFromSocket(
        _queueTopic + state.config.queueId.toString()
    );
    return super.close();
  }
}