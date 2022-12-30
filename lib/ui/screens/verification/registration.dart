import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/verification/signup.dart';
import 'package:queue_management_system_client/ui/screens/verification/confirmation.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/password_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/verification_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../navigation/route_generator.dart';

class RegistrationWidget extends StatefulWidget {
  const RegistrationWidget({super.key});

  @override
  State<RegistrationWidget> createState() => RegistrationState();
}

class RegistrationState extends State<RegistrationWidget> {

  final String title = 'Регистрация';
  final String usernameHint = 'Логин';
  final String emailHint = 'Почта';
  final String firstNameHint = 'Имя';
  final String lastNameHint = 'Фамилия';
  final String passwordHint = 'Пароль';
  final String repeatPasswordHint = 'Повторите пароль';
  final String signupText = 'Зарегистрироваться';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegistrationCubit>(
      create: (context) => statesAssembler.getRegistrationCubit(),
      lazy: true,

      child: BlocConsumer<RegistrationCubit, RegistrationLogicState>(

        listener: (context, state) {
          if (state.readyToConfirm) {
            Navigator.of(context).pushNamed(
              Routes.toConfirmation,
              arguments: ConfirmationParams(
                  username: state.username,
                  password: state.password
              )
            ).then((value) =>
                BlocProvider.of<RegistrationCubit>(context).onPush()
            );
          }
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
            BlocProvider.of<RegistrationCubit>(context).onSnackBarShowed();
          }
        },

        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: state.loading ? const Center(
            child: CircularProgressIndicator(),
          ) : state.readyToConfirm ?
          const SizedBox.shrink() : Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  children: <Widget>[
                    TextFieldWidget(
                      text: state.username,
                      label: usernameHint,
                      onTextChanged: (text) {
                        BlocProvider.of<RegistrationCubit>(context).setUsername(text);
                      },
                    ),
                    TextFieldWidget(
                      text: state.email,
                      label: emailHint,
                      onTextChanged: (text) {
                        BlocProvider.of<RegistrationCubit>(context).setEmail(text);
                      },
                    ),
                    TextFieldWidget(
                      text: state.firstName,
                      label: firstNameHint,
                      onTextChanged: (text) {
                        BlocProvider.of<RegistrationCubit>(context).setFirstName(text);
                      },
                    ),
                    TextFieldWidget(
                      text: state.lastName,
                      label: lastNameHint,
                      onTextChanged: (text) {
                        BlocProvider.of<RegistrationCubit>(context).setLastName(text);
                      },
                    ),
                    PasswordWidget(
                      text: state.password,
                      label: passwordHint,
                      onTextChanged: (text) {
                        BlocProvider.of<RegistrationCubit>(context).setPassword(text);
                      },
                    ),
                    PasswordWidget(
                      text: state.repeatPassword,
                      label: repeatPasswordHint,
                      onTextChanged: (text) {
                        BlocProvider.of<RegistrationCubit>(context).setRepeatPassword(text);
                      },
                    ),
                    ButtonWidget(
                      text: signupText,
                      onClick: () {
                        BlocProvider.of<RegistrationCubit>(context).onClickSignup();
                      },
                    ),
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

class RegistrationLogicState {

  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String repeatPassword;
  final String? snackBar;
  final bool readyToConfirm;
  final bool loading;

  RegistrationLogicState({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.repeatPassword,
    required this.snackBar,
    required this.readyToConfirm,
    required this.loading
  });

  RegistrationLogicState copyWith({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? password,
    String? repeatPassword,
    String? snackBar,
    bool? readyToConfirm,
    bool? loading
  }) => RegistrationLogicState(
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      repeatPassword: repeatPassword ?? this.repeatPassword,
      snackBar: snackBar,
      readyToConfirm: readyToConfirm ?? this.readyToConfirm,
      loading: loading ?? this.loading
  );
}

@injectable
class RegistrationCubit extends Cubit<RegistrationLogicState> {

  final VerificationInteractor verificationInteractor;

  RegistrationCubit({
    required this.verificationInteractor,
  }) : super(
      RegistrationLogicState(
          username: '',
          email: '',
          firstName: '',
          lastName: '',
          password: '',
          repeatPassword: '',
          snackBar: null,
          readyToConfirm: false,
          loading: false
      )
  );

  void setUsername(String text) {
    emit(state.copyWith(username: text));
  }

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }

  void setFirstName(String text) {
    emit(state.copyWith(firstName: text));
  }

  void setLastName(String text) {
    emit(state.copyWith(lastName: text));
  }

  void setPassword(String text) {
    emit(state.copyWith(password: text));
  }

  void setRepeatPassword(String text) {
    emit(state.copyWith(repeatPassword: text));
  }

  Future<void> onClickSignup() async {
    emit(state.copyWith(loading: true));
    Result signupResult = await verificationInteractor.signup(
      SignupModel(
        username: state.username,
        email: state.email,
        firstName: state.firstName,
        lastName: state.lastName,
        password: state.password,
        repeatPassword: state.repeatPassword
      )
    );
    if (signupResult is SuccessResult) {
      emit(state.copyWith(loading: false, readyToConfirm: true));
    } else if (signupResult is ErrorResult) {
      emit(state.copyWith(loading: false, snackBar: signupResult.description));
    }
  }

  void onPush() {
    emit(state.copyWith(readyToConfirm: false));
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}
