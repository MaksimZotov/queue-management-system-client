import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';

class ClientRejoinResult {
  final String email;

  ClientRejoinResult({
    required this.email
  });
}


class ClientRejoinWidget extends StatefulWidget {

  const ClientRejoinWidget({super.key});

  @override
  State<ClientRejoinWidget> createState() => _ClientRejoinState();
}

class _ClientRejoinState extends State<ClientRejoinWidget> {
  final String title = 'Переподключение к очереди';
  final String emailHint = 'Почта';

  final String rejoinText = 'Переподключиться';
  final String cancelText = 'Отмена';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientRejoinCubit>(
      create: (context) => statesAssembler.getClientRejoinCubit(),
      lazy: true,
      child: BlocBuilder<ClientRejoinCubit, ClientRejoinLogicState>(
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
                onTextChanged: BlocProvider.of<ClientRejoinCubit>(context).setEmail
            ),
            const SizedBox(height: 16),
            ButtonWidget(
                text: rejoinText,
                onClick: () => Navigator.of(context).pop(
                    ClientRejoinResult(
                        email: state.email
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

class ClientRejoinLogicState {

  final String email;

  ClientRejoinLogicState({
    required this.email
  });

  ClientRejoinLogicState copyWith({
    String? email
  }) => ClientRejoinLogicState(
    email: email ?? this.email
  );
}

@injectable
class ClientRejoinCubit extends Cubit<ClientRejoinLogicState> {

  ClientRejoinCubit() : super(
      ClientRejoinLogicState(
          email: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }
}