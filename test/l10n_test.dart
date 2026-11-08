import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seedaily/domain/bible_data.dart';
import 'package:seedaily/domain/models.dart';
import 'package:seedaily/l10n/l10n.dart';

void main() {
  tearDown(() => applyAppLocale(const Locale('fr')));

  group('resolveAppLocale', () {
    test('appareil fr_CA → fr', () {
      expect(resolveAppLocale(null, const [Locale('fr', 'CA')]),
          const Locale('fr'));
    });

    test('appareil de_DE → en', () {
      expect(resolveAppLocale(null, const [Locale('de', 'DE')]),
          const Locale('en'));
    });

    test('appareil en_US → en', () {
      expect(resolveAppLocale(null, const [Locale('en', 'US')]),
          const Locale('en'));
    });

    test('aucune langue appareil → en', () {
      expect(resolveAppLocale(null, const []), const Locale('en'));
    });

    test('le choix des réglages prime sur l\'appareil', () {
      expect(
          resolveAppLocale(languageOverride('en'), const [Locale('fr', 'FR')]),
          const Locale('en'));
      expect(
          resolveAppLocale(languageOverride('fr'), const [Locale('de', 'DE')]),
          const Locale('fr'));
      expect(languageOverride(kLanguageAuto), isNull);
    });
  });

  test('textes hors context et noms de livres suivent la langue', () {
    applyAppLocale(const Locale('fr'));
    expect(appL10n.dayCount(3), '3 jours');
    expect(BibleData.displayName('Genèse'), 'Genèse');
    expect(
        Passage(book: 'Cantique des cantiques', fromChapter: 1, toChapter: 2)
            .reference,
        'Cantique des cantiques 1-2');

    applyAppLocale(const Locale('en'));
    expect(appL10n.dayCount(1), '1 day');
    expect(appL10n.dayCount(3), '3 days');
    expect(BibleData.displayName('Genèse'), 'Genesis');
    expect(BibleData.displayName('Siracide'), 'Sirach');
    expect(
        Passage(book: 'Cantique des cantiques', fromChapter: 1, toChapter: 2)
            .reference,
        'Song of Solomon 1-2');
    expect(Passage.abbreviateBookName('Matthieu'), 'Matt');
  });

  for (final (locale, expected) in [
    (const Locale('fr'), 'Réglages'),
    (const Locale('en'), 'Settings'),
  ]) {
    testWidgets('une clé rendue en ${locale.languageCode}', (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(builder: (context) => Text(context.l10n.settingsTitle)),
      ));
      expect(find.text(expected), findsOneWidget);
    });
  }
}
