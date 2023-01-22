import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class CreateLocationResult {
  final String name;
  final String description;

  CreateLocationResult({
    required this.name,
    required this.description
  });
}

class CreateLocationWidget extends BaseWidget {

  const CreateLocationWidget({super.key, required super.emitConfig});

  @override
  State<CreateLocationWidget> createState() => _CreateLocationState();
}

class _CreateLocationState extends BaseDialogState<CreateLocationWidget, CreateLocationLogicState, CreateLocationCubit> {

  @override
  String getTitle(
      BuildContext context,
      CreateLocationLogicState state,
      CreateLocationWidget widget
  ) => AppLocalizations.of(context)!.deleteLocationQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      CreateLocationLogicState state,
      CreateLocationWidget widget
  ) => [
    TextFieldWidget(
        label: AppLocalizations.of(context)!.name,
        text: state.name,
        onTextChanged: BlocProvider.of<CreateLocationCubit>(context).setName
    ),
    TextFieldWidget(
        maxLines: null,
        label: AppLocalizations.of(context)!.description,
        text: state.description,
        onTextChanged: BlocProvider.of<CreateLocationCubit>(context).setDescription
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: AppLocalizations.of(context)!.create,
        onClick: () => Navigator.of(context).pop(
            CreateLocationResult(
                name: state.name,
                description: state.description
            )
        )
    )
  ];

  @override
  CreateLocationCubit getCubit() => statesAssembler.getCreateLocationCubit();
}

class CreateLocationLogicState extends BaseLogicState {

  final String name;
  final String description;

  CreateLocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.name,
    required this.description
  });

  CreateLocationLogicState copyWith({
    String? name,
    String? description
  }) => CreateLocationLogicState(
      name: name ?? this.name,
      description: description ?? this.description
  );

  @override
  CreateLocationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => CreateLocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      name: name,
      description: description
  );
}

@injectable
class CreateLocationCubit extends BaseCubit<CreateLocationLogicState> {

  CreateLocationCubit() : super(
      CreateLocationLogicState(
          name: '',
          description: ''
      )
  );

  void setName(String text) {
    emit(state.copyWith(name: text));
  }

  void setDescription(String text) {
    emit(state.copyWith(description: text));
  }
}