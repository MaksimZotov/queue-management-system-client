import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/services_sequence_interactor.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteServicesSequenceConfig extends BaseDialogConfig {
  final int locationId;
  final int servicesSequenceId;

  DeleteServicesSequenceConfig({
    required this.locationId,
    required this.servicesSequenceId
  });
}

class DeleteServicesSequenceResult extends BaseDialogResult {
  final int servicesSequenceId;

  DeleteServicesSequenceResult({
    required this.servicesSequenceId,
  });
}

class DeleteServicesSequenceWidget extends BaseDialogWidget<DeleteServicesSequenceConfig> {

  const DeleteServicesSequenceWidget({
    super.key,
    required super.config
  });

  @override
  State<DeleteServicesSequenceWidget> createState() => _DeleteServicesSequenceState();
}

class _DeleteServicesSequenceState extends BaseDialogState<
    DeleteServicesSequenceWidget,
    DeleteServicesSequenceLogicState,
    DeleteServicesSequenceCubit
> {

  @override
  String getTitle(
      BuildContext context,
      DeleteServicesSequenceLogicState state,
      DeleteServicesSequenceWidget widget
  ) => getLocalizations(context).deleteServicesSequenceQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteServicesSequenceLogicState state,
      DeleteServicesSequenceWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).delete,
        onClick: getCubitInstance(context).deleteServicesSequence
    )
  ];

  @override
  DeleteServicesSequenceCubit getCubit() =>
      statesAssembler.getDeleteServicesSequenceCubit(widget.config);
}

class DeleteServicesSequenceLogicState extends BaseDialogLogicState<
    DeleteServicesSequenceConfig,
    DeleteServicesSequenceResult
> {

  DeleteServicesSequenceLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result
  });

  @override
  DeleteServicesSequenceLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    DeleteServicesSequenceResult? result
  }) => DeleteServicesSequenceLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result
  );
}

@injectable
class DeleteServicesSequenceCubit extends BaseDialogCubit<DeleteServicesSequenceLogicState> {

  final ServicesSequenceInteractor _servicesSequenceInteractor;

  DeleteServicesSequenceCubit(
      this._servicesSequenceInteractor,
      @factoryParam DeleteServicesSequenceConfig config
  ) : super(
      DeleteServicesSequenceLogicState(
          config: config
      )
  );

  Future<void> deleteServicesSequence() async {
    showLoad();
    await _servicesSequenceInteractor.deleteServicesSequenceInLocation(
      state.config.locationId,
      state.config.servicesSequenceId
    )
      ..onSuccess((result) {
        popResult(
            DeleteServicesSequenceResult(
                servicesSequenceId: state.config.servicesSequenceId
            )
        );
      })
      ..onError((result) {
        showError(result);
      });
  }
}