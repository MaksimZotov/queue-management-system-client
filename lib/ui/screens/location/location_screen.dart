import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/location/switch_to_terminal_mode_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/interactors/terminal_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/location_model.dart';
import '../../../domain/models/terminal/terminal_state.dart';
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
        appBar: state.terminalState == null
            ? AppBar(
                title: state.locationModel != null
                    ? Text(getLocalizations(context).locationPattern(state.locationModel!.name))
                    : null,
                actions: [
                  IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => SwitchToTerminalModeWidget(
                              config: SwitchToTerminalModeConfig(
                                  locationId: state.config.locationId
                              )
                          )
                      ).then((result) {
                        if (result is SwitchToTerminalModeResult) {
                          getCubitInstance(context).handleSwitchToTerminalModeResult(result);
                        }
                      })
                  )
                ],
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
                          username: widget.config.username,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).servicesSequences,
                  onClick: () => widget.emitConfig(
                      ServicesSequencesConfig(
                          username: widget.config.username,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).queueTypes,
                  onClick: () => widget.emitConfig(
                      QueueTypesConfig(
                          username: widget.config.username,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).queues,
                  onClick: () => widget.emitConfig(
                      QueuesConfig(
                          username: widget.config.username,
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

  final TerminalState? terminalState;

  LocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading = true,
    required this.config,
    required this.locationModel,
    required this.terminalState
  });

  @override
  LocationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    LocationModel? locationModel,
    TerminalState? terminalState
  }) => LocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      locationModel: locationModel ?? this.locationModel,
      terminalState: terminalState ?? this.terminalState
  );
}

@injectable
class LocationCubit extends BaseCubit<LocationLogicState> {
  final LocationInteractor _locationInteractor;
  final TerminalInteractor _terminalInteractor;

  LocationCubit(
      this._locationInteractor,
      this._terminalInteractor,
      @factoryParam LocationConfig config
  ) : super(
      LocationLogicState(
          config: config,
          locationModel: null,
          terminalState: null
      )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    await _terminalInteractor.clearTerminalState();
    await _locationInteractor.getLocation(
        state.config.locationId, 
        state.config.username
    ) 
      ..onSuccess((result) {
        emit(state.copy(locationModel: result.data));
      })
      ..onError((result) { 
        showError(result);
      });
    hideLoad();
  }

  Future<void> handleSwitchToTerminalModeResult(SwitchToTerminalModeResult result) async {
    await _terminalInteractor.setTerminalState(result.terminalState);
    emit(state.copy(terminalState: result.terminalState));
  }
}
