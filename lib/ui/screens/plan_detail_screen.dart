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
            onPressed: () => _showExportBottomSheet(context, plan),
            tooltip: 'Exporter',
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

  void _showExportBottomSheet(BuildContext context, GeneratedPlan plan) {
    bool sectionColors = true;
    bool includeCheckbox = true;
    bool isExporting = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Titre ────────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.seedGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.picture_as_pdf_outlined,
                          color: AppTheme.seedGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exporter en PDF',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                )),
                        Text('Calendrier A4 paysage',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                )),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                const SizedBox(height: 8),

                // ── Options ───────────────────────────────────────────────
                Text('Options',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        )),
                const SizedBox(height: 12),

                _ExportOptionTile(
                  icon: Icons.palette_outlined,
                  title: 'Couleurs par genre biblique',
                  subtitle: 'Loi · Historiques · Sagesse · Prophètes · NT',
                  value: sectionColors,
                  onChanged: (v) => setSheetState(() => sectionColors = v),
                ),
                const SizedBox(height: 8),
                _ExportOptionTile(
                  icon: Icons.check_box_outlined,
                  title: 'Cases à cocher',
                  subtitle: 'Pour suivre la lecture sur papier',
                  value: includeCheckbox,
                  onChanged: (v) => setSheetState(() => includeCheckbox = v),
                ),

                const SizedBox(height: 24),

                // ── Bouton export ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isExporting
                        ? null
                        : () async {
                            setSheetState(() => isExporting = true);
                            Navigator.pop(ctx);
                            await _exportService.sharePdf(
                              plan,
                              sectionColors: sectionColors,
                              includeCheckbox: includeCheckbox,
                            );
                          },
                    icon: isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.share_outlined),
                    label: Text(isExporting ? 'Génération…' : 'Générer et partager'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.seedGold,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppTheme.seedGold.withValues(alpha: 0.4)
              : cs.outline,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        secondary: Icon(icon,
            color: value ? AppTheme.seedGold : cs.onSurface.withValues(alpha: 0.5),
            size: 22),
        title: Text(title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                )),
        subtitle: Text(subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                )),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: AppTheme.seedGold,
        inactiveThumbColor: cs.onSurface.withValues(alpha: 0.4),
        inactiveTrackColor: cs.surface,
      ),
    );
  }
}
