import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../domain/bible_data.dart';
import '../../domain/models.dart';
import 'reading_day_card.dart';

/// Widget pour l'affichage par livre biblique (format By Book)
/// Regroupe les jours de lecture par livre avec un en-tête pour chaque livre
class ByBookViewWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const Center(
        child: Text('Aucun jour de lecture'),
      );
    }

    // Regrouper les jours par livre
    final bookGroups = _groupByBook(days);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookGroups.length,
      itemBuilder: (context, bookIndex) {
        final bookData = bookGroups[bookIndex];
        final bookName = bookData['bookName'] as String;
        final bookDays = bookData['days'] as List<MapEntry<int, ReadingDay>>;
        final totalChapters = bookData['totalChapters'] as int;
        final book = BibleData.getBook(bookName);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de livre
            _buildBookHeader(context, bookName, book, totalChapters,
                bookDays.length),
            const SizedBox(height: 12),

            // Jours pour ce livre
            ...bookDays.map((entry) {
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

  Widget _buildBookHeader(
    BuildContext context,
    String bookName,
    BibleBook? book,
    int totalChapters,
    int daysCount,
  ) {
    // Déterminer la catégorie du livre pour l'icône et la couleur
    final testament = book?.isOldTestament == true ? 'AT' : 'NT';
    final testamentColor = book?.isOldTestament == true
        ? AppTheme.deepNavy
        : AppTheme.seedGold;

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
      child: Row(
        children: [
          // Icône du livre
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

          // Informations du livre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bookName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: testamentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        testament,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                    const Icon(
                      Icons.library_books,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalChapters chapitre${totalChapters > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$daysCount jour${daysCount > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }

  List<Map<String, dynamic>> _groupByBook(List<ReadingDay> days) {
    final bookGroups = <Map<String, dynamic>>[];
    String? currentBook;
    List<MapEntry<int, ReadingDay>> currentBookDays = [];
    Set<int> currentBookChapters = {};

    for (int i = 0; i < days.length; i++) {
      final day = days[i];

      // Trouver le premier livre dans les passages du jour
      // (on assume que les jours sont organisés par livre dans le générateur)
      final firstBookInDay = day.passages.isNotEmpty
          ? day.passages.first.book
          : null;

      if (firstBookInDay == null) continue;

      // Si on change de livre, sauvegarder le groupe précédent
      if (currentBook != null && firstBookInDay != currentBook) {
        if (currentBookDays.isNotEmpty) {
          bookGroups.add({
            'bookName': currentBook,
            'days': List<MapEntry<int, ReadingDay>>.from(currentBookDays),
            'totalChapters': currentBookChapters.length,
          });
          currentBookDays = [];
          currentBookChapters = {};
        }
      }

      currentBook = firstBookInDay;
      currentBookDays.add(MapEntry(i, day));

      // Compter les chapitres uniques pour ce livre
      for (final passage in day.passages) {
        if (passage.book == currentBook) {
          for (int ch = passage.fromChapter; ch <= passage.toChapter; ch++) {
            currentBookChapters.add(ch);
          }
        }
      }
    }

    // Ajouter le dernier groupe
    if (currentBook != null && currentBookDays.isNotEmpty) {
      bookGroups.add({
        'bookName': currentBook,
        'days': currentBookDays,
        'totalChapters': currentBookChapters.length,
      });
    }

    return bookGroups;
  }
}
