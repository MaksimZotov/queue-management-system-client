import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/client/client_model.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/client_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class ClientConfirmConfig extends BaseDialogConfig {
  final int queueId;
  final String email;

  ClientConfirmConfig({
    required this.queueId,
    required this.email
  });
}

class ClientConfirmResult extends BaseDialogResult {
  final ClientModel clientModel;

  ClientConfirmResult({
    required this.clientModel
  });
}

class ClientConfirmWidget extends BaseDialogWidget<ClientConfirmConfig> {

  const ClientConfirmWidget({
    super.key,
    required super.config
  });

  @override
  State<ClientConfirmWidget> createState() => _ClientConfirmState();
}

class _ClientConfirmState extends BaseDialogState<
    ClientConfirmWidget,
    ClientConfirmLogicState,
    ClientConfirmCubit
> {

  @override
  String getTitle(
      BuildContext context,
      ClientConfirmLogicState state,
      ClientConfirmWidget widget
  ) => getLocalizations(context).codeConfirmation;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      ClientConfirmLogicState state,
      ClientConfirmWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).code,
        text: state.code,
        onTextChanged: getCubitInstance(context).setEmail
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).confirm,
        onClick: getCubitInstance(context).confirm
    ),
  ];

  @override
  ClientConfirmCubit getCubit() =>
      statesAssembler.getClientConfirmCubit(widget.config);
}

class ClientConfirmLogicState extends BaseDialogLogicState<
    ClientConfirmConfig,
    ClientConfirmResult
> {

  final String code;

  ClientConfirmLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.code
  });

  ClientConfirmLogicState copyWith({
    String? code
  }) => ClientConfirmLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      result: result,
      code: code ?? this.code
  );

  @override
  ClientConfirmLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    ClientConfirmResult? result
  }) => ClientConfirmLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      code: code
  );
}

@injectable
class ClientConfirmCubit extends BaseDialogCubit<ClientConfirmLogicState> {

  final ClientInteractor _clientInteractor;

  ClientConfirmCubit(
      this._clientInteractor,
      @factoryParam ClientConfirmConfig config
  ) : super(
      ClientConfirmLogicState(
          config: config,
          code: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(code: text));
  }

  Future<void> confirm() async {
    showLoad();
    await _clientInteractor.confirmClientCodeInQueue(
        state.config.queueId,
        state.config.email,
        state.code
    )
      ..onSuccess((result) {
        popResult(ClientConfirmResult(clientModel: result.data));
      })
      ..onError((result) {
        showError(result);
      });
  }
}