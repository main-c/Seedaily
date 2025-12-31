import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../../core/theme.dart';

class PlanCard extends StatelessWidget {
  final GeneratedPlan plan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = plan.progress;
    final streak = plan.currentStreak;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: '${plan.completedDays}/${plan.totalDays} jours',
                  ),
                  const SizedBox(width: 8),
                  if (streak > 0)
                    _buildStreakChip(context, streak),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.seedGold,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _getMotivationalMessage(progress),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      backgroundColor: AppTheme.borderSubtle,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.seedGold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakChip(BuildContext context, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.seedGold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.seedGold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            '$streak jour${streak > 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.deepNavy,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(double progress) {
    if (progress == 0) return 'Commençons';
    if (progress < 25) return 'C\'est parti';
    if (progress < 50) return 'Continue';
    if (progress < 75) return 'Bien joué';
    if (progress < 100) return 'Presque là';
    return 'Terminé';
  }
}
