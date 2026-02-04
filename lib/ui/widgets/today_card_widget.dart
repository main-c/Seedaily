import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';

/// Widget réutilisable pour afficher la carte du jour actuel de lecture
/// Utilisé dans MonthCalendarWidget et ListViewWidget
class TodayCardWidget extends StatelessWidget {
  final ReadingDay day;
  final VoidCallback? onMarkComplete;
  final bool showButton;

  const TodayCardWidget({
    super.key,
    required this.day,
    this.onMarkComplete,
    this.showButton = true,
  });


  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMMM', 'fr_FR').format(day.date);
    final groupedPassages = day.passages.isNotEmpty
        ? Passage.groupConsecutivePassages(day.passages)
        : <String>[];

    // Label dynamique selon si c'est vraiment aujourd'hui ou non
    final badgeLabel =  'LECTURE DU JOUR';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C5F7C),
            Color(0xFF1A3A4F),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.5),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge dynamique
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.seedGold,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.deepNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            // Date
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.surface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),

            // Passages groupés
            Text(
              groupedPassages.isNotEmpty
                  ? groupedPassages.join('\n')
                  : 'Aucune lecture',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.surface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statut',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.surface.withValues(alpha: 0.8),
                      ),
                ),
                Text(
                  day.completed ? 'Complété' : 'À lire',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.surface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),

            // Bouton marquer comme lu
            if (showButton && onMarkComplete != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onMarkComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.seedGold,
                    foregroundColor: AppTheme.deepNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.completed
                            ? 'Marquer comme non lu'
                            : 'Marquer comme lu',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.deepNavy,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        day.completed ? Icons.close : Icons.check,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
