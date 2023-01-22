import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/account/confirm_model.dart';
import 'package:queue_management_system_client/domain/models/account/signup_model.dart';
import 'package:queue_management_system_client/ui/screens/account/confirm_dialog.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/password_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/account/login_model.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class RegistrationWidget extends BaseWidget {

  RegistrationWidget({super.key, required super.emitConfig});

  @override
  State<RegistrationWidget> createState() => RegistrationState();
}

class RegistrationState extends BaseState<RegistrationWidget, RegistrationLogicState, RegistrationCubit> {

  @override
  void handleEvent(BuildContext context, RegistrationLogicState state, RegistrationWidget widget) {
    super.handleEvent(context, state, widget);
    if (state.showConfirmDialog) {
      showDialog(
          context: context,
          builder: (context) => const ConfirmWidget()
      ).then((result) {
        if (result is ConfirmResult) {
          BlocProvider.of<RegistrationCubit>(context).confirm(result);
        }
      });
    }
  }

  @override
  Widget getWidget(BuildContext context, RegistrationLogicState state, RegistrationWidget widget) => Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.registration),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  children: <Widget>[
                    TextFieldWidget(
                      text: state.username,
                      label: AppLocalizations.of(context)!.uniqueName,
                      error: state.errors[RegistrationCubit.usernameKey],
                      onTextChanged: BlocProvider.of<RegistrationCubit>(context).setUsername,
                    ),
                    TextFieldWidget(
                      text: state.email,
                      label: AppLocalizations.of(context)!.email,
                      error: state.errors[RegistrationCubit.emailKey],
                      onTextChanged: BlocProvider.of<RegistrationCubit>(context).setEmail,
                    ),
                    TextFieldWidget(
                      text: state.firstName,
                      label: AppLocalizations.of(context)!.firstName,
                      error: state.errors[RegistrationCubit.firstNameKey],
                      onTextChanged:  BlocProvider.of<RegistrationCubit>(context).setFirstName,
                    ),
                    TextFieldWidget(
                      text: state.lastName,
                      label: AppLocalizations.of(context)!.lastName,
                      error: state.errors[RegistrationCubit.lastNameKey],
                      onTextChanged: BlocProvider.of<RegistrationCubit>(context).setLastName,
                    ),
                    PasswordWidget(
                      text: state.password,
                      label: AppLocalizations.of(context)!.password,
                      error: state.errors[RegistrationCubit.passwordKey],
                      onTextChanged: BlocProvider.of<RegistrationCubit>(context).setPassword,
                    ),
                    PasswordWidget(
                      text: state.repeatPassword,
                      label: AppLocalizations.of(context)!.repeatPassword,
                      error: state.errors[RegistrationCubit.repeatPasswordKey],
                      onTextChanged: BlocProvider.of<RegistrationCubit>(context).setRepeatPassword,
                    ),
                    const SizedBox(height: 16),
                    ButtonWidget(
                      text: AppLocalizations.of(context)!.signup,
                      onClick: BlocProvider.of<RegistrationCubit>(context).onClickSignup,
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

  final String username;
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
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.repeatPassword,
    required this.showConfirmDialog,
    required this.errors
  });

  RegistrationLogicState copyWith({
    String? username,
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
      loading: loading,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      repeatPassword: repeatPassword ?? this.repeatPassword,
      showConfirmDialog: showConfirmDialog ?? this.showConfirmDialog,
      errors: errors ?? this.errors
  );

  @override
  RegistrationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => RegistrationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
      repeatPassword: repeatPassword,
      showConfirmDialog: showConfirmDialog,
      errors: errors
  );
}

@injectable
class RegistrationCubit extends BaseCubit<RegistrationLogicState> {

  static const usernameKey = 'USERNAME';
  static const emailKey = 'EMAIL';
  static const firstNameKey = 'FIRST_NAME';
  static const lastNameKey = 'LAST_NAME';
  static const passwordKey = 'PASSWORD';
  static const repeatPasswordKey = 'REPEAT_PASSWORD';

  final AccountInteractor accountInteractor;

  RegistrationCubit(
    this.accountInteractor,
  ) : super(
      RegistrationLogicState(
          username: '',
          email: '',
          firstName: '',
          lastName: '',
          password: '',
          repeatPassword: '',
          showConfirmDialog: false,
          errors: { }
      )
  );

  void setUsername(String text) {
    emit(state.copyWith(
        username: text,
        errors: Map.from(state.errors)..removeWhere((k, v) => k == usernameKey)
    ));
  }

  void setEmail(String text) {
    emit(state.copyWith(
        email: text,
        errors: Map.from(state.errors)..removeWhere((k, v) => k == emailKey))
    );
  }

  void setFirstName(String text) {
    emit(state.copyWith(
        firstName: text,
        errors: Map.from(state.errors)..removeWhere((k, v) => k == firstNameKey))
    );
  }

  void setLastName(String text) {
    emit(state.copyWith(
        lastName: text,
        errors: Map.from(state.errors)..removeWhere((k, v) => k == lastNameKey))
    );
  }

  void setPassword(String text) {
    emit(state.copyWith(
        password: text,
        errors: Map.from(state.errors)..removeWhere((k, v) => k == passwordKey))
    );
  }

  void setRepeatPassword(String text) {
    emit(state.copyWith(
        repeatPassword: text,
        errors: Map.from(state.errors)..removeWhere((k, v) => k == repeatPasswordKey))
    );
  }

  Future<void> onClickSignup() async {
    showLoad();
    await accountInteractor.signup(
      SignupModel(
        username: state.username,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
        password: state.password,
        repeatPassword: state.repeatPassword
      )
    )
      ..onSuccess((result) {
        hideLoad();
        emit(state.copyWith(showConfirmDialog: true, errors: {}));
        emit(state.copyWith(showConfirmDialog: false));
      })
      ..onError((result) {
        emit(state.copyWith(errors: result.errors));
        showError(result);
      });
  }

  Future<void> confirm(ConfirmResult result) async {
    showLoad();
    await accountInteractor.confirm(
      ConfirmModel(
          username: state.username,
          code: result.code
      )
    )
      ..onSuccess((result) async {
        await accountInteractor.login(
          LoginModel(
            username: state.username,
            password: state.password
          )
        )
          ..onSuccess((result) {
            hideLoad();
            navigate(LocationsConfig(username: state.username));
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
