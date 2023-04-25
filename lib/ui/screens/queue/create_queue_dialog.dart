import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/models/queue/create_queue_request.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/queue_interactor.dart';
import '../../../domain/interactors/specialist_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/specialist_model.dart';
import '../../../domain/models/queue/queue_model.dart';
import '../../router/routes_config.dart';
import '../../widgets/dropdown_widget.dart';

class CreateQueueConfig extends BaseDialogConfig {
  final int locationId;

  CreateQueueConfig({
      required this.locationId,
  });
}

class CreateQueueResult extends BaseDialogResult {
  final QueueModel? queueModel;

  CreateQueueResult({
    required this.queueModel
  });
}

class CreateQueueWidget extends BaseDialogWidget<CreateQueueConfig> {

  const CreateQueueWidget({
    super.key,
    required super.config
  });

  @override
  State<CreateQueueWidget> createState() => _CreateQueueState();
}

class _CreateQueueState extends BaseDialogState<
    CreateQueueWidget,
    CreateQueueLogicState,
    CreateQueueCubit
> {

  @override
  String getTitle(
      BuildContext context,
      CreateQueueLogicState state,
      CreateQueueWidget widget
  ) => getLocalizations(context).creationOfQueue;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      CreateQueueLogicState state,
      CreateQueueWidget widget
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
    Align(
      alignment: Alignment.centerLeft,
      child: Text(
          getLocalizations(context).specialist,
          style: const TextStyle(
              fontSize: Dimens.labelFontSize
          )
      ),
    ),
    const SizedBox(height: Dimens.fieldElementsMargin),
    DropdownWidget<SpecialistModel>(
        value: state.selectedSpecialist,
        items: state.specialists,
        onChanged: getCubitInstance(context).selectSpecialist,
        getText: (item) => item.name
    ),
    const SizedBox(height: Dimens.contentMargin * 2),
    ButtonWidget(
        text: getLocalizations(context).create,
        onClick: getCubitInstance(context).createQueue
    )
  ];

  @override
  CreateQueueCubit getCubit() =>
      statesAssembler.getCreateQueueCubit(widget.config);
}

class CreateQueueLogicState extends BaseDialogLogicState<
    CreateQueueConfig,
    CreateQueueResult
> {

  final String name;
  final String description;

  final List<SpecialistModel> specialists;
  final SpecialistModel? selectedSpecialist;

  CreateQueueLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.name,
    required this.description,
    required this.specialists,
    required this.selectedSpecialist
  });

  @override
  CreateQueueLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    CreateQueueResult? result,
    String? name,
    String? description,
    List<SpecialistModel>? specialists,
    SpecialistModel? selectedSpecialist
  }) => CreateQueueLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      name: name ?? this.name,
      description: description ?? this.description,
      specialists: specialists ?? this.specialists,
      selectedSpecialist: selectedSpecialist ?? this.selectedSpecialist
  );
}

@injectable
class CreateQueueCubit extends BaseDialogCubit<CreateQueueLogicState> {

  final QueueInteractor _queueInteractor;
  final SpecialistInteractor _specialistInteractor;

  CreateQueueCubit(
      this._queueInteractor,
      this._specialistInteractor,
      @factoryParam CreateQueueConfig config
  ) : super(
      CreateQueueLogicState(
          config: config,
          name: '',
          description: '',
          specialists: [],
          selectedSpecialist: null
      )
  );

  @override
  Future<void> onStart() async {
    showLoad();
    await _specialistInteractor.getSpecialistsInLocation(
        state.config.locationId
    )
      ..onSuccess((result) async {
        List<SpecialistModel> specialists = result.data.results;
        if (specialists.isEmpty) {
          popResult(CreateQueueResult(queueModel: null));
        } else {
          emit(
              state.copy(
                  specialists: specialists,
                  selectedSpecialist: specialists.first
              )
          );
          hideLoad();
        }
      })
      ..onError((result) {
        showError(result);
      });
  }

  void setName(String text) {
    emit(state.copy(name: text));
  }

  void setDescription(String text) {
    emit(state.copy(description: text));
  }

  void selectSpecialist(SpecialistModel? specialistModel) {
    emit(
        state.copy(
            selectedSpecialist: specialistModel
        )
    );
  }

  Future<void> createQueue() async {
    showLoad();

    await _queueInteractor.createQueue(
        state.config.locationId,
        CreateQueueRequest(
            specialistId: state.selectedSpecialist!.id,
            name: state.name,
            description: state.description.isEmpty ? null : state.description
        )
    )
      ..onSuccess((result) {
        popResult(CreateQueueResult(queueModel: result.data));
      })
      ..onError((result) {
        showError(result);
      });
  }
}