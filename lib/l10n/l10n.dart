import 'package:flutter/material.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Translates a dish label key (stored in English in Firestore) to the
  /// current locale's display name.
  String localizeLabel(String label) {
    final loc = l10n;
    return switch (label) {
      'Breakfast' => loc.labelBreakfast,
      'Lunch' => loc.labelLunch,
      'Dinner' => loc.labelDinner,
      _ => label,
    };
  }

  /// Returns the localized 3-letter abbreviation for a weekday (1 = Mon … 7 = Sun).
  String dayAbbr(int weekday) {
    final loc = l10n;
    return switch (weekday) {
      1 => loc.monTab,
      2 => loc.tueTab,
      3 => loc.wedTab,
      4 => loc.thuTab,
      5 => loc.friTab,
      6 => loc.satTab,
      7 => loc.sunTab,
      _ => '?',
    };
  }
}
