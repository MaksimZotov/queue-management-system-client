import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/di/assemblers/states_assembler.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../domain/interactors/rights_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteRightConfig extends BaseDialogConfig {
  final int locationId;
  final String email;

  DeleteRightConfig({
    required this.locationId,
    required this.email,
  });
}

class DeleteRightResult extends BaseDialogResult {
  final String email;

  DeleteRightResult({
    required this.email,
  });
}

class DeleteRightWidget extends BaseDialogWidget<DeleteRightConfig> {

  const DeleteRightWidget({
    super.key,
    required super.config
  });

  @override
  State<DeleteRightWidget> createState() => _DeleteRightState();
}

class _DeleteRightState extends BaseDialogState<
    DeleteRightWidget,
    DeleteRightLogicState,
    DeleteRightCubit
> {

  @override
  String getTitle(
      BuildContext context,
      DeleteRightLogicState state,
      DeleteRightWidget widget
  ) => getLocalizations(context).revokeRightsQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteRightLogicState state,
      DeleteRightWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).revoke,
        onClick: getCubitInstance(context).deleteRight
    )
  ];

  @override
  DeleteRightCubit getCubit() =>
      statesAssembler.getDeleteRightCubit(widget.config);
}

class DeleteRightLogicState extends BaseDialogLogicState<
    DeleteRightConfig,
    DeleteRightResult
> {

  DeleteRightLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
  });

  @override
  DeleteRightLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    DeleteRightResult? result
  }) => DeleteRightLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
  );
}

@injectable
class DeleteRightCubit extends BaseDialogCubit<DeleteRightLogicState> {

  final RightsInteractor _rightsInteractor;

  DeleteRightCubit(
      this._rightsInteractor,
      @factoryParam DeleteRightConfig config
  ) : super(
      DeleteRightLogicState(
        config: config
      )
  );

  Future<void> deleteRight() async {
    showLoad();
    await _rightsInteractor.deleteRights(
        state.config.locationId,
        state.config.email
    )
      ..onSuccess((result) {
        popResult(DeleteRightResult(email: state.config.email));
      })..onError((result) {
        showError(result);
      });
  }
}
