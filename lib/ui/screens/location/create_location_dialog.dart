import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';

class CreateLocationResult {
  final String name;
  final String description;

  CreateLocationResult({
    required this.name,
    required this.description
  });
}


class CreateLocationWidget extends StatefulWidget {

  const CreateLocationWidget({super.key});

  @override
  State<CreateLocationWidget> createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocationWidget> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateLocationCubit>(
      create: (context) => statesAssembler.getCreateLocationCubit(),
      child: BlocBuilder<CreateLocationCubit, CreateLocationLogicState>(
        builder: (context, state) => SimpleDialog(
          title: Text(AppLocalizations.of(context)!.creationOfLocation),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(16.0)
              )
          ),
          children: [
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
            const SizedBox(height: 16),
            ButtonWidget(
                text: AppLocalizations.of(context)!.create,
                onClick: () => Navigator.of(context).pop(
                    CreateLocationResult(
                        name: state.name,
                        description: state.description
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

class CreateLocationLogicState {

  final String name;
  final String description;

  CreateLocationLogicState({
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
}

@injectable
class CreateLocationCubit extends Cubit<CreateLocationLogicState> {

  final LocationInteractor locationInteractor;

  CreateLocationCubit({
    required this.locationInteractor
  }) : super(
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