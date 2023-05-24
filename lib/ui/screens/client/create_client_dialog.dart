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
  return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

class CreateClientConfig extends BaseDialogConfig {
  final int locationId;
  final List<int>? serviceIds;
  final int? servicesSequenceId;

  CreateClientConfig({
    required this.locationId,
    this.serviceIds,
    this.servicesSequenceId
  });
}

class CreateClientResult extends BaseDialogResult {}


class CreateClientWidget extends BaseDialogWidget<
    CreateClientConfig
> {

  const CreateClientWidget({
    super.key,
    required super.config
  });

  @override
  State<CreateClientWidget> createState() => _CreateClientState();
}

class _CreateClientState extends BaseDialogState<
    CreateClientWidget,
    CreateClientLogicState,
    CreateClientCubit
> {

  @override
  String getTitle(
      BuildContext context,
      CreateClientLogicState state,
      CreateClientWidget widget
  ) => getLocalizations(context).connection;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      CreateClientLogicState state,
      CreateClientWidget widget
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
  ] : <Widget>[
    TextFieldWidget(
        label: getLocalizations(context).phone,
        text: state.phone,
        onTextChanged: getCubitInstance(context).setPhone
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).connect,
        onClick: () => getCubitInstance(context).connect(
            getLocalizations(context).yourTicketNumberWithColon
        )
    )
  ];

  @override
  CreateClientCubit getCubit() =>
      statesAssembler.getAddClientCubit(widget.config);
}

class CreateClientLogicState extends BaseDialogLogicState<
    CreateClientConfig,
    CreateClientResult
> {

  final String phone;

  final bool clientAdded;
  final int ticketCode;

  CreateClientLogicState({
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
  CreateClientLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    CreateClientResult? result,
    String? phone,
    bool? clientAdded,
    int? ticketCode,
  }) => CreateClientLogicState(
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
class CreateClientCubit extends BaseDialogCubit<
    CreateClientLogicState
> {

  final ClientInteractor _clientInteractor;

  CreateClientCubit(
      this._clientInteractor,
      @factoryParam CreateClientConfig config
  ) : super(
      CreateClientLogicState(
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
    bool notAndroid = !_checkAndroidAndNotWeb();
    bool confirmationRequired = notAndroid || state.phone.trim().isNotEmpty;
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
          popResult(CreateClientResult());
        }
      })
      ..onError((result) {
        showError(result);
      });
  }
}