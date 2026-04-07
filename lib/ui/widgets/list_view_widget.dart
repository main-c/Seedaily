import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/models.dart';
import 'day_card_widget.dart';
import 'today_card_widget.dart';

/// Widget pour l'affichage en liste simple (format List)
/// Positionne automatiquement sur la lecture du jour à l'ouverture.
class ListViewWidget extends StatefulWidget {
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
  State<ListViewWidget> createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  // Hauteur estimée par item (card + séparateur) pour le pré-positionnement
  static const double _estimatedItemHeight = 165.0;

  late final ScrollController _scrollController;

  // Clé sur le jour courant pour ensureVisible après pré-positionnement
  final GlobalKey _currentDayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Pré-position approximative : force ListView.builder à construire l'item
    final estimatedOffset =
        ((widget.currentDayIndex ?? 0) * _estimatedItemHeight)
            .clamp(0.0, double.infinity);
    _scrollController =
        ScrollController(initialScrollOffset: estimatedOffset);

    // Après le premier frame, affiner avec ensureVisible (item maintenant construit)
    if (widget.currentDayIndex != null && widget.currentDayIndex! > 0) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToToday());
    }
  }

  void _scrollToToday() {
    final ctx = _currentDayKey.currentContext;
    if (ctx == null || !_scrollController.hasClients) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.15,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Calcule les dates des jours marqués lus hors séquence (trous avant eux).
  Set<DateTime> _computeOutOfSequenceDates() {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final sortedPast = widget.days
        .where((d) {
          final dn = DateTime(d.date.year, d.date.month, d.date.day);
          return !dn.isAfter(todayNorm);
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    DateTime? earliestUncompleted;
    for (final d in sortedPast) {
      if (!d.completed) {
        earliestUncompleted = DateTime(d.date.year, d.date.month, d.date.day);
        break;
      }
    }
    if (earliestUncompleted == null) return {};

    return sortedPast
        .where((d) {
          final dn = DateTime(d.date.year, d.date.month, d.date.day);
          return d.completed && dn.isAfter(earliestUncompleted!);
        })
        .map((d) => DateTime(d.date.year, d.date.month, d.date.day))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) {
      return const Center(child: Text('Aucun jour de lecture'));
    }

    final outOfSequenceDates = _computeOutOfSequenceDates();

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.days.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final day = widget.days[index];
        final isCurrent = widget.currentDayIndex == index;
        final isCompleted = day.completed;
        final isFuture =
            widget.currentDayIndex != null && index > widget.currentDayIndex!;
        final dayNorm = DateTime(day.date.year, day.date.month, day.date.day);
        final isOutOfSequence = outOfSequenceDates.contains(dayNorm);

        if (isCurrent) {
          return TodayCardWidget(
            key: _currentDayKey,
            day: day,
            onMarkComplete: widget.showCheckbox &&
                    !widget.isPreviewMode &&
                    widget.onDayTap != null
                ? () => widget.onDayTap!(index)
                : null,
            showButton: widget.showCheckbox && !widget.isPreviewMode,
          );
        }

        return DayCardWidget(
          day: day,
          dayIndex: index,
          isCurrent: false,
          isCompleted: isCompleted,
          isFuture: isFuture,
          isOutOfSequence: isOutOfSequence,
          showCheckbox: widget.showCheckbox,
          isPreviewMode: widget.isPreviewMode,
          onTap: widget.onDayTap != null ? () => widget.onDayTap!(index) : null,
        );
      },
    );
  }
}
