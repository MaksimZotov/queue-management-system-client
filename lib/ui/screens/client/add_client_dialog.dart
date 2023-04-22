import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/location_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/add_client_request.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
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
  ) => state.clientAdded ? <Widget>[
      Text(
          getLocalizations(context).yourTicketNumberWithColonPattern(
              state.ticketCode
          )
      ),
      const SizedBox(height: Dimens.contentMargin),
      ButtonWidget(
          text: getLocalizations(context).close,
          onClick: () => Navigator.of(context).pop()
      )
    ] : (
      (defaultTargetPlatform != TargetPlatform.android ? <Widget>[
        TextFieldWidget(
            label: getLocalizations(context).email,
            text: state.email,
            onTextChanged: getCubitInstance(context).setEmail
        )
      ] : <Widget>[]) + <Widget>[
        const SizedBox(height: Dimens.contentMargin),
        ButtonWidget(
            text: getLocalizations(context).connect,
            onClick: () => getCubitInstance(context).connect(
                getLocalizations(context).yourTicketNumberWithColon
            )
        )
      ]
  );

  @override
  AddClientCubit getCubit() =>
      statesAssembler.getAddClientCubit(widget.config);
}

class AddClientLogicState extends BaseDialogLogicState<
    AddClientConfig,
    AddClientResult
> {

  final String email;

  final bool clientAdded;
  final int ticketCode;

  AddClientLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.email,
    required this.clientAdded,
    required this.ticketCode
  });

  @override
  AddClientLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    AddClientResult? result,
    String? email,
    bool? clientAdded,
    int? ticketCode,
  }) => AddClientLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      email: email ?? this.email,
      clientAdded: clientAdded ?? this.clientAdded,
      ticketCode: ticketCode ?? this.ticketCode
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
          clientAdded: false,
          ticketCode: -1
      )
  );

  void setEmail(String text) {
    emit(state.copy(email: text));
  }

  Future<void> connect(String yourTicketNumberWithColon) async {
    showLoad();
    await _locationInteractor.addClientInLocation(
        state.config.locationId,
        AddClientRequest(
            email: state.email,
            serviceIds: state.config.serviceIds,
            servicesSequenceId: state.config.servicesSequenceId,
            confirmationRequired: defaultTargetPlatform != TargetPlatform.android
        ),
        yourTicketNumberWithColon
    )
      ..onSuccess((result) async {
        int? code = result.data.code;
        if (code != null) {
          emit(state.copy(clientAdded: true, ticketCode: code));
        } else {
          popResult(AddClientResult());
        }
      })
      ..onError((result) {
        showError(result);
      });
  }
}