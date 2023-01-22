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

class ClientConfirmWidget extends BaseWidget {
  final ClientConfirmConfig config;

  const ClientConfirmWidget({super.key, required super.emitConfig, required this.config});

  @override
  State<ClientConfirmWidget> createState() => _ClientConfirmState();
}

class _ClientConfirmState extends BaseDialogState<ClientConfirmWidget, ClientConfirmLogicState, ClientConfirmCubit> {

  @override
  String getTitle(
      BuildContext context,
      ClientConfirmLogicState state,
      ClientConfirmWidget widget
  ) => AppLocalizations.of(context)!.codeConfirmation;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      ClientConfirmLogicState state,
      ClientConfirmWidget widget
  ) => [
    TextFieldWidget(
        label: AppLocalizations.of(context)!.code,
        text: state.code,
        onTextChanged: BlocProvider.of<ClientConfirmCubit>(context).setEmail
    ),
    const SizedBox(height: 10),
    ButtonWidget(
        text: AppLocalizations.of(context)!.confirm,
        onClick: () => Navigator.of(context).pop(
            ClientConfirmResult(
                code: state.code,
                email: widget.config.email
            )
        )
    ),
  ];

  @override
  ClientConfirmCubit getCubit() => statesAssembler.getClientConfirmCubit();
}

class ClientConfirmLogicState extends BaseLogicState {

  final String code;

  ClientConfirmLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.code
  });

  ClientConfirmLogicState copyWith({
    String? email
  }) => ClientConfirmLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      code: email ?? this.code
  );

  @override
  ClientConfirmLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => ClientConfirmLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      code: code
  );
}

@injectable
class ClientConfirmCubit extends BaseCubit<ClientConfirmLogicState> {

  ClientConfirmCubit() : super(
      ClientConfirmLogicState(
          code: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }
}