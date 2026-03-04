import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme.dart';
import '../../domain/bible_data.dart';
import '../../domain/models.dart';
import 'day_card_widget.dart';

/// Widget pour l'affichage par livre biblique (format By Book)
/// Regroupe les jours de lecture par livre avec un en-tête pour chaque livre
class ByBookViewWidget extends StatefulWidget {
  final List<ReadingDay> days;
  final int? currentDayIndex;
  final int? selectedDayIndex;
  final Function(int)? onDayTap;
  final bool isPreviewMode;
  final bool showCheckbox;

  const ByBookViewWidget({
    super.key,
    required this.days,
    this.currentDayIndex,
    this.selectedDayIndex,
    this.onDayTap,
    this.isPreviewMode = false,
    this.showCheckbox = true,
  });

  @override
  State<ByBookViewWidget> createState() => _ByBookViewWidgetState();
}

class _ByBookViewWidgetState extends State<ByBookViewWidget> {
  static const double _estimatedDayHeight = 165.0;
  static const double _estimatedHeaderHeight = 148.0; // header + SizedBox(12)
  static const double _estimatedGroupFooter = 48.0;  // SizedBox(12) + Divider + SizedBox(24)

  late final ScrollController _scrollController;
  late final List<Map<String, dynamic>> _bookGroups;
  final GlobalKey _currentDayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _bookGroups = _groupByBook(widget.days);

    final estimatedOffset = _computeScrollOffset();
    _scrollController =
        ScrollController(initialScrollOffset: estimatedOffset);

    if (widget.currentDayIndex != null && estimatedOffset > 0) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToToday());
    }
  }

  /// Estime l'offset de scroll jusqu'au groupe contenant currentDayIndex
  double _computeScrollOffset() {
    if (widget.currentDayIndex == null || widget.currentDayIndex == 0) {
      return 0.0;
    }
    double offset = 0.0;
    for (final group in _bookGroups) {
      final groupDays =
          group['days'] as List<MapEntry<int, ReadingDay>>;
      final containsCurrent =
          groupDays.any((e) => e.key == widget.currentDayIndex);
      if (containsCurrent) {
        offset += _estimatedHeaderHeight;
        for (final entry in groupDays) {
          if (entry.key == widget.currentDayIndex) break;
          offset += _estimatedDayHeight;
        }
        break;
      }
      offset += _estimatedHeaderHeight +
          groupDays.length * _estimatedDayHeight +
          _estimatedGroupFooter;
    }
    return offset.clamp(0.0, double.infinity);
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

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) {
      return const Center(child: Text('Aucun jour de lecture'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _bookGroups.length,
      itemBuilder: (context, bookIndex) {
        final bookData = _bookGroups[bookIndex];
        final bookName = bookData['bookName'] as String;
        final bookDays =
            bookData['days'] as List<MapEntry<int, ReadingDay>>;
        final totalChapters = bookData['totalChapters'] as int;
        final completedDays = bookData['completedDays'] as int;
        final book = BibleData.getBook(bookName);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookHeader(
              context,
              bookName,
              book,
              totalChapters,
              bookDays.length,
              completedDays,
            ),
            const SizedBox(height: 12),

            ...bookDays.map((entry) {
              final dayIndex = entry.key;
              final day = entry.value;
              final isCurrent = widget.currentDayIndex == dayIndex;
              final isFuture = widget.currentDayIndex != null &&
                  dayIndex > widget.currentDayIndex!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DayCardWidget(
                  key: isCurrent ? _currentDayKey : null,
                  day: day,
                  dayIndex: dayIndex,
                  isCurrent: isCurrent,
                  isCompleted: day.completed,
                  isFuture: isFuture,
                  showCheckbox: widget.showCheckbox,
                  isPreviewMode: widget.isPreviewMode,
                  onTap: widget.onDayTap != null
                      ? () => widget.onDayTap!(dayIndex)
                      : null,
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

  Widget _buildBookHeader(
    BuildContext context,
    String bookName,
    BibleBook? book,
    int totalChapters,
    int daysCount,
    int completedDays,
  ) {
    final testament = book?.isOldTestament == true ? 'AT' : 'NT';
    final testamentColor =
        book?.isOldTestament == true ? AppTheme.deepNavy : AppTheme.seedGold;
    final progressPercentage =
        daysCount > 0 ? completedDays / daysCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            testamentColor.withValues(alpha: 0.1),
            testamentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: testamentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: testamentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: AppTheme.surface,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bookName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepNavy,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: testamentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            testament,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: testamentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.library_books,
                            size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '$totalChapters chapitre${totalChapters > 1 ? 's' : ''}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today,
                            size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '$daysCount jour${daysCount > 1 ? 's' : ''}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                    value: progressPercentage,
                    backgroundColor: AppTheme.borderSubtle,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(testamentColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progressPercentage * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: testamentColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupByBook(List<ReadingDay> days) {
    final bookGroups = <Map<String, dynamic>>[];
    String? currentBook;
    List<MapEntry<int, ReadingDay>> currentBookDays = [];
    Set<int> currentBookChapters = {};
    int currentCompletedDays = 0;

    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final firstBookInDay =
          day.passages.isNotEmpty ? day.passages.first.book : null;
      if (firstBookInDay == null) continue;

      if (currentBook != null && firstBookInDay != currentBook) {
        if (currentBookDays.isNotEmpty) {
          bookGroups.add({
            'bookName': currentBook,
            'days': List<MapEntry<int, ReadingDay>>.from(currentBookDays),
            'totalChapters': currentBookChapters.length,
            'completedDays': currentCompletedDays,
          });
          currentBookDays = [];
          currentBookChapters = {};
          currentCompletedDays = 0;
        }
      }

      currentBook = firstBookInDay;
      currentBookDays.add(MapEntry(i, day));
      if (day.completed) currentCompletedDays++;
      for (final passage in day.passages) {
        if (passage.book == currentBook) {
          for (int ch = passage.fromChapter; ch <= passage.toChapter; ch++) {
            currentBookChapters.add(ch);
          }
        }
      }
    }

    if (currentBook != null && currentBookDays.isNotEmpty) {
      bookGroups.add({
        'bookName': currentBook,
        'days': currentBookDays,
        'totalChapters': currentBookChapters.length,
        'completedDays': currentCompletedDays,
      });
    }

    return bookGroups;
  }
}
