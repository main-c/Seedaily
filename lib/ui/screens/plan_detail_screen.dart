import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../services/export_service.dart';
import '../../core/theme.dart';

class PlanDetailScreen extends StatefulWidget {
  final String planId;

  const PlanDetailScreen({
    super.key,
    required this.planId,
  });

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calendrier'),
            Tab(text: 'Liste'),
          ],
          indicatorColor: AppTheme.seedGold,
          labelColor: AppTheme.deepNavy,
        ),
      ),
      body: Column(
        children: [
          _buildProgressHeader(plan),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarView(plan),
                _buildListView(plan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(GeneratedPlan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderSubtle),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.check_circle_outline,
                label: 'Complétés',
                value: '${plan.completedDays}/${plan.totalDays}',
              ),
              _buildStatItem(
                context,
                icon: Icons.trending_up,
                label: 'Progression',
                value: '${plan.progress.toStringAsFixed(0)}%',
              ),
              if (plan.currentStreak > 0)
                _buildStatItem(
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
              minHeight: 8,
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

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.seedGold, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCalendarView(GeneratedPlan plan) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plan.days.length,
      itemBuilder: (context, index) {
        final day = plan.days[index];
        return _buildDayCard(day, index + 1);
      },
    );
  }

  Widget _buildListView(GeneratedPlan plan) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plan.days.length,
      itemBuilder: (context, index) {
        final day = plan.days[index];
        return _buildDayCard(day, index + 1);
      },
    );
  }

  Widget _buildDayCard(ReadingDay day, int dayNumber) {
    final dateFormat = DateFormat('EEE dd MMM', 'fr_FR');
    final isToday = _isToday(day.date);
    final isPast = day.date.isBefore(DateTime.now()) && !isToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<PlansProvider>().toggleDayCompletion(
                widget.planId,
                day.date,
              );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isToday
                ? Border.all(color: AppTheme.seedGold, width: 2)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: day.completed
                      ? AppTheme.seedGold
                      : AppTheme.surface,
                  border: Border.all(
                    color: day.completed
                        ? AppTheme.seedGold
                        : AppTheme.borderSubtle,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: day.completed
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppTheme.surface,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Jour $dayNumber',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.seedGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Aujourd\'hui',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.deepNavy,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(day.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: day.passages.map((passage) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            passage.reference,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
