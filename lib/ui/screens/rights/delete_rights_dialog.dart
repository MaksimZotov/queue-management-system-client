import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/di/assemblers/states_assembler.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../domain/interactors/rights_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteRightsConfig extends BaseDialogConfig {
  final int locationId;
  final String email;

  DeleteRightsConfig({
    required this.locationId,
    required this.email,
  });
}

class DeleteRightsResult extends BaseDialogResult {
  final String email;

  DeleteRightsResult({
    required this.email,
  });
}

class DeleteRightsWidget extends BaseDialogWidget<DeleteRightsConfig> {

  const DeleteRightsWidget({
    super.key,
    required super.config
  });

  @override
  State<DeleteRightsWidget> createState() => _DeleteRightsState();
}

class _DeleteRightsState extends BaseDialogState<
    DeleteRightsWidget,
    DeleteRightsLogicState,
    DeleteRightsCubit
> {

  @override
  String getTitle(
      BuildContext context,
      DeleteRightsLogicState state,
      DeleteRightsWidget widget
  ) => getLocalizations(context).revokeRightsQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteRightsLogicState state,
      DeleteRightsWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).revoke,
        onClick: getCubitInstance(context).deleteRights
    )
  ];

  @override
  DeleteRightsCubit getCubit() =>
      statesAssembler.getDeleteRightsCubit(widget.config);
}

class DeleteRightsLogicState extends BaseDialogLogicState<
    DeleteRightsConfig,
    DeleteRightsResult
> {

  DeleteRightsLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
  });

  @override
  DeleteRightsLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    DeleteRightsResult? result
  }) => DeleteRightsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
  );
}

@injectable
class DeleteRightsCubit extends BaseDialogCubit<DeleteRightsLogicState> {

  final RightsInteractor _rightsInteractor;

  DeleteRightsCubit(
      this._rightsInteractor,
      @factoryParam DeleteRightsConfig config
  ) : super(
      DeleteRightsLogicState(
        config: config
      )
  );

  Future<void> deleteRights() async {
    showLoad();
    await _rightsInteractor.deleteRights(
        state.config.locationId,
        state.config.email
    )
      ..onSuccess((result) {
        popResult(DeleteRightsResult(email: state.config.email));
      })..onError((result) {
        showError(result);
      });
  }
}
