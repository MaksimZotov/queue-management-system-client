import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/account/signup_model.dart';
import 'package:queue_management_system_client/ui/screens/account/confirm_registration_dialog.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/password_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class RegistrationWidget extends BaseWidget<RegistrationConfig> {

  const RegistrationWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<RegistrationWidget> createState() => RegistrationState();
}

class RegistrationState extends BaseState<
    RegistrationWidget,
    RegistrationLogicState,
    RegistrationCubit
> {

  @override
  void handleEvent(
      BuildContext context,
      RegistrationLogicState state,
      RegistrationWidget widget
  ) {
    super.handleEvent(context, state, widget);
    if (state.showConfirmDialog) {
      showDialog(
          context: context,
          builder: (context) => ConfirmRegistrationWidget(
            config: ConfirmRegistrationConfig(
                email: state.email,
                password: state.password
            ),
          )
      ).then((result) {
        if (result is ConfirmRegistrationResult) {
          getCubitInstance(context).handleConfirmResult(result);
        }
      });
    }
  }

  @override
  Widget getWidget(
      BuildContext context,
      RegistrationLogicState state,
      RegistrationWidget widget
  ) => Scaffold(
    appBar: AppBar(
      title: Text(getLocalizations(context).registration),
    ),
    body: state.loading
        ? const Center(child: CircularProgressIndicator())
        : state.showConfirmDialog
        ? const SizedBox.shrink()
        : Center(
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
                    TextFieldWidget(
                      text: state.email,
                      label: getLocalizations(context).email,
                      error: state.errors[RegistrationCubit.emailKey],
                      onTextChanged: getCubitInstance(context).setEmail,
                    ),
                    TextFieldWidget(
                      text: state.firstName,
                      label: getLocalizations(context).firstName,
                      error: state.errors[RegistrationCubit.firstNameKey],
                      onTextChanged: getCubitInstance(context).setFirstName,
                    ),
                    TextFieldWidget(
                      text: state.lastName,
                      label: getLocalizations(context).lastName,
                      error: state.errors[RegistrationCubit.lastNameKey],
                      onTextChanged: getCubitInstance(context).setLastName,
                    ),
                    PasswordWidget(
                      text: state.password,
                      label: getLocalizations(context).password,
                      error: state.errors[RegistrationCubit.passwordKey],
                      onTextChanged: getCubitInstance(context).setPassword,
                    ),
                    PasswordWidget(
                      text: state.repeatPassword,
                      label: getLocalizations(context).repeatPassword,
                      error: state.errors[RegistrationCubit.repeatPasswordKey],
                      onTextChanged: getCubitInstance(context).setRepeatPassword,
                    ),
                    const SizedBox(height: Dimens.contentMargin * 2),
                    ButtonWidget(
                      text: getLocalizations(context).signup,
                      onClick: getCubitInstance(context).onClickSignup,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
  );

  @override
  RegistrationCubit getCubit() => statesAssembler.getRegistrationCubit();
}

class RegistrationLogicState extends BaseLogicState {

  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String repeatPassword;
  final bool showConfirmDialog;
  final Map<String, String> errors;

  RegistrationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.repeatPassword,
    required this.showConfirmDialog,
    required this.errors
  });

  @override
  RegistrationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    String? email,
    String? firstName,
    String? lastName,
    String? password,
    String? passwordError,
    String? repeatPassword,
    bool? showConfirmDialog,
    Map<String, String>? errors
  }) => RegistrationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      repeatPassword: repeatPassword ?? this.repeatPassword,
      showConfirmDialog: showConfirmDialog ?? this.showConfirmDialog,
      errors: errors ?? this.errors
  );
}

@injectable
class RegistrationCubit extends BaseCubit<RegistrationLogicState> {

  static const emailKey = 'EMAIL';
  static const firstNameKey = 'FIRST_NAME';
  static const lastNameKey = 'LAST_NAME';
  static const passwordKey = 'PASSWORD';
  static const repeatPasswordKey = 'REPEAT_PASSWORD';

  final AccountInteractor _accountInteractor;

  RegistrationCubit(
    this._accountInteractor,
  ) : super(
      RegistrationLogicState(
          email: '',
          firstName: '',
          lastName: '',
          password: '',
          repeatPassword: '',
          showConfirmDialog: false,
          errors: { }
      )
  );

  void setEmail(String text) {
    emit(state.copy(
        email: text,
        errors: Map.from(state.errors)
          ..removeWhere((k, v) => k == emailKey))
    );
  }

  void setFirstName(String text) {
    emit(state.copy(
        firstName: text,
        errors: Map.from(state.errors)
          ..removeWhere((k, v) => k == firstNameKey))
    );
  }

  void setLastName(String text) {
    emit(state.copy(
        lastName: text,
        errors: Map.from(state.errors)
          ..removeWhere((k, v) => k == lastNameKey))
    );
  }

  void setPassword(String text) {
    emit(state.copy(
        password: text,
        errors: Map.from(state.errors)
          ..removeWhere((k, v) => k == passwordKey))
    );
  }

  void setRepeatPassword(String text) {
    emit(state.copy(
        repeatPassword: text,
        errors: Map.from(state.errors)
          ..removeWhere((k, v) => k == repeatPasswordKey))
    );
  }

  Future<void> onClickSignup() async {
    showLoad();
    await _accountInteractor.signup(
      SignupModel(
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
        password: state.password,
        repeatPassword: state.repeatPassword
      )
    )
      ..onSuccess((result) {
        hideLoad();
        emit(state.copy(showConfirmDialog: true, errors: {}));
        emit(state.copy(showConfirmDialog: false));
      })
      ..onError((result) {
        emit(state.copy(errors: result.errors));
        showError(result);
      });
  }

  void handleConfirmResult(ConfirmRegistrationResult result) {
    navigate(result.locationsConfig);
  }
}
