import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';
import 'passage_chip.dart';

/// Widget représentant une carte de jour de lecture
/// Utilisé à la fois dans la preview (CustomizePlanScreen) et dans le détail du plan
class ReadingDayCard extends StatelessWidget {
  final ReadingDay day;
  final bool isPreviewMode;
  final bool showCheckbox;
  final bool showDayCheckbox;
  final bool isDayComplete;
  final Function(bool?)? onDayCheckChanged;
  final Function(Passage, bool?)? onPassageCheckChanged;
  final Set<String>? completedPassages;

  const ReadingDayCard({
    super.key,
    required this.day,
    this.isPreviewMode = false,
    this.showCheckbox = true,
    this.showDayCheckbox = true,
    this.isDayComplete = false,
    this.onDayCheckChanged,
    this.onPassageCheckChanged,
    this.completedPassages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header : Date + Checkbox du jour
            Row(
              children: [
                if (showCheckbox && showDayCheckbox) ...[
                  Checkbox(
                    value: isDayComplete,
                    onChanged: isPreviewMode ? null : onDayCheckChanged,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: AppTheme.seedGold,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    DateFormat('EEEE d MMMM', 'fr_FR').format(day.date),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepNavy,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Passages
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: day.passages.map((passage) {
                final isComplete =
                    completedPassages?.contains(_passageKey(passage)) ?? false;
                return PassageChip(
                  passage: passage,
                  isPreviewMode: isPreviewMode,
                  showCheckbox: showCheckbox && !showDayCheckbox,
                  isComplete: isComplete,
                  onCheckChanged: (value) {
                    if (!isPreviewMode && onPassageCheckChanged != null) {
                      onPassageCheckChanged!(passage, value);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _passageKey(Passage passage) {
    return '${passage.book}_${passage.fromChapter}_${passage.toChapter}';
  }
}
