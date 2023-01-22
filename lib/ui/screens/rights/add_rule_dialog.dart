import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class AddRuleResult {
  final String email;

  AddRuleResult({
    required this.email,
  });
}


class AddRuleWidget extends BaseWidget {

  const AddRuleWidget({super.key, required super.emitConfig});

  @override
  State<AddRuleWidget> createState() => _AddRuleState();
}

class _AddRuleState extends BaseDialogState<AddRuleWidget, AddRuleLogicState, AddRuleCubit> {

  @override
  String getTitle(
      BuildContext context,
      AddRuleLogicState state,
      AddRuleWidget widget
  ) => AppLocalizations.of(context)!.addingOfEmployee;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      AddRuleLogicState state,
      AddRuleWidget widget
  ) => [
    TextFieldWidget(
        label: AppLocalizations.of(context)!.email,
        text: state.email,
        onTextChanged: BlocProvider.of<AddRuleCubit>(context).setEmail
    ),
    const SizedBox(height: 10),
    ButtonWidget(
        text: AppLocalizations.of(context)!.add,
        onClick: () => Navigator.of(context).pop(
            AddRuleResult(
              email: state.email,
            )
        )
    ),
  ];

  @override
  AddRuleCubit getCubit() => statesAssembler.getAddRuleCubit();
}

class AddRuleLogicState extends BaseLogicState {

  final String email;

  AddRuleLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.email,
  });

  AddRuleLogicState copyWith({
    String? email
  }) => AddRuleLogicState(
    email: email ?? this.email
  );

  @override
  AddRuleLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => AddRuleLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      email: email
  );
}

@injectable
class AddRuleCubit extends BaseCubit<AddRuleLogicState> {

  AddRuleCubit() : super(
      AddRuleLogicState(
          email: '',
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }
}