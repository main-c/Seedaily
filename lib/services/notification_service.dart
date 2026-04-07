import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../core/theme.dart';
import '../domain/models.dart';

/// IDs des actions de notification (utilisés pour la navigation)
const String kNotificationActionViewPlans = 'view_plans';
const String kNotificationActionCreatePlan = 'create_plan';

/// IDs de notifications
const int _kEveningNotifId = 20;
const int _kTestNotifId = 99;

/// Détails Android communs pour les notifications quotidiennes (avec boutons d'action)
const AndroidNotificationDetails _dailyAndroidDetails =
    AndroidNotificationDetails(
  'daily_reading',
  'Lecture quotidienne',
  channelDescription: 'Rappels quotidiens pour votre lecture biblique',
  importance: Importance.max,
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

const DarwinNotificationDetails _dailyIosDetails = DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
);

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ============================================================
  // Pools de messages contextuels
  // ============================================================

  static const List<String> _messagesGeneric = [
    '10 minutes aujourd\'hui peuvent nourrir toute ta journée',
    'Un nouveau chapitre t\'attend aujourd\'hui',
    'Prêt pour ta lecture du jour?',
    'La Parole te nourrit chaque jour',
    'Continue ton parcours, tu progresses bien',
    'Un moment avec Dieu aujourd\'hui?',
    'Ta lecture quotidienne est prête',
    'Garde le cap, tu es sur la bonne voie',
  ];

  static const List<String> _messagesUrgent = [
    'Tu as {n} jours de retard. Ouvre ton plan maintenant!',
    '⚠️ {n} jours non lus t\'attendent. Commence par un seul chapitre!',
    'Le retard s\'accumule ({n} jours). Un petit effort aujourd\'hui?',
    'Tu es à {n} jours du rythme. La Parole t\'attend!',
  ];

  static const List<String> _messagesGentleCatchup = [
    'Encore un effort et tu rattrapes ton plan!',
    'Un chapitre aujourd\'hui et tu es presque à jour.',
    'La régularité vient avec la pratique. Tu peux le faire!',
    'Presque rattrapé — continue sur ta lancée!',
  ];

  static const List<String> _messagesOnTrack = [
    'Tu es dans le rythme. La Parole t\'attend!',
    'Parfait, tu es à jour. Continue comme ça!',
    'Un nouveau chapitre t\'attend aujourd\'hui.',
    'Tu es fidèle à ton plan. Bravo!',
  ];

  static const List<String> _messagesPraise = [
    'Impressionnant! Tu es en avance de {n} jour(s).',
    'Tu es {n} jour(s) en avance sur ton plan. Continue!',
    'En avance de {n} jour(s)! Tu es une inspiration.',
    'Quel rythme! {n} jour(s) d\'avance. Garde le cap!',
  ];

  // ============================================================
  // Initialisation
  // ============================================================

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

  // ============================================================
  // Permissions
  // ============================================================

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
          final canExact =
              await androidImplementation.canScheduleExactNotifications();
          debugPrint('[NOTIF] canScheduleExactNotifications: $canExact');
          if (canExact != true) {
            await androidImplementation.requestExactAlarmsPermission();
          }

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

  // ============================================================
  // Sélection du message contextuel
  // ============================================================

  String _selectMessage(List<GeneratedPlan> activePlans) {
    final day = DateTime.now().day;

    if (activePlans.isEmpty) {
      return _messagesGeneric[day % _messagesGeneric.length];
    }

    final worstDelta = activePlans
        .map((p) => p.onTrackDelta)
        .reduce((a, b) => a < b ? a : b);

    if (worstDelta < -3) {
      final msg = _messagesUrgent[day % _messagesUrgent.length];
      return msg.replaceAll('{n}', '${-worstDelta}');
    } else if (worstDelta < 0) {
      return _messagesGentleCatchup[day % _messagesGentleCatchup.length];
    } else if (worstDelta == 0) {
      return _messagesOnTrack[day % _messagesOnTrack.length];
    } else {
      final msg = _messagesPraise[day % _messagesPraise.length];
      return msg.replaceAll('{n}', '$worstDelta');
    }
  }

  // ============================================================
  // Scheduling principal (intelligent)
  // ============================================================

  /// Planifie les rappels du matin de façon intelligente.
  /// - Respecte les jours de lecture choisis par l'utilisateur
  /// - Adapte le message selon la progression (retard / à jour / avance)
  /// - Annule uniquement les IDs 0-6 (morning slots) sans toucher à l'ID 20 (soir)
  Future<void> scheduleSmartNotifications({
    required int hour,
    required int minute,
    List<GeneratedPlan> activePlans = const [],
    Set<String> readingDayNames = const {
      'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'
    },
  }) async {
    if (!_initialized) await init();

    try {
      // Annuler uniquement les slots matin (IDs 0-6)
      for (int id = 0; id <= 6; id++) {
        await _notifications.cancel(id);
      }

      // Mapping jour → (weekday Dart, notif ID)
      const dayMap = {
        'mon': (weekday: 1, id: 0),
        'tue': (weekday: 2, id: 1),
        'wed': (weekday: 3, id: 2),
        'thu': (weekday: 4, id: 3),
        'fri': (weekday: 5, id: 4),
        'sat': (weekday: 6, id: 5),
        'sun': (weekday: 7, id: 6),
      };

      final effectiveDays = readingDayNames.isEmpty
          ? {'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'}
          : readingDayNames;

      final message = _selectMessage(activePlans);

      for (final dayName in effectiveDays) {
        final entry = dayMap[dayName];
        if (entry == null) continue;

        final scheduled =
            _nextWeekdayDateTime(entry.weekday, hour, minute);
        final scheduledTz =
            tz.TZDateTime.from(scheduled.toUtc(), tz.local);

        await _notifications.zonedSchedule(
          entry.id,
          'Seedaily',
          message,
          scheduledTz,
          const NotificationDetails(
            android: _dailyAndroidDetails,
            iOS: _dailyIosDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }

      debugPrint('[NOTIF] Smart notifications programmées'
          ' pour : $effectiveDays à ${hour}h${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('[NOTIF] ERREUR scheduling smart : $e');
      rethrow;
    }
  }

  /// Compatibilité : wrapper vers scheduleSmartNotifications sans contexte plan.
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) =>
      scheduleSmartNotifications(hour: hour, minute: minute);

  // ============================================================
  // Notification de rattrapage du soir (ID=20)
  // ============================================================

  /// Planifie un rappel du soir répétitif chaque jour à 20:00 si l'utilisateur est en retard.
  /// Se répète quotidiennement jusqu'à annulation explicite (cancelEveningCatchupNotification).
  Future<void> scheduleEveningCatchupNotification({
    required int behindDays,
  }) async {
    if (!_initialized) await init();

    try {
      final now = DateTime.now();
      var evening = DateTime(now.year, now.month, now.day, 20, 0);
      if (!evening.isAfter(now)) {
        evening = evening.add(const Duration(days: 1));
      }

      final scheduledTz = tz.TZDateTime.from(evening.toUtc(), tz.local);
      final body = behindDays > 3
          ? '⚠️ Tu as $behindDays jours de retard. Un petit effort ce soir?'
          : '⚠️ Tu n\'as pas encore lu aujourd\'hui. Prends quelques minutes!';

      await _notifications.zonedSchedule(
        _kEveningNotifId,
        'Seedaily',
        body,
        scheduledTz,
        const NotificationDetails(
          android: _dailyAndroidDetails,
          iOS: _dailyIosDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint(
          '[NOTIF] Evening catch-up programmé à 20:00 chaque soir ($behindDays j. de retard)');
    } catch (e) {
      debugPrint('[NOTIF] ERREUR scheduling evening : $e');
    }
  }

  Future<void> cancelEveningCatchupNotification() async {
    await _notifications.cancel(_kEveningNotifId);
    debugPrint('[NOTIF] Evening catch-up annulé');
  }

  // ============================================================
  // Test & utilitaires
  // ============================================================

  /// Affiche immédiatement une notification de test.
  Future<void> showTestNotification() async {
    if (!_initialized) await init();
    await _notifications.show(
      _kTestNotifId,
      'Seedaily — Test',
      '📖 Rappel de lecture : un chapitre t\'attend aujourd\'hui!',
      const NotificationDetails(
        android: _dailyAndroidDetails,
        iOS: _dailyIosDetails,
      ),
    );
    debugPrint('[NOTIF] Test notification envoyée');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // ============================================================
  // Helpers
  // ============================================================

  /// Retourne la prochaine occurrence du [targetWeekday] (1=lun..7=dim) à [hour]:[minute].
  DateTime _nextWeekdayDateTime(int targetWeekday, int hour, int minute) {
    final now = DateTime.now();
    var date = DateTime(now.year, now.month, now.day, hour, minute);
    int daysToAdd = (targetWeekday - now.weekday + 7) % 7;
    if (daysToAdd == 0 && !date.isAfter(now)) {
      daysToAdd = 7;
    }
    return date.add(Duration(days: daysToAdd));
  }
}
