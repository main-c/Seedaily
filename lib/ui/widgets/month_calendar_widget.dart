import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';

/// Widget représentant un calendrier mensuel pour la vue d'ensemble du plan
/// Affiche seulement les jours de lecture sélectionnés par l'utilisateur
class MonthCalendarWidget extends StatefulWidget {
  final List<ReadingDay> days;
  final int currentDayIndex;
  final int? selectedDayIndex;
  final Set<String> selectedReadingDays;
  final Function(int)? onDayTap;
  final Function(int)? onDayComplete;
  final bool isPreviewMode;

  const MonthCalendarWidget({
    super.key,
    required this.days,
    this.currentDayIndex = 0,
    this.selectedDayIndex,
    this.selectedReadingDays = const {
      'mon',
      'tue',
      'wed',
      'thu',
      'fri',
      'sat',
      'sun'
    },
    this.onDayTap,
    this.onDayComplete,
    this.isPreviewMode = false,
  });

  @override
  State<MonthCalendarWidget> createState() => _MonthCalendarWidgetState();
}

class _MonthCalendarWidgetState extends State<MonthCalendarWidget> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    if (widget.days.isNotEmpty) {
      final currentDay = widget.days.length > widget.currentDayIndex
          ? widget.days[widget.currentDayIndex]
          : widget.days.first;
      _displayMonth = DateTime(currentDay.date.year, currentDay.date.month);
    } else {
      _displayMonth = DateTime.now();
    }
  }

  bool get _canNavigatePrevious {
    if (widget.days.isEmpty) return false;
    final firstDay = widget.days.first.date;
    final firstMonth = DateTime(firstDay.year, firstDay.month);
    return _displayMonth.isAfter(firstMonth);
  }

  bool get _canNavigateNext {
    if (widget.days.isEmpty) return false;
    final lastDay = widget.days.last.date;
    final lastMonth = DateTime(lastDay.year, lastDay.month);
    return _displayMonth.isBefore(lastMonth);
  }

  void _previousMonth() {
    if (_canNavigatePrevious) {
      setState(() {
        _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
      });
    }
  }

  void _nextMonth() {
    if (_canNavigateNext) {
      setState(() {
        _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) {
      return const Center(
        child: Text('Aucun jour de lecture'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header : Mois et année avec navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _canNavigatePrevious ? _previousMonth : null,
                  color: _canNavigatePrevious
                      ? AppTheme.seedGold
                      : AppTheme.textMuted.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat('MMMM yyyy', 'fr_FR').format(_displayMonth),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _canNavigateNext ? _nextMonth : null,
                  color: _canNavigateNext
                      ? AppTheme.seedGold
                      : AppTheme.textMuted.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),

          // Compteur de jours
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.seedGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.isPreviewMode ? 'aperçu' : '${widget.days.length} jours',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.seedGold,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (widget.isPreviewMode && !_canNavigateNext) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Créez le plan pour voir tous les mois',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Grille du calendrier
          _buildCalendarGrid(context, _displayMonth),

          // Carte de détail du jour sélectionné
          if (widget.selectedDayIndex != null &&
              widget.selectedDayIndex! < widget.days.length)
            _buildSelectedDayCard(context, widget.days[widget.selectedDayIndex!]),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, DateTime month) {
    const weekDays = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final daysByDate = <DateTime, int>{};
    for (var i = 0; i < widget.days.length; i++) {
      final day = widget.days[i];
      final dateKey = DateTime(day.date.year, day.date.month, day.date.day);
      daysByDate[dateKey] = i;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          ...List.generate((daysInMonth + firstWeekday) ~/ 7 + 1, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return Expanded(child: Container());
                  }

                  final date = DateTime(month.year, month.month, dayNumber);
                  final readingDayIndex = daysByDate[date];

                  return Expanded(
                    child: _buildDayCell(
                      context,
                      dayNumber,
                      readingDayIndex,
                      date,
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    int dayNumber,
    int? readingDayIndex,
    DateTime date,
  ) {
    final isCurrentDay = readingDayIndex == widget.currentDayIndex;
    final isSelectedDay = readingDayIndex == widget.selectedDayIndex;
    final isReadingDay = readingDayIndex != null;
    final isPastDay =
        readingDayIndex != null && readingDayIndex < widget.currentDayIndex;

    if (!isReadingDay) {
      return Container(
        margin: const EdgeInsets.all(2),
        child: Center(
          child: Text(
            '$dayNumber',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted.withValues(alpha: 0.2),
                  fontWeight: FontWeight.w300,
                ),
          ),
        ),
      );
    }

    final readingDay = widget.days[readingDayIndex];
    final passages = readingDay.passages;

    String displayText;
    if (passages.isEmpty) {
      displayText = '$dayNumber';
    } else {
      final grouped =
          Passage.groupConsecutivePassages(passages, useAbbreviations: true);
      displayText = grouped.join('\n');
    }

    return InkWell(
      onTap: widget.onDayTap != null
          ? () => widget.onDayTap!(readingDayIndex)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 65,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelectedDay
              ? AppTheme.seedGold
              : isCurrentDay
                  ? AppTheme.seedGold.withValues(alpha: 0.2)
                  : isPastDay
                      ? AppTheme.seedGold.withValues(alpha: 0.1)
                      : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelectedDay
                ? AppTheme.seedGold
                : isCurrentDay
                    ? AppTheme.seedGold.withValues(alpha: 0.5)
                    : isPastDay
                        ? AppTheme.seedGold.withValues(alpha: 0.2)
                        : AppTheme.borderSubtle,
            width: isSelectedDay ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$dayNumber',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelectedDay
                        ? AppTheme.surface
                        : isCurrentDay
                            ? AppTheme.seedGold
                            : isPastDay
                                ? AppTheme.textMuted
                                : AppTheme.seedGold,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                displayText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelectedDay
                          ? AppTheme.surface
                          : isCurrentDay
                              ? AppTheme.deepNavy
                              : isPastDay
                                  ? AppTheme.textMuted
                                  : AppTheme.deepNavy,
                      fontWeight: FontWeight.w500,
                      fontSize: 9,
                      height: 1.2,
                    ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayCard(BuildContext context, ReadingDay day) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Option 1: Utiliser un gradient (pas besoin d'image)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C5F7C),
            Color(0xFF1A3A4F),
          ],
        ),
        // Option 2: Décommenter pour utiliser une image de fond
        // image: const DecorationImage(
        //   image: AssetImage('assets/images/mountain_bg.jpg'),
        //   fit: BoxFit.cover,
        // ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.seedGold,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'AUJOURD\'HUI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.deepNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('d MMMM', 'fr_FR').format(day.date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.surface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              day.passages.isNotEmpty
                  ? day.passages.first.reference
                  : 'Aucune lecture',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.surface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppTheme.surface,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Environ 4 minutes de lecture',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.surface,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statut',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.surface.withValues(alpha: 0.8),
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: day.completed
                        ? AppTheme.seedGold.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppTheme.surface.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    day.completed ? 'Complété' : 'À lire',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.surface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onDayComplete != null && widget.selectedDayIndex != null
                    ? () => widget.onDayComplete!(widget.selectedDayIndex!)
                    : null,
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
                      day.completed ? 'Marquer comme non lu' : 'Marquer comme lu',
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
        ),
      ),
    );
  }
}
