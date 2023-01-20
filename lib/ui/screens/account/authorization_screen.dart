import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/account_interactor.dart';
import 'package:queue_management_system_client/domain/models/account/login_model.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/password_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';

class AuthorizationWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;

  AuthorizationWidget({super.key, required this.emitConfig});

  @override
  State<AuthorizationWidget> createState() => AuthorizationState();
}

class AuthorizationState extends State<AuthorizationWidget> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthorizationCubit>(
      create: (context) => statesAssembler.getAuthorizationCubit(),
      child: BlocConsumer<AuthorizationCubit, AuthorizationLogicState>(
        listener: (context, state) {
          if (state.readyToLogin) {
            BlocProvider.of<AuthorizationCubit>(context).onPush();
            widget.emitConfig(LocationsConfig(username: state.username));
          }
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
          }
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.authorization),
          ),
          body: state.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : state.readyToLogin
                  ? const SizedBox.shrink()
                  : Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Column(
                              children: <Widget>[
                                TextFieldWidget(
                                  text: state.username,
                                  label: AppLocalizations.of(context)!.uniqueName,
                                  error: state.errors[AuthorizationCubit.usernameKey],
                                  onTextChanged:
                                      BlocProvider.of<AuthorizationCubit>(
                                              context)
                                          .setUsername,
                                ),
                                PasswordWidget(
                                  text: state.password,
                                  label: AppLocalizations.of(context)!.password,
                                  error: state.errors[AuthorizationCubit.passwordKey],
                                  onTextChanged:
                                      BlocProvider.of<AuthorizationCubit>(
                                              context)
                                          .setPassword,
                                ),
                                const SizedBox(height: 16),
                                ButtonWidget(
                                  text: AppLocalizations.of(context)!.login,
                                  onClick: BlocProvider.of<AuthorizationCubit>(
                                          context)
                                      .onClickLogin,
                                )
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

class AuthorizationLogicState {
  final String username;
  final String password;
  final String? snackBar;
  final bool readyToLogin;
  final bool loading;
  final Map<String, String> errors;

  AuthorizationLogicState(
      {required this.username,
      required this.password,
      required this.snackBar,
      required this.readyToLogin,
      required this.loading,
      required this.errors});

  AuthorizationLogicState copyWith(
          {String? username,
          String? password,
          String? snackBar,
          bool? readyToLogin,
          bool? loading,
          Map<String, String>? errors}) =>
      AuthorizationLogicState(
          username: username ?? this.username,
          password: password ?? this.password,
          snackBar: snackBar,
          readyToLogin: readyToLogin ?? this.readyToLogin,
          loading: loading ?? this.loading,
          errors: errors ?? this.errors);
}

@injectable
class AuthorizationCubit extends Cubit<AuthorizationLogicState> {
  static const usernameKey = 'USERNAME';
  static const passwordKey = 'PASSWORD';

  final AccountInteractor accountInteractor;

  AuthorizationCubit({required this.accountInteractor})
      : super(AuthorizationLogicState(
            username: '',
            password: '',
            snackBar: null,
            readyToLogin: false,
            loading: false,
            errors: {}));

  void setUsername(String text) {
    emit(state.copyWith(
        username: text,
        errors: Map.from(state.errors)..removeWhere((k, v) => k == usernameKey)
    ));
  }

  void setPassword(String text) {
    emit(state.copyWith(
        password: text,
        errors: Map.from(state.errors)..removeWhere((k, v) => k == passwordKey))
    );
  }

  Future<void> onClickLogin() async {
    emit(state.copyWith(loading: true));
    await accountInteractor.login(LoginModel(username: state.username, password: state.password))
      ..onSuccess((result) {
        emit(state.copyWith(loading: false, readyToLogin: true, errors: {}));
        emit(state.copyWith(readyToLogin: false));
      })
      ..onError((result) {
        emit(state.copyWith(
            loading: false,
            snackBar: result.description,
            errors: result.errors
        ));
        emit(state.copyWith(snackBar: null));
      });
  }

  void onPush() {
    emit(state.copyWith(readyToLogin: false));
  }
}
