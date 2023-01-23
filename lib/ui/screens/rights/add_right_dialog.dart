import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';

import '../../../dimens.dart';
import '../../../domain/interactors/rights_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class AddRightConfig extends BaseDialogConfig {
  final int locationId;

  AddRightConfig({
    required this.locationId
  });
}

class AddRightResult extends BaseDialogResult {
  final String email;

  AddRightResult({
    required this.email,
  });
}

class AddRightWidget extends BaseDialogWidget<AddRightConfig> {

  const AddRightWidget({
    super.key,
    required super.config
  });

  @override
  State<AddRightWidget> createState() => _AddRightState();
}

class _AddRightState extends BaseDialogState<
    AddRightWidget,
    AddRightLogicState,
    AddRightCubit
> {

  @override
  String getTitle(
      BuildContext context,
      AddRightLogicState state,
      AddRightWidget widget
  ) => getLocalizations(context).addingOfEmployee;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      AddRightLogicState state,
      AddRightWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).email,
        text: state.email,
        onTextChanged: getCubitInstance(context).setEmail
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).add,
        onClick: getCubitInstance(context).addRight
    ),
  ];

  @override
  AddRightCubit getCubit() => statesAssembler.getAddRightCubit(widget.config);
}

class AddRightLogicState extends BaseDialogLogicState<
    AddRightConfig,
    AddRightResult
> {

  final String email;

  AddRightLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.email,
  });

  AddRightLogicState copyWith({
    String? email
  }) => AddRightLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading,
      config: config,
      result: result,
      email: email ?? this.email
  );

  @override
  AddRightLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    AddRightResult? result
  }) => AddRightLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      email: email
  );
}

@injectable
class AddRightCubit extends BaseDialogCubit<AddRightLogicState> {

  final RightsInteractor _rightsInteractor;

  AddRightCubit(
      this._rightsInteractor,
      @factoryParam AddRightConfig config
  ) : super(
      AddRightLogicState(
          config: config,
          email: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }

  Future<void> addRight() async {
    showLoad();
    await _rightsInteractor.addRights(
        state.config.locationId,
        state.email
    )
      ..onSuccess((result) {
        popResult(AddRightResult(email: state.email));
      })..onError((result) {
        showError(result);
      });
  }
}