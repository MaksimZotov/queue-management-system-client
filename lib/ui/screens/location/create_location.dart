import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';


class CreateLocationWidget extends StatefulWidget {

  const CreateLocationWidget({super.key});

  @override
  State<CreateLocationWidget> createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocationWidget> {
  final String title = 'Создание локации';
  final String nameHint = 'Название';
  final String descriptionHint = 'Описание';
  final String createText = 'Создать';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateLocationCubit>(
      create: (context) => statesAssembler.getCreateLocationCubit(),
      lazy: true,
      child: BlocConsumer<CreateLocationCubit, CreateLocationLogicState>(

        listener: (context, state) {
          if (state.readyToClose) {
            Navigator.of(context).pop();
          }
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.snackBar!)));
            BlocProvider.of<CreateLocationCubit>(context).onSnackBarShowed();
          }
        },

        builder: (context, state) => state.loading ? const Center(
          child: CircularProgressIndicator(),
        ) : SimpleDialog(
          title: Text(title),
          contentPadding: const EdgeInsets.all(20),
          children: [
            TextFieldWidget(
              label: nameHint,
              text: state.name,
              onTextChanged: BlocProvider.of<CreateLocationCubit>(context).setName
            ),
            TextFieldWidget(
              maxLines: null,
              label: descriptionHint,
              text: state.description,
                onTextChanged: BlocProvider.of<CreateLocationCubit>(context).setDescription
            ),
            ButtonWidget(
                text: createText,
                onClick: BlocProvider.of<CreateLocationCubit>(context).createLocation,
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

  final bool readyToClose;

  final String? snackBar;
  final bool loading;


  CreateLocationLogicState({
    required this.name,
    required this.description,
    required this.readyToClose,
    required this.snackBar,
    required this.loading,
  });

  CreateLocationLogicState copyWith({
    String? name,
    String? description,
    bool? readyToClose,
    String? snackBar,
    bool? loading,
  }) => CreateLocationLogicState(
      name: name ?? this.name,
      description: description ?? this.description,
      readyToClose: readyToClose ?? this.readyToClose,
      snackBar: snackBar,
      loading: loading ?? this.loading
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
          description: '',
          readyToClose: false,
          snackBar: null,
          loading: false
      )
  );

  Future createLocation() async {
    emit(state.copyWith(loading: true));
    await locationInteractor.createLocation(
      LocationModel(
          id: null,
          name: state.name,
          description: state.description
      )
    )..onSuccess((result) {
      emit(state.copyWith(loading: false, readyToClose: true));
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    });
  }

  void setName(String text) {
    emit(state.copyWith(name: text));
  }

  void setDescription(String text) {
    emit(state.copyWith(description: text));
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}