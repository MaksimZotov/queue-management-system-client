import '../../../domain/enums/kiosk_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension KioskModeExtensions on KioskMode {

  String getName(AppLocalizations localizations) {
    switch (this) {
      case KioskMode.all:
        return localizations.allTypes;
      case KioskMode.services:
        return localizations.services;
      case KioskMode.sequences:
        return localizations.servicesSequences;
      case KioskMode.specialists:
        return localizations.specialists;
    }
  }
}