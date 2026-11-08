# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This App Is

Seedaily is a French-language Bible reading plan generator for Android/iOS/Web (Flutter). Users pick a plan template, customize it, then track daily progress. Plans live locally (Hive). On top of that, optional online features use Firebase: Google sign-in, shared reading groups (Firestore + Cloud Functions + FCM), and a Bible reader whose versions are downloaded from Firebase Storage.

The repo also contains:
- `functions/` — Firebase Cloud Functions (TypeScript, Node 24) for group push notifications
- `landing/` — static marketing site (Vercel), including `join.html` for group invite links
- `scripts/prepare_bibles.py` — builds the Bible version zips uploaded to Firebase Storage
- `firestore.rules` — Firestore security rules (deployed via `firebase.json`)

## Commands

```bash
# Flutter app
flutter pub get
cd ios && pod install && cd ..
flutter run                     # debug
flutter test
flutter test test/plan_generation_mvp_test.dart   # single test file
flutter test --plain-name "<test name>"           # single test
flutter analyze
dart format .

flutter build appbundle --release   # Android
flutter build ios --release
flutter build web --release

# After changing icon/splash config
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# Cloud Functions (from functions/)
npm run lint
npm run build
npm run serve                   # local emulator
firebase deploy --only functions          # predeploy runs lint + build
firebase deploy --only firestore:rules
npm run test:rules              # from functions/, Firestore rules tests (emulator, needs Java 21+)

# Bible data (sources expected in scripts/truth_*/FR-Français/*.sqlite)
python3 scripts/prepare_bibles.py         # outputs scripts/dist/<id>.zip
```

## Architecture

**Startup (`lib/main.dart`):** `runZonedGuarded` → Firebase init → App Check (debug provider in debug, Play Integrity in release) → Crashlytics hooks → Hive init → local notifications → home widget → Remote Config update check (`UpdateGateService`, compares `min_version`/`soft_version` to the app version and shows a force/soft update dialog). The native splash is held until all of this finishes.

**State (Provider + ChangeNotifier), wired in `main.dart`:**
- `AuthProvider` — Firebase Auth (Google sign-in only). Signing in upserts `users/{uid}` and stores the FCM token.
- `PlansProvider` — plan CRUD, progress, streaks. It is a `ChangeNotifierProxyProvider` of `AuthProvider`: once signed in it receives `GroupsService` + user id, so toggling a day on a **group plan** (`plan.groupId != null`) also writes to Firestore.
- `GroupsProvider` — proxy of `AuthProvider`; subscribes to the user's groups via a `collectionGroup('members')` query, cleared on sign-out.
- `SettingsProvider` — theme mode, notifications.
- `BibleReaderProvider` — downloaded versions, selected version, font size.

**Navigation:** GoRouter. Main shell (`/`, tab chosen with `?tab=N`) uses an `IndexedStack`, so all tabs stay built. Other routes: `/plan/:id`, `/customize-plan/:templateId`, `/edit-plan/:planId` (same `CustomizePlanScreen`), `/about`, `/bible-library`, `/groups/create`, `/groups/join`, `/group/:id`, and the deep link `/join/:code` (`seedaily://app/join/CODE`).

**Local storage:** Hive boxes `reading_plans` and `settings`, with manual `toJson`/`fromJson`. `fromJson()` handles backward-compatible schema migrations (e.g. `OutputOptions` → `DisplayOptions`), so keep old keys readable when changing models.

**Plan generation (`lib/services/plan_generator.dart`):** distributes passages across reading days by verse-count weighting (balanced / front-loaded / back-loaded). Structured plans come from fixed data files in `lib/domain/` (`mcheyne_plan_data.dart`, `ligue_plan_data.dart`, `horner_plan_data.dart`, `revolutionary_plan_data.dart`). Book metadata and verse counts (66 canonical + 7 deuterocanonical) are in `bible_data.dart`. Editing a plan regenerates it and restores completion by **date**.

