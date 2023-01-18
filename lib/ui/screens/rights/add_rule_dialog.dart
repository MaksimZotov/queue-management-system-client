import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';

class AddRuleResult {
  final String email;

  AddRuleResult({
    required this.email,
  });
}


class AddRuleWidget extends StatefulWidget {

  const AddRuleWidget({super.key});

  @override
  State<AddRuleWidget> createState() => _AddRuleState();
}

class _AddRuleState extends State<AddRuleWidget> {
  final String title = 'Добавление сотрудника';
  final String emailHint = 'Почта';

  final String addText = 'Добавить';
  final String cancelText = 'Отмена';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddRuleCubit>(
      create: (context) => statesAssembler.getAddRuleCubit(),
      lazy: true,
      child: BlocBuilder<AddRuleCubit, AddRuleLogicState>(
        builder: (context, state) => SimpleDialog(
          title: Text(title),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(16.0)
              )
          ),
          children: [
            TextFieldWidget(
                label: emailHint,
                text: state.email,
                onTextChanged: BlocProvider.of<AddRuleCubit>(context).setEmail
            ),
            const SizedBox(height: 16),
            ButtonWidget(
                text: addText,
                onClick: () => Navigator.of(context).pop(
                    AddRuleResult(
                        email: state.email,
                    )
                )
            ),
            ButtonWidget(
                text: cancelText,
                onClick: Navigator.of(context).pop
            )
          ],
        ),
      ),
    );
  }
}

class AddRuleLogicState {

  final String email;

  AddRuleLogicState({
    required this.email,
  });

  AddRuleLogicState copyWith({
    String? email,
    String? firstName,
    String? lastName,
  }) => AddRuleLogicState(
    email: email ?? this.email,
  );
}

@injectable
class AddRuleCubit extends Cubit<AddRuleLogicState> {

  AddRuleCubit() : super(
      AddRuleLogicState(
          email: '',
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }
}