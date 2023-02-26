import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class EnableLocationConfig extends BaseDialogConfig {
  final int locationId;

  EnableLocationConfig({
    required this.locationId,
  });
}

class EnableLocationResult extends BaseDialogResult {}

class EnableLocationWidget extends BaseDialogWidget<EnableLocationConfig> {

  const EnableLocationWidget({
    super.key,
    required super.config
  });

  @override
  State<EnableLocationWidget> createState() => _EnableLocationState();
}

class _EnableLocationState extends BaseDialogState<
    EnableLocationWidget,
    EnableLocationLogicState,
    EnableLocationCubit
> {

  @override
  String getTitle(
      BuildContext context,
      EnableLocationLogicState state,
      EnableLocationWidget widget
  ) => getLocalizations(context).locationPausing;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      EnableLocationLogicState state,
      EnableLocationWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).turnOn,
        onClick: getCubitInstance(context).enableLocation
    ),
    ButtonWidget(
        text: getLocalizations(context).turnOff,
        onClick: getCubitInstance(context).disableLocation
    )
  ];

  @override
  EnableLocationCubit getCubit() =>
      statesAssembler.getEnableLocationCubit(widget.config);
}

class EnableLocationLogicState extends BaseDialogLogicState<
    EnableLocationConfig,
    EnableLocationResult
> {

  EnableLocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    required super.config,
    super.result,
    super.loading,
  });

  @override
  EnableLocationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    EnableLocationResult? result
  }) => EnableLocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result
  );
}

@injectable
class EnableLocationCubit extends BaseDialogCubit<EnableLocationLogicState> {

  final LocationInteractor _locationInteractor;

  EnableLocationCubit(
      this._locationInteractor,
      @factoryParam EnableLocationConfig config
  ) : super(
      EnableLocationLogicState(
        config: config,
      )
  );

  Future enableLocation() async {
    showLoad();
    await _locationInteractor.enableLocation(
        state.config.locationId
    )..onSuccess((result) {
      popResult(EnableLocationResult());
    })..onError((result) {
      showError(result);
    });
  }

  Future disableLocation() async {
    showLoad();
    await _locationInteractor.disableLocation(
        state.config.locationId
    )..onSuccess((result) {
      popResult(EnableLocationResult());
    })..onError((result) {
      showError(result);
    });
  }
}