import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/base/result.dart';
import 'package:queue_management_system_client/ui/screens/verification/registration.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../router/routes_config.dart';
import '../location/locations.dart';

class SelectWidget extends StatefulWidget {
  ValueChanged<BaseConfig> emitConfig;

  SelectWidget({super.key, required this.emitConfig});

  @override
  State<SelectWidget> createState() => SelectState();
}

class SelectState extends State<SelectWidget> {
  final String title = 'Выбор способа верификации';
  final String authorization = 'Авторизация';
  final String registration = 'Регистрация';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectCubit>(
      create: (context) => statesAssembler.getSelectCubit()..onStart(),
      lazy: true,
      child: BlocConsumer<SelectCubit, SelectLogicState>(

        listener: (context, state) {
          if (state.selectStateEnum == SelectStateEnum.goToLocations) {
            BlocProvider.of<SelectCubit>(context).onPush();
            print('FFFFFFFFFFFFFFFFFFFFFFFFF');
            print('goToLocations');
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
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
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

  SelectCubit({
    required this.locationInteractor
  }) : super(SelectLogicState(SelectStateEnum.loading));

  Future<void> onStart() async {
    final result = await locationInteractor.getMyLocations(0, LocationsLogicState.pageSize);
    if (result is SuccessResult) {
      //emit(SelectLogicState(SelectStateEnum.goToLocations));
    } else if (result is ErrorResult) {
      emit(SelectLogicState(SelectStateEnum.stay));
    }
  }

  void onPush() {
    emit(SelectLogicState(SelectStateEnum.loading));
  }
}
