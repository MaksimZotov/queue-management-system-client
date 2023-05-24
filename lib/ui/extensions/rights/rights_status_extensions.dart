import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../domain/enums/rights_status.dart';

extension RightsStatusExtensions on RightsStatus {

  String getName(AppLocalizations localizations) {
    switch (this) {
      case RightsStatus.employee:
        return localizations.employee;
      case RightsStatus.administrator:
        return localizations.administrator;
    }
  }
}