import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/services_sequence_interactor.dart';
import 'package:queue_management_system_client/domain/models/location/services_sequence_model.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/create_services_sequence_request.dart';
import '../../router/routes_config.dart';

class CreateServicesSequenceConfig extends BaseDialogConfig {
  final int locationId;
  Map<int, int> serviceIdsToOrderNumbers;

  CreateServicesSequenceConfig({
    required this.locationId,
    required this.serviceIdsToOrderNumbers
  });
}

class CreateServicesSequenceResult extends BaseDialogResult {
  final ServicesSequenceModel servicesSequenceModel;

  CreateServicesSequenceResult({
    required this.servicesSequenceModel
  });
}

class CreateServicesSequenceWidget extends BaseDialogWidget<CreateServicesSequenceConfig> {

  const CreateServicesSequenceWidget({
    super.key,
    required super.config
  });

  @override
  State<CreateServicesSequenceWidget> createState() => _CreateServicesSequenceState();
}

class _CreateServicesSequenceState extends BaseDialogState<
    CreateServicesSequenceWidget,
    CreateServicesSequenceLogicState,
    CreateServicesSequenceCubit
> {

  @override
  String getTitle(
      BuildContext context,
      CreateServicesSequenceLogicState state,
      CreateServicesSequenceWidget widget
  ) => getLocalizations(context).creationOfServicesSequence;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      CreateServicesSequenceLogicState state,
      CreateServicesSequenceWidget widget
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
        onClick: getCubitInstance(context).createQueue
    )
  ];

  @override
  CreateServicesSequenceCubit getCubit() =>
      statesAssembler.getCreateServicesSequenceCubit(widget.config);
}

class CreateServicesSequenceLogicState extends BaseDialogLogicState<
    CreateServicesSequenceConfig,
    CreateServicesSequenceResult
> {

  final String name;
  final String description;

  CreateServicesSequenceLogicState({
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
  CreateServicesSequenceLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    CreateServicesSequenceResult? result,
    String? name,
    String? description
  }) => CreateServicesSequenceLogicState(
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
class CreateServicesSequenceCubit extends BaseDialogCubit<CreateServicesSequenceLogicState> {

  final ServicesSequenceInteractor _servicesSequenceInteractor;

  CreateServicesSequenceCubit(
      this._servicesSequenceInteractor,
      @factoryParam CreateServicesSequenceConfig config
  ) : super(
      CreateServicesSequenceLogicState(
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

  Future<void> createQueue() async {
    showLoad();

    await _servicesSequenceInteractor.createServicesSequenceInLocation(
        state.config.locationId,
        CreateServicesSequenceRequest(
            name: state.name,
            description: state.description.isEmpty ? null : state.description,
            serviceIdsToOrderNumbers: state.config.serviceIdsToOrderNumbers
        )
    )
      ..onSuccess((result) {
        popResult(
            CreateServicesSequenceResult(
                servicesSequenceModel: result.data
            )
        );
      })
      ..onError((result) {
        showError(result);
      });
  }
}