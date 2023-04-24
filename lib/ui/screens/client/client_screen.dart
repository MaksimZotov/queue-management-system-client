import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/client_in_queue_status.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/queue_state_for_client_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/widgets/client_info_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/socket_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/locationnew/client.dart';
import '../../../domain/models/locationnew/location_state.dart';
import '../../widgets/button_widget.dart';
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
              style: const TextStyle(fontSize: 56)
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
                              fieldValue: state.queueName ?? '-'
                          ),
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).phoneWithColon,
                              fieldValue: state.clientState.phone ?? '-'
                          ),
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).codeWithColon,
                              fieldValue: state.clientState.code?.toString() ?? '-'
                          )
                        ],
                      )
                  ),
                  const SizedBox(height: 10),
                  ButtonWidget(
                      text: getLocalizations(context).leave,
                      onClick: getCubitInstance(context).leave
                  ),
                ]
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
}

class ClientLogicState extends BaseLogicState {

  final ClientConfig config;
  final QueueStateForClientModel clientState;
  final String phone;
  final bool showConfirmDialog;
  final LocationState locationState;

  String? get queueName {
    for (Client client in locationState.clients) {
      if (client.id == clientState.clientId && client.queue?.name != null) {
        return client.queue?.name;
      }
    }
    return null;
  }

  bool get inQueue =>
      queueName != null;

  ClientLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.clientState,
    required this.phone,
    required this.showConfirmDialog,
    required this.locationState
  });

  @override
  ClientLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    List<LocationModel>? locations,
    QueueStateForClientModel? clientState,
    String? phone,
    bool? showConfirmDialog,
    LocationState? locationState,
  }) => ClientLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      clientState: clientState ?? this.clientState,
      phone: phone ?? this.phone,
      showConfirmDialog: showConfirmDialog ?? this.showConfirmDialog,
      locationState: locationState ?? this.locationState
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
          phone: '',
          showConfirmDialog: false,
          locationState: LocationState(null, [])
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
        emit(state.copy(clientState: result.data, phone: result.data.phone));
        _connectToSocket();
        hideLoad();
      })
      ..onError((result) async {
        await _clientInteractor.getQueueStateForClient(
            state.config.clientId,
            state.config.accessKey
        )
          ..onSuccess((result) {
            emit(state.copy(clientState: result.data, phone: result.data.phone));
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

  Future<void> leave() async {
    showLoad();
    await _clientInteractor.leaveQueue(state.config.clientId, state.config.accessKey)
      ..onSuccess((result) {
        emit(state.copy(clientState: result.data));
      })
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> _connectToSocket() async {
    await _locationInteractor.getLocationState(
        state.clientState.locationId
    )..onSuccess((result) {
      _handleNewLocationState(result.data);
    })..onError((result) {
      showError(result);
    });
    _socketInteractor.connectToSocket<LocationState>(
        _locationTopic + state.clientState.locationId.toString(),
        () => { /* Do nothing */ },
        _handleNewLocationState,
        (error) => { /* Do nothing */ }
    );
    _startUpdating();
  }

  void _handleNewLocationState(LocationState locationState) {
    emit(state.copy(locationState: locationState));
  }

  void _startUpdating() async {
    _timer = Timer.periodic(const Duration(seconds: _updatePeriod), (timer) {
      emit(state.copy(error: state.error));
    });
  }
}