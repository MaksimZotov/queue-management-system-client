import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/rights_status.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/location/switch_to_kiosk_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/kiosk_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/kiosk/kiosk_state.dart';
import '../../../domain/models/location/location_model.dart';
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
        appBar: state.kioskState == null
            ? AppBar(
                title: state.locationModel != null
                    ? Text(getLocalizations(context).locationPattern(state.locationModel!.name))
                    : null,
                actions: [
                  IconButton(
                      tooltip: getLocalizations(context).switchToBoardMode,
                      icon: const Icon(Icons.monitor),
                      onPressed: () => widget.emitConfig(
                          BoardConfig(
                              email: state.config.email,
                              locationId: state.config.locationId
                          )
                      )
                  ),
                  IconButton(
                      tooltip: getLocalizations(context).switchToKioskMode,
                      icon: const Icon(Icons.co_present_sharp),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => SwitchToKioskWidget(
                              config: SwitchToKioskConfig(
                                  locationId: state.config.locationId
                              )
                          )
                      ).then((result) {
                        if (result is SwitchToKioskResult) {
                          getCubitInstance(context).handleSwitchToTerminalModeResult(result);
                        }
                      })
                  ),
                ] + (
                    (state.locationModel?.isOwner == true || state.locationModel?.rightsStatus == RightsStatus.administrator)
                    ? [
                        IconButton(
                            tooltip: getLocalizations(context).rightsSettings,
                            icon: const Icon(Icons.people_sharp),
                            onPressed: () => widget.emitConfig(
                                RightsConfig(
                                    email: state.config.email,
                                    locationId: state.config.locationId
                                )
                            )
                        )
                      ]
                    : []
                ),
            )
            : null,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ButtonWidget(
                  text: getLocalizations(context).services,
                  onClick: () => widget.emitConfig(
                      ServicesConfig(
                          email: widget.config.email,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).servicesSequences,
                  onClick: () => widget.emitConfig(
                      ServicesSequencesConfig(
                          email: widget.config.email,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).specialists,
                  onClick: () => widget.emitConfig(
                      SpecialistsConfig(
                          email: widget.config.email,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).queues,
                  onClick: () => widget.emitConfig(
                      QueuesConfig(
                          email: widget.config.email,
                          locationId: widget.config.locationId
                      )
                  )
                )
              ],
            ),
          ),
        ),
  );

  @override
  LocationCubit getCubit() => statesAssembler.getLocationCubit(widget.config);
}

class LocationLogicState extends BaseLogicState {
  
  final LocationConfig config;
  
  final LocationModel? locationModel;

  final KioskState? kioskState;

  LocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading = true,
    required this.config,
    required this.locationModel,
    required this.kioskState
  });

  @override
  LocationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    LocationModel? locationModel,
    KioskState? kioskState
  }) => LocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      locationModel: locationModel ?? this.locationModel,
      kioskState: kioskState ?? this.kioskState
  );
}

@injectable
class LocationCubit extends BaseCubit<LocationLogicState> {
  final LocationInteractor _locationInteractor;
  final KioskInteractor _terminalInteractor;

  LocationCubit(
      this._locationInteractor,
      this._terminalInteractor,
      @factoryParam LocationConfig config
  ) : super(
      LocationLogicState(
          config: config,
          locationModel: null,
          kioskState: null
      )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    await _terminalInteractor.clearKioskState();
    await _locationInteractor.getLocation(
        state.config.locationId, 
        state.config.email
    ) 
      ..onSuccess((result) {
        emit(state.copy(locationModel: result.data));
      })
      ..onError((result) { 
        showError(result);
      });
    hideLoad();
  }

  Future<void> handleSwitchToTerminalModeResult(SwitchToKioskResult result) async {
    await _terminalInteractor.setKioskState(result.kioskState);
    emit(state.copy(kioskState: result.kioskState));
  }
}
