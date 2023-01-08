import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';

class AddClientResult {
  final String email;
  final String firstName;
  final String lastName;
  final bool save;

  AddClientResult({
    required this.email,
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
  final String title = 'Подключение клиента к очереди';
  final String emailHint = 'Почта';
  final String firstNameHint = 'Имя';
  final String lastNameHint = 'Фамилия';

  final String addText = 'Добавить';
  final String addAndSaveText = 'Добавить и сохранить';
  final String cancelText = 'Отмена';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddClientCubit>(
      create: (context) => statesAssembler.getAddClientCubit(),
      lazy: true,
      child: BlocBuilder<AddClientCubit, AddClientLogicState>(
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
                onTextChanged: BlocProvider.of<AddClientCubit>(context).setEmail
            ),
            TextFieldWidget(
                label: firstNameHint,
                text: state.firstName,
                onTextChanged: BlocProvider.of<AddClientCubit>(context).setFirstName
            ),
            TextFieldWidget(
                label: lastNameHint,
                text: state.lastName,
                onTextChanged: BlocProvider.of<AddClientCubit>(context).setLastName
            ),
            const SizedBox(height: 16),
            ButtonWidget(
                text: addText,
                onClick: () => Navigator.of(context).pop(
                    AddClientResult(
                        email: state.email,
                        firstName: state.firstName,
                        lastName: state.lastName,
                        save: false
                    )
                )
            ),
            ButtonWidget(
                text: addAndSaveText,
                onClick: () => Navigator.of(context).pop(
                    AddClientResult(
                        email: state.email,
                        firstName: state.firstName,
                        lastName: state.lastName,
                        save: true
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

class AddClientLogicState {

  final String email;
  final String firstName;
  final String lastName;

  AddClientLogicState({
    required this.email,
    required this.firstName,
    required this.lastName
  });

  AddClientLogicState copyWith({
    String? email,
    String? firstName,
    String? lastName,
  }) => AddClientLogicState(
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
  );
}

@injectable
class AddClientCubit extends Cubit<AddClientLogicState> {

  AddClientCubit() : super(
      AddClientLogicState(
          email: '',
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