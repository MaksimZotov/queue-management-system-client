import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/data/api/server_api.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/locationnew/location_state.dart';
import 'package:queue_management_system_client/domain/models/queue/client_in_queue_model.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_state_model.dart';
import 'package:queue_management_system_client/ui/widgets/client_item_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/client_interactor.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../../domain/models/locationnew/client.dart';
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
      title: Text(state.queueStateModel.name),
        actions: state.queueStateModel.enabled != null
            ? [
              IconButton(
                  tooltip: state.queueStateModel.enabled == true
                      ? getLocalizations(context).turnOffQueue
                      : getLocalizations(context).turnOnQueue,
                  icon: Icon(
                      state.queueStateModel.enabled == true
                          ? Icons.bedtime_off
                          : Icons.bedtime
                  ),
                  onPressed: getCubitInstance(context).changeQueueEnableState
              )
            ]
            : null
    ),
    body: ListView.builder(
      itemBuilder: (context, index) {
        return ClientItemWidget(
          client: state.availableClients[index],
          onNotify: getCubitInstance(context).notify,
          onServe: getCubitInstance(context).serve,
          onDelete: getCubitInstance(context).delete,
        );
      },
      itemCount: state.availableClients.length,
    )
  );

  @override
  QueueCubit getCubit() => statesAssembler.getQueueCubit(widget.config);
}

class QueueLogicState extends BaseLogicState {

  final QueueConfig config;
  final QueueStateModel queueStateModel;
  final LocationState? locationState;
  final Client? servingClient;
  final List<Client> availableClients;
  
  QueueLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.queueStateModel,
    required this.locationState,
    required this.servingClient,
    required this.availableClients
  });

  @override
  QueueLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    QueueStateModel? queueStateModel,
    LocationState? locationState,
    Client? servingClient,
    List<Client>? availableClients
  }) => QueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      queueStateModel: queueStateModel ?? this.queueStateModel,
      locationState: locationState,
      servingClient: servingClient,
      availableClients: availableClients ?? this.availableClients
  );
}

@injectable
class QueueCubit extends BaseCubit<QueueLogicState> {

  static const String _locationTopic = '/topic/locations/';

  final QueueInteractor _queueInteractor;
  final ClientInteractor _clientInteractor;
  final SocketInteractor _socketInteractor;
  final LocationInteractor _locationInteractor;

  QueueCubit(
    this._queueInteractor,
    this._clientInteractor,
    this._socketInteractor,
    this._locationInteractor,
    @factoryParam QueueConfig config
  ) : super(
      QueueLogicState(
          config: config,
          queueStateModel: QueueStateModel(
              id: config.queueId,
              name: '',
              services: []
          ),
          locationState: null,
          servingClient: null,
          availableClients: []
      )
  );

  @override
  Future<void> onStart() async {
    await _queueInteractor.getQueueState(
        state.config.queueId
    )..onSuccess((result) {
      emit(state.copy(queueStateModel: result.data));
    })..onError((result) {
      showError(result);
    });

    await _locationInteractor.getLocationState(
        state.config.locationId
    )..onSuccess((result) {
      emit(
          state.copy(
              locationState: result.data,
              availableClients: result.data.clients
          )
      );
    })..onError((result) {
      showError(result);
    });

    _socketInteractor.connectToSocket<LocationState>(
      _locationTopic + state.config.locationId.toString(),
      () => { /* Do nothing */ },
      (locationState) => {
        emit(state.copy(locationState: locationState))
      },
      (error) => { /* Do nothing */ }
    );
  }

  Future<void> notify(Client client) async {
    await _queueInteractor.notifyClientInQueue(state.config.queueId, client.id)
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> serve(Client client) async {
    await _queueInteractor.serveClientInQueue(state.config.queueId, client.id)
      ..onError((result) {
        showError(result);
    });
  }

  Future<void> delete(Client client) async {
    await _clientInteractor.deleteClientInLocation(state.config.locationId, client.id)
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> changeQueueEnableState() async {
    Result result;
    if (state.queueStateModel.enabled == true) {
      result = await _queueInteractor.disableQueue(state.config.queueId);
    } else {
      result = await _queueInteractor.enableQueue(state.config.queueId);
    }
    result.onError((result) {
      showError(result);
    });
  }

  @override
  Future<void> close() async {
    _socketInteractor.disconnectFromSocket(
        _locationTopic + state.config.locationId.toString()
    );
    return super.close();
  }
}