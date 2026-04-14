import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';

/// Widget réutilisable pour afficher la carte du jour actuel de lecture
/// Utilisé dans MonthCalendarWidget et ListViewWidget
class TodayCardWidget extends StatefulWidget {
  final ReadingDay day;
  final VoidCallback? onMarkComplete;
  final bool showButton;

  const TodayCardWidget({
    super.key,
    required this.day,
    this.onMarkComplete,
    this.showButton = true,
  });

  @override
  State<TodayCardWidget> createState() => _TodayCardWidgetState();
}

class _TodayCardWidgetState extends State<TodayCardWidget> {
  late Set<int> _completedPassages;

  @override
  void initState() {
    super.initState();
    _completedPassages = _initialCompleted();
  }

  @override
  void didUpdateWidget(TodayCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day != widget.day) {
      setState(() => _completedPassages = _initialCompleted());
    }
  }

  Set<int> _initialCompleted() {
    if (widget.day.completed) {
      return Set.from(List.generate(widget.day.passages.length, (i) => i));
    }
    return {};
  }

  void _togglePassage(int index) {
    final wasAll = _completedPassages.length == widget.day.passages.length;

    setState(() {
      if (_completedPassages.contains(index)) {
        _completedPassages.remove(index);
      } else {
        _completedPassages.add(index);
      }
    });

    final isNowAll = _completedPassages.length == widget.day.passages.length;

    // Déclencher le toggle uniquement aux transitions complété ↔ non-complété
    if (!wasAll && isNowAll) {
      widget.onMarkComplete?.call();
    } else if (wasAll && !isNowAll) {
      widget.onMarkComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('d MMMM', 'fr_FR').format(widget.day.date);
    final passages = widget.day.passages;
    final completedCount = _completedPassages.length;
    final totalCount = passages.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final allCompleted = totalCount > 0 && completedCount == totalCount;
    final canInteract = widget.showButton && widget.onMarkComplete != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3D52), Color(0xFF0F2232)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.seedGold,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LECTURE DU JOUR',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            // Date
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            // Passages individuels
            if (passages.isEmpty)
              Text(
                'Aucune lecture',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              )
            else
              ...passages.asMap().entries.map((entry) {
                final i = entry.key;
                final passage = entry.value;
                final isChecked = _completedPassages.contains(i);
                return GestureDetector(
                  onTap: canInteract ? () => _togglePassage(i) : null,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isChecked
                                ? AppTheme.seedGold
                                : Colors.transparent,
                            border: Border.all(
                              color: isChecked
                                  ? AppTheme.seedGold
                                  : Colors.white.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: isChecked
                              ? Icon(Icons.check,
                                  size: 13, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            passage.reference,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: isChecked
                                      ? Colors.white.withValues(alpha: 0.45)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: Colors.white.withValues(alpha: 0.45),
                                  decorationThickness: 2,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 8),

            // Bouton progressif
            if (widget.showButton && widget.onMarkComplete != null)
              _ProgressButton(
                progress: progress,
                completedCount: completedCount,
                totalCount: totalCount,
                allCompleted: allCompleted,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressButton extends StatelessWidget {
  final double progress;
  final int completedCount;
  final int totalCount;
  final bool allCompleted;

  const _ProgressButton({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.allCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        progress >= 0.5 ? AppTheme.deepNavy : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 52,
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.seedGold,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Remplissage progressif
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: constraints.maxWidth * progress,
                color: AppTheme.seedGold,
              ),

              // Label centré
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: allCompleted
                      ? Row(
                          key: const ValueKey('done'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 18, color: textColor),
                            const SizedBox(width: 8),
                            Text(
                              'Lecture complète',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        )
                      : Text(
                          key: const ValueKey('progress'),
                          '$completedCount / $totalCount passage${totalCount > 1 ? 's' : ''} lu${completedCount > 1 ? 's' : ''}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
