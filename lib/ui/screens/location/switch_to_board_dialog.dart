import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../../widgets/text_field_widget.dart';
import '../base.dart';

class SwitchToBoardConfig extends BaseDialogConfig {}

class SwitchToBoardResult extends BaseDialogResult {
  final int columnsAmount;
  final int rowsAmount;
  final int switchFrequency;

  SwitchToBoardResult({
    required this.columnsAmount,
    required this.rowsAmount,
    required this.switchFrequency
  });
}

class SwitchToBoardWidget extends BaseDialogWidget<SwitchToBoardConfig> {

  const SwitchToBoardWidget({
    super.key,
    required super.config
  });

  @override
  State<SwitchToBoardWidget> createState() => _SwitchToBoardState();
}

class _SwitchToBoardState extends BaseDialogState<
    SwitchToBoardWidget,
    SwitchToBoardLogicState,
    SwitchToBoardCubit
> {

  @override
  String getTitle(
      BuildContext context,
      SwitchToBoardLogicState state,
      SwitchToBoardWidget widget
  ) => getLocalizations(context).switchToBoardModeQuestion;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      SwitchToBoardLogicState state,
      SwitchToBoardWidget widget
  ) => [
    TextFieldWidget(
        label: getLocalizations(context).columnsAmount,
        text: state.columnsAmount,
        onTextChanged: getCubitInstance(context).setColumnsAmount
    ),
    TextFieldWidget(
        label: getLocalizations(context).rowsAmount,
        text: state.rowsAmount,
        onTextChanged: getCubitInstance(context).setRowsAmount
    ),
    TextFieldWidget(
        label: getLocalizations(context).switchFrequency,
        text: state.switchFrequency,
        onTextChanged: getCubitInstance(context).setSwitchFrequency
    ),
    const SizedBox(height: Dimens.contentMargin),
    ButtonWidget(
        text: getLocalizations(context).switchVerb,
        onClick: () => getCubitInstance(context).switchToBoard(
            getLocalizations(context).maxColumnsAmountMustBeNonNegativeNumber,
            getLocalizations(context).maxRowsAmountMustBeNonNegativeNumber,
            getLocalizations(context).switchFrequencyMustBeNonNegativeNumber
        )
    )
  ];

  @override
  SwitchToBoardCubit getCubit() =>
      statesAssembler.getSwitchToBoardCubit(widget.config);
}

class SwitchToBoardLogicState extends BaseDialogLogicState<
    SwitchToBoardConfig,
    SwitchToBoardResult
> {

  final String columnsAmount;
  final String rowsAmount;
  final String switchFrequency;

  SwitchToBoardLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    required super.config,
    super.result,
    super.loading,
    required this.columnsAmount,
    required this.rowsAmount,
    required this.switchFrequency
  });

  @override
  SwitchToBoardLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    String? columnsAmount,
    String? rowsAmount,
    String? switchFrequency,
    SwitchToBoardResult? result
  }) => SwitchToBoardLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      columnsAmount: columnsAmount ?? this.columnsAmount,
      rowsAmount: rowsAmount ?? this.rowsAmount,
      switchFrequency: switchFrequency ?? this.switchFrequency,
      result: result
  );
}

@injectable
class SwitchToBoardCubit extends BaseDialogCubit<SwitchToBoardLogicState> {

  SwitchToBoardCubit(
      @factoryParam SwitchToBoardConfig config
  ) : super(
      SwitchToBoardLogicState(
        config: config,
          columnsAmount: '5',
          rowsAmount: '5',
          switchFrequency: '5'
      )
  );

  void setColumnsAmount(String text) {
    emit(state.copy(columnsAmount: text));
  }

  void setRowsAmount(String text) {
    emit(state.copy(rowsAmount: text));
  }

  void setSwitchFrequency(String text) {
    emit(state.copy(switchFrequency: text));
  }

  void switchToBoard(
      String parseColumnsAmountErrorMessage,
      String parseRowsAmountErrorMessage,
      String parseSwitchFrequencyErrorMessage
  ) {
    int? columnsAmount = int.tryParse(state.columnsAmount);
    if (columnsAmount == null || columnsAmount < 0) {
      showSnackBar(parseColumnsAmountErrorMessage);
      return;
    }
    int? rowsAmount = int.tryParse(state.rowsAmount);
    if (rowsAmount == null || rowsAmount < 0) {
      showSnackBar(parseRowsAmountErrorMessage);
      return;
    }
    int? switchFrequency = int.tryParse(state.switchFrequency);
    if (switchFrequency == null || switchFrequency < 0) {
      showSnackBar(parseSwitchFrequencyErrorMessage);
      return;
    }
    popResult(
        SwitchToBoardResult(
          columnsAmount: columnsAmount,
          rowsAmount: rowsAmount,
          switchFrequency: switchFrequency
        )
    );
  }
}