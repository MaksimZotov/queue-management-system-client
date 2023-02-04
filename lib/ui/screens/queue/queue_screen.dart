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
import 'package:queue_management_system_client/domain/models/queue/queue_state_model.dart';
import 'package:queue_management_system_client/ui/widgets/client_item_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../router/routes_config.dart';
import '../base.dart';


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
          state.queueStateModel.name.isEmpty
              ? ''
              : getLocalizations(context).queuePattern(state.queueStateModel.name)
      ),
      actions: state.queueStateModel.ownerEmail != null
          ? [
            IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: getCubitInstance(context).downloadQrCode
            ),
          ]
          : null,
    ),
    body: ListView.builder(
      itemBuilder: (context, index) {
        return ClientItemWidget(
          client: state.queueStateModel.clients[index],
          onNotify: getCubitInstance(context).notify,
          onServe: getCubitInstance(context).serve,
        );
      },
      itemCount: state.queueStateModel.clients.length,
    )
  );

  @override
  QueueCubit getCubit() => statesAssembler.getQueueCubit(widget.config);
}

class QueueLogicState extends BaseLogicState {

  final QueueConfig config;
  final QueueStateModel queueStateModel;
  
  QueueLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.queueStateModel,
  });

  @override
  QueueLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    QueueStateModel? queueStateModel,
  }) => QueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      queueStateModel: queueStateModel ?? this.queueStateModel
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
          queueStateModel: QueueStateModel(
            id: config.queueId,
            name: '',
            clients: []
          ),
      )
  );

  @override
  Future<void> onStart() async {
    await queueInteractor.getQueueState(
        state.config.queueId
    )..onSuccess((result) {
      emit(state.copy(queueStateModel: result.data));
    })..onError((result) {
      showError(result);
    });

    socketInteractor.connectToSocket<QueueStateModel>(
      _queueTopic + state.config.queueId.toString(),
      () => { /* Do nothing */ },
      (queue) => {
        emit(state.copy(queueStateModel: queue))
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

  Future<void> downloadQrCode() async {
    String email = state.queueStateModel.ownerEmail!;
    int locationId = state.config.locationId;
    int queueId = state.config.queueId;
    String url = '${ServerApi.clientUrl}/$email/locations/$locationId/queues/$queueId/client';

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