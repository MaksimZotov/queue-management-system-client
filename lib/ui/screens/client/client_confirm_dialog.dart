import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';

class ClientConfirmConfig {
  final String email;

  ClientConfirmConfig({
    required this.email,
  });
}

class ClientConfirmResult {
  final String code;
  final String email;

  ClientConfirmResult({
    required this.code,
    required this.email
  });
}

class ClientConfirmWidget extends StatefulWidget {
  final ClientConfirmConfig config;

  const ClientConfirmWidget({super.key, required this.config});

  @override
  State<ClientConfirmWidget> createState() => _ClientConfirmState();
}

class _ClientConfirmState extends State<ClientConfirmWidget> {
  final String title = 'Подтверждение кода';
  final String codeHint = 'Код';

  final String confirmText = 'Подтвердить';
  final String cancelText = 'Отмена';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientConfirmCubit>(
      create: (context) => statesAssembler.getClientConfirmCubit(),
      lazy: true,
      child: BlocBuilder<ClientConfirmCubit, ClientConfirmLogicState>(
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
                label: codeHint,
                text: state.code,
                onTextChanged: BlocProvider.of<ClientConfirmCubit>(context).setEmail
            ),
            const SizedBox(height: 16),
            ButtonWidget(
                text: confirmText,
                onClick: () => Navigator.of(context).pop(
                    ClientConfirmResult(
                        code: state.code,
                        email: widget.config.email
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

class ClientConfirmLogicState {

  final String code;

  ClientConfirmLogicState({
    required this.code
  });

  ClientConfirmLogicState copyWith({
    String? email
  }) => ClientConfirmLogicState(
      code: email ?? this.code
  );
}

@injectable
class ClientConfirmCubit extends Cubit<ClientConfirmLogicState> {

  ClientConfirmCubit() : super(
      ClientConfirmLogicState(
          code: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }
}