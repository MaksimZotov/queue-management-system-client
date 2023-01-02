import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/verification_interactor.dart';
import 'package:queue_management_system_client/domain/models/verification/login.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/verification/Confirm.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';
import '../location/locations.dart';


class ConfirmationConfig {
  final String username;
  final String password;

  ConfirmationConfig({
    required this.username,
    required this.password
  });
}


class ConfirmationWidget extends StatefulWidget {
  final ConfirmationConfig config;

  const ConfirmationWidget({super.key, required this.config});

  @override
  State<ConfirmationWidget> createState() => ConfirmationState();
}

class ConfirmationState extends State<ConfirmationWidget> {

  final String title = 'Подтверждение кода';
  final String codeHint = "Код";
  final String continueText = "Продолжить";

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfirmationCubit>(
      create: (context) => statesAssembler.getConfirmationCubit(widget.config),
      lazy: true,
      child: BlocConsumer<ConfirmationCubit, ConfirmationLogicState>(

        listener: (context, state) {
          if (state.readyToLogin) {
            BlocProvider.of<ConfirmationCubit>(context).onPush();
            // TODO
            // Navigator.of(context).pushNamed(
            //   Routes.locationsInAccount,
            //   arguments: LocationsConfig(
            //       username: null
            //   )
            // ).then((value) =>
            //     BlocProvider.of<ConfirmationCubit>(context).onPush()
            // );
          }
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.snackBar!),
            ));
            BlocProvider.of<ConfirmationCubit>(context).onSnackBarShowed();
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
                      text: state.code,
                      label: codeHint,
                      onTextChanged: (text) {
                        BlocProvider.of<ConfirmationCubit>(context).setCode(text);
                      },
                    ),
                    ButtonWidget(
                      text: continueText,
                      onClick: () {
                        BlocProvider.of<ConfirmationCubit>(context).onClickConfirm();
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

class ConfirmationLogicState {

  final ConfirmationConfig params;
  final String code;
  final String? snackBar;
  final bool readyToLogin;
  final bool loading;

  ConfirmationLogicState({
    required this.params,
    required this.code,
    required this.snackBar,
    required this.readyToLogin,
    required this.loading
  });

  ConfirmationLogicState copyWith({
    String? code,
    String? snackBar,
    bool? readyToLogin,
    bool? loading
  }) => ConfirmationLogicState(
      params: params,
      code: code ?? this.code,
      snackBar: snackBar,
      readyToLogin: readyToLogin ?? this.readyToLogin,
      loading: loading ?? this.loading
  );
}

@injectable
class ConfirmationCubit extends Cubit<ConfirmationLogicState> {

  final VerificationInteractor verificationInteractor;

  ConfirmationCubit({
    required this.verificationInteractor,
    @factoryParam required ConfirmationConfig params
  }) : super(
      ConfirmationLogicState(
          params: params,
          code: '',
          snackBar: null,
          readyToLogin: false,
          loading: false
      )
  );

  void setCode(String text) {
    emit(state.copyWith(code: text));
  }

  Future<void> onClickConfirm() async {
    emit(state.copyWith(loading: true));
    Result confirmResult = await verificationInteractor.confirm(
        ConfirmModel(
            username: state.params.username,
            code: state.code
        )
    );
    if (confirmResult is SuccessResult) {
      Result loginResult = await verificationInteractor.login(
          LoginModel(
              username: state.params.username,
              password: state.params.password
          )
      );
      if (loginResult is SuccessResult) {
        emit(state.copyWith(loading: false, readyToLogin: true));
      } else if (loginResult is ErrorResult) {
        emit(state.copyWith(loading: false, snackBar: loginResult.description));
      }
    } else if (confirmResult is ErrorResult) {
      emit(state.copyWith(loading: false, snackBar: confirmResult.description));
    }
  }

  void onPush() {
    emit(state.copyWith(readyToLogin: false));
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}