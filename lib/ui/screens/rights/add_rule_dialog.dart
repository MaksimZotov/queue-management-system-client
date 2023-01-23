import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';

import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class AddRuleConfig extends BaseDialogConfig {}

class AddRuleResult extends BaseDialogResult {
  final String email;

  AddRuleResult({
    required this.email,
  });
}

class AddRuleWidget extends BaseDialogWidget<AddRuleConfig> {

  const AddRuleWidget({
    super.key,
    required super.emitConfig,
    required super.config
  });

  @override
  State<AddRuleWidget> createState() => _AddRuleState();
}

class _AddRuleState extends BaseDialogState<
    AddRuleWidget,
    AddRuleLogicState,
    AddRuleCubit
> {

  @override
  String getTitle(
      BuildContext context,
      AddRuleLogicState state,
      AddRuleWidget widget
  ) => getLocalizations(context).addingOfEmployee;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      AddRuleLogicState state,
      AddRuleWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).email,
        text: state.email,
        onTextChanged: getCubitInstance(context).setEmail
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).add,
        onClick: () => Navigator.of(context).pop(
            AddRuleResult(
              email: state.email,
            )
        )
    ),
  ];

  @override
  AddRuleCubit getCubit() => statesAssembler.getAddRuleCubit(widget.config);
}

class AddRuleLogicState extends BaseDialogLogicState<
    AddRuleConfig,
    AddRuleResult
> {

  final String email;

  AddRuleLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.email,
  });

  AddRuleLogicState copyWith({
    String? email
  }) => AddRuleLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      result: result,
      email: email ?? this.email
  );

  @override
  AddRuleLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => AddRuleLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      email: email
  );

  @override
  AddRuleLogicState copyResult({
    AddRuleResult? result
  }) => AddRuleLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      result: result,
      email: email
  );
}

@injectable
class AddRuleCubit extends BaseDialogCubit<AddRuleLogicState> {

  AddRuleCubit(
      @factoryParam AddRuleConfig config
  ) : super(
      AddRuleLogicState(
          config: config,
          email: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }
}