import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/account/confirm_model.dart';
import 'package:queue_management_system_client/domain/models/account/signup_model.dart';
import 'package:queue_management_system_client/ui/screens/account/confirm_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/password_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/account/login_model.dart';
import '../../router/routes_config.dart';

class RegistrationWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;

  RegistrationWidget({super.key, required this.emitConfig});

  @override
  State<RegistrationWidget> createState() => RegistrationState();
}

class RegistrationState extends State<RegistrationWidget> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegistrationCubit>(
      create: (context) => statesAssembler.getRegistrationCubit(),

      child: BlocConsumer<RegistrationCubit, RegistrationLogicState>(

        listener: (context, state) {
          if (state.readyToConfirm) {
            showDialog(
                context: context,
                builder: (context) => const ConfirmWidget()
            ).then((result) {
              if (result is ConfirmResult) {
                BlocProvider.of<RegistrationCubit>(context).confirm(result);
              }
            });
          } else if (state.readyToLocations) {
            widget.emitConfig(
              LocationsConfig(username: state.username)
            );
          } else if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.registration),
          ),
          body: state.loading ? const Center(
            child: CircularProgressIndicator(),
          ) : state.readyToConfirm ?
          const SizedBox.shrink() : Center(
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
        ),
      ),
    );
  }
}

class RegistrationLogicState {

  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String repeatPassword;
  final String? snackBar;
  final bool readyToConfirm;
  final bool readyToLocations;
  final bool loading;
  final Map<String, String> errors;

  RegistrationLogicState({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.repeatPassword,
    required this.snackBar,
    required this.readyToConfirm,
    required this.readyToLocations,
    required this.loading,
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
    String? snackBar,
    bool? readyToConfirm,
    bool? readyToLocations,
    bool? loading,
    Map<String, String>? errors
  }) => RegistrationLogicState(
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      repeatPassword: repeatPassword ?? this.repeatPassword,
      snackBar: snackBar,
      readyToConfirm: readyToConfirm ?? this.readyToConfirm,
      readyToLocations: readyToLocations ?? this.readyToLocations,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors
  );
}

@injectable
class RegistrationCubit extends Cubit<RegistrationLogicState> {

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
          snackBar: null,
          readyToConfirm: false,
          readyToLocations: false,
          loading: false,
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
    emit(state.copyWith(loading: true));
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
        emit(state.copyWith(loading: false, readyToConfirm: true, errors: {}));
        emit(state.copyWith(readyToConfirm: false));
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description, errors: result.errors));
        emit(state.copyWith(snackBar: null));
      });
  }

  Future<void> confirm(ConfirmResult result) async {
    emit(state.copyWith(loading: true));
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
            emit(state.copyWith(loading: false, readyToLocations: true));
            emit(state.copyWith(readyToLocations: false));
          })
          ..onError((result) {
            emit(state.copyWith(loading: false, snackBar: result.description));
            emit(state.copyWith(snackBar: null));
          });
      })
      ..onError((result) {
        emit(state.copyWith(loading: false, snackBar: result.description));
        emit(state.copyWith(snackBar: null));
      });
  }
}
