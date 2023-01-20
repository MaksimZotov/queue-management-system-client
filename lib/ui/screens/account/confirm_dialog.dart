import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/account_interactor.dart';
import 'package:queue_management_system_client/domain/models/account/login_model.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/account/confirm_model.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';
import '../location/locations_screen.dart';


class ConfirmResult {
  final String code;

  ConfirmResult({
    required this.code
  });
}


class ConfirmWidget extends StatefulWidget {

  const ConfirmWidget({super.key});

  @override
  State<ConfirmWidget> createState() => _ConfirmState();
}

class _ConfirmState extends State<ConfirmWidget> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfirmCubit>(
      create: (context) => statesAssembler.getConfirmCubit(),
      child: BlocBuilder<ConfirmCubit, ConfirmLogicState>(
        builder: (context, state) => SimpleDialog(
          title: Text(AppLocalizations.of(context)!.codeConfirmation),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(16.0)
              )
          ),
          children: [
            TextFieldWidget(
                label: AppLocalizations.of(context)!.code,
                text: state.code,
                onTextChanged: BlocProvider.of<ConfirmCubit>(context).setCode
            ),
            const SizedBox(height: 16),
            ButtonWidget(
                text: AppLocalizations.of(context)!.confirm,
                onClick: () => Navigator.of(context).pop(
                    ConfirmResult(
                        code: state.code
                    )
                )
            ),
            ButtonWidget(
                text: AppLocalizations.of(context)!.cancel,
                onClick: Navigator.of(context).pop
            )
          ],
        ),
      ),
    );
  }
}

class ConfirmLogicState {

  final String code;

  ConfirmLogicState({
    required this.code
  });

  ConfirmLogicState copyWith({
    String? code,
    String? description
  }) => ConfirmLogicState(
      code: code ?? this.code
  );
}

@injectable
class ConfirmCubit extends Cubit<ConfirmLogicState> {

  ConfirmCubit() : super(ConfirmLogicState(code: ''));

  void setCode(String text) {
    emit(state.copyWith(code: text));
  }
}