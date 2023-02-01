import '../../../domain/enums/terminal_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension TerminalModeExtensions on TerminalMode {

  String getName(AppLocalizations localizations) {
    switch (this) {
      case TerminalMode.all:
        return localizations.allTypes;
      case TerminalMode.services:
        return localizations.services;
      case TerminalMode.servicesSequences:
        return localizations.servicesSequences;
      case TerminalMode.queueTypes:
        return localizations.queueTypes;
    }
  }
}