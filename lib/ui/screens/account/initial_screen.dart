import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
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
  State<InitialWidget> createState() => InitialState();
}

class InitialState extends BaseState<
    InitialWidget,
    InitialLogicState,
    InitialCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      InitialLogicState state,
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
  InitialCubit getCubit() => statesAssembler.getInitialCubit(widget.config);
}

enum InitialStateEnum {
  loading, stay, goToLocations
}

class InitialLogicState extends BaseLogicState {

  final InitialConfig config;

  InitialLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading = true,
    required this.config,
  });

  @override
  InitialLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => InitialLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config
  );
}

@injectable
class InitialCubit extends BaseCubit<InitialLogicState> {
  final AccountInteractor _accountInteractor;

  InitialCubit(
     this._accountInteractor,
      @factoryParam InitialConfig config
  ) : super(
      InitialLogicState(
        config: config
      )
  );

  @override
  Future<void> onStart() async {
    if (state.config.firstLaunch && await _accountInteractor.checkToken()) {
      int? accountId = await _accountInteractor.getCurrentAccountId();
      if (accountId != null) {
        navigate(LocationsConfig(accountId: accountId));
      }
    }
    hideLoad();
  }
}
