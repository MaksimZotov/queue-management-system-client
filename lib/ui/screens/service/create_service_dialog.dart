import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/service_interactor.dart';
import 'package:queue_management_system_client/domain/models/service/service_model.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/service/create_service_request.dart';
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
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).create,
        onClick: () => getCubitInstance(context).createService()
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

  CreateServiceLogicState({
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
  CreateServiceLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    CreateServiceResult? result,
    String? name,
    String? description
  }) => CreateServiceLogicState(
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
class CreateServiceCubit extends BaseDialogCubit<CreateServiceLogicState> {

  final ServiceInteractor _serviceInteractor;

  CreateServiceCubit(
      this._serviceInteractor,
      @factoryParam CreateServiceConfig config
  ) : super(
      CreateServiceLogicState(
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

  Future<void> createService() async {
    showLoad();
    await _serviceInteractor.createServiceInLocation(
        state.config.locationId,
        CreateServiceRequest(
            name: state.name,
            description: state.description.isEmpty ? null : state.description
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