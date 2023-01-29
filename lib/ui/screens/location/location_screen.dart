import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class LocationWidget extends BaseWidget<LocationConfig> {

  const LocationWidget({
    super.key,
    required super.config,
    required super.emitConfig
  });

  @override
  State<LocationWidget> createState() => LocationState();
}

class LocationState extends BaseState<
    LocationWidget,
    LocationLogicState,
    LocationCubit
> {

  @override
  Widget getWidget(
      BuildContext context,
      LocationLogicState state,
      LocationWidget widget
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
                  text: getLocalizations(context).authorization,
                  onClick: () {
                    widget.emitConfig(AuthorizationConfig());
                  },
                ),
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
                )
              ],
            ),
          ),
        ),
  );

  @override
  LocationCubit getCubit() => statesAssembler.getLocationCubit(widget.config);
}

enum LocationStateEnum {
  loading, stay, goToLocations
}

class LocationLogicState extends BaseLogicState {

  LocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading = true,
  });

  @override
  LocationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => LocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class LocationCubit extends BaseCubit<LocationLogicState> {
  final LocationInteractor _locationInteractor;
  final AccountInteractor _accountInteractor;

  LocationCubit(
      this._locationInteractor,
      this._accountInteractor,
  ) : super(LocationLogicState());

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