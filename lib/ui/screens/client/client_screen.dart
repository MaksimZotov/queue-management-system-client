import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/client_in_queue_status.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/queue_state_for_client_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/widgets/client_info_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
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
  ) => Scaffold(
    appBar: AppBar(
      title: Text(state.clientState.queueName),
    ),
    body: state.loading ? const Center(
      child: CircularProgressIndicator(),
    ) : Center(
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
                      elevation: state.clientState.inQueue ? 5 : 0,
                      color: state.clientState.inQueue ? Colors.white : Colors.transparent,
                      child: Column(
                        children: <Widget>[] + (state.clientState.inQueue ? [
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).statusWithColon,
                              fieldValue: state.clientState.status == ClientInQueueStatus.confirmed
                                  ? getLocalizations(context).confirmed
                                  : getLocalizations(context).reserved
                          ),
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).emailWithColon,
                              fieldValue: state.clientState.email!
                          ),
                        ] : []) + (state.clientState.status == ClientInQueueStatus.confirmed ? [
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).codeWithColon,
                              fieldValue: state.clientState.code.toString()
                          )
                        ] : []),
                      )
                  ),
                  const SizedBox(height: 10),
                  Column(
                      children: (state.clientState.status == ClientInQueueStatus.confirmed ? <Widget>[
                        ButtonWidget(
                            text: getLocalizations(context).leave,
                            onClick: getCubitInstance(context).leave
                        )
                      ] : <Widget>[]) + <Widget>[
                        ButtonWidget(
                            text: getLocalizations(context).update,
                            onClick: getCubitInstance(context).onStart
                        ),
                      ]
                  ),
                ]
            ),
          ),
        ),
      ),
    ),
  );

  @override
  ClientCubit getCubit() => statesAssembler.getClientCubit(widget.config);
}

class ClientLogicState extends BaseLogicState {

  final ClientConfig config;
  final QueueStateForClientModel clientState;
  final String email;
  final bool showConfirmDialog;

  ClientLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.config,
    required this.clientState,
    required this.email,
    required this.showConfirmDialog
  });

  @override
  ClientLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    List<LocationModel>? locations,
    QueueStateForClientModel? clientState,
    String? email,
    bool? showConfirmDialog,
  }) => ClientLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      clientState: clientState ?? this.clientState,
      email: email ?? this.email,
      showConfirmDialog: showConfirmDialog ?? this.showConfirmDialog
  );
}

@injectable
class ClientCubit extends BaseCubit<ClientLogicState> {

  final ClientInteractor _clientInteractor;

  ClientCubit(
    this._clientInteractor,
    @factoryParam ClientConfig config
  ) : super(
      ClientLogicState(
          config: config,
          clientState: QueueStateForClientModel(
            inQueue: false,
            queueName: '',
            code: 0
          ),
          email: '',
          showConfirmDialog: false
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
        emit(state.copy(clientState: result.data, email: result.data.email));
        hideLoad();
      })
      ..onError((result) async {
        await _clientInteractor.getQueueStateForClient(
            state.config.clientId,
            state.config.accessKey
        )
          ..onSuccess((result) {
            emit(state.copy(clientState: result.data, email: result.data.email));
            hideLoad();
          })
          ..onError((result) {
            showError(result);
          });
      });
  }

  Future<void> leave() async {
    showLoad();
    await _clientInteractor.leaveQueue(state.config.clientId, state.config.accessKey)
      ..onSuccess((result) {
        emit(state.copy(clientState: result.data));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}