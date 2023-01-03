import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/verification_interactor.dart';
import 'package:queue_management_system_client/domain/models/verification/login.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/verification/Confirm.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';
import '../location/locations.dart';


class ConfirmationResult {
  final String code;

  ConfirmationResult({
    required this.code
  });
}


class ConfirmationWidget extends StatefulWidget {

  const ConfirmationWidget({super.key});

  @override
  State<ConfirmationWidget> createState() => _ConfirmationState();
}

class _ConfirmationState extends State<ConfirmationWidget> {
  final String title = 'Подтверждение кода';
  final String codeHint = 'Код';
  final String confirmText = 'Подтвердить';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfirmationCubit>(
      create: (context) => statesAssembler.getConfirmationCubit(),
      lazy: true,
      child: BlocBuilder<ConfirmationCubit, ConfirmationLogicState>(
        builder: (context, state) => SimpleDialog(
          title: Text(title),
          contentPadding: const EdgeInsets.all(20),
          children: [
            TextFieldWidget(
                label: codeHint,
                text: state.code,
                onTextChanged: BlocProvider.of<ConfirmationCubit>(context).setCode
            ),
            ButtonWidget(
                text: confirmText,
                onClick: () => Navigator.of(context).pop(
                    ConfirmationResult(
                        code: state.code
                    )
                )
            )
          ],
        ),
      ),
    );
  }
}

class ConfirmationLogicState {

  final String code;

  ConfirmationLogicState({
    required this.code
  });

  ConfirmationLogicState copyWith({
    String? code,
    String? description
  }) => ConfirmationLogicState(
      code: code ?? this.code
  );
}

@injectable
class ConfirmationCubit extends Cubit<ConfirmationLogicState> {

  ConfirmationCubit() : super(ConfirmationLogicState(code: ''));

  void setCode(String text) {
    emit(state.copyWith(code: text));
  }
}