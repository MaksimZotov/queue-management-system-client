import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/create_location_request.dart';
import '../../../domain/models/location/location_model.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class CreateLocationConfig extends BaseDialogConfig {}

class CreateLocationResult extends BaseDialogResult {
  final LocationModel locationModel;

  CreateLocationResult({
    required this.locationModel
  });
}

class CreateLocationWidget extends BaseDialogWidget<CreateLocationConfig> {

  const CreateLocationWidget({
    super.key,
    required super.config
  });

  @override
  State<CreateLocationWidget> createState() => _CreateLocationState();
}

class _CreateLocationState extends BaseDialogState<
    CreateLocationWidget,
    CreateLocationLogicState,
    CreateLocationCubit
> {

  @override
  String getTitle(
      BuildContext context,
      CreateLocationLogicState state,
      CreateLocationWidget widget
  ) => getLocalizations(context).creationOfLocation;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      CreateLocationLogicState state,
      CreateLocationWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).name,
        text: state.name,
        onTextChanged: getCubitInstance(context).setName
    ),
    TextFieldWidget(
        maxLines: null,
        label: getLocalizations(context).description,
        text: state.description,
        onTextChanged: getCubitInstance(context).setDescription
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).create,
        onClick: getCubitInstance(context).createLocation
    )
  ];

  @override
  CreateLocationCubit getCubit() =>
      statesAssembler.getCreateLocationCubit(widget.config);
}

class CreateLocationLogicState extends BaseDialogLogicState<
    CreateLocationConfig,
    CreateLocationResult
> {

  final String name;
  final String description;

  CreateLocationLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.name,
    required this.description
  });

  @override
  CreateLocationLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    CreateLocationResult? result,
    String? name,
    String? description
  }) => CreateLocationLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      name: name ?? this.name,
      description: description ?? this.description
  );
}

@injectable
class CreateLocationCubit extends BaseDialogCubit<CreateLocationLogicState> {

  final LocationInteractor _locationInteractor;
  
  CreateLocationCubit(
      this._locationInteractor,
      @factoryParam CreateLocationConfig config
  ) : super(
      CreateLocationLogicState(
          config: config,
          name: '',
          description: ''
      )
  );

  void setName(String text) {
    emit(state.copy(name: text));
  }

  void setDescription(String text) {
    emit(state.copy(description: text));
  }

  Future<void> createLocation() async {
    showLoad();
    await _locationInteractor.createLocation(
        CreateLocationRequest(
            name: state.name,
            description: state.description.isEmpty ? null : state.description
        )
    )..onSuccess((result) {
      popResult(
          CreateLocationResult(
              locationModel: result.data
          )
      );
    })..onError((result) {
      showError(result);
    });
  }
}