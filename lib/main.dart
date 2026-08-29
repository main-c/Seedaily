import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/theme.dart';
import 'services/groups_service.dart';
import 'services/storage_service.dart';
import 'services/plan_generator.dart';
import 'services/notification_service.dart';
import 'services/update_gate_service.dart';
import 'services/widget_service.dart';
import 'providers/auth_provider.dart';
import 'providers/groups_provider.dart';
import 'providers/plans_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/bible_reader_provider.dart';
import 'ui/screens/main_shell_screen.dart';
import 'ui/screens/customize_plan_screen.dart';
import 'ui/screens/plan_detail_screen.dart';
import 'ui/screens/about_screen.dart';
import 'ui/screens/bible_library_screen.dart';
import 'ui/screens/create_group_screen.dart';
import 'ui/screens/group_detail_screen.dart';
import 'ui/screens/join_group_screen.dart';

String? pendingNotificationAction;
bool didLaunchFromNotification = false;
void Function(String?)? _handleNotificationAction;

void main() async {
  await runZonedGuarded(
    () async {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      await initializeDateFormatting('fr_FR', null);
      Intl.defaultLocale = 'fr_FR';
      await Firebase.initializeApp();

      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      final storageService = StorageService();
      await storageService.init();

      final notificationService = NotificationService();
      try {
        await notificationService.init(
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            _handleNotificationAction?.call(response.actionId);
          },
        );
      } catch (e) {
        debugPrint('Notification init failed: $e');
      }

      NotificationAppLaunchDetails? launchDetails;
      try {
        launchDetails =
            await notificationService.getNotificationAppLaunchDetails();
      } catch (_) {}

      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        didLaunchFromNotification = true;
        pendingNotificationAction =
            launchDetails.notificationResponse?.actionId;
        debugPrint('[NOTIF] App lancée depuis une notification'
            ' — actionId=$pendingNotificationAction');
      } else {
        debugPrint('[NOTIF] App lancée normalement (pas depuis notification)');
      }

      final planGenerator = PlanGenerator();
      await WidgetService.init();

      final hasSeenOnboarding = await storageService.getHasSeenOnboarding();

      // Vérification silencieuse de version — ne bloque pas l'app en cas d'erreur.
      final updateStatus = await UpdateGateService.check();

      FlutterNativeSplash.remove();

      runApp(
        SeedailyApp(
          storageService: storageService,
          notificationService: notificationService,
          planGenerator: planGenerator,
          hasSeenOnboarding: hasSeenOnboarding,
          updateStatus: updateStatus,
        ),
      );
    },
    (error, stack) =>
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
  );
}

class SeedailyApp extends StatefulWidget {
  final StorageService storageService;
  final NotificationService notificationService;
  final PlanGenerator planGenerator;
  final bool hasSeenOnboarding;
  final UpdateStatus updateStatus;

  const SeedailyApp({
    super.key,
    required this.storageService,
    required this.notificationService,
    required this.planGenerator,
    required this.hasSeenOnboarding,
    required this.updateStatus,
  });

  @override
  State<SeedailyApp> createState() => _SeedailyAppState();
}

class _SeedailyAppState extends State<SeedailyApp> {
  late final GoRouter _router;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _groupsService = GroupsService();

  @override
  void initState() {
    super.initState();

    final initialLocation = _computeInitialLocation();
    final showTour = !widget.hasSeenOnboarding;
    pendingNotificationAction = null;

    _router = GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final tabIndex =
                int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
            return MainShellScreen(
              key: mainShellKey,
              initialIndex: tabIndex,
              showTourOnLoad: showTour,
            );
          },
        ),
        GoRoute(
          path: '/plan/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PlanDetailScreen(planId: id);
          },
        ),
        GoRoute(
          path: '/customize-plan/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CustomizePlanScreen(templateId: id);
          },
        ),
        GoRoute(
          path: '/edit-plan/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CustomizePlanScreen(planId: id);
          },
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: '/bible-library',
          builder: (context, state) => const BibleLibraryScreen(),
        ),
        // Groupe — routes poussées par-dessus la shell principale
        GoRoute(
          path: '/groups/create',
          builder: (context, state) => const CreateGroupScreen(),
        ),
        GoRoute(
          path: '/groups/join',
          builder: (context, state) => const JoinGroupScreen(),
        ),
        // Deep link : seedaily://app/join/:code
        GoRoute(
          path: '/join/:code',
          builder: (context, state) {
            final code = state.pathParameters['code'] ?? '';
            return JoinGroupScreen(initialCode: code.toUpperCase());
          },
        ),
        // Route groupe — écran détail du groupe
        GoRoute(
          path: '/group/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return GroupDetailScreen(groupId: id);
          },
        ),
      ],
    );

    _handleNotificationAction = (actionId) {
      if (actionId == kNotificationActionCreatePlan) {
        _router.go('/?tab=1');
      } else {
        _router.go('/');
      }
    };

    if (widget.updateStatus != UpdateStatus.upToDate) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showUpdateDialog(widget.updateStatus));
    }
  }

  void _showUpdateDialog(UpdateStatus status) {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    showDialog(
      context: ctx,
      barrierDismissible: status == UpdateStatus.softUpdate,
      builder: (_) => AlertDialog(
        title: Text(status == UpdateStatus.forceUpdate
            ? 'Mise à jour requise'
            : 'Mise à jour disponible'),
        content: Text(status == UpdateStatus.forceUpdate
            ? "Cette version n'est plus supportée. Merci de mettre à jour l'application pour continuer."
            : 'Une nouvelle version de Seedaily est disponible avec des améliorations.'),
        actions: [
          if (status == UpdateStatus.softUpdate)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Plus tard'),
            ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.seedGold),
            child: const Text('Mettre à jour',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _computeInitialLocation() {
    if (pendingNotificationAction == kNotificationActionCreatePlan) {
      return '/?tab=1';
    }
    return '/';
  }

  @override
  void dispose() {
    _handleNotificationAction = null;
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PlansProvider>(
          create: (_) => PlansProvider(
            storage: widget.storageService,
            generator: widget.planGenerator,
            notifications: widget.notificationService,
          )..loadPlans(),
          update: (_, auth, plans) {
            if (auth.isSignedIn && auth.uid != null) {
              plans?.setGroupContext(
                groupsService: _groupsService,
                userId: auth.uid!,
                displayName: auth.displayName,
              );
            } else {
              plans?.clearGroupContext();
            }
            return plans!;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            storage: widget.storageService,
            notifications: widget.notificationService,
          )..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => BibleReaderProvider(
            storage: widget.storageService,
          )..load(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GroupsProvider>(
          create: (_) => GroupsProvider(),
          update: (_, auth, groups) {
            if (auth.isSignedIn && auth.uid != null) {
              groups?.init(auth.uid!);
            } else {
              groups?.clear();
            }
            return groups!;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) => MaterialApp.router(
          title: 'Seedaily',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'),
          ],
          locale: const Locale('fr', 'FR'),
          routerConfig: _router,
        ),
      ),
    );
  }
}
