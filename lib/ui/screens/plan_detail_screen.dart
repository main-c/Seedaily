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
                  color: AppTheme.deepNavy,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.deepNavy,
        actions: [
          // Bouton configuration → page d'édition
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/edit-plan/${widget.planId}'),
            tooltip: 'Configuration',
          ),
          // IconButton(
          //   icon: const Icon(Icons.share_outlined),
          //   onPressed: () => _exportService.sharePdf(plan),
          //   tooltip: 'Partager',

          // ),
        ],
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
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
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
                  color: AppTheme.textMuted,
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
                      color: AppTheme.deepNavy,
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
              backgroundColor: AppTheme.borderSubtle,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.seedGold,
              ),
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
    // Trouver le jour actuel (le premier jour non complété)
    int? currentDayIndex;
    for (int i = 0; i < plan.days.length; i++) {
      if (!plan.days[i].completed) {
        currentDayIndex = i;
        break;
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
