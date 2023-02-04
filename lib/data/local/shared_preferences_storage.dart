import 'package:injectable/injectable.dart';
import 'package:queue_management_system_client/domain/enums/kiosk_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/kiosk/kiosk_state.dart';

@lazySingleton
class SharedPreferencesStorage {
  static const _kioskStateModeIndex = 'KIOSK_STATE_MODE_INDEX';
  static const _kioskStateMultipleSelect = 'KIOSK_STATE_MULTIPLE_SELECT';

  Future<void> setKioskState({
    required KioskState kioskState
  }) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_kioskStateModeIndex, kioskState.kioskMode.index);
    prefs.setBool(_kioskStateMultipleSelect, kioskState.multipleSelect);
  }

  Future<KioskState?> getKioskState() async {
    final prefs = await SharedPreferences.getInstance();
    int? modeIndex = prefs.getInt(_kioskStateModeIndex);
    if (modeIndex == null) {
      return null;
    }
    bool? multipleSelect = prefs.getBool(_kioskStateMultipleSelect);
    if (multipleSelect == null) {
      return null;
    }
    KioskMode terminalMode = KioskMode.values[modeIndex];
    return KioskState(
        kioskMode: terminalMode,
        multipleSelect: multipleSelect
    );
  }

  Future<void> clearKioskState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kioskStateModeIndex);
    await prefs.remove(_kioskStateMultipleSelect);
  }
}