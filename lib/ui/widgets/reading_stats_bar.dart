import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Widget représentant une barre de statistiques pour un plan de lecture
/// Affiche : nombre de jours, livres, chapitres, progression
class ReadingStatsBar extends StatelessWidget {
  final int totalDays;
  final int bookCount;
  final int totalChapters;
  final double? avgChaptersPerDay;
  final int? completedDays;
  final bool showProgress;
  final bool compactMode;

  const ReadingStatsBar({
    super.key,
    required this.totalDays,
    required this.bookCount,
    required this.totalChapters,
    this.avgChaptersPerDay,
    this.completedDays,
    this.showProgress = false,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = showProgress && completedDays != null && totalDays > 0
        ? completedDays! / totalDays
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de progression en premier si mode compact (comme dans l'image 1)
          if (showProgress && completedDays != null && compactMode) ...[
            _buildCompactProgressBar(context, progress),
            const SizedBox(height: 16),
          ],

          // Statistiques principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.calendar_today,
                value: '$totalDays',
                label: 'jours',
              ),
              _buildDivider(),
              _buildStatItem(
                context,
                icon: Icons.menu_book,
                value: '$bookCount',
                label: 'livres',
              ),
              _buildDivider(),
              _buildStatItem(
                context,
                icon: Icons.article,
                value: '$totalChapters',
                label: 'chapitres',
              ),
              if (avgChaptersPerDay != null) ...[
                _buildDivider(),
                _buildStatItem(
                  context,
                  icon: Icons.trending_up,
                  value: avgChaptersPerDay!.toStringAsFixed(1),
                  label: 'chap/jour',
                ),
              ],
            ],
          ),

          // Barre de progression standard (si pas compact mode)
          if (showProgress && completedDays != null && !compactMode) ...[
            const SizedBox(height: 16),
            _buildStandardProgressBar(context, progress),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactProgressBar(BuildContext context, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header : "PROGRESSION TOTALE" + Badge "24% Terminé"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROGRESSION TOTALE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Badge "24% Terminé" + Détails jours
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toInt()}% Terminé',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '$completedDays/$totalDays jours',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Barre de progression
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.borderSubtle,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.seedGold,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStandardProgressBar(BuildContext context, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.seedGold,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.backgroundLight,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.seedGold,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$completedDays / $totalDays jours complétés',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.seedGold,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.borderSubtle,
    );
  }
}
