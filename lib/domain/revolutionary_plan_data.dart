import 'models.dart';

/// Plan révolutionnaire - 25 lectures par mois
/// Permet des jours de rattrapage/repos
/// Environ 12 mois pour lire toute la Bible

class RevolutionaryDayDefinition {
  final int dayIndex;
  final List<Passage> passages;

  const RevolutionaryDayDefinition({
    required this.dayIndex,
    required this.passages,
  });
}

/// Exemple des premiers jours du plan révolutionnaire
/// TODO: Compléter avec tous les jours nécessaires
final List<RevolutionaryDayDefinition> revolutionaryPlanDays = [
  // Jour 1
  RevolutionaryDayDefinition(
    dayIndex: 0,
    passages: [
      Passage(book: 'Genèse', fromChapter: 1, toChapter: 3),
    ],
  ),
  // Jour 2
  RevolutionaryDayDefinition(
    dayIndex: 1,
    passages: [
      Passage(book: 'Genèse', fromChapter: 4, toChapter: 6),
    ],
  ),
  // Jour 3
  RevolutionaryDayDefinition(
    dayIndex: 2,
    passages: [
      Passage(book: 'Genèse', fromChapter: 7, toChapter: 9),
    ],
  ),
];
