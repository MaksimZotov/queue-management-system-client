import '../models/kiosk/kiosk_state.dart';

abstract class KioskInteractor {
  Future<void> setKioskState(KioskState kioskState);
  Future<KioskState?> getKioskState();
  Future<void> clearKioskState();
}