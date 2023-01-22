import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/account_interactor.dart';
import 'package:queue_management_system_client/domain/models/account/login_model.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/password_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';
import '../base.dart';

class AuthorizationWidget extends BaseWidget {
  AuthorizationWidget({super.key, required super.emitConfig});

  @override
  State<AuthorizationWidget> createState() => AuthorizationState();
}

class AuthorizationState extends BaseState<AuthorizationWidget, AuthorizationLogicState, AuthorizationCubit> {

  @override
  Widget getWidget(BuildContext context, AuthorizationLogicState state, AuthorizationWidget widget) => Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.authorization),
    ),
    body: state.loading
        ? const Center(child: CircularProgressIndicator())
        : state.nextConfig != null
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
                      error: state.errors[AuthorizationCubit.usernameKey],
                      onTextChanged:
                      BlocProvider.of<AuthorizationCubit>(context).setUsername,
                    ),
                    PasswordWidget(
                      text: state.password,
                      label: AppLocalizations.of(context)!.password,
                      error: state.errors[AuthorizationCubit.passwordKey],
                      onTextChanged:
                      BlocProvider.of<AuthorizationCubit>(context).setPassword,
                    ),
                    const SizedBox(height: Dimens.contentMargin),
                    ButtonWidget(
                      text: AppLocalizations.of(context)!.login,
                      onClick: BlocProvider.of<AuthorizationCubit>(context).onClickLogin,
                    )
                  ],
                ),
              ),
            ),
          ),
    ),
  );

  @override
  AuthorizationCubit getCubit() => statesAssembler.getAuthorizationCubit();
}

class AuthorizationLogicState extends BaseLogicState {
  final String username;
  final String password;
  final Map<String, String> errors;

  AuthorizationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.username,
    required this.password,
    required this.errors
  });

  AuthorizationLogicState copyWith({
    String? username,
    String? password,
    Map<String, String>? errors
  }) => AuthorizationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      username: username ?? this.username,
      password: password ?? this.password,
      errors: errors ?? this.errors
  );

  @override
  AuthorizationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => AuthorizationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      username: username,
      password: password,
      errors: errors
  );
}

@injectable
class AuthorizationCubit extends BaseCubit<AuthorizationLogicState> {
  static const usernameKey = 'USERNAME';
  static const passwordKey = 'PASSWORD';

  final AccountInteractor accountInteractor;

  AuthorizationCubit(
    this.accountInteractor
  ) : super(
      AuthorizationLogicState(
          username: '',
          password: '',
          errors: {}
      )
  );

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
    showLoad();
    await accountInteractor.login(
        LoginModel(
            username: state.username,
            password: state.password
        )
    )
      ..onSuccess((result) {
        emit(state.copyWith(errors: {}));
        hideLoad();
        navigate(LocationsConfig(username: state.username));
      })
      ..onError((result) {
        emit(state.copyWith(errors: result.errors));
        showError(result);
      });
  }
}
