import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/queue_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/domain/models/client/serve_client_request.dart';
import 'package:queue_management_system_client/domain/models/location/state/location_state.dart';
import 'package:queue_management_system_client/domain/models/queue/queue_state_model.dart';
import 'package:queue_management_system_client/ui/widgets/client_item_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/client_interactor.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../../domain/models/location/change/base/location_change_model.dart';
import '../../../domain/models/location/state/client.dart';
import '../../../domain/models/location/state/service.dart';
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
          title: Text(state.queueStateModel.name)
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => index == 0
            ? Column(
                children: (state.servingClient != null ? <Widget>[
                  ClientItemWidget(
                    client: state.servingClient!,
                    onChange: (client) => widget.emitConfig(
                        ServicesSequencesConfig(
                            accountId: widget.config.accountId,
                            locationId: widget.config.locationId,
                            kioskMode: null,
                            multipleSelect: null,
                            clientId: client.id,
                            queueId: widget.config.queueId
                        )
                    ),
                    onNotify: getCubitInstance(context).notify,
                    onServe: getCubitInstance(context).serve,
                    onReturn: getCubitInstance(context).returnClient,
                    onCall: null,
                    onDelete: getCubitInstance(context).delete,
                  ),
                  const SizedBox(height: Dimens.contentMargin),
                  Container(height: 2, color: Colors.grey),
                  const SizedBox(height: Dimens.contentMargin)
                ] : <Widget>[])
            )
            : ClientItemWidget(
                client: state.availableClients[index - 1],
                onChange: null,
                onNotify: getCubitInstance(context).notify,
                onServe: null,
                onReturn: null,
                onCall: getCubitInstance(context).call,
                onDelete: getCubitInstance(context).delete,
            ),
        itemCount: 1 + state.availableClients.length,
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
    List<Client>? availableClients,
  }) => QueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      queueStateModel: queueStateModel ?? this.queueStateModel,
      locationState: locationState ?? this.locationState,
      servingClient: servingClient ?? this.servingClient,
      availableClients: availableClients ?? this.availableClients
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

  List<LocationChange> changes = [];

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

    _socketInteractor.connectToSocket<LocationChange>(
      _locationTopic + state.config.locationId.toString(),
      () async => {
        await _locationInteractor.getLocationState(
            state.config.locationId
        )..onSuccess((result) {
            _setLocationState(result.data);
        })..onError((result) {
            showError(result);
        })
      },
      _handleLocationChange,
      (error) => { }
    );

    _startUpdating();
  }

  Future<void> notify(Client client) async {
    await _clientInteractor.notifyClientInQueue(state.config.queueId, client.id)
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> serve(Client client) async {
    await _clientInteractor.serveClientInQueue(
        state.config.queueId,
        client.id,
        ServeClientRequest(
            services: state.servingClient?.services.map((e) => e.id).toList() ?? []
        )
    )
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> returnClient(Client client) async {
    await _clientInteractor.returnClientToQueue(state.config.queueId, client.id)
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> call(Client client) async {
    await _clientInteractor.callClientInQueue(state.config.queueId, client.id)
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

  @override
  Future<void> close() async {
    _socketInteractor.disconnectFromSocket(
        _locationTopic + state.config.locationId.toString()
    );
    _timer?.cancel();
    return super.close();
  }

  void _startUpdating() async {
    _timer = Timer.periodic(const Duration(seconds: _updatePeriod), (timer) {
      emit(state.copy());
    });
  }

  void _setLocationState(LocationState locationState) {
    LocationState actualLocationState = _locationInteractor.transformLocation(
        locationState,
        changes
    );

    Client? servingClient;
    for (Client client in actualLocationState.clients) {
      if (client.queue?.id == state.queueStateModel.id) {
        servingClient = _mapClientWithMinOrder(client);
        if (servingClient.services.isNotEmpty) {
          break;
        }
      }
    }

    List<Client> filteredClients = List.from(actualLocationState.clients)
      ..removeWhere((client) => client.id == servingClient?.id || client.queue != null);

    List<Client> availableClients = filteredClients.map(_mapClientWithMinOrder).toList()
      ..removeWhere((client) => client.services.isEmpty);

    availableClients.sort((a, b) => a.waitTimestamp.compareTo(b.waitTimestamp));

    emit(
        QueueLogicState(
            config: state.config,
            queueStateModel: state.queueStateModel,
            locationState: actualLocationState,
            servingClient: servingClient,
            availableClients: availableClients
        )
    );

    changes.clear();
  }

  void _handleLocationChange(LocationChange locationChange) {
    LocationState? prevLocationState = state.locationState;
    changes.add(locationChange);
    if (prevLocationState != null) {
      LocationState newLocationState = _locationInteractor.transformLocation(
          prevLocationState,
          changes
      );
      changes.clear();
      _setLocationState(newLocationState);
    }
  }

  Client _mapClientWithMinOrder(Client client) {
    int min = 0x7fffffff;
    for (Service service in client.services) {
      if (service.orderNumber < min) {
        min = service.orderNumber;
      }
    }
    return Client(
        id: client.id,
        code: client.code,
        phone: client.phone,
        waitTimestamp: client.waitTimestamp,
        totalTimestamp: client.totalTimestamp,
        services: List.from(client.services)
          ..removeWhere((service) => !state.queueStateModel.services.contains(service.id) || service.orderNumber != min),
        queue: client.queue
    );
  }
}