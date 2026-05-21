import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../domain/models.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/plan_generator.dart';
import '../services/widget_service.dart';

const List<int> _streakMilestones = [7, 14, 30, 60, 100, 365];

class PlansProvider with ChangeNotifier {
  final StorageService _storage;
  final PlanGenerator _generator;
  final NotificationService _notifications;

  List<GeneratedPlan> _plans = [];
  bool _isLoading = false;
  int _bestStreak = 0;
  int? _pendingMilestone;

  PlansProvider({
    required StorageService storage,
    required PlanGenerator generator,
    required NotificationService notifications,
  })  : _storage = storage,
        _generator = generator,
        _notifications = notifications;

  List<GeneratedPlan> get plans => _plans;
  bool get isLoading => _isLoading;
  int get bestStreak => _bestStreak;
  int? get pendingMilestone => _pendingMilestone;

  void clearPendingMilestone() {
    _pendingMilestone = null;
  }

  List<ReadingPlanTemplate> get templates => _generator.getDefaultTemplates();

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      _plans = await _storage.getAllPlans();
      _bestStreak = await _storage.getBestStreak();
    } catch (e) {
      debugPrint('Erreur lors du chargement des plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    await _rescheduleSmartNotifications();
    await _updateWidget();
  }

  Future<void> createPlan({
    required String templateId,
    required String title,
    required GeneratorOptions options,
  }) async {
    try {
      final plan = _generator.generate(
        templateId: templateId,
        title: title,
        options: options,
      );

      await _storage.savePlan(plan);
      await loadPlans();

      AnalyticsService.instance.logPlanCreated(
        templateId: templateId,
        durationDays: plan.totalDays,
      );
    } catch (e) {
      debugPrint('Erreur lors de la création du plan: $e');
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      final plan = _plans.firstWhere((p) => p.id == planId);
      AnalyticsService.instance.logPlanDeleted(templateId: plan.templateId);

      await _storage.deletePlan(planId);
      _plans.removeWhere((p) => p.id == planId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la suppression du plan: $e');
      rethrow;
    }

    await _rescheduleSmartNotifications();
  }

  /// Met à jour un plan existant avec de nouvelles options
  /// Régénère le plan avec les nouvelles options tout en préservant la progression
  Future<void> updatePlan({
    required String planId,
    required String title,
    required GeneratorOptions options,
  }) async {
    try {
      final existingPlan = _plans.firstWhere((p) => p.id == planId);

      // Sauvegarder la progression des jours complétés (par date)
      final completedDates = <DateTime>{};
      for (final day in existingPlan.days) {
        if (day.completed) {
          completedDates.add(DateTime(day.date.year, day.date.month, day.date.day));
        }
      }

      // Régénérer le plan avec les nouvelles options
      final updatedPlan = _generator.generate(
        templateId: existingPlan.templateId,
        title: title,
        options: options,
        existingPlanId: planId,
      );

      // Restaurer la progression sur les jours correspondants
      for (final day in updatedPlan.days) {
        final dateKey = DateTime(day.date.year, day.date.month, day.date.day);
        if (completedDates.contains(dateKey)) {
          day.completed = true;
        }
      }

      // Sauvegarder le plan mis à jour
      await _storage.savePlan(updatedPlan);
      await loadPlans();
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du plan: $e');
      rethrow;
    }
  }

  /// Réinitialise la progression d'un plan (tous les jours à non-lus)
  Future<void> resetPlanProgress(String planId) async {
    try {
      final plan = _plans.firstWhere((p) => p.id == planId);

      for (final day in plan.days) {
        if (day.completed) {
          day.completed = false;
          await _storage.updatePlanDay(planId, day.date, false);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la réinitialisation du plan: $e');
      rethrow;
    }
  }

  Future<void> toggleDayCompletion(String planId, DateTime date) async {
    try {
      final plan = _plans.firstWhere((p) => p.id == planId);
      final dayIndex = plan.days.indexWhere(
        (d) =>
            d.date.year == date.year &&
            d.date.month == date.month &&
            d.date.day == date.day,
      );

      if (dayIndex != -1) {
        final newValue = !plan.days[dayIndex].completed;
        await _storage.updatePlanDay(planId, date, newValue);
        plan.days[dayIndex].completed = newValue;
        notifyListeners();

        if (newValue) {
          final streak = plan.currentStreak;
          AnalyticsService.instance.logDayCompleted(
            streakLength: streak,
            progress: plan.progress,
          );
          if (plan.progress >= 100) {
            AnalyticsService.instance.logPlanCompleted(
              templateId: plan.templateId,
            );
          }
          await _checkAndUpdateBestStreak(streak);
        } else {
          AnalyticsService.instance.logDayUnchecked();
        }

        await _updateWidget();

        // Si le jour togglé est aujourd'hui, mettre à jour la notification du soir
        final today = DateTime.now();
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;

        if (isToday) {
          final activePlans = _plans.where((p) => p.progress < 100).toList();
          if (activePlans.isEmpty) {
            await _notifications.cancelEveningCatchupNotification();
          } else {
            final worstDelta = activePlans
                .map((p) => p.onTrackDelta)
                .reduce(min);
            if (worstDelta < 0) {
              await _notifications.scheduleEveningCatchupNotification(
                behindDays: -worstDelta,
              );
            } else {
              await _notifications.cancelEveningCatchupNotification();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du jour: $e');
      rethrow;
    }
  }

  GeneratedPlan? getPlanById(String planId) {
    try {
      return _plans.firstWhere((p) => p.id == planId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Widget écran d'accueil
  // ============================================================

  Future<void> _updateWidget() async {
    final activePlans = _plans.where((p) => p.progress < 100).toList();
    final streak = activePlans.isEmpty
        ? 0
        : activePlans.map((p) => p.currentStreak).reduce(max);
    await WidgetService.updateTodayWidget(
      activePlans: activePlans,
      streak: streak,
    );
  }

  // ============================================================
  // Streak gamifié
  // ============================================================

  Future<void> _checkAndUpdateBestStreak(int currentStreak) async {
    if (currentStreak > _bestStreak) {
      _bestStreak = currentStreak;
      await _storage.saveBestStreak(_bestStreak);
    }

    final seenMilestones = await _storage.getSeenMilestones();
    for (final milestone in _streakMilestones) {
      if (currentStreak >= milestone && !seenMilestones.contains(milestone)) {
        await _storage.addSeenMilestone(milestone);
        _pendingMilestone = milestone;
        notifyListeners();
        break;
      }
    }
  }

  // ============================================================
  // Passages par weekday (pour notifications enrichies)
  // ============================================================

  /// Pour chaque jour de la semaine, retourne le résumé des passages
  /// du premier plan actif qui a une lecture ce jour-là.
  Map<String, String> _buildPassagesByDay(
      List<GeneratedPlan> activePlans, int hour, int minute) {
    const dayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    const dayMap = {
      'mon': 1, 'tue': 2, 'wed': 3, 'thu': 4,
      'fri': 5, 'sat': 6, 'sun': 7,
    };

    final result = <String, String>{};
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);

    // Calcule le prochain jour non lu pour chaque plan actif
    String? nextUnreadPassage(GeneratedPlan plan) {
      final upcoming = plan.days.where((d) {
        final dn = DateTime(d.date.year, d.date.month, d.date.day);
        return !dn.isBefore(todayNorm) && !d.completed;
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      if (upcoming.isEmpty) return null;
      final refs = Passage.groupConsecutivePassages(upcoming.first.passages,
          useAbbreviations: true);
      return refs.take(3).join(' · ');
    }

    for (final dayName in dayNames) {
      final targetWeekday = dayMap[dayName]!;

      // Prochaine occurrence de ce weekday
      int daysToAdd = (targetWeekday - now.weekday + 7) % 7;
      final notifTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (daysToAdd == 0 && !notifTime.isAfter(now)) daysToAdd = 7;
      final targetDate = now.add(Duration(days: daysToAdd));
      final targetNorm =
          DateTime(targetDate.year, targetDate.month, targetDate.day);

      // 1. Chercher un jour qui correspond exactement à la date cible
      for (final plan in activePlans) {
        final readingDay = plan.days.where((d) {
          final dn = DateTime(d.date.year, d.date.month, d.date.day);
          return dn == targetNorm;
        }).firstOrNull;

        if (readingDay != null && readingDay.passages.isNotEmpty) {
          final refs = Passage.groupConsecutivePassages(readingDay.passages,
              useAbbreviations: true);
          result[dayName] = refs.take(3).join(' · ');
          break;
        }
      }

      // 2. Fallback : prochain jour non lu du plan si aucune date exacte
      if (!result.containsKey(dayName)) {
        for (final plan in activePlans) {
          final passage = nextUnreadPassage(plan);
          if (passage != null && passage.isNotEmpty) {
            result[dayName] = passage;
            break;
          }
        }
      }

      // 3. Fallback ultime : n'importe quel jour à venir (lu ou non)
      if (!result.containsKey(dayName)) {
        for (final plan in activePlans) {
          final upcoming = plan.days
              .where((d) =>
                  !DateTime(d.date.year, d.date.month, d.date.day)
                      .isBefore(todayNorm))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          if (upcoming.isNotEmpty && upcoming.first.passages.isNotEmpty) {
            final refs = Passage.groupConsecutivePassages(
                upcoming.first.passages,
                useAbbreviations: true);
            result[dayName] = refs.take(3).join(' · ');
            break;
          }
        }
      }
    }

    return result;
  }

  // ============================================================
  // Smart notification rescheduling
  // ============================================================

  Future<void> _rescheduleSmartNotifications() async {
    try {
      final enabled = await _storage.getNotificationsEnabled();
      if (!enabled) return;

      final notifTime = await _storage.getNotificationTime();
      final hour = notifTime?.hour ?? 9;
      final minute = notifTime?.minute ?? 0;

      final activePlans = _plans.where((p) => p.progress < 100).toList();

      final readingDayNames = activePlans
          .expand((p) => p.options.schedule.readingDays)
          .toSet();

      final passagesByDay = _buildPassagesByDay(activePlans, hour, minute);
      final currentStreak = activePlans.isEmpty
          ? 0
          : activePlans.map((p) => p.currentStreak).reduce(max);

      await _notifications.scheduleSmartNotifications(
        hour: hour,
        minute: minute,
        activePlans: activePlans,
        readingDayNames: readingDayNames.isEmpty
            ? {'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'}
            : readingDayNames,
        passagesByDay: passagesByDay,
        currentStreak: currentStreak,
      );

      // Evening catch-up
      if (activePlans.isEmpty) {
        await _notifications.cancelEveningCatchupNotification();
      } else {
        final worstDelta = activePlans
            .map((p) => p.onTrackDelta)
            .reduce(min);
        if (worstDelta < 0) {
          await _notifications.scheduleEveningCatchupNotification(
            behindDays: -worstDelta,
          );
        } else {
          await _notifications.cancelEveningCatchupNotification();
        }
      }
    } catch (e) {
      debugPrint('[NOTIF] Erreur reschedule smart notifications: $e');
    }
  }
}
