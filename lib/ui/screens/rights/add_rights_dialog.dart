import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/rights_status.dart';
import 'package:queue_management_system_client/domain/models/rights/add_rights_request.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';

import '../../../dimens.dart';
import '../../../domain/interactors/rights_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';

class AddRightsConfig extends BaseDialogConfig {
  final int locationId;

  AddRightsConfig({
    required this.locationId
  });
}

class AddRightsResult extends BaseDialogResult {
  final String email;

  AddRightsResult({
    required this.email,
  });
}

class AddRightsWidget extends BaseDialogWidget<AddRightsConfig> {

  const AddRightsWidget({
    super.key,
    required super.config
  });

  @override
  State<AddRightsWidget> createState() => _AddRightsState();
}

class _AddRightsState extends BaseDialogState<
    AddRightsWidget,
    AddRightsLogicState,
    AddRightsCubit
> {

  @override
  String getTitle(
      BuildContext context,
      AddRightsLogicState state,
      AddRightsWidget widget
  ) => getLocalizations(context).addingOfEmployee;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      AddRightsLogicState state,
      AddRightsWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).email,
        text: state.email,
        onTextChanged: getCubitInstance(context).setEmail
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).add,
        onClick: getCubitInstance(context).addRights
    ),
  ];

  @override
  AddRightsCubit getCubit() => statesAssembler.getAddRightsCubit(widget.config);
}

class AddRightsLogicState extends BaseDialogLogicState<
    AddRightsConfig,
    AddRightsResult
> {

  final String email;

  AddRightsLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.email,
  });

  @override
  AddRightsLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    AddRightsResult? result,
    String? email
  }) => AddRightsLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      email: email ?? this.email
  );
}

@injectable
class AddRightsCubit extends BaseDialogCubit<AddRightsLogicState> {

  final RightsInteractor _rightsInteractor;

  AddRightsCubit(
      this._rightsInteractor,
      @factoryParam AddRightsConfig config
  ) : super(
      AddRightsLogicState(
          config: config,
          email: ''
      )
  );

  void setEmail(String text) {
    emit(state.copy(email: text));
  }

  Future<void> addRights() async {
    showLoad();
    await _rightsInteractor.addRights(
        state.config.locationId,
        AddRightsRequest(
            email: state.email,
            status: RightsStatus.administrator
        )
    )
      ..onSuccess((result) {
        popResult(AddRightsResult(email: state.email));
      })..onError((result) {
        showError(result);
      });
  }
}