import 'models.dart';

/// Plan de lecture M'Cheyne.
///
/// Attention : ce fichier ne contient qu'un extrait de données pour les
/// premiers jours à titre d'exemple. Il faudra compléter l'ensemble des
/// 365 jours conformément au plan original.

class McheyneDayDefinition {
  McheyneDayDefinition({
    required this.dayIndex,
    required this.passages,
  });

  final int dayIndex; // 0-based
  final List<Passage> passages;
}

/// Quelques jours d'exemple du plan M'Cheyne.
///
/// TODO: compléter avec l'intégralité du plan (365 jours).
final List<McheyneDayDefinition> mcheynePlanDays = [
  McheyneDayDefinition(
    dayIndex: 0,
    passages: [
      Passage(book: 'Genèse', fromChapter: 1, toChapter: 1),
      Passage(book: 'Matthieu', fromChapter: 1, toChapter: 1),
      Passage(book: 'Esdras', fromChapter: 1, toChapter: 1),
      Passage(book: 'Actes', fromChapter: 1, toChapter: 1),
    ],
  ),
  McheyneDayDefinition(
    dayIndex: 1,
    passages: [
      Passage(book: 'Genèse', fromChapter: 2, toChapter: 2),
      Passage(book: 'Matthieu', fromChapter: 2, toChapter: 2),
      Passage(book: 'Esdras', fromChapter: 2, toChapter: 2),
      Passage(book: 'Actes', fromChapter: 2, toChapter: 2),
    ],
  ),
  McheyneDayDefinition(
    dayIndex: 2,
    passages: [
      Passage(book: 'Genèse', fromChapter: 3, toChapter: 3),
      Passage(book: 'Matthieu', fromChapter: 3, toChapter: 3),
      Passage(book: 'Esdras', fromChapter: 3, toChapter: 3),
      Passage(book: 'Actes', fromChapter: 3, toChapter: 3),
    ],
  ),
];





