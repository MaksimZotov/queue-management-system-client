import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class DeleteLocationConfig extends BaseDialogConfig {
  final int id;

  DeleteLocationConfig({
    required this.id,
  });
}

class DeleteLocationResult extends BaseDialogResult {
  final int id;

  DeleteLocationResult({
    required this.id,
  });
}

class DeleteLocationWidget extends BaseDialogWidget<DeleteLocationConfig> {

  const DeleteLocationWidget({
    super.key,
    required super.config
  });

  @override
  State<DeleteLocationWidget> createState() => _DeleteLocationState();
}

class _DeleteLocationState extends BaseDialogState<
    DeleteLocationWidget,
    DeleteLocationLogicState,
    DeleteLocationCubit
> {

  @override
  String getTitle(
      BuildContext context,
      DeleteLocationLogicState state,
      DeleteLocationWidget widget
  ) => getLocalizations(context).deleteLocationQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteLocationLogicState state,
      DeleteLocationWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).delete,
        onClick: getCubitInstance(context).deleteLocation
    )
  ];

  @override
  DeleteLocationCubit getCubit() =>
      statesAssembler.getDeleteLocationCubit(widget.config);
}

class DeleteLocationLogicState extends BaseDialogLogicState<
    DeleteLocationConfig,
    DeleteLocationResult
> {

  DeleteLocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    required super.config,
    super.result,
    super.loading,
  });

  @override
  DeleteLocationLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    DeleteLocationResult? result
  }) => DeleteLocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result
  );
}

@injectable
class DeleteLocationCubit extends BaseDialogCubit<DeleteLocationLogicState> {

  final LocationInteractor _locationInteractor;

  DeleteLocationCubit(
      this._locationInteractor,
      @factoryParam DeleteLocationConfig config
  ) : super(
      DeleteLocationLogicState(
          config: config,
      )
  );

  Future deleteLocation() async {
    showLoad();
    await _locationInteractor.deleteLocation(
        state.config.id
    )..onSuccess((result) {
      popResult(DeleteLocationResult(id: state.config.id));
    })..onError((result) {
      showError(result);
    });
  }
}