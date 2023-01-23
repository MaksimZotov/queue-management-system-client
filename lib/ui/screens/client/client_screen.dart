import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/client_in_queue_status.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/client_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/client/client_confirm_dialog.dart';
import 'package:queue_management_system_client/ui/screens/client/client_join_dialog.dart';
import 'package:queue_management_system_client/ui/screens/client/client_rejoin_dialog.dart';
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
  void handleEvent(
      BuildContext context,
      ClientLogicState state,
      ClientWidget widget
  ) {
    super.handleEvent(context, state, widget);
    if (state.showConfirmDialog) {
      showDialog(
          context: context,
          builder: (context) => ClientConfirmWidget(
              config: ClientConfirmConfig(
                  queueId: state.config.queueId,
                  email: state.email
              )
          )
      ).then((result) {
        if (result is ClientConfirmResult) {
          getCubitInstance(context).handleConfirmResult(result);
        }
      });
    }
  }

  @override
  Widget getWidget(
      BuildContext context,
      ClientLogicState state,
      ClientWidget widget
  ) =>  Scaffold(
    appBar: AppBar(
      title: Text(
          getLocalizations(context).queuePattern(state.clientState.queueName)
      ),
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
                        children: <Widget>[
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).queueLengthWithColon,
                              fieldValue: state.clientState.queueLength.toString()
                          )
                        ] + (state.clientState.inQueue ? [
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
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).firstNameWithColon,
                              fieldValue: state.clientState.firstName!
                          ),
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).lastNameWithColon,
                              fieldValue: state.clientState.lastName!
                          ),
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).beforeMeWithColon,
                              fieldValue: state.clientState.beforeMe.toString()
                          )
                        ] : []) + (state.clientState.status == ClientInQueueStatus.confirmed ? [
                          ClientInfoFieldWidget(
                              fieldName: getLocalizations(context).code,
                              fieldValue: state.clientState.accessKey!
                          )
                        ] : []),
                      )
                  ),
                  const SizedBox(height: 10),
                  Column(
                      children: (!state.clientState.inQueue ? <Widget>[
                        ButtonWidget(
                          text: getLocalizations(context).join,
                          onClick: () => showDialog(
                              context: context,
                              builder: (context) => ClientJoinWidget(
                                  config: ClientJoinConfig(
                                    queueId: state.config.queueId
                                  ),
                              )
                          ).then((result) {
                            if (result is ClientJoinResult) {
                              getCubitInstance(context).handleJoinResult(result);
                            }
                          }),
                        )
                      ] : <Widget>[]) + (state.clientState.status == ClientInQueueStatus.confirmed ? <Widget>[
                        ButtonWidget(
                            text: getLocalizations(context).leave,
                            onClick: getCubitInstance(context).leave
                        )
                      ] : <Widget>[]) + (state.clientState.status == ClientInQueueStatus.reserved ? <Widget>[
                        ButtonWidget(
                            text: getLocalizations(context).windowConfirmation,
                            onClick: () {
                              if (state.email != '') {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        ClientConfirmWidget(
                                            config: ClientConfirmConfig(
                                                queueId: state.config.queueId,
                                                email: state.email
                                            )
                                        )
                                ).then((result) =>
                                    getCubitInstance(context).handleConfirmResult(result)
                                );
                              }
                            }
                        )
                      ] : <Widget>[]) + <Widget>[
                        ButtonWidget(
                          text: getLocalizations(context).rejoin,
                          onClick: () => showDialog(
                              context: context,
                              builder: (context) => ClientRejoinWidget(
                                  config: ClientRejoinConfig(
                                      queueId: state.config.queueId
                                  )
                              )
                          ).then((result) {
                            if (result is ClientRejoinResult) {
                              getCubitInstance(context).handleRejoinResult(result);
                            }
                          }),
                        ),
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
  final ClientModel clientState;
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
    ClientModel? clientState,
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
          clientState: ClientModel(
            inQueue: false,
            queueName: '',
            queueLength: 0
          ),
          email: '',
          showConfirmDialog: false
      )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    await _clientInteractor.getClientInQueue(
        state.config.username,
        state.config.locationId,
        state.config.queueId
    )
      ..onSuccess((result) {
        emit(state.copy(clientState: result.data, email: result.data.email));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> handleJoinResult(ClientJoinResult result) async {
    emit(state.copy(clientState: result.clientModel));
  }

  Future<void> handleRejoinResult(ClientRejoinResult result) async {
    emit(state.copy(clientState: result.clientModel));
  }

  Future<void> handleConfirmResult(ClientConfirmResult result) async {
    emit(state.copy(clientState: result.clientModel));
  }

  Future<void> leave() async {
    showLoad();
    await _clientInteractor.leaveQueue(state.config.queueId)
      ..onSuccess((result) {
        emit(state.copy(clientState: result.data));
        hideLoad();
      })
      ..onError((result) {
        showError(result);
      });
  }
}