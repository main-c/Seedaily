import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';
import 'day_card_widget.dart';

/// Widget pour l'affichage par semaine
/// Affiche les jours de lecture groupés par semaine avec navigation
class WeekViewWidget extends StatefulWidget {
  final List<ReadingDay> days;
  final int? currentDayIndex;
  final int? selectedDayIndex;
  final Function(int)? onDayTap;
  final bool isPreviewMode;
  final bool showCheckbox;
  final int? currentStreak;
  final double? progress;

  const WeekViewWidget({
    super.key,
    required this.days,
    this.currentDayIndex,
    this.selectedDayIndex,
    this.onDayTap,
    this.isPreviewMode = false,
    this.showCheckbox = true,
    this.currentStreak,
    this.progress,
  });

  @override
  State<WeekViewWidget> createState() => _WeekViewWidgetState();
}

class _WeekViewWidgetState extends State<WeekViewWidget> {
  late int _currentWeekIndex;
  late List<List<ReadingDay>> _weeklyDays;

  @override
  void initState() {
    super.initState();
    _weeklyDays = _groupDaysByWeek(widget.days);

    _currentWeekIndex = 0;
    if (widget.currentDayIndex != null) {
      for (int i = 0; i < _weeklyDays.length; i++) {
        if (_weeklyDays[i]
            .any((day) => widget.days.indexOf(day) == widget.currentDayIndex)) {
          _currentWeekIndex = i;
          break;
        }
      }
    }
  }

  List<List<ReadingDay>> _groupDaysByWeek(List<ReadingDay> days) {
    if (days.isEmpty) return [];

    List<List<ReadingDay>> weeks = [];
    List<ReadingDay> currentWeek = [];

    for (var day in days) {
      if (currentWeek.isEmpty) {
        currentWeek.add(day);
      } else {
        final lastDay = currentWeek.last;
        final daysDiff = day.date.difference(lastDay.date).inDays;

        if (daysDiff <= 7 && day.date.weekday >= lastDay.date.weekday) {
          currentWeek.add(day);
        } else {
          weeks.add(List.from(currentWeek));
          currentWeek = [day];
        }
      }
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return weeks;
  }

  void _previousWeek() {
    if (_currentWeekIndex > 0) {
      setState(() {
        _currentWeekIndex--;
      });
    }
  }

  void _nextWeek() {
    if (_currentWeekIndex < _weeklyDays.length - 1) {
      setState(() {
        _currentWeekIndex++;
      });
    }
  }

  String _getWeekBooks(List<ReadingDay> weekDays) {
    if (weekDays.isEmpty) return '';

    final books = <String>{};
    for (final day in weekDays) {
      for (final passage in day.passages) {
        books.add(passage.book);
      }
    }

    return books.take(2).join(' & ');
  }

  /// Retourne l'image d'asset selon le numéro de la semaine
  String _getWeekImage(int weekIndex) {
    final images = [
      'assets/images/golden_waves_bg.jpg',
      'assets/images/mountain_bg.jpg',
      'assets/images/lake_bg.jpg',
      'assets/images/desert_bg.jpg',
      'assets/images/sunset_bg.jpg',
      'assets/images/forest_bg.jpg',
    ];

    // Boucler parmi les images disponibles
    return images[weekIndex % images.length];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty || _weeklyDays.isEmpty) {
      return const Center(
        child: Text('Aucun jour de lecture'),
      );
    }

    final currentWeekDays = _weeklyDays[_currentWeekIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header avec fond
          _buildWeekHeader(context, currentWeekDays),

          // Navigation semaine
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.deepNavy.withValues(alpha: 0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentWeekIndex > 0 ? _previousWeek : null,
                    color: _currentWeekIndex > 0
                        ? AppTheme.deepNavy
                        : AppTheme.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Semaine ${_currentWeekIndex + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.deepNavy,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentWeekIndex < _weeklyDays.length - 1
                        ? _nextWeek
                        : null,
                    color: _currentWeekIndex < _weeklyDays.length - 1
                        ? AppTheme.deepNavy
                        : AppTheme.textMuted.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Contenu de la semaine
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: currentWeekDays.asMap().entries.map((entry) {
                final day = entry.value;
                final globalIndex = widget.days.indexOf(day);
                final isCurrent = widget.currentDayIndex == globalIndex;
                final isFuture = widget.currentDayIndex != null &&
                    globalIndex > widget.currentDayIndex!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DayCardWidget(
                    day: day,
                    dayIndex: globalIndex,
                    isCurrent: isCurrent,
                    isCompleted: day.completed,
                    isFuture: isFuture,
                    showCheckbox: widget.showCheckbox,
                    isPreviewMode: widget.isPreviewMode,
                    onTap: widget.onDayTap != null
                        ? () => widget.onDayTap!(globalIndex)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(BuildContext context, List<ReadingDay> weekDays) {
    final books = _getWeekBooks(weekDays);
    final weekImage = _getWeekImage(_currentWeekIndex);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(weekImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Semaine du ${DateFormat('d MMMM', 'fr_FR').format(weekDays.first.date)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.surface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              if (books.isNotEmpty)
                Text(
                  books,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.surface.withValues(alpha: 0.9),
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
