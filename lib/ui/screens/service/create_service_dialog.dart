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
import '../../../domain/models/location/create_service_request.dart';
import '../../../domain/models/queue/queue_model.dart';
import '../../router/routes_config.dart';

class CreateServiceConfig extends BaseDialogConfig {
  final int locationId;

  CreateServiceConfig({
    required this.locationId,
  });
}

class CreateServiceResult extends BaseDialogResult {
  final ServiceModel serviceModel;

  CreateServiceResult({
    required this.serviceModel
  });
}

class CreateServiceWidget extends BaseDialogWidget<CreateServiceConfig> {

  const CreateServiceWidget({
    super.key,
    required super.config
  });

  @override
  State<CreateServiceWidget> createState() => _CreateServiceState();
}

class _CreateServiceState extends BaseDialogState<
    CreateServiceWidget,
    CreateServiceLogicState,
    CreateServiceCubit
> {

  @override
  String getTitle(
      BuildContext context,
      CreateServiceLogicState state,
      CreateServiceWidget widget
  ) => getLocalizations(context).creationOfService;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      CreateServiceLogicState state,
      CreateServiceWidget widget
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
        text: state.supposedDuration,
        onTextChanged: getCubitInstance(context).setSupposedDuration
    ),
    TextFieldWidget(
        label: getLocalizations(context).maxDuration,
        text: state.maxDuration,
        onTextChanged: getCubitInstance(context).setMaxDuration
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).create,
        onClick: getCubitInstance(context).createService
    )
  ];

  @override
  CreateServiceCubit getCubit() =>
      statesAssembler.getCreateServiceCubit(widget.config);
}

class CreateServiceLogicState extends BaseDialogLogicState<
    CreateServiceConfig,
    CreateServiceResult
> {

  final String name;
  final String description;
  final String supposedDuration;
  final String maxDuration;

  CreateServiceLogicState({
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
  CreateServiceLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    CreateServiceResult? result,
    String? name,
    String? description,
    String? supposedDuration,
    String? maxDuration
  }) => CreateServiceLogicState(
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
class CreateServiceCubit extends BaseDialogCubit<CreateServiceLogicState> {

  final LocationInteractor _locationInteractor;

  CreateServiceCubit(
      this._locationInteractor,
      @factoryParam CreateServiceConfig config
  ) : super(
      CreateServiceLogicState(
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
    emit(state.copy(supposedDuration: text));
  }

  void setMaxDuration(String text) {
    emit(state.copy(maxDuration: text));
  }

  Future<void> createService() async {
    showLoad();

    await _locationInteractor.createServiceInLocation(
        state.config.locationId,
        CreateServiceRequest(
            name: state.name,
            description: state.description.isEmpty ? null : state.description,
            supposedDuration: int.parse(state.supposedDuration),
            maxDuration: int.parse(state.maxDuration)
        )
    )
      ..onSuccess((result) {
        popResult(CreateServiceResult(serviceModel: result.data));
      })
      ..onError((result) {
        showError(result);
      });
  }
}