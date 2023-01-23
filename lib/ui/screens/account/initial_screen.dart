import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class InitialWidget extends BaseWidget<InitialConfig> {

  const InitialWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<InitialWidget> createState() => SelectState();
}

class SelectState extends BaseState<
    InitialWidget,
    SelectLogicState,
    SelectCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      SelectLogicState state,
      InitialWidget widget
  ) => state.loading
      ? const Center(
        child: CircularProgressIndicator(),
      )
      : Scaffold(
        appBar: AppBar(
          title: Text(getLocalizations(context).enterAccount),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ButtonWidget(
                  text: getLocalizations(context).authorization,
                  onClick: () {
                    widget.emitConfig(AuthorizationConfig());
                  },
                ),
                ButtonWidget(
                  text: getLocalizations(context).registration,
                  onClick: () {
                    widget.emitConfig(RegistrationConfig());
                  },
                ),
              ],
            ),
          ),
        ),
  );

  @override
  SelectCubit getCubit() => statesAssembler.getSelectCubit();
}

enum SelectStateEnum {
  loading, stay, goToLocations
}

class SelectLogicState extends BaseLogicState {

  SelectLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading = true,
  });

  @override
  SelectLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => SelectLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class SelectCubit extends BaseCubit<SelectLogicState> {
  final LocationInteractor _locationInteractor;
  final AccountInteractor _accountInteractor;

  SelectCubit(
     this._locationInteractor,
     this._accountInteractor,
  ) : super(SelectLogicState());

  @override
  Future<void> onStart() async {
    if (await _accountInteractor.checkToken()) {
      String? username = await _accountInteractor.getCurrentUsername();
      if (username != null) {
        await _locationInteractor.checkHasRights(username)
          ..onSuccess((result) {
            if (result.data.hasRights) {
              navigate(LocationsConfig(username: username));
            }
          });
      }
    }
    hideLoad();
  }
}
