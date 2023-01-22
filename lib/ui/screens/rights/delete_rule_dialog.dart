import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/di/assemblers/states_assembler.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class DeleteRuleConfig {
  final String email;

  DeleteRuleConfig({
    required this.email,
  });
}

class DeleteRuleResult {
  final String email;

  DeleteRuleResult({
    required this.email,
  });
}

class DeleteRuleWidget extends BaseWidget {
  final DeleteRuleConfig config;

  const DeleteRuleWidget({super.key, required super.emitConfig, required this.config});

  @override
  State<DeleteRuleWidget> createState() => _DeleteRuleState();
}

class _DeleteRuleState extends BaseDialogState<DeleteRuleWidget, DeleteRuleLogicState, DeleteRuleCubit> {

  @override
  String getTitle(
      BuildContext context,
      DeleteRuleLogicState state,
      DeleteRuleWidget widget
  ) => AppLocalizations.of(context)!.revokeRightsQuestion;

  @override
  List<Widget> getDialogContentWidget(BuildContext context, DeleteRuleLogicState state, DeleteRuleWidget widget) => [
    ButtonWidget(
        text: AppLocalizations.of(context)!.revoke,
        onClick: () => Navigator.of(context).pop(
            DeleteRuleResult(
                email: widget.config.email
            )
        )
    )
  ];

  @override
  DeleteRuleCubit getCubit() => statesAssembler.getDeleteRuleCubit();
}

class DeleteRuleLogicState extends BaseLogicState {

  DeleteRuleLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading
  });

  @override
  DeleteRuleLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => DeleteRuleLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class DeleteRuleCubit extends BaseCubit<DeleteRuleLogicState> {
  DeleteRuleCubit() : super(DeleteRuleLogicState());
}
