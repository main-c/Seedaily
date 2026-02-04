import 'package:flutter/material.dart';

import '../../domain/models.dart';
import 'day_card_widget.dart';
import 'today_card_widget.dart';

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
        final isCurrent = currentDayIndex == index;
        final isCompleted = day.completed;
        final isFuture = currentDayIndex != null && index > currentDayIndex!;

        // Card spéciale pour le jour actuel (style gradient)
        if (isCurrent) {
          return TodayCardWidget(
            day: day,
            onMarkComplete: showCheckbox && !isPreviewMode && onDayTap != null
                ? () => onDayTap!(index)
                : null,
            showButton: showCheckbox && !isPreviewMode,
          );
        }

        // Card standard pour les autres jours
        return DayCardWidget(
          day: day,
          dayIndex: index,
          isCurrent: false,
          isCompleted: isCompleted,
          isFuture: isFuture,
          showCheckbox: showCheckbox,
          isPreviewMode: isPreviewMode,
          onTap: onDayTap != null ? () => onDayTap!(index) : null,
        );
      },
    );
  }
}
