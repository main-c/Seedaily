import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';
import 'passage_chip.dart';

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

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty || _weeklyDays.isEmpty) {
      return const Center(
        child: Text('Aucun jour de lecture'),
      );
    }

    final currentWeekDays = _weeklyDays[_currentWeekIndex];

    return Column(
      children: [
        // Header avec fond
        _buildWeekHeader(context, currentWeekDays),

        // Barre de progression
        if (!widget.isPreviewMode && widget.progress != null)
          _buildProgressBar(context),

        // Navigation semaine
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppTheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentWeekIndex > 0 ? _previousWeek : null,
                color: _currentWeekIndex > 0
                    ? AppTheme.deepNavy
                    : AppTheme.textMuted.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 16),
              Text(
                'Semaine ${_currentWeekIndex + 1}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepNavy,
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

        const Divider(height: 1),

        // Contenu de la semaine
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: currentWeekDays.asMap().entries.map((entry) {
              final day = entry.value;
              final globalIndex = widget.days.indexOf(day);
              return _buildDaySection(context, day, globalIndex);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekHeader(BuildContext context, List<ReadingDay> weekDays) {
    final books = _getWeekBooks(weekDays);

    return Container(
      height: 180,
      decoration: BoxDecoration(
        // Option 1: Gradient (pas besoin d'image)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.seedGold.withValues(alpha: 0.3),
            AppTheme.deepNavy.withValues(alpha: 0.8),
          ],
        ),
        // Option 2: Décommenter pour utiliser une image
        // image: const DecorationImage(
        //   image: AssetImage('assets/images/golden_waves_bg.jpg'),
        //   fit: BoxFit.cover,
        // ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
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
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = widget.progress ?? 0.0;
    final streak = widget.currentStreak ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression du plan',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (streak > 0)
                Row(
                  children: [
                    Text(
                      '$streak Jours de suite ',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.seedGold,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Icon(
                      Icons.local_fire_department,
                      color: AppTheme.seedGold,
                      size: 16,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: AppTheme.borderSubtle,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.seedGold,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${progress.toInt()}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.seedGold,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(
    BuildContext context,
    ReadingDay day,
    int globalIndex,
  ) {
    final isCurrent = widget.currentDayIndex == globalIndex;
    final isCompleted = day.completed;

    final dayFormat = DateFormat('EEEE', 'fr_FR');
    final dayName = dayFormat.format(day.date);
    final capitalizedDayName = dayName[0].toUpperCase() + dayName.substring(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: AppTheme.seedGold, width: 2)
            : Border.all(color: AppTheme.borderSubtle, width: 0.5),
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
          // Header avec le nom du jour
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppTheme.seedGold.withValues(alpha: 0.05)
                  : AppTheme.backgroundLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.seedGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: AppTheme.surface,
                    ),
                  ),
                Text(
                  capitalizedDayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepNavy,
                      ),
                ),
              ],
            ),
          ),

          // Liste des passages en pills
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: day.passages.map((passage) {
                return PassageChip(
                  passage: passage,
                  isComplete: isCompleted,
                  isCurrent: isCurrent,
                  usePillStyle: true,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
