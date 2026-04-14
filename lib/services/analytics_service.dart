import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  final _analytics = FirebaseAnalytics.instance;

  // ── Plan lifecycle ─────────────────────────────────────────────────────────

  Future<void> logPlanCreated({
    required String templateId,
    required int durationDays,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'plan_created',
        parameters: {
          'template_id': templateId,
          'duration_days': durationDays,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logPlanCreated error: $e');
    }
  }

  Future<void> logPlanDeleted({required String templateId}) async {
    try {
      await _analytics.logEvent(
        name: 'plan_deleted',
        parameters: {'template_id': templateId},
      );
    } catch (e) {
      debugPrint('[Analytics] logPlanDeleted error: $e');
    }
  }

  Future<void> logPlanCompleted({required String templateId}) async {
    try {
      await _analytics.logEvent(
        name: 'plan_completed',
        parameters: {'template_id': templateId},
      );
    } catch (e) {
      debugPrint('[Analytics] logPlanCompleted error: $e');
    }
  }

  // ── Lecture quotidienne ────────────────────────────────────────────────────

  Future<void> logDayCompleted({
    required int streakLength,
    required double progress,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'day_completed',
        parameters: {
          'streak_length': streakLength,
          'progress_pct': progress.round(),
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logDayCompleted error: $e');
    }
  }

  Future<void> logDayUnchecked() async {
    try {
      await _analytics.logEvent(name: 'day_unchecked');
    } catch (e) {
      debugPrint('[Analytics] logDayUnchecked error: $e');
    }
  }

  // ── Export ─────────────────────────────────────────────────────────────────

  Future<void> logPlanExported() async {
    try {
      await _analytics.logEvent(name: 'plan_exported');
    } catch (e) {
      debugPrint('[Analytics] logPlanExported error: $e');
    }
  }

  // ── Settings ───────────────────────────────────────────────────────────────

  Future<void> logNotificationsToggled({required bool enabled}) async {
    try {
      await _analytics.logEvent(
        name: 'notifications_toggled',
        parameters: {'enabled': enabled ? 1 : 0},
      );
    } catch (e) {
      debugPrint('[Analytics] logNotificationsToggled error: $e');
    }
  }

  Future<void> logThemeChanged({required String mode}) async {
    try {
      await _analytics.logEvent(
        name: 'theme_changed',
        parameters: {'mode': mode},
      );
    } catch (e) {
      debugPrint('[Analytics] logThemeChanged error: $e');
    }
  }
}
