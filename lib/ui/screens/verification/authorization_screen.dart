import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/verification_interactor.dart';
import 'package:queue_management_system_client/domain/models/verification/login_model.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/password_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';
import '../location/locations_screen.dart';


class AuthorizationWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;

  AuthorizationWidget({super.key, required this.emitConfig});

  @override
  State<AuthorizationWidget> createState() => AuthorizationState();
}

class AuthorizationState extends State<AuthorizationWidget> {

  final String title = 'Авторизация';
  final String usernameHint = "Логин";
  final String passwordHint = "Пароль";
  final String loginText = "Войти";

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthorizationCubit>(
      create: (context) => statesAssembler.getAuthorizationCubit(),
      lazy: true,
      child: BlocConsumer<AuthorizationCubit, AuthorizationLogicState>(

        listener: (context, state) {
          if (state.readyToLogin) {
            BlocProvider.of<AuthorizationCubit>(context).onPush();
            widget.emitConfig(
                LocationsConfig(
                    username: 'me'
                )
            );
          }
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
            BlocProvider.of<AuthorizationCubit>(context).onSnackBarShowed();
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: state.loading ? const Center(
            child: CircularProgressIndicator(),
          ) : state.readyToLogin ? const SizedBox.shrink() : Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  children: <Widget>[
                    TextFieldWidget(
                      text: state.username,
                      label: usernameHint,
                      onTextChanged: (text) {
                        BlocProvider.of<AuthorizationCubit>(context).setUsername(text);
                      },
                    ),
                    PasswordWidget(
                      text: state.password,
                      label: passwordHint,
                      onTextChanged: (text) {
                        BlocProvider.of<AuthorizationCubit>(context).setPassword(text);
                      },
                    ),
                    ButtonWidget(
                      text: loginText,
                      onClick: () {
                        BlocProvider.of<AuthorizationCubit>(context).onClickLogin();
                      },
                    )
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

class AuthorizationLogicState {

  final String username;
  final String password;
  final String? snackBar;
  final bool readyToLogin;
  final bool loading;

  AuthorizationLogicState({
    required this.username,
    required this.password,
    required this.snackBar,
    required this.readyToLogin,
    required this.loading
  });

  AuthorizationLogicState copyWith({
    String? username,
    String? password,
    String? snackBar,
    bool? readyToLogin,
    bool? loading
  }) => AuthorizationLogicState(
      username: username ?? this.username,
      password: password ?? this.password,
      snackBar: snackBar,
      readyToLogin: readyToLogin ?? this.readyToLogin,
      loading: loading ?? this.loading
  );
}

@injectable
class AuthorizationCubit extends Cubit<AuthorizationLogicState> {

  final VerificationInteractor verificationInteractor;

  AuthorizationCubit({
    required this.verificationInteractor
  }) : super(
      AuthorizationLogicState(
        username: '',
        password: '',
        snackBar: null,
        readyToLogin: false,
        loading: false
      )
  );

  void setUsername(String text) {
    emit(state.copyWith(username: text));
  }

  void setPassword(String text) {
    emit(state.copyWith(password: text));
  }

  Future<void> onClickLogin() async {
    emit(state.copyWith(loading: true));
    Result result = await verificationInteractor.login(
        LoginModel(
            username: state.username,
            password: state.password
        )
    );
    if (result is SuccessResult) {
      emit(state.copyWith(loading: false, readyToLogin: true));
    } else if (result is ErrorResult) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    }
  }

  void onPush() {
    emit(state.copyWith(readyToLogin: false));
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}