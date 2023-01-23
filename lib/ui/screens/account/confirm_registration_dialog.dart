import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/account/confirm_model.dart';
import '../../../domain/models/account/login_model.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';

class ConfirmRegistrationConfig extends BaseDialogConfig {
  final String username;
  final String password;

  ConfirmRegistrationConfig({
    required this.username,
    required this.password
  });
}

class ConfirmRegistrationResult extends BaseDialogResult {
  final LocationsConfig locationsConfig;

  ConfirmRegistrationResult({
    required this.locationsConfig
  });
}


class ConfirmRegistrationWidget extends BaseDialogWidget<
    ConfirmRegistrationConfig
> {

  const ConfirmRegistrationWidget({
    super.key,
    required super.config
  });

  @override
  State<ConfirmRegistrationWidget> createState() => _ConfirmRegistrationState();
}

class _ConfirmRegistrationState extends BaseDialogState<
    ConfirmRegistrationWidget,
    ConfirmRegistrationLogicState,
    ConfirmRegistrationCubit
> {

  @override
  String getTitle(
      BuildContext context,
      ConfirmRegistrationLogicState state,
      ConfirmRegistrationWidget widget
  ) => getLocalizations(context).codeConfirmation;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      ConfirmRegistrationLogicState state,
      ConfirmRegistrationWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).code,
        text: state.code,
        onTextChanged: getCubitInstance(context).setCode
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).confirm,
        onClick: getCubitInstance(context).confirm
    )
  ];

  @override
  ConfirmRegistrationCubit getCubit() =>
      statesAssembler.getConfirmRegistrationCubit(widget.config);
}

class ConfirmRegistrationLogicState extends BaseDialogLogicState<
    ConfirmRegistrationConfig,
    ConfirmRegistrationResult
> {

  final String code;

  ConfirmRegistrationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.code
  });

  @override
  ConfirmRegistrationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    ConfirmRegistrationResult? result,
    String? code
  }) => ConfirmRegistrationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      code: code ?? this.code
  );
}

@injectable
class ConfirmRegistrationCubit extends BaseDialogCubit<
    ConfirmRegistrationLogicState
> {

  final AccountInteractor _accountInteractor;

  ConfirmRegistrationCubit(
      this._accountInteractor,
      @factoryParam ConfirmRegistrationConfig config
  ) : super(
      ConfirmRegistrationLogicState(
        config: config,
        code: ''
      )
  );

  void setCode(String text) {
    emit(state.copy(code: text));
  }

  Future<void> confirm() async {
    showLoad();
    await _accountInteractor.confirm(
        ConfirmModel(
            username: state.config.username,
            code: state.code
        )
    )
      ..onSuccess((result) async {
        await _accountInteractor.login(
            LoginModel(
                username: state.config.username,
                password: state.config.password
            )
        )
          ..onSuccess((result) {
            hideLoad();
            popResult(
                ConfirmRegistrationResult(
                    locationsConfig: LocationsConfig(
                        username: state.config.username
                    )
                )
            );
          })
          ..onError((result) {
            showError(result);
          });
      })
      ..onError((result) {
        showError(result);
      });
  }
}