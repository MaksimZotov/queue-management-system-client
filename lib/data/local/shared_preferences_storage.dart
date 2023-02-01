import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/terminal_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/terminal/terminal_state.dart';

@lazySingleton
class SharedPreferencesStorage {
  static const _terminalStateModeIndex = 'TERMINAL_STATE_MODE_INDEX';
  static const _terminalStateMultipleSelect = 'TERMINAL_STATE_MULTIPLE_SELECT';

  Future<void> setTerminalState({
    required TerminalState terminalState
  }) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_terminalStateModeIndex, terminalState.terminalMode.index);
    prefs.setBool(_terminalStateMultipleSelect, terminalState.multipleSelect);
  }

  Future<TerminalState?> getTerminalState() async {
    final prefs = await SharedPreferences.getInstance();
    int? modeIndex = prefs.getInt(_terminalStateModeIndex);
    if (modeIndex == null) {
      return null;
    }
    bool? multipleSelect = prefs.getBool(_terminalStateMultipleSelect);
    if (multipleSelect == null) {
      return null;
    }
    TerminalMode terminalMode = TerminalMode.values[modeIndex];
    return TerminalState(
        terminalMode: terminalMode,
        multipleSelect: multipleSelect
    );
  }

  Future<void> clearTerminalState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_terminalStateModeIndex);
    await prefs.remove(_terminalStateMultipleSelect);
  }
}