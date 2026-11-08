import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../domain/models.dart';
import '../l10n/l10n.dart';

class WidgetService {
  static const String _appGroupId = 'com.seedaily.app';
  static const String _androidWidgetName = 'SeedailyWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> updateTodayWidget({
    required List<GeneratedPlan> activePlans,
    required int streak,
  }) async {
    try {
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);

      String passage = '';
      bool isRead = false;
      bool isToday = false;
      String targetPlanId = '';

      // Lecture du jour
      for (final plan in activePlans) {
        final readingDay = plan.days.firstWhereOrNull((d) {
          final dn = DateTime(d.date.year, d.date.month, d.date.day);
          return dn == todayNorm;
        });
        if (readingDay != null && readingDay.passages.isNotEmpty) {
          final refs = Passage.groupConsecutivePassages(
            readingDay.passages,
            useAbbreviations: true,
          );
          passage = refs.take(3).join(' · ');
          isRead = readingDay.completed;
          isToday = true;
          targetPlanId = plan.id;
          break;
        }
      }

      // Fallback : prochain jour non lu
      if (passage.isEmpty && activePlans.isNotEmpty) {
        final plan = activePlans.first;
        final next = plan.days.firstWhereOrNull((d) {
          final dn = DateTime(d.date.year, d.date.month, d.date.day);
          return !dn.isBefore(todayNorm) && !d.completed;
        });
        if (next != null && next.passages.isNotEmpty) {
          final refs = Passage.groupConsecutivePassages(
            next.passages,
            useAbbreviations: true,
          );
          passage = refs.take(3).join(' · ');
          isToday = false;
          targetPlanId = plan.id;
        }
      }

      // Message contextuel
      final message = _buildMessage(activePlans, streak, isRead);

      // Tracker hebdomadaire (L M M J V S D → "1100101")
      final weekTracker = _buildWeekTracker(activePlans);

      await HomeWidget.saveWidgetData<String>('widget_streak_count', streak.toString());
      await HomeWidget.saveWidgetData<String>('widget_passage', passage);
      await HomeWidget.saveWidgetData<bool>('widget_is_today', isToday);
      await HomeWidget.saveWidgetData<bool>('widget_is_read', isRead);
      await HomeWidget.saveWidgetData<String>('widget_message', message);
      await HomeWidget.saveWidgetData<String>('widget_week_days', weekTracker);
      // Libellés traduits envoyés depuis Dart : le widget suit la langue
      // de l'app, pas celle de l'appareil.
      final l10n = appL10n;
      await HomeWidget.saveWidgetData<String>(
          'widget_streak_label', l10n.widgetStreakLabel(streak));
      await HomeWidget.saveWidgetData<String>(
          'widget_badge_read', l10n.widgetBadgeRead);
      await HomeWidget.saveWidgetData<String>(
          'widget_section_today', l10n.widgetSectionToday);
      await HomeWidget.saveWidgetData<String>(
          'widget_section_next', l10n.widgetSectionNext);
      await HomeWidget.saveWidgetData<String>(
          'widget_empty', l10n.widgetEmpty);
      await HomeWidget.saveWidgetData<String>(
          'widget_day_labels', l10n.widgetDayLabels);
      await HomeWidget.saveWidgetData<String>(
        'widget_uri',
        targetPlanId.isNotEmpty ? '/plan/$targetPlanId' : '/',
      );
      await HomeWidget.updateWidget(androidName: _androidWidgetName);

      debugPrint('[WIDGET] passage="$passage" streak=$streak lu=$isRead semaine=$weekTracker');
    } catch (e) {
      debugPrint('[WIDGET] Erreur: $e');
    }
  }

  /// Message contextuel selon la situation du jour
  static String _buildMessage(
      List<GeneratedPlan> plans, int streak, bool isRead) {
    final l10n = appL10n;
    if (plans.isEmpty) return l10n.widgetNoPlan;
    if (isRead) return l10n.widgetReadToday;
    if (streak > 30) return l10n.widgetStreakAmazing(streak);
    if (streak > 7) return l10n.widgetStreakGood(streak);
    if (streak > 0) return l10n.widgetStreakDay(streak);
    return l10n.widgetReady;
  }

  /// Retourne une chaîne de 7 caractères "1"/"0" pour L M M J V S D
  /// "1" = jour lu cette semaine, "0" = non lu
  static String _buildWeekTracker(List<GeneratedPlan> plans) {
    final now = DateTime.now();
    // Lundi de la semaine courante
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final buffer = StringBuffer();
    for (int i = 0; i < 7; i++) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      bool read = false;
      for (final plan in plans) {
        final rd = plan.days.firstWhereOrNull((d) {
          final dn = DateTime(d.date.year, d.date.month, d.date.day);
          return dn == day;
        });
        if (rd != null && rd.completed) {
          read = true;
          break;
        }
      }
      buffer.write(read ? '1' : '0');
    }
    return buffer.toString();
  }
}
