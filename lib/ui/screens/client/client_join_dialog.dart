import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/client_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/client/client_join_info.dart';
import '../../../domain/models/client/client_model.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class ClientJoinConfig extends BaseDialogConfig {
  final int queueId;

  ClientJoinConfig({
    required this.queueId
  });
}

class ClientJoinResult extends BaseDialogResult {
  final ClientModel clientModel;

  ClientJoinResult({
    required this.clientModel
  });
}

class ClientJoinWidget extends BaseDialogWidget<ClientJoinConfig> {

  const ClientJoinWidget({
    super.key,
    required super.config
  });

  @override
  State<ClientJoinWidget> createState() => _ClientJoinState();
}

class _ClientJoinState extends BaseDialogState<
    ClientJoinWidget,
    ClientJoinLogicState,
    ClientJoinCubit
> {

  @override
  String getTitle(
      BuildContext context,
      ClientJoinLogicState state,
      ClientJoinWidget widget
  ) => getLocalizations(context).connectionToQueue;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      ClientJoinLogicState state,
      ClientJoinWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).email,
        text: state.email,
        onTextChanged: getCubitInstance(context).setEmail
    ),
    TextFieldWidget(
        label: getLocalizations(context).firstName,
        text: state.firstName,
        onTextChanged: getCubitInstance(context).setFirstName
    ),
    TextFieldWidget(
        label: getLocalizations(context).lastName,
        text: state.lastName,
        onTextChanged: getCubitInstance(context).setLastName
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).join,
        onClick: getCubitInstance(context).join
    )
  ];

  @override
  ClientJoinCubit getCubit() =>
      statesAssembler.getClientJoinCubit(widget.config);
}

class ClientJoinLogicState extends BaseDialogLogicState<
    ClientJoinConfig,
    ClientJoinResult
> {

  final String email;
  final String firstName;
  final String lastName;

  ClientJoinLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.email,
    required this.firstName,
    required this.lastName
  });

  ClientJoinLogicState copyWith({
    String? email,
    String? firstName,
    String? lastName,
  }) => ClientJoinLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      result: result,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
  );

  @override
  ClientJoinLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    ClientJoinResult? result
  }) => ClientJoinLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      email: email,
      firstName: firstName,
      lastName: lastName,
  );
}

@injectable
class ClientJoinCubit extends BaseDialogCubit<ClientJoinLogicState> {

  final ClientInteractor _clientInteractor;

  ClientJoinCubit(
      this._clientInteractor,
      @factoryParam ClientJoinConfig config
  ) : super(
      ClientJoinLogicState(
          config: config,
          email: '',
          firstName: '',
          lastName: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }

  void setFirstName(String text) {
    emit(state.copyWith(firstName: text));
  }

  void setLastName(String text) {
    emit(state.copyWith(lastName: text));
  }

  Future<void> join() async {
    showLoad();
    await _clientInteractor.joinClientToQueue(
        state.config.queueId,
        ClientJoinInfo(
            email: state.email,
            firstName: state.firstName,
            lastName: state.lastName
        )
    )
      ..onSuccess((result) {
        popResult(ClientJoinResult(clientModel: result.data));
      })
      ..onError((result) {
        showError(result);
      });
  }
}