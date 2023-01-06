import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';

class ClientJoinResult {
  final String email;
  final String firstName;
  final String lastName;

  ClientJoinResult({
    required this.email,
    required this.firstName,
    required this.lastName
  });
}


class ClientJoinWidget extends StatefulWidget {

  const ClientJoinWidget({super.key});

  @override
  State<ClientJoinWidget> createState() => _ClientJoinState();
}

class _ClientJoinState extends State<ClientJoinWidget> {
  final String title = 'Подключение к очереди';
  final String emailHint = 'Почта';
  final String firstNameHint = 'Имя';
  final String lastNameHint = 'Фамилия';

  final String joinText = 'Подключиться';
  final String cancelText = 'Отмена';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientJoinCubit>(
      create: (context) => statesAssembler.getClientJoinCubit(),
      lazy: true,
      child: BlocBuilder<ClientJoinCubit, ClientJoinLogicState>(
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
                onTextChanged: BlocProvider.of<ClientJoinCubit>(context).setEmail
            ),
            TextFieldWidget(
                label: firstNameHint,
                text: state.firstName,
                onTextChanged: BlocProvider.of<ClientJoinCubit>(context).setFirstName
            ),
            TextFieldWidget(
                label: lastNameHint,
                text: state.lastName,
                onTextChanged: BlocProvider.of<ClientJoinCubit>(context).setLastName
            ),
            const SizedBox(height: 16),
            ButtonWidget(
                text: joinText,
                onClick: () => Navigator.of(context).pop(
                    ClientJoinResult(
                        email: state.email,
                        firstName: state.firstName,
                        lastName: state.lastName
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

class ClientJoinLogicState {

  final String email;
  final String firstName;
  final String lastName;

  ClientJoinLogicState({
    required this.email,
    required this.firstName,
    required this.lastName
  });

  ClientJoinLogicState copyWith({
    String? email,
    String? firstName,
    String? lastName,
  }) => ClientJoinLogicState(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
  );
}

@injectable
class ClientJoinCubit extends Cubit<ClientJoinLogicState> {

  ClientJoinCubit() : super(
      ClientJoinLogicState(
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