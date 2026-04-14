import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../services/export_service.dart';
import '../../core/theme.dart';
import '../widgets/month_calendar_widget.dart';
import '../widgets/list_view_widget.dart';
import '../widgets/weekly_view_widget.dart';
import '../widgets/by_book_view_widget.dart';

class PlanDetailScreen extends StatefulWidget {
  final String planId;

  const PlanDetailScreen({
    super.key,
    required this.planId,
  });

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  final _exportService = ExportService();
  int? _selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlansProvider>().getPlanById(widget.planId);

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plan introuvable')),
        body: const Center(
          child: Text('Ce plan n\'existe pas'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          // Bouton configuration → page d'édition
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/edit-plan/${widget.planId}'),
            tooltip: 'Configuration',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _exportService.sharePdf(plan),
            tooltip: 'Partager',
          ),
        ],
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressHeader(plan),
          Expanded(
            child: _buildCurrentView(plan),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(GeneratedPlan plan) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final expectedDays = plan.days.where((d) {
      final dayNorm = DateTime(d.date.year, d.date.month, d.date.day);
      return !dayNorm.isAfter(todayNorm);
    }).length;
    final delta = plan.completedDays - expectedDays;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la section
          Text(
            'Progression du plan',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 12),

          // Jours lus avec pourcentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${plan.completedDays}/${plan.totalDays} jours',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
              ),
              Text(
                '${plan.progress.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.seedGold,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barre de progression - agrandie pour meilleure visibilité
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: plan.progress / 100,
              minHeight: 12,
              backgroundColor: Theme.of(context).colorScheme.outline,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.seedGold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Badge avance / retard / à jour
          _buildPaceIndicator(delta, expectedDays),
        ],
      ),
    );
  }

  Widget _buildPaceIndicator(int delta, int expectedDays) {
    if (expectedDays == 0) return const SizedBox.shrink();

    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String label;

    if (delta == 0) {
      bgColor = Colors.green.withValues(alpha: 0.12);
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline;
      label = 'À jour';
    } else if (delta > 0) {
      bgColor = Colors.green.withValues(alpha: 0.12);
      textColor = Colors.green.shade700;
      icon = Icons.trending_up;
      label = 'En avance de $delta jour${delta > 1 ? 's' : ''}';
    } else {
      final behind = -delta;
      bgColor = behind <= 3
          ? Colors.orange.withValues(alpha: 0.12)
          : Colors.red.withValues(alpha: 0.10);
      textColor = behind <= 3 ? Colors.orange.shade800 : Colors.red.shade700;
      icon = Icons.trending_down;
      label = 'En retard de $behind jour${behind > 1 ? 's' : ''}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  /// Marque un jour comme complété/non-complété et sauvegarde dans Hive
  void _toggleDayCompletion(GeneratedPlan plan, int dayIndex) {
    final day = plan.days[dayIndex];
    context.read<PlansProvider>().toggleDayCompletion(
          widget.planId,
          day.date,
        );
  }

  /// Construit la vue actuellement sélectionnée
  Widget _buildCurrentView(GeneratedPlan plan) {
    // Trouver le jour correspondant à aujourd'hui (date calendaire)
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    int? currentDayIndex;
    for (int i = 0; i < plan.days.length; i++) {
      final d = plan.days[i].date;
      if (DateTime(d.year, d.month, d.day) == todayNorm) {
        currentDayIndex = i;
        break;
      }
    }
    // Fallback : premier jour non complété si aujourd'hui est hors du plan
    if (currentDayIndex == null) {
      for (int i = 0; i < plan.days.length; i++) {
        if (!plan.days[i].completed) {
          currentDayIndex = i;
          break;
        }
      }
    }

    // Afficher le widget selon le format du plan
    switch (plan.options.display.format) {
      case OutputFormat.calendar:
        return MonthCalendarWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex ?? 0,
          selectedDayIndex: _selectedDayIndex ?? currentDayIndex ?? 0,
          selectedReadingDays: const <String>{},
          isPreviewMode: false,
          onDayTap: (index) {
            setState(() {
              _selectedDayIndex = index;
            });
          },
          onDayComplete: (index) => _toggleDayCompletion(plan, index),
        );

      case OutputFormat.list:
        return ListViewWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex,
          selectedDayIndex: _selectedDayIndex,
          isPreviewMode: false,
          showCheckbox: true,
          onDayTap: (index) => _toggleDayCompletion(plan, index),
        );

      case OutputFormat.weekly:
        return WeekViewWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex,
          selectedDayIndex: _selectedDayIndex,
          isPreviewMode: false,
          showCheckbox: true,
          currentStreak: plan.currentStreak,
          progress: plan.progress,
          onDayTap: (index) => _toggleDayCompletion(plan, index),
        );

      case OutputFormat.byBook:
        return ByBookViewWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex,
          selectedDayIndex: _selectedDayIndex,
          isPreviewMode: false,
          showCheckbox: true,
          onDayTap: (index) => _toggleDayCompletion(plan, index),
        );

      case OutputFormat.circle:
        // Format Circle pas encore implémenté, utiliser liste par défaut
        return ListViewWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex,
          selectedDayIndex: _selectedDayIndex,
          isPreviewMode: false,
          showCheckbox: true,
          onDayTap: (index) => _toggleDayCompletion(plan, index),
        );
    }
  }
}
