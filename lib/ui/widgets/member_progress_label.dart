import 'package:flutter/material.dart';

import '../../domain/group_models.dart';

/// « En retard de 3 j · 8 % », « À jour · 12 % » ou « En avance de 2 j · 15 % »,
/// suivi de l'heure de lecture du jour si le membre a lu.
class MemberProgressLabel extends StatelessWidget {
  final GroupDayStatus status;
  const MemberProgressLabel({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final behind = status.daysBehind;
    final pct = '${(status.progress * 100).round()} %';
    final rhythm = behind > 0
        ? 'En retard de $behind j'
        : behind < 0
            ? 'En avance de ${-behind} j'
            : 'À jour';
    final at = status.completedAt;
    final time = status.hasCompleted && at != null
        ? ' · lu à ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}'
        : '';

    return Text(
      '$rhythm · $pct$time',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            // Mêmes couleurs que le badge de retard de la page du plan.
            color: behind > 3
                ? Colors.red.shade700
                : behind > 0
                    ? Colors.orange.shade800
                    : cs.onSurface.withValues(alpha: 0.5),
          ),
    );
  }
}
