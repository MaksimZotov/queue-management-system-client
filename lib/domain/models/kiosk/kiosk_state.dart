import 'package:queue_management_system_client/domain/enums/kiosk_mode.dart';

class KioskState {
  final KioskMode kioskMode;
  final bool multipleSelect;

  KioskState({
    required this.kioskMode,
    required this.multipleSelect
  });
}