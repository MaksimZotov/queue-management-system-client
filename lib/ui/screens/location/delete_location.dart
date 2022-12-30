import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/location/location.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/interactors/location_interactor.dart';

class DeleteLocationParams {
  final int id;

  DeleteLocationParams({
    required this.id,
  });
}

class DeleteLocationWidget extends StatefulWidget {
  final DeleteLocationParams params;

  const DeleteLocationWidget({super.key, required this.params});

  @override
  State<DeleteLocationWidget> createState() => _DeleteLocationState();
}

class _DeleteLocationState extends State<DeleteLocationWidget> {
  final String title = 'Удалить локацию?';
  final String yesText = 'Удалить';
  final String cancelText = 'Отмена';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeleteLocationCubit>(
      create: (context) => statesAssembler.getDeleteLocationCubit(widget.params),
      lazy: true,
      child: BlocConsumer<DeleteLocationCubit, DeleteLocationLogicState>(

        listener: (context, state) {
          if (state.readyToClose) {
            Navigator.of(context).pop();
          }
          if (state.snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.snackBar!)));
            BlocProvider.of<DeleteLocationCubit>(context).onSnackBarShowed();
          }
        },

        builder: (context, state) => state.loading ? const Center(
          child: CircularProgressIndicator(),
        ) : SimpleDialog(
          title: Text(title),
          contentPadding: const EdgeInsets.all(20),
          children: [
            ButtonWidget(
              text: yesText,
              onClick: BlocProvider.of<DeleteLocationCubit>(context).deleteLocation,
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

class DeleteLocationLogicState {

  final DeleteLocationParams params;

  final String name;

  final bool readyToClose;

  final String? snackBar;
  final bool loading;


  DeleteLocationLogicState({
    required this.params,
    required this.name,
    required this.readyToClose,
    required this.snackBar,
    required this.loading,
  });

  DeleteLocationLogicState copyWith({
    String? name,
    bool? readyToClose,
    String? snackBar,
    bool? loading,
  }) => DeleteLocationLogicState(
      params: params,
      name: name ?? this.name,
      readyToClose: readyToClose ?? this.readyToClose,
      snackBar: snackBar,
      loading: loading ?? this.loading
  );
}

@injectable
class DeleteLocationCubit extends Cubit<DeleteLocationLogicState> {

  final LocationInteractor locationInteractor;

  DeleteLocationCubit({
    required this.locationInteractor,
    @factoryParam required DeleteLocationParams params
  }) : super(
      DeleteLocationLogicState(
          params: params,
          name: '',
          readyToClose: false,
          snackBar: null,
          loading: false
      )
  );

  Future deleteLocation() async {
    emit(state.copyWith(loading: true));
    await locationInteractor.deleteLocation(state.params.id)..onSuccess((result) {
      emit(state.copyWith(loading: false, readyToClose: true));
    })..onError((result) {
      emit(state.copyWith(loading: false, snackBar: result.description));
    });
  }

  void onSnackBarShowed() {
    emit(state.copyWith(snackBar: null));
  }
}