**Reading groups:**
- Firestore layout: `groups/{groupId}` (host-owned, holds `inviteCode`, `planMeta`, `planSnapshot`), with subcollections `members/{uid}` and `progress/{progressId}`.
- The host's plan is serialized into a day-by-day snapshot (`PlanSnapshotService.fromPlan`, capped at 365 days because Horner is infinite). Members rebuild an identical local `GeneratedPlan` from the snapshot (`toPlan`). They don't regenerate it.
- Invite codes are generated client-side (6 uppercase chars). `inviteCodes/{code}` → `{groupId}` is the only way to find a group by code: groups can't be listed, a group is readable only by its members, and joining requires the member doc to carry the right `inviteCode` (checked by the rules).
- Cloud Functions (`functions/src/index.ts`) send FCM pushes on group creation, member join, and progress creation, plus a daily scheduled reminder (19:00 UTC).
- Changing what the client writes usually means updating `firestore.rules` too.

**Bible reader:** `BibleReaderService` (singleton) downloads `bibles/<id>/<id>.zip` from Firebase Storage, extracts it in an isolate to `<appDocs>/bibles/<id>/` (one JSON file per book, `{book, chapters: [[verses]]}`), and writes a `.complete` marker. Chapters are kept in an in-memory LRU cache (30 entries). Versions (public domain only): `lsg`, `martin`, `ostervald`, `epee`, defined in `lib/domain/bible_reader_models.dart`. Never add copyrighted versions (NEG, TOB, Semeur, BFC).

**Other services:** `ExportService` (Dart-native PDF, colored by genre: Law=brown, History=blue, Wisdom=purple, Prophets=orange, NT=green), `NotificationService` (timezone-aware local notifications with action buttons handled in `main.dart`), `WidgetService` (Android home-screen widget `SeedailyWidget` via `home_widget`, refreshed from `PlansProvider`).

**Analytics:** `AnalyticsService` (`lib/services/analytics_service.dart`) is a singleton wrapping Firebase Analytics. **Toujours passer par ce wrapper**, jamais appeler `FirebaseAnalytics.instance` directement ailleurs. Custom events: `plan_created`, `plan_deleted`, `plan_completed`, `day_completed`, `day_unchecked`, `plan_exported`, `notifications_toggled`, `theme_changed`. Live debugging: `adb shell setprop debug.firebase.analytics.app com.seedaily.app`, then Firebase Console → DebugView.

**Gotcha:** `lib/ui/widgets/plan_detail_screen.dart` is an older file that nothing imports. The live screen is `lib/ui/screens/plan_detail_screen.dart`.

## Colors — règle absolue

**Ne jamais utiliser les constantes `AppTheme.*` comme couleurs de rendu dans les widgets.** Ces constantes sont figées et cassent le mode sombre. Theme: Material 3, Lexend, defined in `lib/core/theme.dart`.

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

## Localization

French only (`Locale('fr', 'FR')` and `Intl.defaultLocale = 'fr_FR'` hardcoded). All user-facing strings, including Cloud Function notification text, are in French.

## Plan template IDs

- **Structured** (fixed structure, only the start date is editable): `mcheyne`, `bible-year-ligue`, `revolutionary`, `horner` (infinite loop over 10 lists)
- **Thematic** (fixed books, duration and rhythm editable): `new-testament`, `old-testament`, `gospels`, `psalms`, `proverbs`
- **Fully customizable**: `canonical-plan`, `chronological-plan`

## Backlog — Balance adaptative (priorité haute)

Le plan ajuste dynamiquement la charge des jours restants selon le comportement du lecteur :
- **En retard** → redistribuer les passages manquants sur les jours suivants (+1 chapitre/jour progressivement)
- **En avance** → proposer d'accélérer pour finir plus tôt
- **Inactif** (3+ jours) → réduire temporairement la charge

Piste : une fonction dans `PlansProvider` qui recalcule les jours restants à l'ouverture d'un plan (à partir de `currentDayIndex`, des jours complétés et du streak). Le champ `balance` de `DistributionOptions` existe déjà mais le générateur ne l'utilise pas encore. Attention aux plans de groupe : leurs jours sont indexés via le snapshot partagé (`dayIndex`), donc les redistribuer localement désynchroniserait la progression du groupe.
