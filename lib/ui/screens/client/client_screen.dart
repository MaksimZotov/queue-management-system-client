import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/client_in_queue_status.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/client_model.dart';
import 'package:queue_management_system_client/domain/models/client/client_join_info_model.dart';
import 'package:queue_management_system_client/domain/models/location/location_model.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/client/client_confirm_dialog.dart';
import 'package:queue_management_system_client/ui/screens/client/client_join_dialog.dart';
import 'package:queue_management_system_client/ui/screens/client/client_rejoin_dialog.dart';
import 'package:queue_management_system_client/ui/screens/verification/confirm_dialog.dart';
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
  final String titleStart = 'Очередь: ';
  final String queueLength = 'В очереди:';
  final String statusStart = 'Статус:';
  final String emailStart = 'Почта:';
  final String firstNameStart = 'Имя:';
  final String lastNameStart = 'Фамилия:';
  final String beforeMeStart = 'Перед вами:';

  final String joinText = 'Подключиться';
  final String rejoinText = 'Переподключиться';
  final String leaveText = 'Покинуть';
  final String updateText = 'Обновить';
  final String confirmWindowText = 'Окно подтверждения';


  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientCubit>(
      create: (context) => statesAssembler.getClientCubit(widget.config)..onStart(),
      lazy: true,
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
          }
        },

        builder: (context, state) =>
            Scaffold(
              appBar: AppBar(
                title: Text(
                    titleStart + state.clientState.queueName
                ),
              ),
              body: state.loading ? const Center(
                child: CircularProgressIndicator(),
              ) : Center(
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
                                  fieldName: queueLength,
                                  fieldValue: state.clientState.queueLength.toString()
                              )
                            ] + (state.clientState.inQueue ? [
                              ClientInfoFieldWidget(
                                  fieldName: statusStart,
                                  fieldValue: state.clientState.status!.name
                              ),
                              ClientInfoFieldWidget(
                                  fieldName: emailStart,
                                  fieldValue: state.clientState.email!
                              ),
                              ClientInfoFieldWidget(
                                  fieldName: firstNameStart,
                                  fieldValue: state.clientState.firstName!
                              ),
                              ClientInfoFieldWidget(
                                  fieldName: lastNameStart,
                                  fieldValue: state.clientState.lastName!
                              ),
                              ClientInfoFieldWidget(
                                  fieldName: beforeMeStart,
                                  fieldValue: state.clientState.beforeMe.toString()
                              )
                            ] : []),
                          )
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: (state.clientState.inQueue ? <Widget>[
                            ButtonWidget(
                                text: leaveText,
                                onClick: BlocProvider.of<ClientCubit>(context).leave
                            )
                          ] : <Widget>[
                            ButtonWidget(
                              text: joinText,
                              onClick: () => showDialog(
                                  context: context,
                                  builder: (context) => const ClientJoinWidget()
                              ).then((result) {
                                if (result is ClientJoinResult) {
                                  BlocProvider.of<ClientCubit>(context).join(result);
                                }
                              }),
                            )
                          ]) + (state.clientState.status == ClientInQueueStatus.reserved ? <Widget>[
                          ButtonWidget(
                              text: confirmWindowText,
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
                            text: rejoinText,
                            onClick: () => showDialog(
                                context: context,
                                builder: (context) => const ClientRejoinWidget()
                            ).then((result) {
                              if (result is ClientJoinResult) {
                                BlocProvider.of<ClientCubit>(context).rejoin(result);
                              }
                            }),
                          ),
                          ButtonWidget(
                              text: updateText,
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
        emit(state.copyWith(loading: false, clientState: result.data));
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
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
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
      });
  }

  Future<void> rejoin(ClientJoinResult result) async {
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
      });
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}