import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteServiceConfig extends BaseDialogConfig {
  final int locationId;
  final int serviceId;

  DeleteServiceConfig({
    required this.locationId,
    required this.serviceId
  });
}

class DeleteServiceResult extends BaseDialogResult {
  final int serviceId;

  DeleteServiceResult({
    required this.serviceId,
  });
}

class DeleteServiceWidget extends BaseDialogWidget<DeleteServiceConfig> {

  const DeleteServiceWidget({
    super.key,
    required super.config
  });

  @override
  State<DeleteServiceWidget> createState() => _DeleteServiceState();
}

class _DeleteServiceState extends BaseDialogState<
    DeleteServiceWidget,
    DeleteServiceLogicState,
    DeleteServiceCubit
> {

  @override
  String getTitle(
      BuildContext context,
      DeleteServiceLogicState state,
      DeleteServiceWidget widget
  ) => getLocalizations(context).deleteQueueQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteServiceLogicState state,
      DeleteServiceWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).delete,
        onClick: getCubitInstance(context).deleteService
    )
  ];

  @override
  DeleteServiceCubit getCubit() =>
      statesAssembler.getDeleteServiceCubit(widget.config);
}

class DeleteServiceLogicState extends BaseDialogLogicState<
    DeleteServiceConfig,
    DeleteServiceResult
> {

  DeleteServiceLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result
  });

  @override
  DeleteServiceLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    DeleteServiceResult? result
  }) => DeleteServiceLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result
  );
}

@injectable
class DeleteServiceCubit extends BaseDialogCubit<DeleteServiceLogicState> {

  final LocationInteractor _locationInteractor;

  DeleteServiceCubit(
      this._locationInteractor,
      @factoryParam DeleteServiceConfig config
  ) : super(
      DeleteServiceLogicState(
          config: config
      )
  );

  Future<void> deleteService() async {
    showLoad();
    await _locationInteractor.deleteServiceInLocation(
        state.config.locationId,
        state.config.serviceId
    )
      ..onSuccess((result) {
        popResult(DeleteServiceResult(serviceId: state.config.serviceId));
      })
      ..onError((result) {
        showError(result);
      });
  }
}