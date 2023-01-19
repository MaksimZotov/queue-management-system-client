import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/account_interactor.dart';
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
            String? username = state.username;
            if (username != null) {
              widget.emitConfig(LocationsConfig(username: username));
            }
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
  final String? username;

  SelectLogicState({
    required this.selectStateEnum,
    required this.username
  });
}

@injectable
class SelectCubit extends Cubit<SelectLogicState> {
  final LocationInteractor locationInteractor;
  final AccountInteractor accountInteractor;

  SelectCubit(
     this.locationInteractor,
     this.accountInteractor,
  ) : super(
      SelectLogicState(
          selectStateEnum: SelectStateEnum.loading,
          username: null
      )
  );

  Future<void> onStart() async {
    if (await accountInteractor.checkToken()) {
      await locationInteractor.getLocations(null)
          ..onSuccess((value) async {
            String? username = await accountInteractor.getCurrentUsername();
            if (username != null) {
              emit(
                  SelectLogicState(
                      selectStateEnum: SelectStateEnum.goToLocations,
                      username: username
                  )
              );
            }
          });
    }
    emit(
        SelectLogicState(
            selectStateEnum: SelectStateEnum.stay,
            username: null
        )
    );
  }
}
