import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifications;

  DateTime _notificationTime = DateTime(2025, 1, 1, 9, 0);
  bool _notificationsEnabled = false;
  bool _notifPromptShown = false;
  ThemeMode _themeMode = ThemeMode.light;

  SettingsProvider({
    required StorageService storage,
    required NotificationService notifications,
  })  : _storage = storage,
        _notifications = notifications;

  DateTime get notificationTime => _notificationTime;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notifPromptShown => _notifPromptShown;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    try {
      final savedTime = await _storage.getNotificationTime();
      if (savedTime != null) {
        _notificationTime = savedTime;
      }

      _notificationsEnabled = await _storage.getNotificationsEnabled();
      _notifPromptShown = await _storage.getNotifPromptShown();

      final savedMode = await _storage.getThemeMode();
      _themeMode = switch (savedMode) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des paramètres: $e');
    }
  }

  Future<void> setNotificationTime(DateTime time) async {
    try {
      _notificationTime = time;
      await _storage.saveNotificationTime(time);

      if (_notificationsEnabled) {
        await _notifications.scheduleDailyNotification(
          hour: time.hour,
          minute: time.minute,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'heure: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      _notificationsEnabled = enabled;
      await _storage.saveNotificationsEnabled(enabled);
      AnalyticsService.instance.logNotificationsToggled(enabled: enabled);

      if (enabled) {
        final granted = await _notifications.requestPermissions();
        if (granted) {
          await _notifications.scheduleDailyNotification(
            hour: _notificationTime.hour,
            minute: _notificationTime.minute,
          );
        } else {
          _notificationsEnabled = false;
          await _storage.saveNotificationsEnabled(false);
        }
      } else {
        await _notifications.cancelAllNotifications();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la modification des notifications: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      _ => 'light',
    };
    await _storage.saveThemeMode(value);
    AnalyticsService.instance.logThemeChanged(mode: value);
    notifyListeners();
  }

  Future<void> markNotifPromptShown() async {
    _notifPromptShown = true;
    await _storage.setNotifPromptShown();
  }

  Future<void> showTestNotification() async {
    await _notifications.showTestNotification();
  }
}
