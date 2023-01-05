import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';

class CreateQueueResult {
  final String name;
  final String description;

  CreateQueueResult({
    required this.name,
    required this.description
  });
}


class CreateQueueWidget extends StatefulWidget {

  const CreateQueueWidget({super.key});

  @override
  State<CreateQueueWidget> createState() => _CreateQueueState();
}

class _CreateQueueState extends State<CreateQueueWidget> {
  final String title = 'Создание очереди';
  final String nameHint = 'Название';
  final String descriptionHint = 'Описание';
  final String createText = 'Создать';
  final String cancelText = 'Отмена';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateQueueCubit>(
      create: (context) => statesAssembler.getCreateQueueCubit(),
      lazy: true,
      child: BlocBuilder<CreateQueueCubit, CreateQueueLogicState>(
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
                label: nameHint,
                text: state.name,
                onTextChanged: BlocProvider.of<CreateQueueCubit>(context).setName
            ),
            TextFieldWidget(
                maxLines: null,
                label: descriptionHint,
                text: state.description,
                onTextChanged: BlocProvider.of<CreateQueueCubit>(context).setDescription
            ),
            const SizedBox(height: 16),
            ButtonWidget(
                text: createText,
                onClick: () => Navigator.of(context).pop(
                    CreateQueueResult(
                        name: state.name,
                        description: state.description
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

class CreateQueueLogicState {

  final String name;
  final String description;

  CreateQueueLogicState({
    required this.name,
    required this.description
  });

  CreateQueueLogicState copyWith({
    String? name,
    String? description
  }) => CreateQueueLogicState(
      name: name ?? this.name,
      description: description ?? this.description
  );
}

@injectable
class CreateQueueCubit extends Cubit<CreateQueueLogicState> {

  final LocationInteractor locationInteractor;

  CreateQueueCubit({
    required this.locationInteractor
  }) : super(
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