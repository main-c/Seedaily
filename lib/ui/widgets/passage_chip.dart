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
  final Function(bool?)? onCheckChanged;

  const PassageChip({
    super.key,
    required this.passage,
    this.isPreviewMode = false,
    this.showCheckbox = false,
    this.isComplete = false,
    this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (showCheckbox && !isPreviewMode) {
      // Mode interactif : checkbox + texte
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
    } else {
      // Mode simple : juste le texte
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.borderSubtle,
            width: 0.5,
          ),
        ),
        child: Text(
          passage.reference,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.deepNavy,
              ),
        ),
      );
    }
  }
}
