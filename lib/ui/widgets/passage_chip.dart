import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';

/// Widget représentant un chip de passage biblique
/// Peut inclure une checkbox pour marquer comme lu
class PassageChip extends StatelessWidget {
  final Passage passage;
  final bool isPreviewMode;
  final bool showCheckbox;
  final bool isComplete;
  final bool isCurrent;
  final bool usePillStyle;
  final Function(bool?)? onCheckChanged;

  const PassageChip({
    super.key,
    required this.passage,
    this.isPreviewMode = false,
    this.showCheckbox = false,
    this.isComplete = false,
    this.isCurrent = false,
    this.usePillStyle = false,
    this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Style pill arrondi pour la vue hebdomadaire
    if (usePillStyle) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppTheme.seedGold.withValues(alpha: 0.15)
              : isComplete
                  ? AppTheme.textMuted.withValues(alpha: 0.1)
                  : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? AppTheme.seedGold
                : AppTheme.borderSubtle,
            width: 1,
          ),
        ),
        child: Text(
          passage.reference,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isCurrent
                    ? AppTheme.seedGold
                    : isComplete
                        ? AppTheme.textMuted
                        : AppTheme.deepNavy,
                fontWeight: FontWeight.w600,
                decoration: isComplete ? TextDecoration.lineThrough : null,
              ),
        ),
      );
    }

    // Mode avec checkbox
    if (showCheckbox && !isPreviewMode) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isComplete
              ? AppTheme.seedGold.withValues(alpha: 0.1)
              : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isComplete
                ? AppTheme.seedGold
                : AppTheme.borderSubtle,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: isComplete,
                onChanged: onCheckChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                activeColor: AppTheme.seedGold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              passage.reference,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.deepNavy,
                    decoration:
                        isComplete ? TextDecoration.lineThrough : null,
                  ),
            ),
          ],
        ),
      );
    }

    // Mode simple standard
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isComplete
            ? AppTheme.textMuted.withValues(alpha: 0.05)
            : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isComplete
              ? AppTheme.borderSubtle.withValues(alpha: 0.5)
              : AppTheme.borderSubtle,
          width: 0.5,
        ),
      ),
      child: Text(
        passage.reference,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isComplete ? AppTheme.textMuted : AppTheme.deepNavy,
              decoration: isComplete ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
