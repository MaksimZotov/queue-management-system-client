import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';

class AddClientResult {
  final String firstName;
  final String lastName;
  final bool save;

  AddClientResult({
    required this.firstName,
    required this.lastName,
    required this.save
  });
}


class AddClientWidget extends StatefulWidget {

  const AddClientWidget({super.key});

  @override
  State<AddClientWidget> createState() => _AddClientState();
}

class _AddClientState extends State<AddClientWidget> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddClientCubit>(
      create: (context) => statesAssembler.getAddClientCubit(),
      lazy: true,
      child: BlocBuilder<AddClientCubit, AddClientLogicState>(
        builder: (context, state) => SimpleDialog(
          title: Text(AppLocalizations.of(context)!.connectionOfClientToQueue),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(16.0)
              )
          ),
          children: [
            TextFieldWidget(
                label: AppLocalizations.of(context)!.firstName,
                text: state.firstName,
                onTextChanged: BlocProvider.of<AddClientCubit>(context).setFirstName
            ),
            TextFieldWidget(
                label: AppLocalizations.of(context)!.lastName,
                text: state.lastName,
                onTextChanged: BlocProvider.of<AddClientCubit>(context).setLastName
            ),
            const SizedBox(height: 16),
            ButtonWidget(
                text: AppLocalizations.of(context)!.add,
                onClick: () => Navigator.of(context).pop(
                    AddClientResult(
                        firstName: state.firstName,
                        lastName: state.lastName,
                        save: false
                    )
                )
            ),
            ButtonWidget(
                text: AppLocalizations.of(context)!.addAndSave,
                onClick: () => Navigator.of(context).pop(
                    AddClientResult(
                        firstName: state.firstName,
                        lastName: state.lastName,
                        save: true
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

class AddClientLogicState {

  final String firstName;
  final String lastName;

  AddClientLogicState({
    required this.firstName,
    required this.lastName
  });

  AddClientLogicState copyWith({
    String? email,
    String? firstName,
    String? lastName,
  }) => AddClientLogicState(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
  );
}

@injectable
class AddClientCubit extends Cubit<AddClientLogicState> {

  AddClientCubit() : super(
      AddClientLogicState(
          firstName: '',
          lastName: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }

  void setFirstName(String text) {
    emit(state.copyWith(firstName: text));
  }

  void setLastName(String text) {
    emit(state.copyWith(lastName: text));
  }
}