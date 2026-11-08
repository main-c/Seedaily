import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Choix de langue stocké dans Hive (`settings` / `app_language`).
const String kLanguageAuto = 'auto';

/// `fr*` → français, toute autre langue → anglais.
/// [override] = langue choisie dans les réglages (null = automatique).
Locale resolveAppLocale(Locale? override, List<Locale> deviceLocales) {
  final locale =
      override ?? (deviceLocales.isEmpty ? null : deviceLocales.first);
  return locale?.languageCode == 'fr' ? const Locale('fr') : const Locale('en');
}

/// 'auto' | 'fr' | 'en' → override passé à [resolveAppLocale].
Locale? languageOverride(String language) =>
    language == kLanguageAuto ? null : Locale(language);

Locale _current = const Locale('fr');

/// Langue résolue de l'app, utilisable hors BuildContext
/// (notifications, widget, export PDF, générateur de plans).
Locale get currentAppLocale => _current;
bool get isEnglishLocale => _current.languageCode == 'en';
AppLocalizations get appL10n => lookupAppLocalizations(_current);

/// Applique la langue résolue : services sans context + DateFormat par défaut.
void applyAppLocale(Locale locale) {
  _current = locale;
  Intl.defaultLocale = locale.languageCode == 'fr' ? 'fr_FR' : 'en_US';
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
