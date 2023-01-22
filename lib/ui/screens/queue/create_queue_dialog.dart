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

class CreateQueueResult {
  final String name;
  final String description;

  CreateQueueResult({
    required this.name,
    required this.description
  });
}


class CreateQueueWidget extends BaseWidget {

  const CreateQueueWidget({super.key, required super.emitConfig});

  @override
  State<CreateQueueWidget> createState() => _CreateQueueState();
}

class _CreateQueueState extends BaseDialogState<CreateQueueWidget, CreateQueueLogicState, CreateQueueCubit> {

  @override
  String getTitle(
      BuildContext context,
      CreateQueueLogicState state,
      CreateQueueWidget widget
  ) => AppLocalizations.of(context)!.creationOfQueue;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      CreateQueueLogicState state,
      CreateQueueWidget widget
  ) => [
    TextFieldWidget(
        label: AppLocalizations.of(context)!.name,
        text: state.name,
        onTextChanged: BlocProvider.of<CreateQueueCubit>(context).setName
    ),
    TextFieldWidget(
        maxLines: null,
        label: AppLocalizations.of(context)!.description,
        text: state.description,
        onTextChanged: BlocProvider.of<CreateQueueCubit>(context).setDescription
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: AppLocalizations.of(context)!.create,
        onClick: () => Navigator.of(context).pop(
            CreateQueueResult(
                name: state.name,
                description: state.description
            )
        )
    )
  ];

  @override
  CreateQueueCubit getCubit() => statesAssembler.getCreateQueueCubit();
}

class CreateQueueLogicState extends BaseLogicState {

  final String name;
  final String description;

  CreateQueueLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required this.name,
    required this.description
  });

  CreateQueueLogicState copyWith({
    String? name,
    String? description
  }) => CreateQueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      name: name ?? this.name,
      description: description ?? this.description
  );

  @override
  CreateQueueLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading
  }) => CreateQueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      name: name,
      description: description
  );
}

@injectable
class CreateQueueCubit extends BaseCubit<CreateQueueLogicState> {

  CreateQueueCubit() : super(
      CreateQueueLogicState(
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