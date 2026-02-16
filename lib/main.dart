import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/theme.dart';
import 'services/storage_service.dart';
import 'services/plan_generator.dart';
import 'services/notification_service.dart';
import 'providers/plans_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/screens/main_shell_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/customize_plan_screen.dart';
import 'ui/screens/plan_detail_screen.dart';
import 'ui/screens/about_screen.dart';

String? pendingNotificationAction;
bool didLaunchFromNotification = false;
void Function(String?)? _handleNotificationAction;

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initializeDateFormatting('fr_FR', null);

  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init(
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      _handleNotificationAction?.call(response.actionId);
    },
  );

  final launchDetails = await notificationService.getNotificationAppLaunchDetails();
  if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
    didLaunchFromNotification = true;
    pendingNotificationAction = launchDetails.notificationResponse?.actionId;
  }

  final planGenerator = PlanGenerator();

  runApp(
    SeedailyApp(
      storageService: storageService,
      notificationService: notificationService,
      planGenerator: planGenerator,
    ),
  );
}

class SeedailyApp extends StatefulWidget {
  final StorageService storageService;
  final NotificationService notificationService;
  final PlanGenerator planGenerator;

  const SeedailyApp({
    super.key,
    required this.storageService,
    required this.notificationService,
    required this.planGenerator,
  });

  @override
  State<SeedailyApp> createState() => _SeedailyAppState();
}

class _SeedailyAppState extends State<SeedailyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    final initialLocation = _computeInitialLocation();
    pendingNotificationAction = null;

    _router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        // Splash : logo + Seedaily sur fond blanc
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
        ),
        // Shell principal avec navigation en bas
        GoRoute(
          path: '/',
          builder: (context, state) {
            final tabIndex =
                int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
            return MainShellScreen(key: mainShellKey,  initialIndex: tabIndex);
          },
        ),
        // Routes secondaires (sans la barre de navigation)
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
        // Route pour éditer un plan existant
        GoRoute(
          path: '/edit-plan/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CustomizePlanScreen(planId: id);
          },
        ),
        // Route À propos
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
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
  }

  String _computeInitialLocation() {
    if (!didLaunchFromNotification) return '/splash';
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
          create: (_) => PlansProvider(
            storage: widget.storageService,
            generator: widget.planGenerator,
          )..loadPlans(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            storage: widget.storageService,
            notifications: widget.notificationService,
          )..loadSettings(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Seedaily',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
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
    );
  }
}
