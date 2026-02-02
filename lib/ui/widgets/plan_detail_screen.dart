import 'package:flutter/material.dart';
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
        title: Text(plan.title),
        elevation: 0,
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.deepNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _exportService.sharePdf(plan),
            tooltip: 'Partager',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportService.exportToPdf(plan),
            tooltip: 'Exporter en PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressHeader(plan),
          Expanded(
            child: _buildViewByFormat(plan),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(GeneratedPlan plan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                context,
                icon: Icons.check_circle_outline,
                label: 'Complétés',
                value: '${plan.completedDays}/${plan.totalDays}',
              ),
              _buildStatCard(
                context,
                icon: Icons.trending_up,
                label: 'Progression',
                value: '${plan.progress.toStringAsFixed(0)}%',
              ),
              if (plan.currentStreak > 0)
                _buildStatCard(
                  context,
                  icon: Icons.local_fire_department,
                  label: 'Série',
                  value: '${plan.currentStreak}',
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: plan.progress / 100,
              minHeight: 6,
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

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderSubtle, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.seedGold, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ],
        ),
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

  Widget _buildViewByFormat(GeneratedPlan plan) {
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
