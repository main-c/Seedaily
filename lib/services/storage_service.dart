import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models.dart';

class StorageService {
  static const String _plansBoxName = 'reading_plans';
  static const String _settingsBoxName = 'settings';

  Box<dynamic>? _plansBox;
  Box<dynamic>? _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _plansBox = await Hive.openBox(_plansBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  Future<void> savePlan(GeneratedPlan plan) async {
    await _plansBox?.put(plan.id, plan.toJson());
  }

  Future<void> deletePlan(String planId) async {
    await _plansBox?.delete(planId);
  }

  Future<List<GeneratedPlan>> getAllPlans() async {
    final box = _plansBox;
    if (box == null) return [];

    final plans = <GeneratedPlan>[];
    for (final key in box.keys) {
      try {
        final json = box.get(key) as Map<dynamic, dynamic>;
        final planJson = Map<String, dynamic>.from(json);
        plans.add(GeneratedPlan.fromJson(planJson));
      } catch (e) {
        continue;
      }
    }

    plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return plans;
  }

  Future<GeneratedPlan?> getPlan(String planId) async {
    try {
      final json = _plansBox?.get(planId) as Map<dynamic, dynamic>?;
      if (json == null) return null;

      final planJson = Map<String, dynamic>.from(json);
      return GeneratedPlan.fromJson(planJson);
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePlanDay(
      String planId, DateTime date, bool completed) async {
    final plan = await getPlan(planId);
    if (plan == null) return;

    final dayIndex = plan.days.indexWhere(
      (d) =>
          d.date.year == date.year &&
          d.date.month == date.month &&
          d.date.day == date.day,
    );

    if (dayIndex != -1) {
      plan.days[dayIndex].completed = completed;
      await savePlan(plan);
    }
  }

  Future<void> saveNotificationTime(DateTime time) async {
    await _settingsBox?.put(
        'notification_time', time.toIso8601String());
  }

  Future<DateTime?> getNotificationTime() async {
    try {
      final timeString = _settingsBox?.get('notification_time') as String?;
      if (timeString == null) return null;
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _settingsBox?.put('notifications_enabled', enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    return _settingsBox?.get('notifications_enabled', defaultValue: true) ??
        true;
  }

  Future<void> clearAllData() async {
    await _plansBox?.clear();
    await _settingsBox?.clear();
  }
}
