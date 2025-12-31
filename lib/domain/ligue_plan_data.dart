import 'models.dart';

/// Plan Bible en 1 an de la Ligue
/// Lecture quotidienne équilibrée : AT + Psaume + Proverbe + NT
/// 365 jours

class LigueDayDefinition {
  final int dayIndex;
  final List<Passage> passages;

  const LigueDayDefinition({
    required this.dayIndex,
    required this.passages,
  });
}

/// Exemple des premiers jours du plan de la Ligue
/// TODO: Compléter avec les 365 jours
final List<LigueDayDefinition> liguePlanDays = [
  // Jour 1
  LigueDayDefinition(
    dayIndex: 0,
    passages: [
      Passage(book: 'Genèse', fromChapter: 1, toChapter: 1),
      Passage(book: 'Psaumes', fromChapter: 1, toChapter: 1),
      Passage(book: 'Proverbes', fromChapter: 1, toChapter: 1),
      Passage(book: 'Matthieu', fromChapter: 1, toChapter: 1),
    ],
  ),
  // Jour 2
  LigueDayDefinition(
    dayIndex: 1,
    passages: [
      Passage(book: 'Genèse', fromChapter: 2, toChapter: 2),
      Passage(book: 'Psaumes', fromChapter: 2, toChapter: 2),
      Passage(book: 'Proverbes', fromChapter: 2, toChapter: 2),
      Passage(book: 'Matthieu', fromChapter: 2, toChapter: 2),
    ],
  ),
  // Jour 3
  LigueDayDefinition(
    dayIndex: 2,
    passages: [
      Passage(book: 'Genèse', fromChapter: 3, toChapter: 3),
      Passage(book: 'Psaumes', fromChapter: 3, toChapter: 3),
      Passage(book: 'Proverbes', fromChapter: 3, toChapter: 3),
      Passage(book: 'Matthieu', fromChapter: 3, toChapter: 3),
    ],
  ),
];
