import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/client_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/client/client_model.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class ClientRejoinConfig extends BaseDialogConfig {
  final int queueId;

  ClientRejoinConfig({
    required this.queueId
  });
}

class ClientRejoinResult extends BaseDialogResult {
  final ClientModel clientModel;

  ClientRejoinResult({
    required this.clientModel
  });
}

class ClientRejoinWidget extends BaseDialogWidget<ClientRejoinConfig> {

  const ClientRejoinWidget({
    super.key,
    required super.emitConfig,
    required super.config
  });

  @override
  State<ClientRejoinWidget> createState() => _ClientRejoinState();
}

class _ClientRejoinState extends BaseDialogState<
    ClientRejoinWidget,
    ClientRejoinLogicState,
    ClientRejoinCubit
> {

  @override
  String getTitle(
      BuildContext context,
      ClientRejoinLogicState state,
      ClientRejoinWidget widget
  ) => getLocalizations(context).reconnectionToQueue;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      ClientRejoinLogicState state,
      ClientRejoinWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).email,
        text: state.email,
        onTextChanged: getCubitInstance(context).setEmail
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).rejoin,
        onClick: getCubitInstance(context).rejoin
    )
  ];

  @override
  ClientRejoinCubit getCubit() =>
      statesAssembler.getClientRejoinCubit(widget.config);
}

class ClientRejoinLogicState extends BaseDialogLogicState<
    ClientRejoinConfig,
    ClientRejoinResult
> {

  final String email;

  ClientRejoinLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.email
  });

  ClientRejoinLogicState copyWith({
    String? email
  }) => ClientRejoinLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      result: result,
      email: email ?? this.email
  );

  @override
  ClientRejoinLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => ClientRejoinLogicState(
    nextConfig: nextConfig,
    error: error,
    snackBar: snackBar,
    loading: loading ?? this.loading,
    config: config,
    result: result,
    email: email
  );

  @override
  ClientRejoinLogicState copyResult({
    ClientRejoinResult? result
  }) => ClientRejoinLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      result: result,
      email: email
  );
}

@injectable
class ClientRejoinCubit extends BaseDialogCubit<ClientRejoinLogicState> {

  final ClientInteractor _clientInteractor;

  ClientRejoinCubit(
      this._clientInteractor,
      @factoryParam ClientRejoinConfig config
  ) : super(
      ClientRejoinLogicState(
          config: config,
          email: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }

  Future<void> rejoin() async {
    await _clientInteractor.rejoinClientToQueue(
        state.config.queueId,
        state.email
    )
      ..onSuccess((result) {
        popResult(ClientRejoinResult(clientModel: result.data));
      })
      ..onError((result) {
        showError(result);
      });
  }
}