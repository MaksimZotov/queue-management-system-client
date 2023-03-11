import 'dart:async';

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
import '../../../dimens.dart';
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
    body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: (state.servingClient != null
          ? <Widget>[
            ClientItemWidget(
              client: state.servingClient!,
              onNotify: getCubitInstance(context).notify,
              onServe: getCubitInstance(context).serve,
              onReturn: getCubitInstance(context).returnClient,
              onCall: null,
              onDelete: getCubitInstance(context).delete,
            ),
            const SizedBox(height: Dimens.contentMargin),
            Container(height: 2, color: Colors.grey),
            const SizedBox(height: Dimens.contentMargin)
          ]
          : <Widget>[]
      ) + [
        Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => ClientItemWidget(
                client: state.availableClients[index],
                onNotify: getCubitInstance(context).notify,
                onServe: null,
                onReturn: null,
                onCall: getCubitInstance(context).call,
                onDelete: getCubitInstance(context).delete,
              ),
              itemCount: state.availableClients.length,
            )
        )
      ],
    )
  );

  @override
  QueueCubit getCubit() => statesAssembler.getQueueCubit(widget.config);
}

class QueueLogicState extends BaseLogicState {

  final QueueConfig config;
  final QueueStateModel queueStateModel;
  final LocationState locationState;

  Client? get servingClient {
    for (Client client in locationState.clients) {
      if (client.queue?.id == queueStateModel.id) {
        return client;
      }
    }
    return null;
  }

  List<Client> get availableClients {
    return List.from(locationState.clients)
      ..removeWhere((client) => client.id == servingClient?.id);
  }
  
  QueueLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.queueStateModel,
    required this.locationState
  });

  @override
  QueueLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    QueueStateModel? queueStateModel,
    LocationState? locationState,
    List<Client>? clients
  }) => QueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      queueStateModel: queueStateModel ?? this.queueStateModel,
      locationState: locationState ?? this.locationState
  );
}

@injectable
class QueueCubit extends BaseCubit<QueueLogicState> {

  static const String _locationTopic = '/topic/locations/';

  static const int _updatePeriod = 10;

  final QueueInteractor _queueInteractor;
  final ClientInteractor _clientInteractor;
  final SocketInteractor _socketInteractor;
  final LocationInteractor _locationInteractor;

  Timer? _timer;

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
          locationState: LocationState(null, [])
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
      _handleNewLocationState(result.data);
    })..onError((result) {
      showError(result);
    });

    _socketInteractor.connectToSocket<LocationState>(
      _locationTopic + state.config.locationId.toString(),
      () => { /* Do nothing */ },
      _handleNewLocationState,
      (error) => { /* Do nothing */ }
    );

    _startUpdating();
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

  Future<void> returnClient(Client client) async {
    await _queueInteractor.returnClientToQueue(state.config.queueId, client.id)
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> call(Client client) async {
    await _queueInteractor.callClientInQueue(state.config.queueId, client.id)
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
    _timer?.cancel();
    return super.close();
  }

  void _handleNewLocationState(LocationState locationState) {
    emit(
        state.copy(
            locationState: locationState,
            clients: locationState.clients
        )
    );
  }

  void _startUpdating() async {
    _timer = Timer.periodic(const Duration(seconds: _updatePeriod), (timer) {
      emit(state.copy());
    });
  }
}