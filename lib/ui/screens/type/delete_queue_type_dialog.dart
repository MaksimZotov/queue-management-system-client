import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteQueueTypeConfig extends BaseDialogConfig {
  final int locationId;
  final int queueTypeId;

  DeleteQueueTypeConfig({
    required this.locationId,
    required this.queueTypeId
  });
}

class DeleteQueueTypeResult extends BaseDialogResult {
  final int id;

  DeleteQueueTypeResult({
    required this.id,
  });
}

class DeleteQueueTypeWidget extends BaseDialogWidget<DeleteQueueTypeConfig> {

  const DeleteQueueTypeWidget({
    super.key,
    required super.config
  });

  @override
  State<DeleteQueueTypeWidget> createState() => _DeleteQueueTypeState();
}

class _DeleteQueueTypeState extends BaseDialogState<
    DeleteQueueTypeWidget,
    DeleteQueueTypeLogicState,
    DeleteQueueTypeCubit
> {

  @override
  String getTitle(
      BuildContext context,
      DeleteQueueTypeLogicState state,
      DeleteQueueTypeWidget widget
  ) => getLocalizations(context).deleteQueueQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteQueueTypeLogicState state,
      DeleteQueueTypeWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).delete,
        onClick: getCubitInstance(context).deleteQueueType
    )
  ];

  @override
  DeleteQueueTypeCubit getCubit() =>
      statesAssembler.getDeleteQueueTypeCubit(widget.config);
}

class DeleteQueueTypeLogicState extends BaseDialogLogicState<
    DeleteQueueTypeConfig,
    DeleteQueueTypeResult
> {

  DeleteQueueTypeLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result
  });

  @override
  DeleteQueueTypeLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    DeleteQueueTypeResult? result
  }) => DeleteQueueTypeLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result
  );
}

@injectable
class DeleteQueueTypeCubit extends BaseDialogCubit<DeleteQueueTypeLogicState> {

  final LocationInteractor _locationInteractor;

  DeleteQueueTypeCubit(
      this._locationInteractor,
      @factoryParam DeleteQueueTypeConfig config
  ) : super(
      DeleteQueueTypeLogicState(
          config: config
      )
  );

  Future<void> deleteQueueType() async {
    showLoad();
    await _locationInteractor.deleteQueueTypeInLocation(
        state.config.locationId,
        state.config.queueTypeId
    )
      ..onSuccess((result) {
        popResult(DeleteQueueTypeResult(id: state.config.queueTypeId));
      })
      ..onError((result) {
        showError(result);
      });
  }
}