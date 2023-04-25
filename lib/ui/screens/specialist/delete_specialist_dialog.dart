import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/specialist_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteSpecialistConfig extends BaseDialogConfig {
  final int locationId;
  final int specialistId;

  DeleteSpecialistConfig({
    required this.locationId,
    required this.specialistId
  });
}

class DeleteSpecialistResult extends BaseDialogResult {
  final int id;

  DeleteSpecialistResult({
    required this.id,
  });
}

class DeleteSpecialistWidget extends BaseDialogWidget<DeleteSpecialistConfig> {

  const DeleteSpecialistWidget({
    super.key,
    required super.config
  });

  @override
  State<DeleteSpecialistWidget> createState() => _DeleteSpecialistState();
}

class _DeleteSpecialistState extends BaseDialogState<
    DeleteSpecialistWidget,
    DeleteSpecialistLogicState,
    DeleteSpecialistCubit
> {

  @override
  String getTitle(
      BuildContext context,
      DeleteSpecialistLogicState state,
      DeleteSpecialistWidget widget
  ) => getLocalizations(context).deleteSpecialistQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteSpecialistLogicState state,
      DeleteSpecialistWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).delete,
        onClick: getCubitInstance(context).deleteSpecialist
    )
  ];

  @override
  DeleteSpecialistCubit getCubit() =>
      statesAssembler.getDeleteSpecialistCubit(widget.config);
}

class DeleteSpecialistLogicState extends BaseDialogLogicState<
    DeleteSpecialistConfig,
    DeleteSpecialistResult
> {

  DeleteSpecialistLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result
  });

  @override
  DeleteSpecialistLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    DeleteSpecialistResult? result
  }) => DeleteSpecialistLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result
  );
}

@injectable
class DeleteSpecialistCubit extends BaseDialogCubit<DeleteSpecialistLogicState> {

  final SpecialistInteractor _specialistInteractor;

  DeleteSpecialistCubit(
      this._specialistInteractor,
      @factoryParam DeleteSpecialistConfig config
  ) : super(
      DeleteSpecialistLogicState(
          config: config
      )
  );

  Future<void> deleteSpecialist() async {
    showLoad();
    await _specialistInteractor.deleteSpecialistInLocation(
        state.config.locationId,
        state.config.specialistId
    )
      ..onSuccess((result) {
        popResult(DeleteSpecialistResult(id: state.config.specialistId));
      })
      ..onError((result) {
        showError(result);
      });
  }
}