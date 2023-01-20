import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientRejoinCubit>(
      create: (context) => statesAssembler.getClientRejoinCubit(),
      lazy: true,
      child: BlocBuilder<ClientRejoinCubit, ClientRejoinLogicState>(
        builder: (context, state) => SimpleDialog(
          title: Text(AppLocalizations.of(context)!.reconnectionToQueue),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(16.0)
              )
          ),
          children: [
            TextFieldWidget(
                label: AppLocalizations.of(context)!.email,
                text: state.email,
                onTextChanged: BlocProvider.of<ClientRejoinCubit>(context).setEmail
            ),
            const SizedBox(height: 16),
            ButtonWidget(
                text: AppLocalizations.of(context)!.rejoin,
                onClick: () => Navigator.of(context).pop(
                    ClientRejoinResult(
                        email: state.email
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