import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../providers/bible_reader_provider.dart';
import '../screens/bible_reader_screen.dart';

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

  // Version non-toggle pour le lecteur : ne fait que cocher, jamais décocher.
  void _markPassageRead(int index) {
    if (_completedPassages.contains(index)) return;
    final wasAll = _completedPassages.length == widget.day.passages.length;
    setState(() {
      _completedPassages.add(index);
    });
    final isNowAll = _completedPassages.length == widget.day.passages.length;
    if (!wasAll && isNowAll) {
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
                final bibleProvider = context.read<BibleReaderProvider>();
                final canRead = bibleProvider.downloadedIds.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: canRead
                          ? () {
                              final nav = Navigator.of(context);
                              nav.push(MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: bibleProvider,
                                  child: BibleReaderScreen(
                                    passages: widget.day.passages,
                                    initialPassageIndex: i,
                                    onPassageComplete: _markPassageRead,
                                  ),
                                ),
                              ));
                            }
                          : canInteract
                              ? () => _togglePassage(i)
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // Cercle de complétion
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
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
                                  ? const Icon(Icons.check,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            // Référence du passage
                            Expanded(
                              child: Text(
                                passage.reference,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: isChecked
                                          ? Colors.white.withValues(alpha: 0.4)
                                          : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      decoration: isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: Colors.white
                                          .withValues(alpha: 0.4),
                                    ),
                              ),
                            ),
                            // Flèche (si lecture disponible)
                            if (canRead)
                              Icon(
                                Icons.chevron_right,
                                color: isChecked
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.6),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

            // Prompt si aucune Bible installée
            Builder(builder: (ctx) {
              final bibleProvider = ctx.read<BibleReaderProvider>();
              if (bibleProvider.downloadedIds.isNotEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => ctx.push('/bible-library'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_outlined,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.45)),
                      const SizedBox(width: 5),
                      Text(
                        'Ajouter une Bible pour lire',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Bouton progressif — ouvre le lecteur au premier passage non lu
            if (widget.showButton)
              _ProgressButton(
                progress: progress,
                completedCount: completedCount,
                totalCount: totalCount,
                allCompleted: allCompleted,
                onTap: () {
                  final bibleProvider = context.read<BibleReaderProvider>();
                  if (bibleProvider.downloadedIds.isEmpty) return;
                  // Premier passage non lu
                  final firstUnread = List.generate(passages.length, (i) => i)
                      .firstWhere((i) => !_completedPassages.contains(i),
                          orElse: () => 0);
                  final nav = Navigator.of(context);
                  nav.push(MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: bibleProvider,
                      child: BibleReaderScreen(
                        passages: widget.day.passages,
                        initialPassageIndex: firstUnread,
                        onPassageComplete: _markPassageRead,
                      ),
                    ),
                  ));
                },
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
  final VoidCallback? onTap;

  const _ProgressButton({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.allCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        progress >= 0.5 ? AppTheme.deepNavy : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
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
                      : Row(
                          key: const ValueKey('read'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book_outlined,
                                size: 16, color: textColor),
                            const SizedBox(width: 8),
                            Text(
                              completedCount > 0 ? 'Continuer la lecture' : 'Lire',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (completedCount > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '$completedCount/$totalCount',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: textColor.withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ), // Container
      ); // GestureDetector
    },
  );
  }
}
