import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifications;

  DateTime _notificationTime = DateTime(2025, 1, 1, 9, 0);
  bool _notificationsEnabled = true;

  SettingsProvider({
    required StorageService storage,
    required NotificationService notifications,
  })  : _storage = storage,
        _notifications = notifications;

  DateTime get notificationTime => _notificationTime;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> loadSettings() async {
    try {
      final savedTime = await _storage.getNotificationTime();
      if (savedTime != null) {
        _notificationTime = savedTime;
      }

      _notificationsEnabled = await _storage.getNotificationsEnabled();

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
      rethrow;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      _notificationsEnabled = enabled;
      await _storage.saveNotificationsEnabled(enabled);

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
      rethrow;
    }
  }

  /// Affiche une notification de test (bouton temporaire pour dev)
  Future<void> showTestNotification() async {
    await _notifications.showTestNotification();
  }
}
