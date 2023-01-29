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
import '../../../domain/models/location/create_queue_type_request.dart';
import '../../../domain/models/location/create_service_request.dart';
import '../../../domain/models/location/queue_type_model.dart';
import '../../../domain/models/queue/queue_model.dart';
import '../../router/routes_config.dart';

class CreateQueueTypeConfig extends BaseDialogConfig {
  final int locationId;
  final List<int> serviceIds;

  CreateQueueTypeConfig({
    required this.locationId,
    required this.serviceIds
  });
}

class CreateQueueTypeResult extends BaseDialogResult {
  final QueueTypeModel queueTypeModel;

  CreateQueueTypeResult({
    required this.queueTypeModel
  });
}

class CreateQueueTypeWidget extends BaseDialogWidget<CreateQueueTypeConfig> {

  const CreateQueueTypeWidget({
    super.key,
    required super.config
  });

  @override
  State<CreateQueueTypeWidget> createState() => _CreateQueueTypeState();
}

class _CreateQueueTypeState extends BaseDialogState<
    CreateQueueTypeWidget,
    CreateQueueTypeLogicState,
    CreateQueueTypeCubit
> {

  @override
  String getTitle(
      BuildContext context,
      CreateQueueTypeLogicState state,
      CreateQueueTypeWidget widget
  ) => getLocalizations(context).creationOfQueueType;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      CreateQueueTypeLogicState state,
      CreateQueueTypeWidget widget
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
    TextFieldWidget(
        label: getLocalizations(context).supposedDuration,
        text: state.description,
        onTextChanged: getCubitInstance(context).setSupposedDuration
    ),
    TextFieldWidget(
        label: getLocalizations(context).maxDuration,
        text: state.description,
        onTextChanged: getCubitInstance(context).setMaxDuration
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).create,
        onClick: getCubitInstance(context).createQueueType
    )
  ];

  @override
  CreateQueueTypeCubit getCubit() =>
      statesAssembler.getCreateQueueTypeCubit(widget.config);
}

class CreateQueueTypeLogicState extends BaseDialogLogicState<
    CreateQueueTypeConfig,
    CreateQueueTypeResult
> {

  final String name;
  final String description;
  final String supposedDuration;
  final String maxDuration;

  CreateQueueTypeLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.name,
    required this.description,
    required this.supposedDuration,
    required this.maxDuration
  });

  @override
  CreateQueueTypeLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    CreateQueueTypeResult? result,
    String? name,
    String? description,
    String? supposedDuration,
    String? maxDuration
  }) => CreateQueueTypeLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      name: name ?? this.name,
      description: description ?? this.description,
      supposedDuration: supposedDuration ?? this.supposedDuration,
      maxDuration: maxDuration ?? this.maxDuration,
  );
}

@injectable
class CreateQueueTypeCubit extends BaseDialogCubit<CreateQueueTypeLogicState> {

  final LocationInteractor _locationInteractor;

  CreateQueueTypeCubit(
      this._locationInteractor,
      @factoryParam CreateQueueTypeConfig config
  ) : super(
      CreateQueueTypeLogicState(
          config: config,
          name: '',
          description: '',
          supposedDuration: '0',
          maxDuration: '60'
      )
  );

  void setName(String text) {
    emit(state.copy(name: text));
  }

  void setDescription(String text) {
    emit(state.copy(description: text));
  }

  void setSupposedDuration(String text) {
    emit(state.copy(description: text));
  }

  void setMaxDuration(String text) {
    emit(state.copy(description: text));
  }

  Future<void> createQueueType() async {
    showLoad();

    await _locationInteractor.createQueueTypeInLocation(
        state.config.locationId,
        CreateQueueTypeRequest(
            name: state.name,
            description: state.description.isEmpty ? null : state.description,
            serviceIds: state.config.serviceIds
        )
    )
      ..onSuccess((result) {
        popResult(CreateQueueTypeResult(queueTypeModel: result.data));
      })
      ..onError((result) {
        showError(result);
      });
  }
}