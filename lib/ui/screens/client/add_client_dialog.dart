import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/interactors/client_interactor.dart';
import 'package:queue_management_system_client/domain/models/client/create_client_request.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';

bool _checkAndroidAndNotWeb() {
  return true;//!kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

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
          ),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
      )
    ] : (
      (!_checkAndroidAndNotWeb() ? <Widget>[
        TextFieldWidget(
            label: getLocalizations(context).phone,
            text: state.phone,
            onTextChanged: getCubitInstance(context).setPhone
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

  final String phone;

  final bool clientAdded;
  final int ticketCode;

  AddClientLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.phone,
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
    String? phone,
    bool? clientAdded,
    int? ticketCode,
  }) => AddClientLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      phone: phone ?? this.phone,
      clientAdded: clientAdded ?? this.clientAdded,
      ticketCode: ticketCode ?? this.ticketCode
  );
}

@injectable
class AddClientCubit extends BaseDialogCubit<
    AddClientLogicState
> {

  final ClientInteractor _clientInteractor;

  AddClientCubit(
      this._clientInteractor,
      @factoryParam AddClientConfig config
  ) : super(
      AddClientLogicState(
          config: config,
          phone: '',
          clientAdded: false,
          ticketCode: -1
      )
  );

  void setPhone(String text) {
    emit(state.copy(phone: text));
  }

  Future<void> connect(String yourTicketNumberWithColon) async {
    showLoad();
    bool confirmationRequired = !_checkAndroidAndNotWeb();
    await _clientInteractor.createClientInLocation(
        state.config.locationId,
        CreateClientRequest(
            phone: confirmationRequired
                ? state.phone
                : null,
            serviceIds: state.config.serviceIds,
            servicesSequenceId: state.config.servicesSequenceId,
            confirmationRequired: confirmationRequired
        ),
        yourTicketNumberWithColon
    )
      ..onSuccess((result) async {
        int? code = result.data.code;
        if (code != null) {
          emit(state.copy(clientAdded: true, ticketCode: code));
          hideLoad();
        } else {
          popResult(AddClientResult());
        }
      })
      ..onError((result) {
        showError(result);
      });
  }
}