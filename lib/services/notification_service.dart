import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../core/theme.dart';

/// IDs des actions de notification (utilisés pour la navigation)
const String kNotificationActionViewPlans = 'view_plans';
const String kNotificationActionCreatePlan = 'create_plan';

/// Détails Android communs pour les notifications quotidiennes (avec boutons d'action)
const AndroidNotificationDetails _dailyAndroidDetails =
    AndroidNotificationDetails(
  'daily_reading',
  'Lecture quotidienne',
  channelDescription: 'Rappels quotidiens pour votre lecture biblique',
  importance: Importance.high,
  priority: Priority.high,
  actions: [
    AndroidNotificationAction(
      kNotificationActionViewPlans,
      'Voir mes plans',
      showsUserInterface: true,
      cancelNotification: true,
    ),
    AndroidNotificationAction(
      kNotificationActionCreatePlan,
      'Créer un plan',
      showsUserInterface: true,
      cancelNotification: true,
      titleColor: AppTheme.seedGold,
    ),
  ],
);

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static final List<String> _messages = [
    '10 minutes aujourd\'hui peuvent nourrir toute ta journée',
    'Un nouveau chapitre t\'attend aujourd\'hui',
    'Prêt pour ta lecture du jour?',
    'La Parole te nourrit chaque jour',
    'Continue ton parcours, tu progresses bien',
    'Un moment avec Dieu aujourd\'hui?',
    'Ta lecture quotidienne est prête',
    'Garde le cap, tu es sur la bonne voie',
  ];

  Future<void> init({
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
  }) async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));
    debugPrint('[NOTIF] Timezone local détecté : $localTz');

    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Ouvrir Seedaily',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('[NOTIF] Notification reçue/tapée —'
            ' id=${response.id}'
            ' actionId=${response.actionId}'
            ' payload=${response.payload}');
        onDidReceiveNotificationResponse?.call(response);
      },
    );
    _initialized = true;
    debugPrint('[NOTIF] Service initialisé avec succès');
  }

  /// Récupère les infos si l'app a été lancée depuis une notification
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() =>
      _notifications.getNotificationAppLaunchDetails();

  Future<bool> requestPermissions() async {
    try {
      if (!_initialized) await init();

      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final iosImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      bool granted = true;

      if (androidImplementation != null) {
        granted =
            await androidImplementation.requestNotificationsPermission() ??
                false;

        if (granted) {
          // 1. Alarmes exactes (Android 12+) — ouvre "Alarmes et rappels" si non accordé
          final canExact =
              await androidImplementation.canScheduleExactNotifications();
          debugPrint('[NOTIF] canScheduleExactNotifications: $canExact');
          if (canExact != true) {
            await androidImplementation.requestExactAlarmsPermission();
          }

          // 2. Optimisation batterie — ouvre le dialog système si non accordé
          final batteryStatus =
              await Permission.ignoreBatteryOptimizations.status;
          if (!batteryStatus.isGranted) {
            await Permission.ignoreBatteryOptimizations.request();
          }
        }
      }

      if (iosImplementation != null) {
        granted = await iosImplementation.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }

      return granted;
    } catch (e) {
      debugPrint('Erreur lors de la demande de permissions: $e');
      return false;
    }
  }

  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) {
      await init();
    }

    try {
      await cancelAllNotifications();
      debugPrint('[NOTIF] Anciennes alarmes annulées');

      // DateTime.now() = heure locale du téléphone, pas besoin de tz ici
      final now = DateTime.now();
      var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
        debugPrint('[NOTIF] Heure passée → reporté au lendemain');
      }

      // Conversion en TZDateTime uniquement pour l'API zonedSchedule
      final scheduledDate = tz.TZDateTime.from(scheduled.toUtc(), tz.local);

      debugPrint('[NOTIF] Planification —'
          ' heure demandée=${hour}h${minute.toString().padLeft(2, '0')}'
          ' now_local=$now'
          ' scheduled=$scheduledDate'
          ' mode=exactAllowWhileIdle'
          ' repeat=daily');

      final message = _messages[DateTime.now().day % _messages.length];

      await _notifications.zonedSchedule(
        0,
        'Seedaily',
        message,
        scheduledDate,
        NotificationDetails(
          android: _dailyAndroidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Vérification : lister toutes les alarmes en attente
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('[NOTIF] Alarmes en attente après planification : ${pending.length}');
      for (final p in pending) {
        debugPrint('[NOTIF]   → id=${p.id} title="${p.title}" body="${p.body}"');
      }
    } catch (e) {
      debugPrint('[NOTIF] ERREUR planification : $e');
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// [DEBUG] Planifie une notification dans [minutes] minutes
  Future<void> scheduleInMinutes(int minutes) async {
    if (!_initialized) await init();
    // DateTime.now() = heure locale du téléphone
    final fireAt = tz.TZDateTime.from(
      DateTime.now().add(Duration(minutes: minutes)).toUtc(),
      tz.local,
    );
    debugPrint('[NOTIF][DEBUG] Planification test dans $minutes min → $fireAt');
    await _notifications.zonedSchedule(
      99,
      '[TEST] Seedaily',
      'Notification test — planifiée $minutes min avant',
      fireAt,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'debug',
          'Debug',
          channelDescription: 'Notifications de test',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    debugPrint('[NOTIF][DEBUG] Alarme test enregistrée');
  }

  /// [DEBUG] Retourne la liste des alarmes en attente + état des permissions
  Future<List<String>> getPendingInfo() async {
    if (!_initialized) await init();

    final result = <String>[];

    // Vérification permission alarmes exactes (Android 12+)
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final canExact = await androidPlugin.canScheduleExactNotifications();
      result.add('exactAlarms: ${canExact == true ? "✓ ACCORDÉE" : "✗ REFUSÉE — notifications ne se déclencheront pas !"}');
      debugPrint('[NOTIF][DEBUG] canScheduleExactNotifications: $canExact');

      if (canExact != true) {
        // Ouvre les réglages système pour que l'user accorde la permission
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    final pending = await _notifications.pendingNotificationRequests();
    result.add('${pending.length} alarme(s) en attente');
    for (final p in pending) {
      result.add('  id=${p.id} | "${p.title}" | ${p.body}');
    }
    return result;
  }

  /// Affiche une notification de test (même style que le rappel quotidien)
  Future<void> showTestNotification() async {
    if (!_initialized) await init();

    final message = _messages[DateTime.now().day % _messages.length];

    await _notifications.show(
      DateTime.now().millisecond,
      'Seedaily',
      message,
      NotificationDetails(
        android: _dailyAndroidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showImmediateNotification(String title, String body) async {
    if (!_initialized) await init();

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate',
          'Notifications immédiates',
          channelDescription: 'Notifications instantanées',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
