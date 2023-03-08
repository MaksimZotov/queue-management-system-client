import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/add_client_request.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/account_interactor.dart';
import '../../../domain/models/account/confirm_model.dart';
import '../../../domain/models/account/login_model.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';

class AddClientConfig extends BaseDialogConfig {
  final int locationId;
  final List<int>? serviceIds;
  final int? servicesSequenceId;

  AddClientConfig({
    required this.locationId,
    this.serviceIds,
    this.servicesSequenceId
  });
}

class AddClientResult extends BaseDialogResult {}


class AddClientWidget extends BaseDialogWidget<
    AddClientConfig
> {

  const AddClientWidget({
    super.key,
    required super.config
  });

  @override
  State<AddClientWidget> createState() => _AddClientState();
}

class _AddClientState extends BaseDialogState<
    AddClientWidget,
    AddClientLogicState,
    AddClientCubit
> {

  @override
  String getTitle(
      BuildContext context,
      AddClientLogicState state,
      AddClientWidget widget
  ) => getLocalizations(context).connection;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      AddClientLogicState state,
      AddClientWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).email,
        text: state.email,
        onTextChanged: getCubitInstance(context).setEmail
    ),
    TextFieldWidget(
        label: getLocalizations(context).firstName,
        text: state.firstName,
        onTextChanged: getCubitInstance(context).setFirstName
    ),
    TextFieldWidget(
        label: getLocalizations(context).lastName,
        text: state.lastName,
        onTextChanged: getCubitInstance(context).setLastName
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).connect,
        onClick: getCubitInstance(context).connect
    )
  ];

  @override
  AddClientCubit getCubit() =>
      statesAssembler.getAddClientCubit(widget.config);
}

class AddClientLogicState extends BaseDialogLogicState<
    AddClientConfig,
    AddClientResult
> {

  final String email;
  final String firstName;
  final String lastName;

  AddClientLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.email,
    required this.firstName,
    required this.lastName
  });

  @override
  AddClientLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    AddClientResult? result,
    String? email,
    String? firstName,
    String? lastName
  }) => AddClientLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
  );
}

@injectable
class AddClientCubit extends BaseDialogCubit<
    AddClientLogicState
> {

  final LocationInteractor _locationInteractor;

  AddClientCubit(
      this._locationInteractor,
      @factoryParam AddClientConfig config
  ) : super(
      AddClientLogicState(
          config: config,
          email: '',
          firstName: '',
          lastName: ''
      )
  );

  void setEmail(String text) {
    emit(state.copy(email: text));
  }

  void setFirstName(String text) {
    emit(state.copy(firstName: text));
  }

  void setLastName(String text) {
    emit(state.copy(lastName: text));
  }

  Future<void> connect() async {
    showLoad();
    await _locationInteractor.addClientInLocation(
        state.config.locationId,
        AddClientRequest(
            email: state.email,
            firstName: state.firstName,
            lastName: state.lastName,
            serviceIds: state.config.serviceIds,
            servicesSequenceId: state.config.servicesSequenceId
        )
    )
      ..onSuccess((result) async {
        popResult(AddClientResult());
      })
      ..onError((result) {
        showError(result);
      });
  }
}