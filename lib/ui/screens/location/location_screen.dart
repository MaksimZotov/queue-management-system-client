import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_management_system_client/domain/enums/kiosk_mode.dart';
import 'package:queue_management_system_client/domain/enums/rights_status.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/screens/location/enable_location_dialog.dart';
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
                  ),
                  IconButton(
                      tooltip: getLocalizations(context).turnOnTurnOffLocation,
                      icon: const Icon(Icons.bedtime),
                      onPressed: () => _showEnableLocationDialog(context, state)
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
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).servicesSequences,
                  onClick: () => widget.emitConfig(
                      ServicesSequencesConfig(
                          accountId: widget.config.accountId,
                          locationId: widget.config.locationId
                      )
                  )
                ),
                ButtonWidget(
                  text: getLocalizations(context).specialists,
                  onClick: () => widget.emitConfig(
                      SpecialistsConfig(
                          accountId: widget.config.accountId,
                          locationId: widget.config.locationId
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
                          ),
                          const SizedBox(height: Dimens.contentMargin),
                          ButtonWidget(
                              text: getLocalizations(context).downloadQrCode,
                              onClick: getCubitInstance(context).downloadQrCode
                          ),
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
              locationId: state.config.locationId
          )
      )
  ).then((result) {
    if (result is SwitchToKioskResult) {
      getCubitInstance(context).handleSwitchToTerminalModeResult(result);
    }
  });

  void _showEnableLocationDialog(
      BuildContext context,
      LocationLogicState state
  ) => showDialog(
      context: context,
      builder: (context) => EnableLocationWidget(
          config: EnableLocationConfig(
              locationId: state.config.locationId
          )
      )
  );
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
  final KioskInteractor _kioskInteractor;

  LocationCubit(
      this._locationInteractor,
      this._kioskInteractor,
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
    await _kioskInteractor.clearKioskState();
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
    await _kioskInteractor.setKioskState(result.kioskState);
    switch (result.kioskState.kioskMode) {
      case KioskMode.all:
        emit(state.copy(kioskState: result.kioskState));
        break;
      case KioskMode.services:
        navigate(
            ServicesConfig(
                accountId: state.config.accountId,
                locationId: state.config.locationId
            )
        );
        break;
      case KioskMode.servicesSequences:
        navigate(
            ServicesSequencesConfig(
                accountId: state.config.accountId,
                locationId: state.config.locationId
            )
        );
        break;
      case KioskMode.specialists:
        navigate(
            SpecialistsConfig(
                accountId: state.config.accountId,
                locationId: state.config.locationId
            )
        );
    }
  }

  Future<void> downloadQrCode() async {
    int accountId = state.config.accountId;
    int locationId = state.config.locationId;
    String url = '${ServerApi.clientUrl}/accounts/$accountId/locations/$locationId';

    final image = await QrPainter(
      data: url,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImageData(1024);

    if (image != null) {
      await FileSaver.instance.saveFile(
          url,
          image.buffer.asUint8List(),
          'png',
          mimeType: MimeType.PNG
      );
    }
  }
}
