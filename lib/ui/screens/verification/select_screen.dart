import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/verification_interactor.dart';
import '../../router/routes_config.dart';
import '../location/locations_screen.dart';

class SelectWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;

  SelectWidget({super.key, required this.emitConfig});

  @override
  State<SelectWidget> createState() => SelectState();
}

class SelectState extends State<SelectWidget> {
  final String title = 'Вход в аккаунт';
  final String authorization = 'Авторизация';
  final String registration = 'Регистрация';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectCubit>(
      create: (context) => statesAssembler.getSelectCubit()..onStart(),
      child: BlocConsumer<SelectCubit, SelectLogicState>(

        listener: (context, state) {
          if (state.selectStateEnum == SelectStateEnum.goToLocations) {
            widget.emitConfig(LocationsConfig(username: 'me'));
          }
        },

        builder: (context, state) =>
          (state.selectStateEnum == SelectStateEnum.loading ||
           state.selectStateEnum == SelectStateEnum.goToLocations) ? const Center(
            child: CircularProgressIndicator(),
          ) : Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ButtonWidget(
                      text: authorization,
                      onClick: () {
                        widget.emitConfig(AuthorizationConfig());
                      },
                    ),
                    ButtonWidget(
                      text: registration,
                      onClick: () {
                        widget.emitConfig(RegistrationConfig());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}

enum SelectStateEnum {
  loading, stay, goToLocations
}

class SelectLogicState {
  final SelectStateEnum selectStateEnum;
  SelectLogicState(this.selectStateEnum);
}

@injectable
class SelectCubit extends Cubit<SelectLogicState> {
  final LocationInteractor locationInteractor;
  final VerificationInteractor verificationInteractor;

  SelectCubit(
     this.locationInteractor,
     this.verificationInteractor,
  ) : super(SelectLogicState(SelectStateEnum.loading));

  Future<void> onStart() async {
    if (await verificationInteractor.checkToken()) {
      await locationInteractor.getLocations('me')
          ..onSuccess((value) {
            emit(SelectLogicState(SelectStateEnum.goToLocations));
          });
    }
    emit(SelectLogicState(SelectStateEnum.stay));
  }
}
