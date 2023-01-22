import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class ClientRejoinResult {
  final String email;

  ClientRejoinResult({
    required this.email
  });
}


class ClientRejoinWidget extends BaseWidget {

  const ClientRejoinWidget({super.key, required super.emitConfig});

  @override
  State<ClientRejoinWidget> createState() => _ClientRejoinState();
}

class _ClientRejoinState extends BaseDialogState<ClientRejoinWidget, ClientRejoinLogicState, ClientRejoinCubit> {

  @override
  String getTitle(
      BuildContext context,
      ClientRejoinLogicState state,
      ClientRejoinWidget widget
  ) => AppLocalizations.of(context)!.reconnectionToQueue;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      ClientRejoinLogicState state,
      ClientRejoinWidget widget
  ) => [
    TextFieldWidget(
        label: AppLocalizations.of(context)!.email,
        text: state.email,
        onTextChanged: BlocProvider.of<ClientRejoinCubit>(context).setEmail
    ),
    const SizedBox(height: 10),
    ButtonWidget(
        text: AppLocalizations.of(context)!.rejoin,
        onClick: () => Navigator.of(context).pop(
            ClientRejoinResult(
                email: state.email
            )
        )
    )
  ];

  @override
  ClientRejoinCubit getCubit() => statesAssembler.getClientRejoinCubit();
}

class ClientRejoinLogicState extends BaseLogicState {

  final String email;

  ClientRejoinLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.email
  });

  ClientRejoinLogicState copyWith({
    String? email
  }) => ClientRejoinLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      email: email ?? this.email
  );

  @override
  ClientRejoinLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => ClientRejoinLogicState(
    nextConfig: nextConfig,
    error: error,
    snackBar: snackBar,
    loading: loading ?? this.loading,
    email: email
  );
}

@injectable
class ClientRejoinCubit extends BaseCubit<ClientRejoinLogicState> {

  ClientRejoinCubit() : super(
      ClientRejoinLogicState(
          email: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }
}