import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../domain/models/base/result.dart';
import '../../router/routes_config.dart';
import '../base.dart';

class SwitchToBoardConfig extends BaseDialogConfig {}
class SwitchToBoardResult extends BaseDialogResult {}

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
    ButtonWidget(
        text: getLocalizations(context).yes,
        onClick: getCubitInstance(context).switchToBoard
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

  SwitchToBoardLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    required super.config,
    super.result,
    super.loading,
  });

  @override
  SwitchToBoardLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    SwitchToBoardResult? result
  }) => SwitchToBoardLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
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
      )
  );

  void switchToBoard() {
    popResult(SwitchToBoardResult());
  }
}