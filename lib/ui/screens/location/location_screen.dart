import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/enums/kiosk_mode.dart';
import 'package:queue_management_system_client/domain/enums/rights_status.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/location/switch_to_board_dialog.dart';
import 'package:queue_management_system_client/ui/screens/location/switch_to_kiosk_dialog.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../data/api/server_api.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
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
                    ? Text(state.locationModel!.name)
                    : null,
                actions: [
                  IconButton(
                      tooltip: getLocalizations(context).switchToBoardMode,
                      icon: const Icon(Icons.monitor),
                      onPressed: () => _showSwitchToBoardDialog(context, state)
                  ),
                  IconButton(
                      tooltip: getLocalizations(context).switchToKioskMode,
                      icon: const Icon(Icons.co_present_sharp),
                      onPressed: () => _showSwitchToKioskDialog(context, state)
                  )
                ] + (
                    (state.locationModel?.isOwner == true || state.locationModel?.rightsStatus == RightsStatus.administrator)
                    ? [
                        IconButton(
                            tooltip: getLocalizations(context).rightsSettings,
                            icon: const Icon(Icons.manage_accounts),
                            onPressed: () => widget.emitConfig(
                                RightsConfig(
                                    accountId: state.config.accountId,
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
                          accountId: widget.config.accountId,
                          locationId: widget.config.locationId,
                          kioskMode: widget.config.kioskMode,
                          multipleSelect: widget.config.multipleSelect
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).servicesSequences,
                  onClick: () => widget.emitConfig(
                      ServicesSequencesConfig(
                          accountId: widget.config.accountId,
                          locationId: widget.config.locationId,
                          kioskMode: widget.config.kioskMode,
                          multipleSelect: widget.config.multipleSelect
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).specialists,
                  onClick: () => widget.emitConfig(
                      SpecialistsConfig(
                          accountId: widget.config.accountId,
                          locationId: widget.config.locationId,
                          kioskMode: widget.config.kioskMode,
                          multipleSelect: widget.config.multipleSelect
                      )
                  )
                ),
              ] + (
                  (state.kioskState == null)
                      ? <Widget>[
                          ButtonWidget(
                              text: getLocalizations(context).queues,
                              onClick: () => widget.emitConfig(
                                  QueuesConfig(
                                      accountId: widget.config.accountId,
                                      locationId: widget.config.locationId
                                  )
                              )
                          )
                        ]
                      : []
                  )
            ),
          ),
        ),
  );

  @override
  LocationCubit getCubit() => statesAssembler.getLocationCubit(widget.config);


  void _showSwitchToBoardDialog(
      BuildContext context,
      LocationLogicState state
  ) => showDialog(
      context: context,
      builder: (context) => SwitchToBoardWidget(
          config: SwitchToBoardConfig()
      )
  ).then((result) {
    if (result is SwitchToBoardResult) {
      widget.emitConfig(
          BoardConfig(
              accountId: state.config.accountId,
              locationId: state.config.locationId,
              columnsAmount: result.columnsAmount,
              rowsAmount: result.rowsAmount,
              switchFrequency: result.switchFrequency
          )
      );
    }
  });

  void _showSwitchToKioskDialog(
      BuildContext context,
      LocationLogicState state
  ) => showDialog(
      context: context,
      builder: (context) => SwitchToKioskWidget(
          config: SwitchToKioskConfig(
              accountId: state.config.accountId,
              locationId: state.config.locationId
          )
      )
  ).then((result) {
    if (result is SwitchToKioskResult) {
      getCubitInstance(context).handleSwitchToTerminalModeResult(result);
    }
  });
}

class LocationLogicState extends BaseLogicState {
  
  final LocationConfig config;
  
  final LocationModel? locationModel;

  KioskState? get kioskState  {
    for (KioskMode mode in KioskMode.values) {
      if (mode.name == config.kioskMode) {
        return KioskState(
            kioskMode: mode,
            multipleSelect: config.multipleSelect ?? false
        );
      }
    }
    return null;
  }

  LocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading = true,
    required this.config,
    required this.locationModel,
  });

  @override
  LocationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    LocationModel? locationModel
  }) => LocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      locationModel: locationModel ?? this.locationModel
  );
}

@injectable
class LocationCubit extends BaseCubit<LocationLogicState> {
  final LocationInteractor _locationInteractor;

  LocationCubit(
      this._locationInteractor,
      @factoryParam LocationConfig config
  ) : super(
      LocationLogicState(
          config: config,
          locationModel: null
      )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    await _locationInteractor.getLocation(state.config.locationId)
      ..onSuccess((result) {
        emit(state.copy(locationModel: result.data));
      })
      ..onError((result) { 
        showError(result);
      });
    hideLoad();
  }

  Future<void> handleSwitchToTerminalModeResult(SwitchToKioskResult result) async {
    switch (result.kioskState.kioskMode) {
      case KioskMode.all:
        navigate(
            LocationConfig(
                accountId: state.config.accountId,
                locationId: state.config.locationId,
                kioskMode: result.kioskState.kioskMode.name,
                multipleSelect: result.kioskState.multipleSelect
            )
        );
        break;
      case KioskMode.services:
        navigate(
            ServicesConfig(
                accountId: state.config.accountId,
                locationId: state.config.locationId,
                kioskMode: result.kioskState.kioskMode.name,
                multipleSelect: result.kioskState.multipleSelect
            )
        );
        break;
      case KioskMode.sequences:
        navigate(
            ServicesSequencesConfig(
                accountId: state.config.accountId,
                locationId: state.config.locationId,
                kioskMode: result.kioskState.kioskMode.name,
                multipleSelect: result.kioskState.multipleSelect
            )
        );
        break;
      case KioskMode.specialists:
        navigate(
            SpecialistsConfig(
                accountId: state.config.accountId,
                locationId: state.config.locationId,
                kioskMode: result.kioskState.kioskMode.name,
                multipleSelect: result.kioskState.multipleSelect
            )
        );
    }
  }
}
