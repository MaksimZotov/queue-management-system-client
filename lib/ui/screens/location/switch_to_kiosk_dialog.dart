import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/kiosk_mode.dart';
import 'package:queue_management_system_client/ui/extensions/kiosk/kiosk_mode_extensions.dart';
import 'package:queue_management_system_client/ui/screens/base.dart';
import 'package:queue_management_system_client/ui/widgets/button_widget.dart';

import '../../../di/assemblers/states_assembler.dart';
import '../../../dimens.dart';
import '../../../domain/models/base/result.dart';
import '../../../domain/models/kiosk/kiosk_state.dart';
import '../../router/routes_config.dart';

class SwitchToKioskConfig extends BaseDialogConfig {
  final int locationId;

  SwitchToKioskConfig({
    required this.locationId,
  });
}

class SwitchToKioskResult extends BaseDialogResult {
  final KioskState kioskState;

  SwitchToKioskResult({
    required this.kioskState
  });
}

class SwitchToKioskWidget extends BaseDialogWidget<SwitchToKioskConfig> {

  const SwitchToKioskWidget({
    super.key,
    required super.config
  });

  @override
  State<SwitchToKioskWidget> createState() => _SwitchToKioskState();
}

class _SwitchToKioskState extends BaseDialogState<
    SwitchToKioskWidget,
    SwitchToKioskLogicState,
    SwitchToKioskCubit
> {


  @override
  String getTitle(
      BuildContext context,
      SwitchToKioskLogicState state,
      SwitchToKioskWidget widget
  ) => getLocalizations(context).switchingToKioskMode;

  @override
  List<Widget> getDialogContentWidget(
      BuildContext context,
      SwitchToKioskLogicState state,
      SwitchToKioskWidget widget
  ) {
    return [
      const SizedBox(height: Dimens.contentMargin),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
            getLocalizations(context).mode,
            style: const TextStyle(
                fontSize: Dimens.labelFontSize
            )
        ),
      ),
      const SizedBox(height: Dimens.fieldElementsMargin),
      DropdownButtonFormField2(
        buttonHighlightColor: Colors.transparent,
        buttonSplashColor: Colors.transparent,
        focusColor: Colors.transparent,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        isExpanded: true,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 30,
        buttonHeight: 60,
        buttonPadding: const EdgeInsets.only(right: 10),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        value: state.selectedMode,
          items: KioskMode.values
              .map((item) =>
                DropdownMenuItem<KioskMode>(
                  value: item,
                  child: Text(
                    item.getName(getLocalizations(context)),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                )
              )
              .toList(),
          onChanged: getCubitInstance(context).selectMode
      ),
      const SizedBox(height: Dimens.contentMargin * 2),
      Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(
                  getLocalizations(context).multipleSelect,
                  style: const TextStyle(
                      fontSize: 16
                  )
              )
          ),
          Transform.translate(
            offset: const Offset(10, 0),
            child: Switch(
              activeColor: Colors.teal,
              activeTrackColor: Colors.cyan,
              inactiveThumbColor: Colors.blueGrey.shade600,
              inactiveTrackColor: Colors.grey.shade400,
              splashRadius: 0,
              value: state.multipleSelect,
              onChanged: state.multipleSelectDisabled
                  ? null
                  : getCubitInstance(context).setMultipleSelect,
            ),
          ),
        ],
      ),
      const SizedBox(height: Dimens.contentMargin * 2),
      ButtonWidget(
          text: getLocalizations(context).switchButton,
          onClick: getCubitInstance(context).SwitchToKiosk
      )
    ];
  }

    @override
    SwitchToKioskCubit getCubit() =>
        statesAssembler.getSwitchToKioskCubit(widget.config);
}

class SwitchToKioskLogicState extends BaseDialogLogicState<
    SwitchToKioskConfig,
    SwitchToKioskResult
> {

  final String name;
  final String description;

  final KioskMode selectedMode;
  final bool multipleSelect;
  final bool multipleSelectDisabled;
  final bool? prevMultipleSelect;

  SwitchToKioskLogicState({
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
    required this.multipleSelectDisabled,
    this.prevMultipleSelect
  });

  @override
  SwitchToKioskLogicState copy({
    BaseConfig? nextConfig,
    ErrorResult? error,
    String? snackBar,
    bool? loading,
    SwitchToKioskResult? result,
    String? name,
    String? description,
    KioskMode? selectedMode,
    bool? multipleSelect,
    bool? multipleSelectDisabled,
    bool? prevMultipleSelect
  }) => SwitchToKioskLogicState(
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
      multipleSelectDisabled: multipleSelectDisabled ?? this.multipleSelectDisabled,
      prevMultipleSelect: prevMultipleSelect ?? this.prevMultipleSelect
  );
}

@injectable
class SwitchToKioskCubit extends BaseDialogCubit<SwitchToKioskLogicState> {

  SwitchToKioskCubit(
      @factoryParam SwitchToKioskConfig config
  ) : super(
      SwitchToKioskLogicState(
          config: config,
          name: '',
          description: '',
          selectedMode: KioskMode.all,
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

  void selectMode(KioskMode? mode) {
    bool multipleSelectDisabled = mode == KioskMode.servicesSequences;
    emit(
        state.copy(
            selectedMode: mode,
            multipleSelect: multipleSelectDisabled ? false : state.prevMultipleSelect,
            multipleSelectDisabled: multipleSelectDisabled,
            prevMultipleSelect: multipleSelectDisabled ? state.multipleSelect : null
        )
    );
  }

  void setMultipleSelect(bool multiple) {
    emit(
        state.copy(
            multipleSelect: multiple
        )
    );
  }

  Future<void> SwitchToKiosk() async {
    popResult(
        SwitchToKioskResult(
            kioskState: KioskState(
              kioskMode: state.selectedMode,
              multipleSelect: state.multipleSelect
            )
        )
    );
  }
}