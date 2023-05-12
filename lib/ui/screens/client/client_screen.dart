import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/queue_state_for_client_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/ui/models/client/services_container.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/widgets/client_info_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/change/base/location_change_model.dart';
import '../../../domain/models/location/state/client.dart';
import '../../../domain/models/location/state/location_state.dart';
import '../../../domain/models/location/state/service.dart';
import '../base.dart';

class ClientWidget extends BaseWidget<ClientConfig> {

  const ClientWidget({
    super.key,
    required super.config,
    required super.emitConfig,
  });

  @override
  State<ClientWidget> createState() => _ClientState();
}

class _ClientState extends BaseState<
    ClientWidget, 
    ClientLogicState,
    ClientCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      ClientLogicState state,
      ClientWidget widget
  ) => Scaffold(body: _getBody(context, state, widget));

  @override
  ClientCubit getCubit() => statesAssembler.getClientCubit(widget.config);

  Widget _getBody(
      BuildContext context,
      ClientLogicState state,
      ClientWidget widget
  ) {
    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    String? errorText = state.error?.description ?? getErrorText(context, state.error);
    if (errorText != null) {
      return Center(
          child: Text(
              errorText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32)
          )
      );
    }
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 16
            ),
            child: Column(
                children: <Widget>[
                  Card(
                      elevation: 5,
                      color: Colors.white,
                      child: Column(
                        children: [
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).queueWithColon,
                              fieldValue: state.client?.queue?.name ?? '-'
                          ),
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).phoneWithColon,
                              fieldValue: state.clientState.phone ?? '-'
                          ),
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).waitTimeWithColon,
                              fieldValue: _getTimeInMinutes(context, state.client?.waitTimeInMinutes)
                          ),
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).totalTimeWithColon,
                              fieldValue: _getTimeInMinutes(context, state.client?.totalTimeInMinutes)
                          ),
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).codeWithColon,
                              fieldValue: state.clientState.code?.toString() ?? '-'
                          ),
                        ],
                      )
                  ),
                  const SizedBox(height: Dimens.contentMargin)
                ] + _getServices(context, state.client)
            ),
          ),
        ),
      ),
    );
  }

  @override
  void handleEvent(
      BuildContext context,
      ClientLogicState state,
      ClientWidget widget
  ) {
    // Do nothing
  }

  String _getTimeInMinutes(BuildContext context, int? time) {
    if (time == null) {
      return '-';
    }
    return getLocalizations(context).timeInMinutesPattern(time);
  }

  List<Widget> _getServices(BuildContext context, Client? client) {
    if (client == null) {
      return [];
    }
    List<Service> services = client.services.toList();
    if (services.isEmpty) {
      return [];
    }

    List<ServicesContainer> servicesForClientContainers = [];
    List<Service> servicesWithCurOrder = [];

    services.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    int curOrderNumber = services[0].orderNumber;

    int priorityNumber = 1;
    for (int i = 0; i < services.length; i++) {
      Service service = services[i];
      if (service.orderNumber != curOrderNumber) {
        servicesForClientContainers.add(
            ServicesContainer(
                priorityNumber: priorityNumber,
                services: servicesWithCurOrder
            )
        );
        curOrderNumber = service.orderNumber;
        servicesWithCurOrder = [];
        priorityNumber += 1;
      }
      servicesWithCurOrder.add(service);
    }
    if (servicesWithCurOrder.isNotEmpty) {
      servicesForClientContainers.add(
          ServicesContainer(
              priorityNumber: priorityNumber,
              services: servicesWithCurOrder
          )
      );
    }

    return servicesForClientContainers.map((container) =>
        Card(
            elevation: 5,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                          getLocalizations(context).servicesWithPriorityPattern(
                              container.priorityNumber
                          ),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18
                          )
                      )
                  )
                ] + container.services.map((service) =>
                    Card(
                        elevation: 2,
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                                service.name,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                )
                            )
                        )
                    )
                ).toList(),
              )
            )
        )
    ).toList();
  }
}

class ClientLogicState extends BaseLogicState {

  final ClientConfig config;
  final QueueStateForClientModel clientState;
  final bool showConfirmDialog;
  final LocationState? locationState;
  final Client? client;

  bool get inQueue =>
      client?.queue != null;

  ClientLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.clientState,
    required this.showConfirmDialog,
    required this.locationState,
    required this.client
  });

  @override
  ClientLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    List<LocationModel>? locations,
    QueueStateForClientModel? clientState,
    bool? showConfirmDialog,
    LocationState? locationState,
    Client? client
  }) => ClientLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      clientState: clientState ?? this.clientState,
      showConfirmDialog: showConfirmDialog ?? this.showConfirmDialog,
      locationState: locationState ?? this.locationState,
      client: client ?? this.client
  );
}

@injectable
class ClientCubit extends BaseCubit<ClientLogicState> {

  static const String _locationTopic = '/topic/locations/';

  static const int _updatePeriod = 10;

  final ClientInteractor _clientInteractor;
  final SocketInteractor _socketInteractor;
  final LocationInteractor _locationInteractor;

  Timer? _timer;

  List<LocationChange> changes = [];

  ClientCubit(
    this._clientInteractor,
    this._socketInteractor,
    this._locationInteractor,
    @factoryParam ClientConfig config
  ) : super(
      ClientLogicState(
          config: config,
          clientState: QueueStateForClientModel(
            clientId: -1,
            locationId: -1
          ),
          showConfirmDialog: false,
          locationState: LocationState(
              id: null,
              clients: []
          ),
          client: null
      )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    await _clientInteractor.confirmAccessKeyByClient(
        state.config.clientId,
        state.config.accessKey
    )
      ..onSuccess((result) {
        emit(state.copy(clientState: result.data));
        _connectToSocket();
        hideLoad();
      })
      ..onError((result) async {
        await _clientInteractor.getQueueStateForClient(
            state.config.clientId
        )
          ..onSuccess((result) {
            emit(state.copy(clientState: result.data));
            hideLoad();
            _connectToSocket();
          })
          ..onError((result) {
            showError(result);
          });
      });
  }

  @override
  Future<void> close() async {
    _socketInteractor.disconnectFromSocket(
        _locationTopic + state.clientState.locationId.toString()
    );
    _timer?.cancel();
    return super.close();
  }

  @override
  void showError(ErrorResult result) {
    _socketInteractor.disconnectFromSocket(
        _locationTopic + state.clientState.locationId.toString()
    );
    _timer?.cancel();
    emit(state.copy(loading: false, error: result));
  }

  Future<void> _connectToSocket() async {
    _socketInteractor.connectToSocket<LocationChange>(
        _locationTopic + state.clientState.locationId.toString(),
        () async => {
          await _locationInteractor.getLocationState(
              state.clientState.locationId
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

    Client? curClient;

    for (Client client in actualLocationState.clients) {
      if (client.id == state.clientState.clientId) {
        curClient = client;
      }
    }

    emit(
        state.copy(
            locationState: actualLocationState,
            client: curClient
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
}