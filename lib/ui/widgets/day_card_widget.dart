import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seedaily/ui/widgets/today_card_widget.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';

/// Widget unifié pour afficher une carte de jour de lecture
/// - Si c'est le jour à lire (isCurrent=true) → affiche TodayCardWidget (avec bouton)
/// - Si c'est un jour passé → card simplifiée (grisée si complété)
/// - Si c'est un jour futur → card fantomatique (très discrète avec cadenas)
///
/// IMPORTANT: On ne peut marquer un jour comme lu que via le bouton
/// "Marquer comme lu" de TodayCardWidget. Les passages affichent juste du texte.
class DayCardWidget extends StatelessWidget {
  final ReadingDay day;
  final int? dayIndex;
  final bool isCurrent;
  final bool isCompleted;
  final bool showCheckbox;
  final bool isPreviewMode;
  final bool isFuture;
  final VoidCallback? onTap;

  const DayCardWidget({
    super.key,
    required this.day,
    this.dayIndex,
    this.isCurrent = false,
    this.isCompleted = false,
    this.showCheckbox = true,
    this.isPreviewMode = false,
    this.isFuture = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Si c'est le jour à lire, retourner TodayCardWidget
    if (isCurrent) {
      return TodayCardWidget(
        day: day,
        showButton: showCheckbox && !isPreviewMode,
        onMarkComplete: onTap,
      );
    }

    // Format de date : "Lundi 6 janvier"
    final dateFormatted = DateFormat('EEEE d MMMM', 'fr_FR').format(day.date);
    final capitalizedDate =
        dateFormatted[0].toUpperCase() + dateFormatted.substring(1);

    // Grouper les passages consécutifs du même livre
    final groupedPassages = Passage.groupConsecutivePassages(day.passages);

    // Styles différents selon l'état
    final isGrayed = isCompleted; // Card déjà lue
    final isGhost = isFuture && !isCompleted; // Card future

    return Container(
      decoration: BoxDecoration(
        color: isGhost
            ? AppTheme.surface.withValues(alpha: 0.4)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGhost
              ? AppTheme.borderSubtle.withValues(alpha: 0.3)
              : AppTheme.borderSubtle,
          width: 1,
        ),
        boxShadow: isGhost
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: !isPreviewMode && onTap != null ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: isGrayed ? 0.6 : (isGhost ? 0.5 : 1.0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header : Badge + Date + Icône cadenas
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge selon l'état
                            if (isCompleted) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.seedGold.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'COMPLÉTÉ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppTheme.deepNavy,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            // Date
                            Text(
                              capitalizedDate,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppTheme.deepNavy,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Icône cadenas si jour futur
                      if (isFuture && !isCompleted)
                        Icon(
                          Icons.lock_outline,
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Liste des passages (sans checkboxes, juste affichage)
                  ...groupedPassages.map((passageRef) {
                    return _buildPassageRow(context, passageRef);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassageRow(BuildContext context, String passageRef) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        passageRef,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.deepNavy,
              fontWeight: FontWeight.w500,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
      ),
    );
  }
}
