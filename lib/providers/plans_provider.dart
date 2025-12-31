import 'package:flutter/foundation.dart';
import '../domain/models.dart';
import '../services/storage_service.dart';
import '../services/plan_generator.dart';

class PlansProvider with ChangeNotifier {
  final StorageService _storage;
  final PlanGenerator _generator;

  List<GeneratedPlan> _plans = [];
  bool _isLoading = false;

  PlansProvider({
    required StorageService storage,
    required PlanGenerator generator,
  })  : _storage = storage,
        _generator = generator;

  List<GeneratedPlan> get plans => _plans;
  bool get isLoading => _isLoading;

  List<ReadingPlanTemplate> get templates => _generator.getDefaultTemplates();

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      _plans = await _storage.getAllPlans();
    } catch (e) {
      debugPrint('Erreur lors du chargement des plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    } catch (e) {
      debugPrint('Erreur lors de la création du plan: $e');
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _storage.deletePlan(planId);
      _plans.removeWhere((p) => p.id == planId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la suppression du plan: $e');
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
}
