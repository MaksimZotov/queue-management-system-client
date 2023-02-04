import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/location/service_model.dart';
import 'package:queue_management_system_client/domain/models/queue/create_queue_request.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/queue_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/create_specialist_request.dart';
import '../../../domain/models/location/create_service_request.dart';
import '../../../domain/models/location/specialist_model.dart';
import '../../../domain/models/queue/queue_model.dart';
import '../../router/routes_config.dart';

class CreateSpecialistConfig extends BaseDialogConfig {
  final int locationId;
  final List<int> serviceIds;

  CreateSpecialistConfig({
    required this.locationId,
    required this.serviceIds
  });
}

class CreateSpecialistResult extends BaseDialogResult {
  final SpecialistModel specialistModel;

  CreateSpecialistResult({
    required this.specialistModel
  });
}

class CreateSpecialistWidget extends BaseDialogWidget<CreateSpecialistConfig> {

  const CreateSpecialistWidget({
    super.key,
    required super.config
  });

  @override
  State<CreateSpecialistWidget> createState() => _CreateSpecialistState();
}

class _CreateSpecialistState extends BaseDialogState<
    CreateSpecialistWidget,
    CreateSpecialistLogicState,
    CreateSpecialistCubit
> {

  @override
  String getTitle(
      BuildContext context,
      CreateSpecialistLogicState state,
      CreateSpecialistWidget widget
  ) => getLocalizations(context).creationOfSpecialist;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      CreateSpecialistLogicState state,
      CreateSpecialistWidget widget
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
        onClick: getCubitInstance(context).createSpecialist
    )
  ];

  @override
  CreateSpecialistCubit getCubit() =>
      statesAssembler.getCreateSpecialistCubit(widget.config);
}

class CreateSpecialistLogicState extends BaseDialogLogicState<
    CreateSpecialistConfig,
    CreateSpecialistResult
> {

  final String name;
  final String description;

  CreateSpecialistLogicState({
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
  CreateSpecialistLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    CreateSpecialistResult? result,
    String? name,
    String? description
  }) => CreateSpecialistLogicState(
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
class CreateSpecialistCubit extends BaseDialogCubit<CreateSpecialistLogicState> {

  final LocationInteractor _locationInteractor;

  CreateSpecialistCubit(
      this._locationInteractor,
      @factoryParam CreateSpecialistConfig config
  ) : super(
      CreateSpecialistLogicState(
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

  Future<void> createSpecialist() async {
    showLoad();

    await _locationInteractor.createSpecialistInLocation(
        state.config.locationId,
        CreateSpecialistRequest(
            name: state.name,
            description: state.description.isEmpty ? null : state.description,
            serviceIds: state.config.serviceIds
        )
    )
      ..onSuccess((result) {
        popResult(CreateSpecialistResult(specialistModel: result.data));
      })
      ..onError((result) {
        showError(result);
      });
  }
}