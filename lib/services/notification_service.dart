import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../core/theme.dart';
import '../domain/models.dart';
import '../l10n/l10n.dart';

/// IDs des actions de notification (utilisés pour la navigation)
const String kNotificationActionViewPlans = 'view_plans';
const String kNotificationActionCreatePlan = 'create_plan';

/// IDs de notifications
const int _kEveningNotifId = 20;
const int _kTestNotifId = 99;

List<AndroidNotificationAction> _dailyActions() => [
  AndroidNotificationAction(
    kNotificationActionViewPlans,
    appL10n.notifActionViewPlans,
    showsUserInterface: true,
    cancelNotification: true,
  ),
  AndroidNotificationAction(
    kNotificationActionCreatePlan,
    appL10n.notifActionCreatePlan,
    showsUserInterface: true,
    cancelNotification: true,
    titleColor: AppTheme.seedGold,
  ),
];

AndroidNotificationDetails _buildAndroidDetails({
  required String encouragement,
  String? passage,
}) {
  // Expanded view shows both passage and encouragement
  final bigText = (passage != null && passage.isNotEmpty)
      ? '$passage\n$encouragement'
      : encouragement;

  return AndroidNotificationDetails(
    'daily_reading',
    appL10n.notifChannelName,
    channelDescription: appL10n.notifChannelDescription,
    importance: Importance.max,
    priority: Priority.high,
    largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
    styleInformation: BigTextStyleInformation(bigText),
    actions: _dailyActions(),
  );
}

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

  static List<String> get _messagesGeneric {
    final l = appL10n;
    return [
      l.notifGeneric1, l.notifGeneric2, l.notifGeneric3, l.notifGeneric4,
      l.notifGeneric5, l.notifGeneric6, l.notifGeneric7, l.notifGeneric8,
    ];
  }

  static List<String Function(int)> get _messagesUrgent {
    final l = appL10n;
    return [l.notifUrgent1, l.notifUrgent2, l.notifUrgent3, l.notifUrgent4];
  }

  static List<String> get _messagesGentleCatchup {
    final l = appL10n;
    return [l.notifCatchup1, l.notifCatchup2, l.notifCatchup3, l.notifCatchup4];
  }

  static List<String> get _messagesOnTrack {
    final l = appL10n;
    return [l.notifOnTrack1, l.notifOnTrack2, l.notifOnTrack3, l.notifOnTrack4];
  }

  static List<String Function(int)> get _messagesPraise {
    final l = appL10n;
    return [l.notifPraise1, l.notifPraise2, l.notifPraise3, l.notifPraise4];
  }

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
    final linuxSettings = LinuxInitializationSettings(
      defaultActionName: appL10n.notifOpenApp,
    );

    final initSettings = InitializationSettings(
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
      return msg(-worstDelta);
    } else if (worstDelta < 0) {
      return _messagesGentleCatchup[day % _messagesGentleCatchup.length];
    } else if (worstDelta == 0) {
      return _messagesOnTrack[day % _messagesOnTrack.length];
    } else {
      final msg = _messagesPraise[day % _messagesPraise.length];
      return msg(worstDelta);
    }
  }

  // ============================================================
  // Scheduling principal (intelligent)
  // ============================================================

  /// Planifie les rappels du matin de façon intelligente.
  /// - Respecte les jours de lecture choisis par l'utilisateur
  /// - Adapte le message selon la progression (retard / à jour / avance)
  /// - Inclut le passage du jour et le streak dans la notification si disponibles
  /// - Annule uniquement les IDs 0-6 (morning slots) sans toucher à l'ID 20 (soir)
  Future<void> scheduleSmartNotifications({
    required int hour,
    required int minute,
    List<GeneratedPlan> activePlans = const [],
    Set<String> readingDayNames = const {
      'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'
    },
    Map<String, String> passagesByDay = const {},
    int currentStreak = 0,
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

      final contextMessage = _selectMessage(activePlans);
      final title = currentStreak > 1
          ? appL10n.notifDailyTitleStreak(currentStreak)
          : appL10n.notifDailyTitle;

      for (final dayName in effectiveDays) {
        final entry = dayMap[dayName];
        if (entry == null) continue;

        final passage = passagesByDay[dayName];
        // Body shown in collapsed notification: passage if available, else encouragement
        final body = (passage != null && passage.isNotEmpty)
            ? passage
            : contextMessage;

        final scheduled = _nextWeekdayDateTime(entry.weekday, hour, minute);
        final scheduledTz = tz.TZDateTime.from(scheduled.toUtc(), tz.local);

        await _notifications.zonedSchedule(
          entry.id,
          title,
          body,
          scheduledTz,
          NotificationDetails(
            android: _buildAndroidDetails(
              encouragement: contextMessage,
              passage: passage,
            ),
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
          ? appL10n.notifEveningBehind(behindDays)
          : appL10n.notifEveningNotRead;

      await _notifications.zonedSchedule(
        _kEveningNotifId,
        'Seedaily',
        body,
        scheduledTz,
        NotificationDetails(
          android: _buildAndroidDetails(encouragement: body),
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

  /// Affiche immédiatement une notification de test avec passage simulé.
  Future<void> showTestNotification({String? passage}) async {
    if (!_initialized) await init();
    final testMsg = appL10n.widgetReady;
    const testPassage = 'Gen 1 · Matt 1 · Ps 1';
    final effectivePassage = passage ?? testPassage;
    final body = effectivePassage;
    await _notifications.show(
      _kTestNotifId,
      appL10n.notifDailyTitle,
      body,
      NotificationDetails(
        android: _buildAndroidDetails(
          encouragement: testMsg,
          passage: effectivePassage,
        ),
        iOS: _dailyIosDetails,
      ),
    );
    debugPrint('[NOTIF] Test notification envoyée avec passage=$effectivePassage');
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
