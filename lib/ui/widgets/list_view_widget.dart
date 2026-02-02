import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';

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
        final isCompleted = day.completed;
        final isPast = currentDayIndex != null && index < currentDayIndex!;

        return _buildDayItem(
          context,
          day,
          index,
          isSelected,
          isCurrent,
          isCompleted,
          isPast,
        );
      },
    );
  }

  Widget _buildDayItem(
    BuildContext context,
    ReadingDay day,
    int index,
    bool isSelected,
    bool isCurrent,
    bool isCompleted,
    bool isPast,
  ) {
    final dateFormat = DateFormat('EEEE d MMMM', 'fr_FR');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppTheme.seedGold
              : isCurrent
                  ? AppTheme.seedGold.withValues(alpha: 0.5)
                  : AppTheme.borderSubtle,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppTheme.seedGold.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppTheme.seedGold.withValues(alpha: 0.1)
                  : isPast
                      ? AppTheme.backgroundLight.withValues(alpha: 0.5)
                      : AppTheme.backgroundLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(day.date),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isPast && isCompleted
                              ? AppTheme.textMuted
                              : AppTheme.deepNavy,
                        ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.seedGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Aujourd\'hui',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                if (isCompleted && !isCurrent)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.seedGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: AppTheme.seedGold,
                    ),
                  ),
              ],
            ),
          ),

          // Passages
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                if (showCheckbox && !isPreviewMode)
                  GestureDetector(
                    onTap: onDayTap != null ? () => onDayTap!(index) : null,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.seedGold
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? AppTheme.seedGold
                              : AppTheme.borderSubtle,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: AppTheme.surface,
                            )
                          : null,
                    ),
                  ),

                // Passages chips
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: day.passages.map((passage) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.textMuted.withValues(alpha: 0.05)
                              : AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isCompleted
                                ? AppTheme.borderSubtle.withValues(alpha: 0.5)
                                : AppTheme.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          passage.reference,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isCompleted
                                        ? AppTheme.textMuted
                                        : AppTheme.deepNavy,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
