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

## Fonctionnalités v1.2.0

### Plans disponibles

**4 plans structurés** (structure fixe, seule la date de début est modifiable)
- `mcheyne` — M'Cheyne : lecture parallèle AT + NT, 365 jours, intensif
- `bible-year-ligue` — Ligue : AT + Psaume + Proverbe + NT chaque jour, 365 jours
- `revolutionary` — Révolutionnaire : 25 jours/mois avec jours de repos, 365 jours
- `horner` — Horner : lecture en boucle infinie sur 10 listes, durée personnalisable

**5 plans thématiques** (livres figés, durée et rythme modifiables)
- `new-testament` — Nouveau Testament (27 livres, ~90 jours)
- `old-testament` — Ancien Testament (39 livres, ~365 jours)
- `gospels` — Évangiles (Mt, Mc, Lc, Jn, ~30 jours)
- `psalms` — Psaumes (150 chapitres, ~150 jours)
- `proverbs` — Proverbes (31 chapitres, ~31 jours)

**2 plans entièrement personnalisables**
- `canonical-plan` — ordre canonique traditionnel
- `chronological-plan` — ordre chronologique/historique

### Personnalisation d'un plan

- Sélection des livres individuels (filtres AT / NT / Apocryphes)
- Ordre : canonique, chronologique, juif, inversé
- Psaumes quotidiens : aucun / un par jour / séquentiel
- Proverbes quotidiens : aucun / un par jour / selon le jour du mois
- Chevauchement AT/NT : séquentiel ou alterné
- Distribution : équilibrée, progressive, dégressive
- Date de début, durée totale, jours de lecture (Lun–Dim)

### Vues de lecture (plan detail)

- **Liste** — défilement vertical de tous les jours
- **Calendrier** — grille mensuelle avec navigation mois par mois
- **Hebdomadaire** — jours groupés par semaine avec image de fond
- **Par livre** — regroupement par livre biblique

### Suivi de progression

- Cases à cocher par jour
- Pourcentage de complétion + barre de progression
- Streak courant (jours consécutifs)
- Statut : en avance / dans les temps / en retard / terminé
- Filtres accueil : Tous / En cours / Terminés

### Paramètres

- Thème : clair / sombre / système
- Notifications quotidiennes : activer/désactiver + heure personnalisable

### Export & partage

- Export PDF avec code couleur par genre biblique (Loi=marron, Histoire=bleu, Sagesse=violet, Prophètes=orange, NT=vert)
- Options : statistiques incluses, cases à cocher incluses
- Partage via le système natif

### Gestion des plans

- Créer, modifier (régénère en préservant les jours complétés), supprimer
- Réinitialiser la progression

## Features à implémenter (backlog)

### Lecteur biblique intégré — versions multiples (priorité haute)

Objectif : inclure le texte de la Bible directement dans l'app (plusieurs versions), pour que l'utilisateur lise sans quitter l'app.

**Versions disponibles en domaine public (français) :**
- Louis Segond 1910 (LSG) — la plus répandue, domaine public
- Darby — fidèle au texte source, domaine public
- Martin 1744 — domaine public
- Ostervald 1744 — domaine public

**Architecture envisagée :**
- Fichiers JSON par version bundlés dans `assets/bible/` (~4-6 MB/version)
- Structure : `{ "version": "LSG", "books": [{ "name": "Genèse", "chapters": [["1:1 Au commencement...", "1:2 ..."], [...]] }] }`
- Service `BibleReaderService` qui charge le fichier JSON en mémoire à la demande (lazy load)
- Sélecteur de version dans les Paramètres (`SettingsProvider.bibleVersion`)
- Les `DayCard` affichent le texte des passages si une version est chargée

**UI envisagée :**
- Onglet "Lire" ou bottom sheet qui s'ouvre depuis un passage → affiche le texte chapitre complet avec highlight des versets du plan
- Si aucune version chargée → bouton "Ajouter une Bible" → liste des versions disponibles
- Option téléchargement (vs bundle complet selon taille acceptable)

**Contraintes :**
- Ne pas bundler les versions sous copyright (NEG, TOB, Semeur, BFC)
- Taille APK : 4 versions × 5 MB ≈ +20 MB — à évaluer si on bundle tout ou si on propose le téléchargement à la demande

### Balance adaptative (priorité haute)

Idée : le plan ajuste dynamiquement la charge de lecture des jours restants selon le comportement du lecteur.

- **Lecteur en retard** (jours non complétés, streak cassé) → redistribuer les passages manquants sur les prochains jours avec +1 chapitre/jour progressivement, sans écraser
- **Lecteur en avance** → proposer d'accélérer (+1 ch/jour) pour finir plus tôt
- **Lecteur inactif** (3+ jours sans lire) → réduire temporairement la charge pour faciliter le retour

**Implémentation envisagée :**
- Fonction dans `PlansProvider` qui recalcule la distribution des jours restants à chaque ouverture d'un plan
- Basée sur : `currentDayIndex`, jours complétés, jours en retard, streak actuel
- Deux niveaux : statique (front-loaded / back-loaded généré une fois) + dynamique (recalcul en temps réel)
- Le `balance` field dans `DistributionOptions` existe déjà dans les modèles, le générateur ne l'utilise pas encore
