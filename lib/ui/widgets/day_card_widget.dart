import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seedaily/ui/widgets/today_card_widget.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../providers/bible_reader_provider.dart';
import '../screens/bible_reader_screen.dart';

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
  final bool isOutOfSequence;
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
    this.isOutOfSequence = false,
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
            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.4)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGhost
              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline,
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOutOfSequence
                                          ? Colors.orange.withValues(alpha: 0.15)
                                          : AppTheme.seedGold.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'COMPLÉTÉ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: isOutOfSequence
                                                ? Colors.orange.shade800
                                                : Theme.of(context).colorScheme.onSurface,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ),
                                  if (isOutOfSequence) ...[
                                    const SizedBox(width: 6),
                                    Tooltip(
                                      message: 'Des jours précédents ne sont pas encore lus',
                                      child: Icon(
                                        Icons.warning_amber_rounded,
                                        size: 16,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ],
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
                                    color: Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6).withValues(alpha: 0.5),
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Liste des passages (sans checkboxes, juste affichage)
                  ...groupedPassages.map((passageRef) {
                    return _buildPassageRow(context, passageRef);
                  }),

                  // Bouton Lire — visible si une version est téléchargée
                  if (!isPreviewMode && !isFuture)
                    _buildReadButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadButton(BuildContext context) {
    final provider = context.read<BibleReaderProvider>();

    // Aucune Bible installée → prompt discret
    if (provider.downloadedIds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.push('/bible-library'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_outlined,
                    size: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  'Ajouter une Bible pour lire',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () {
            final nav = Navigator.of(context);
            // Ensemble local : on appelle onTap une seule fois quand tous
            // les passages sont lus, peu importe l'ordre de lecture.
            final completedPassages = <int>{};
            nav.push(MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: BibleReaderScreen(
                  passages: day.passages,
                  onPassageComplete: (idx) {
                    completedPassages.add(idx);
                    if (completedPassages.length >= day.passages.length) {
                      onTap?.call();
                    }
                  },
                ),
              ),
            ));
          },
          icon: const Icon(Icons.menu_book_outlined, size: 15),
          label: const Text('Lire'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.seedGold,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
      ),
    );
  }
}
