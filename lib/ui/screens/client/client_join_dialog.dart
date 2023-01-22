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


class ClientJoinWidget extends BaseWidget {

  const ClientJoinWidget({super.key, required super.emitConfig});

  @override
  State<ClientJoinWidget> createState() => _ClientJoinState();
}

class _ClientJoinState extends BaseDialogState<ClientJoinWidget, ClientJoinLogicState, ClientJoinCubit> {

  @override
  String getTitle(
      BuildContext context,
      ClientJoinLogicState state,
      ClientJoinWidget widget
  ) => AppLocalizations.of(context)!.connectionToQueue;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      ClientJoinLogicState state,
      ClientJoinWidget widget
  ) => [
    TextFieldWidget(
        label: AppLocalizations.of(context)!.email,
        text: state.email,
        onTextChanged: BlocProvider.of<ClientJoinCubit>(context).setEmail
    ),
    TextFieldWidget(
        label: AppLocalizations.of(context)!.firstName,
        text: state.firstName,
        onTextChanged: BlocProvider.of<ClientJoinCubit>(context).setFirstName
    ),
    TextFieldWidget(
        label: AppLocalizations.of(context)!.lastName,
        text: state.lastName,
        onTextChanged: BlocProvider.of<ClientJoinCubit>(context).setLastName
    ),
    const SizedBox(height: 16),
    ButtonWidget(
        text: AppLocalizations.of(context)!.join,
        onClick: () => Navigator.of(context).pop(
            ClientJoinResult(
                email: state.email,
                firstName: state.firstName,
                lastName: state.lastName
            )
        )
    )
  ];

  @override
  ClientJoinCubit getCubit() => statesAssembler.getClientJoinCubit();
}

class ClientJoinLogicState extends BaseLogicState {

  final String email;
  final String firstName;
  final String lastName;

  ClientJoinLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.email,
    required this.firstName,
    required this.lastName
  });

  ClientJoinLogicState copyWith({
    String? email,
    String? firstName,
    String? lastName,
  }) => ClientJoinLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
  );

  @override
  ClientJoinLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => ClientJoinLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      email: email,
      firstName: firstName,
      lastName: lastName,
  );
}

@injectable
class ClientJoinCubit extends BaseCubit<ClientJoinLogicState> {

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