import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/terminal_mode.dart';
import 'package:queue_management_system_client/domain/models/queue/create_queue_request.dart';
import 'package:queue_management_system_client/domain/models/terminal/terminal_state.dart';
import 'package:queue_management_system_client/ui/extensions/terminal/terminal_mode_extensions.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';
import 'package:queue_management_system_client/ui/widgets/text_field_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/interactors/location_interactor.dart';
import '../../../domain/interactors/queue_interactor.dart';
import '../../../domain/interactors/terminal_interactor.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/location/queue_type_model.dart';
import '../../../domain/models/queue/queue_model.dart';
import '../../router/routes_config.dart';
import '../../widgets/queue_type_item_widget.dart';

class SwitchToTerminalModeConfig extends BaseDialogConfig {
  final int locationId;

  SwitchToTerminalModeConfig({
    required this.locationId,
  });
}

class SwitchToTerminalModeResult extends BaseDialogResult {
  final TerminalState terminalState;

  SwitchToTerminalModeResult({
    required this.terminalState
  });
}

class SwitchToTerminalModeWidget extends BaseDialogWidget<SwitchToTerminalModeConfig> {

  const SwitchToTerminalModeWidget({
    super.key,
    required super.config
  });

  @override
  State<SwitchToTerminalModeWidget> createState() => _SwitchToTerminalModeState();
}

class _SwitchToTerminalModeState extends BaseDialogState<
    SwitchToTerminalModeWidget,
    SwitchToTerminalModeLogicState,
    SwitchToTerminalModeCubit
> {


  @override
  String getTitle(
      BuildContext context,
      SwitchToTerminalModeLogicState state,
      SwitchToTerminalModeWidget widget
  ) => getLocalizations(context).creationOfQueue;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      SwitchToTerminalModeLogicState state,
      SwitchToTerminalModeWidget widget
  ) {
    return [
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
      DropdownButtonFormField2(
        buttonOverlayColor: null,
        barrierColor: Colors.transparent,
        buttonHighlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        buttonSplashColor: Colors.transparent,
        decoration: InputDecoration(
          hoverColor: Colors.yellow,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        isExpanded: true,
        value: state.selectedMode,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 30,
        buttonHeight: 60,
        buttonPadding: const EdgeInsets.only(left: 20, right: 10),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        items: TerminalMode.values
            .map((item) =>
            DropdownMenuItem<TerminalMode>(
              value: item,
              child: Text(
                item.getName(getLocalizations(context)),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ))
            .toList(),
        onChanged: getCubitInstance(context).selectMode,
      ),
      const SizedBox(height: Dimens.contentMargin),
      ButtonWidget(
          text: getLocalizations(context).create,
          onClick: getCubitInstance(context).switchToTerminalMode
      )
    ];
  }

    @override
    SwitchToTerminalModeCubit getCubit() =>
        statesAssembler.getSwitchToTerminalModeCubit(widget.config);
}

class SwitchToTerminalModeLogicState extends BaseDialogLogicState<
    SwitchToTerminalModeConfig,
    SwitchToTerminalModeResult
> {

  final String name;
  final String description;

  final TerminalMode selectedMode;
  final bool multipleSelect;
  final bool multipleSelectDisabled;

  SwitchToTerminalModeLogicState({
    super.nextConfig,
    super.error,
    super.snackBar,
    super.loading,
    required super.config,
    super.result,
    required this.name,
    required this.description,
    required this.selectedMode,
    required this.multipleSelect,
    required this.multipleSelectDisabled
  });

  @override
  SwitchToTerminalModeLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    SwitchToTerminalModeResult? result,
    String? name,
    String? description,
    TerminalMode? selectedMode,
    bool? multipleSelect,
    bool? multipleSelectDisabled
  }) => SwitchToTerminalModeLogicState(
      nextConfig: nextConfig,
      error: error,
      snackBar: snackBar,
      loading: loading ?? this.loading,
      config: config,
      result: result,
      name: name ?? this.name,
      description: description ?? this.description,
      selectedMode: selectedMode ?? this.selectedMode,
      multipleSelect: multipleSelect ?? this.multipleSelect,
      multipleSelectDisabled: multipleSelectDisabled ?? this.multipleSelectDisabled
  );
}

@injectable
class SwitchToTerminalModeCubit extends BaseDialogCubit<SwitchToTerminalModeLogicState> {

  SwitchToTerminalModeCubit(
      @factoryParam SwitchToTerminalModeConfig config
  ) : super(
      SwitchToTerminalModeLogicState(
          config: config,
          name: '',
          description: '',
          selectedMode: TerminalMode.all,
          multipleSelect: true,
          multipleSelectDisabled: false
      )
  );

  void setName(String text) {
    emit(state.copy(name: text));
  }

  void setDescription(String text) {
    emit(state.copy(description: text));
  }

  void selectMode(TerminalMode? mode) {
    emit(
        state.copy(
            selectedMode: mode
        )
    );
  }

  Future<void> switchToTerminalMode() async {
    popResult(
        SwitchToTerminalModeResult(
            terminalState: TerminalState(
              terminalMode: state.selectedMode,
              multipleSelect: state.multipleSelect
            )
        )
    );
  }
}