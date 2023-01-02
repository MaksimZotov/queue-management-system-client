import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/client.dart';
import 'package:queue_management_system_client/domain/models/client/client_join_info.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';
import 'package:queue_management_system_client/ui/router/routes_config.dart';
import 'package:queue_management_system_client/ui/screens/client/client_join.dart';

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
  final String queueLength = 'В очереди: ';
  final String emailStart = 'Почта: ';
  final String firstNameStart = 'Имя: ';
  final String lastNameStart = 'Фамилия: ';
  final String beforeMeStart = 'Перед вами: ';

  final String joinText = 'Подключиться';

  final String empty = '';


  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientCubit>(
      create: (context) => statesAssembler.getClientCubit(widget.config)..onStart(),
      lazy: true,
      child: BlocBuilder<ClientCubit, ClientLogicState>(
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
                        Text(
                          queueLength + (state.clientState.queueLength.toString()),
                        )
                      ] + (state.clientState.inQueue ? <Widget>[
                        Text(
                          emailStart + state.clientState.email!,
                        ),
                        Text(
                          firstNameStart + state.clientState.firstName!,
                        ),
                        Text(
                          lastNameStart + state.clientState.lastName!,
                        ),
                        Text(
                          beforeMeStart + state.clientState.beforeMe.toString(),
                        ),
                      ] : []) + [
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
                        ),
                      ],
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

  final String? snackBar;
  final bool loading;


  ClientLogicState({
    required this.config,
    required this.clientState,
    required this.snackBar,
    required this.loading,
  });

  ClientLogicState copyWith({
    List<LocationModel>? locations,
    ClientModel? clientState,
    bool? isLast,
    String? snackBar,
    bool? loading,
  }) =>
      ClientLogicState(
          config: config,
          clientState: clientState ?? this.clientState,
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
          snackBar: null,
          loading: false
      )
  );

  Future<void> onStart() async {
    await clientInteractor.getClientInQueue(
        state.config.username,
        state.config.locationId,
        state.config.queueId
    )
      ..onSuccess((result) {
        emit(state.copyWith(clientState: result.data));
      })
      ..onError((result) {
        emit(state.copyWith(snackBar: result.description));
      });
  }

  Future<void> join(ClientJoinResult clientJoinResult) async {
    await clientInteractor.joinClientToQueue(
        state.config.username,
        state.config.locationId,
        state.config.queueId,
        ClientJoinInfo(
            email: clientJoinResult.email,
            firstName: clientJoinResult.firstName,
            lastName: clientJoinResult.lastName
        )
    )
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