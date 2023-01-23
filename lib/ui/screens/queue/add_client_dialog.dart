import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/queue_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/queue/add_client_info.dart';
import '../../router/routes_config.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AddClientConfig extends BaseDialogConfig {
  final int queueId;
  final String queueName;

  AddClientConfig({
      required this.queueId,
      required this.queueName
  });
}

class AddClientResult extends BaseDialogResult {}

class AddClientWidget extends BaseDialogWidget<AddClientConfig> {

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
  ) => getLocalizations(context).connectionOfClientToQueue;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      AddClientLogicState state,
      AddClientWidget widget
  ) => [
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
        text: getLocalizations(context).add,
        onClick: () => getCubitInstance(context).addClient(false)
    ),
    ButtonWidget(
        text: getLocalizations(context).addAndSave,
        onClick: () => getCubitInstance(context).addClient(true)
    )
  ];

  @override
  AddClientCubit getCubit() => statesAssembler.getAddClientCubit(widget.config);
}

class AddClientLogicState extends BaseDialogLogicState<
    AddClientConfig,
    AddClientResult
> {

  final String firstName;
  final String lastName;

  AddClientLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.firstName,
    required this.lastName
  });

  AddClientLogicState copyWith({
    String? email,
    String? firstName,
    String? lastName,
  }) => AddClientLogicState(
    nextConfig: nextConfig,
    error: error,
    snackBar: snackBar,
    loading: loading,
    config: config,
    result: result,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
  );

  @override
  AddClientLogicState copyBase({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    AddClientResult? result
  }) => AddClientLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      firstName: firstName,
      lastName: lastName
  );
}

@injectable
class AddClientCubit extends BaseDialogCubit<AddClientLogicState> {

  final QueueInteractor _queueInteractor;

  AddClientCubit(
      this._queueInteractor,
      @factoryParam AddClientConfig config
  ) : super(
      AddClientLogicState(
          config: config,
          firstName: '',
          lastName: ''
      )
  );

  void setEmail(String text) {
    emit(state.copyWith(email: text));
  }

  void setFirstName(String text) {
    emit(state.copyWith(firstName: text));
  }

  void setLastName(String text) {
    emit(state.copyWith(lastName: text));
  }

  Future<void> addClient(bool save) async {
    await _queueInteractor.addClientToQueue(
        state.config.queueId,
        AddClientInfo(
            firstName: state.firstName,
            lastName: state.lastName
        )
    )
      ..onSuccess((result) async {
        if (save) {
          await downloadClientState(
              state.config.queueName,
              result.data.publicCode.toString(),
              state.firstName,
              state.lastName,
              result.data.accessKey
          );
          popResult(AddClientResult());
        }
      })
      ..onError((result) {
        showError(result);
      });
  }

  Future<void> downloadClientState(
      String queueName,
      String publicKey,
      String firstName,
      String lastName,
      String accessKey
  ) async {
    final pdf = pw.Document();
    final font = await rootBundle.load("fonts/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
        pw.Page(
            pageFormat: const PdfPageFormat(
                60 * PdfPageFormat.mm, 58 * PdfPageFormat.mm
            ),
            build: (pw.Context context) {
              return pw.Center(
                  child: pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                                queueName,
                                style: pw.TextStyle(font: ttf, fontSize: 18)
                            ),
                            pw.Text(
                                publicKey,
                                style: pw.TextStyle(font: ttf, fontSize: 18)
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                                '$firstName $lastName',
                                style: pw.TextStyle(font: ttf, fontSize: 18)
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                                accessKey,
                                style: pw.TextStyle(font: ttf, fontSize: 18)
                            )
                          ]
                      )
                  )
              );
            }
        )
    );
  }
}