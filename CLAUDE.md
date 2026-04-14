# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This App Is

Seedaily is a French-language Bible reading plan generator for Android/iOS/Web. Users pick from 11+ plan templates (M'Cheyne, Ligue, Horner, canonical, chronological, etc.), customize reading days and content scope, then track daily progress. Plans are stored locally with PDF export and daily push notifications.

## Commands

```bash
# Install dependencies
flutter pub get
cd ios && pod install && cd ..

# Run
flutter run           # debug
flutter run --release

# Test & lint
flutter test
flutter test test/plan_generation_mvp_test.dart  # run single test file
flutter analyze
dart format .

# Build
flutter build appbundle --release   # Android
flutter build ios --release          # iOS
flutter build web --release

# Asset generation (after changing icons/splash config)
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Architecture

**State management:** Provider with ChangeNotifier. Two providers:
- `PlansProvider` (`lib/providers/plans_provider.dart`) — owns all plan CRUD, progress tracking, streak calculation
- `SettingsProvider` (`lib/providers/settings_provider.dart`) — app-wide prefs (theme, notifications)

**Navigation:** GoRouter with routes: `/`, `/plan/:id`, `/customize-plan/:id`, `/edit-plan/:id`, `/about`. Tabs on the home shell use `IndexedStack` so all 3 tabs (Home/Discover/Settings) stay built simultaneously.

**Storage:** Hive key-value store with manual JSON serialization (`toJson`/`fromJson`). No network calls — the app is entirely local. Bible data (66 canonical + 7 deuterocanonical books with verse counts) is embedded in `lib/domain/bible_data.dart`. `fromJson()` handles backward-compatible schema migrations (e.g., `OutputOptions` → `DisplayOptions`).

**Plan generation core** (`lib/services/plan_generator.dart`): Distributes passages across reading days using a weighted verse-count algorithm. Supports balanced, front-loaded, and back-loaded distribution strategies.

**Key domain models** (`lib/domain/`): `GeneratedPlan`, `ReadingDay`, `Passage`, plus enums for all plan options.

**Services:**
- `StorageService` — Hive read/write
- `ExportService` — Dart-native PDF generation with genre-based color coding (Law=brown, History=blue, Wisdom=purple, Prophets=orange, NT=green)
- `NotificationService` — timezone-aware daily notifications via `flutter_local_notifications`
- `AnalyticsService` (`lib/services/analytics_service.dart`) — singleton wrapping Firebase Analytics. **Toujours passer par ce wrapper**, jamais appeler `FirebaseAnalytics.instance` directement ailleurs dans le code.

**Firebase (Analytics + Crashlytics):**
- `google-services.json` dans `android/app/` — ne pas committer si sensible
- Initialisation dans `main.dart` : `Firebase.initializeApp()` + `FlutterError.onError` + `runZonedGuarded` pour capturer tous les crashes
- Analytics collecte automatiquement : sessions, `first_open`, `screen_view`, appareils, OS
- Events custom trackés : `plan_created`, `plan_deleted`, `plan_completed`, `day_completed`, `day_unchecked`, `plan_exported`, `notifications_toggled`, `theme_changed`
- Pour tester les events en temps réel : `adb shell setprop debug.firebase.analytics.app com.seedaily.app` puis Firebase Console → DebugView

**Theme:** Material 3, gold/navy/light palette, Lexend font. Defined in `lib/core/theme.dart`. Supports light / dark / system modes via `SettingsProvider.themeMode` → `MaterialApp.router(themeMode: ...)`.

## Colors — règle absolue

**Ne jamais utiliser les constantes `AppTheme.*` comme couleurs de rendu dans les widgets.** Ces constantes sont figées et cassent le mode sombre.

Toujours utiliser `Theme.of(context).colorScheme.*` dans les `build()` :

| Besoin | Valeur à utiliser |
|---|---|
| Fond de scaffold | rien (le theme le gère) ou `colorScheme.surfaceContainerLowest` |
| Surface d'une carte / container | `colorScheme.surface` |
| Texte principal | `colorScheme.onSurface` |
| Texte secondaire / muet | `colorScheme.onSurface.withValues(alpha: 0.6)` |
| Bordure / séparateur | `colorScheme.outline` |
| Icône inactive / nav bar | `colorScheme.onSurface.withValues(alpha: 0.6)` |
| Couleur primaire (or) | `AppTheme.seedGold` (invariante, OK) |
| Gradient décoratif fixe | `AppTheme.deepNavy` (OK, élément purement visuel) |

**Règle `const` :** `Theme.of(context)` ne peut jamais être dans un contexte `const`. Retirer le `const` du widget parent si nécessaire.

**Règle `context` :** `Theme.of(context)` n'est disponible que dans `build(BuildContext context)`. Pour les méthodes helper d'un `StatelessWidget`, passer `BuildContext context` en paramètre.

**Localization:** French-only (`Locale('fr', 'FR')` hardcoded). All user-facing strings are in French.
