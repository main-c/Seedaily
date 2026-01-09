import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';
import 'reading_day_card.dart';

/// Widget pour l'affichage par semaine (format Weekly)
/// Regroupe les jours de lecture par semaine avec un en-tête pour chaque semaine
class WeeklyViewWidget extends StatelessWidget {
  final List<ReadingDay> days;
  final int? currentDayIndex;
  final int? selectedDayIndex;
  final Function(int)? onDayTap;
  final bool isPreviewMode;
  final bool showCheckbox;

  const WeeklyViewWidget({
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

    // Regrouper les jours par semaine
    final weekGroups = _groupByWeek(days);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weekGroups.length,
      itemBuilder: (context, weekIndex) {
        final weekData = weekGroups[weekIndex];
        final weekDays = weekData['days'] as List<MapEntry<int, ReadingDay>>;
        final weekNumber = weekData['weekNumber'] as int;
        final startDate = weekData['startDate'] as DateTime;
        final endDate = weekData['endDate'] as DateTime;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de semaine
            _buildWeekHeader(context, weekNumber, startDate, endDate),
            const SizedBox(height: 12),

            // Jours de la semaine
            ...weekDays.map((entry) {
              final dayIndex = entry.key;
              final day = entry.value;
              final isSelected = selectedDayIndex == dayIndex;
              final isCurrent = currentDayIndex == dayIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: onDayTap != null ? () => onDayTap!(dayIndex) : null,
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
                ),
              );
            }),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildWeekHeader(
    BuildContext context,
    int weekNumber,
    DateTime startDate,
    DateTime endDate,
  ) {
    final dateFormat = DateFormat('d MMM', 'fr_FR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.seedGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.seedGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.seedGold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'S$weekNumber',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.surface,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semaine $weekNumber',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  startDate.month == endDate.month
                      ? '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}'
                      : '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.calendar_view_week,
            color: AppTheme.seedGold,
            size: 24,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupByWeek(List<ReadingDay> days) {
    final weekGroups = <Map<String, dynamic>>[];

    if (days.isEmpty) return weekGroups;

    int currentWeekNumber = 1;
    DateTime? weekStartDate;
    DateTime? weekEndDate;
    List<MapEntry<int, ReadingDay>> currentWeekDays = [];

    for (int i = 0; i < days.length; i++) {
      final day = days[i];

      // Premier jour ou nouvelle semaine (Lundi)
      if (weekStartDate == null || day.date.weekday == DateTime.monday) {
        // Sauvegarder la semaine précédente si elle existe
        if (weekStartDate != null && currentWeekDays.isNotEmpty) {
          weekGroups.add({
            'weekNumber': currentWeekNumber,
            'startDate': weekStartDate,
            'endDate': weekEndDate ?? weekStartDate,
            'days': List<MapEntry<int, ReadingDay>>.from(currentWeekDays),
          });
          currentWeekNumber++;
          currentWeekDays = [];
        }

        weekStartDate = day.date;
      }

      weekEndDate = day.date;
      currentWeekDays.add(MapEntry(i, day));
    }

    // Ajouter la dernière semaine
    if (weekStartDate != null && currentWeekDays.isNotEmpty) {
      weekGroups.add({
        'weekNumber': currentWeekNumber,
        'startDate': weekStartDate,
        'endDate': weekEndDate ?? weekStartDate,
        'days': currentWeekDays,
      });
    }

    return weekGroups;
  }
}
