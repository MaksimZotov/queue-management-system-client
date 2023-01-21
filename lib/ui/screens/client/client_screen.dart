import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/client_in_queue_status.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/client_model.dart';
import 'package:queue_management_system_client/domain/models/client/client_join_info.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/client/client_confirm_dialog.dart';
import 'package:queue_management_system_client/ui/screens/client/client_join_dialog.dart';
import 'package:queue_management_system_client/ui/screens/client/client_rejoin_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/client_info_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../widgets/button_widget.dart';

class ClientWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;
  final ClientConfig config;

  ClientWidget({super.key, required this.config, required this.emitConfig});

  @override
  State<ClientWidget> createState() => _ClientState();
}

class _ClientState extends State<ClientWidget> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientCubit>(
      create: (context) => statesAssembler.getClientCubit(widget.config)..onStart(),
      child: BlocConsumer<ClientCubit, ClientLogicState>(

        listener: (context, state) {
          if (state.readyToConfirm) {
            showDialog(
                context: context,
                builder: (context) => ClientConfirmWidget(
                    config: ClientConfirmConfig(
                      email: state.email
                    )
                )
            ).then((result) {
              if (result is ClientConfirmResult) {
                BlocProvider.of<ClientCubit>(context).confirm(result);
              }
            });
          } else if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },

        builder: (context, state) =>
            Scaffold(
              appBar: AppBar(
                title: Text(
                    AppLocalizations.of(context)!.queuePattern(state.clientState.queueName)
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
                                    fieldName: AppLocalizations.of(context)!.queueLengthWithColon,
                                    fieldValue: state.clientState.queueLength.toString()
                                )
                              ] + (state.clientState.inQueue ? [
                                ClientInfoFieldWidget(
                                    fieldName: AppLocalizations.of(context)!.statusWithColon,
                                    fieldValue: state.clientState.status == ClientInQueueStatus.confirmed
                                      ? AppLocalizations.of(context)!.confirmed
                                      : AppLocalizations.of(context)!.reserved
                                ),
                                ClientInfoFieldWidget(
                                    fieldName: AppLocalizations.of(context)!.emailWithColon,
                                    fieldValue: state.clientState.email!
                                ),
                                ClientInfoFieldWidget(
                                    fieldName: AppLocalizations.of(context)!.firstNameWithColon,
                                    fieldValue: state.clientState.firstName!
                                ),
                                ClientInfoFieldWidget(
                                    fieldName: AppLocalizations.of(context)!.lastNameWithColon,
                                    fieldValue: state.clientState.lastName!
                                ),
                                ClientInfoFieldWidget(
                                    fieldName: AppLocalizations.of(context)!.beforeMeWithColon,
                                    fieldValue: state.clientState.beforeMe.toString()
                                )
                              ] : []) + (state.clientState.status == ClientInQueueStatus.confirmed ? [
                                ClientInfoFieldWidget(
                                    fieldName: AppLocalizations.of(context)!.code,
                                    fieldValue: state.clientState.accessKey!
                                )
                              ] : []),
                            )
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: (!state.clientState.inQueue ? <Widget>[
                              ButtonWidget(
                                text: AppLocalizations.of(context)!.join,
                                onClick: () => showDialog(
                                    context: context,
                                    builder: (context) => const ClientJoinWidget()
                                ).then((result) {
                                  if (result is ClientJoinResult) {
                                    BlocProvider.of<ClientCubit>(context).join(result);
                                  }
                                }),
                              )
                            ] : <Widget>[]) + (state.clientState.status == ClientInQueueStatus.confirmed ? <Widget>[
                              ButtonWidget(
                                  text: AppLocalizations.of(context)!.leave,
                                  onClick: BlocProvider.of<ClientCubit>(context).leave
                              )
                            ] : <Widget>[]) + (state.clientState.status == ClientInQueueStatus.reserved ? <Widget>[
                            ButtonWidget(
                                text: AppLocalizations.of(context)!.windowConfirmation,
                                onClick: () {
                                  if (state.email != '') {
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            ClientConfirmWidget(
                                                config: ClientConfirmConfig(
                                                    email: state.email
                                                )
                                            )
                                    ).then((result) =>
                                        BlocProvider.of<ClientCubit>(context).confirm(result)
                                    );
                                  }
                                }
                            )
                            ] : <Widget>[]) + <Widget>[
                            ButtonWidget(
                              text: AppLocalizations.of(context)!.rejoin,
                              onClick: () => showDialog(
                                  context: context,
                                  builder: (context) => const ClientRejoinWidget()
                              ).then((result) {
                                if (result is ClientRejoinResult) {
                                  BlocProvider.of<ClientCubit>(context).rejoin(result);
                                }
                              }),
                            ),
                            ButtonWidget(
                                text: AppLocalizations.of(context)!.update,
                                onClick: BlocProvider.of<ClientCubit>(context).onStart
                            ),
                            ]
                          ),
                        ]
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class ClientLogicState {

  static const int pageSize = 30;

  final ClientConfig config;

  final ClientModel clientState;

  final String email;
  final bool readyToConfirm;

  final String? snackBar;
  final bool loading;


  ClientLogicState({
    required this.config,
    required this.clientState,
    required this.email,
    required this.readyToConfirm,
    required this.snackBar,
    required this.loading,
  });

  ClientLogicState copyWith({
    List<LocationModel>? locations,
    ClientModel? clientState,
    String? email,
    bool? readyToConfirm,
    bool? isLast,
    String? snackBar,
    bool? loading,
  }) =>
      ClientLogicState(
          config: config,
          clientState: clientState ?? this.clientState,
          email: email ?? this.email,
          readyToConfirm: readyToConfirm ?? this.readyToConfirm,
          snackBar: snackBar,
          loading: loading ?? this.loading
      );
}

