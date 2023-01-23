import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/di/assemblers/states_assembler.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteRuleConfig extends BaseDialogConfig {
  final String email;

  DeleteRuleConfig({
    required this.email,
  });
}

class DeleteRuleResult extends BaseDialogResult {
  final String email;

  DeleteRuleResult({
    required this.email,
  });
}

class DeleteRuleWidget extends BaseDialogWidget<DeleteRuleConfig> {

  const DeleteRuleWidget({
    super.key,
    required super.emitConfig,
    required super.config
  });

  @override
  State<DeleteRuleWidget> createState() => _DeleteRuleState();
}

class _DeleteRuleState extends BaseDialogState<
    DeleteRuleWidget,
    DeleteRuleLogicState,
    DeleteRuleCubit
> {

  @override
  String getTitle(
      BuildContext context,
      DeleteRuleLogicState state,
      DeleteRuleWidget widget
  ) => getLocalizations(context).revokeRightsQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      DeleteRuleLogicState state,
      DeleteRuleWidget widget
  ) => [
    ButtonWidget(
        text: getLocalizations(context).revoke,
        onClick: () => Navigator.of(context).pop(
            DeleteRuleResult(
                email: widget.config.email
            )
        )
    )
  ];

  @override
  DeleteRuleCubit getCubit() =>
      statesAssembler.getDeleteRuleCubit(widget.config);
}

class DeleteRuleLogicState extends BaseDialogLogicState<
    DeleteRuleConfig,
    DeleteRuleResult
> {

  DeleteRuleLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
  });

  @override
  DeleteRuleLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => DeleteRuleLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
  );

  @override
  DeleteRuleLogicState copyResult({
    DeleteRuleResult? result
  }) => DeleteRuleLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      result: result,
  );
}

@injectable
class DeleteRuleCubit extends BaseDialogCubit<DeleteRuleLogicState> {

  DeleteRuleCubit(
      @factoryParam DeleteRuleConfig config
  ) : super(
      DeleteRuleLogicState(
        config: config
      )
  );
}
