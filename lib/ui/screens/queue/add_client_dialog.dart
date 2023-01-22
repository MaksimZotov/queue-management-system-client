import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

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

class AddClientWidget extends BaseWidget {

  const AddClientWidget({super.key, required super.emitConfig});

  @override
  State<AddClientWidget> createState() => _AddClientState();
}

class _AddClientState extends BaseDialogState<AddClientWidget, AddClientLogicState, AddClientCubit> {

  @override
  String getTitle(
      BuildContext context,
      AddClientLogicState state,
      AddClientWidget widget
  ) => AppLocalizations.of(context)!.connectionOfClientToQueue;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      AddClientLogicState state,
      AddClientWidget widget
  ) => [
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
    const SizedBox(height: Dimens.contentMargin),
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
    )
  ];

  @override
  AddClientCubit getCubit() => statesAssembler.getAddClientCubit();
}

class AddClientLogicState extends BaseLogicState {

  final String firstName;
  final String lastName;

  AddClientLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.firstName,
    required this.lastName
  });

  AddClientLogicState copyWith({
    String? email,
    String? firstName,
    String? lastName,
  }) => AddClientLogicState(
    nextConfig: nextConfig,
    error: error,
    snackBar: snackBar,
    loading: loading,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
  );

  @override
  AddClientLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => AddClientLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      firstName: firstName,
      lastName: lastName
  );
}

@injectable
class AddClientCubit extends BaseCubit<AddClientLogicState> {

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