@injectable
class ClientCubit extends Cubit<ClientLogicState> {

  final ClientInteractor clientInteractor;

  ClientCubit({
    required this.clientInteractor,
    @factoryParam required ClientConfig config
  }) : super(
      ClientLogicState(
          config: config,
          clientState: ClientModel(
            inQueue: false,
            queueName: '',
            queueLength: 0
          ),
          email: '',
          readyToConfirm: false,
          snackBar: null,
          loading: false
      )
  );

  Future<void> onStart() async {
    emit(state.copyWith(loading: true));
    await clientInteractor.getClientInQueue(
        state.config.username,
        state.config.locationId,
        state.config.queueId
    )
      ..onSuccess((result) {
        emit(state.copyWith(loading: false, clientState: result.data, email: result.data.email));
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future<void> join(ClientJoinResult result) async {
    emit(state.copyWith(loading: true, email: result.email));
    await clientInteractor.joinClientToQueue(
        state.config.username,
        state.config.locationId,
        state.config.queueId,
        ClientJoinInfo(
            email: result.email,
            firstName: result.firstName,
            lastName: result.lastName
        )
    )
      ..onSuccess((result) {
        emit(state.copyWith(loading: false, clientState: result.data, readyToConfirm: true));
        emit(state.copyWith(readyToConfirm: false));
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future<void> rejoin(ClientRejoinResult result) async {
    emit(state.copyWith(loading: true, email: result.email));
    await clientInteractor.rejoinClientToQueue(
        state.config.queueId,
        result.email
    )
      ..onSuccess((result) {
        emit(state.copyWith(loading: false, clientState: result.data, readyToConfirm: true));
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future<void> confirm(Object result) async {
    if (result is ClientConfirmResult) {
      emit(state.copyWith(loading: true, readyToConfirm: false));
      await clientInteractor.confirmClientCodeInQueue(
          state.config.queueId,
          result.email,
          result.code
      )
        ..onSuccess((result) {
          emit(state.copyWith(loading: false, clientState: result.data));
        })
        ..onError((result) {
          emit(state.copyWith(loading: false, snackBar: result.description));
          emit(state.copyWith(snackBar: null));
        });
    } else {
      emit(state.copyWith(loading: false, readyToConfirm: false));
    }
  }

  Future<void> leave() async {
    await clientInteractor.leaveQueue(state.config.queueId)
      ..onSuccess((result) {
        emit(state.copyWith(clientState: result.data));
      })
      ..onError((result) {
        emit(state.copyWith(snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }
}