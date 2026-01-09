import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';
import 'reading_day_card.dart';

/// Widget pour l'affichage en liste simple (format List)
/// Affiche tous les jours de lecture dans une liste verticale scrollable
class ListViewWidget extends StatelessWidget {
  final List<ReadingDay> days;
  final int? currentDayIndex;
  final int? selectedDayIndex;
  final Function(int)? onDayTap;
  final bool isPreviewMode;
  final bool showCheckbox;

  const ListViewWidget({
    super.key,
    required this.days,
    this.currentDayIndex,
    this.selectedDayIndex,
    this.onDayTap,
    this.isPreviewMode = false,
    this.showCheckbox = true,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const Center(
        child: Text('Aucun jour de lecture'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final day = days[index];
        final isSelected = selectedDayIndex == index;
        final isCurrent = currentDayIndex == index;

        return GestureDetector(
          onTap: onDayTap != null ? () => onDayTap!(index) : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppTheme.seedGold, width: 2)
                  : isCurrent
                      ? Border.all(
                          color: AppTheme.seedGold.withValues(alpha: 0.5),
                          width: 1)
                      : null,
            ),
            child: ReadingDayCard(
              day: day,
              isPreviewMode: isPreviewMode,
              showCheckbox: showCheckbox,
              showDayCheckbox: true,
            ),
          ),
        );
      },
    );
  }
}
