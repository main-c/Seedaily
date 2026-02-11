import 'models.dart';
import 'bible_data.dart';

/// Plan Révolutionnaire - Lire la Bible en 1 an avec 25 jours de lecture par mois
/// 25 jours × 12 mois = 300 jours de lecture
/// 5-6 jours de repos/rattrapage par mois intégrés
/// Lecture séquentielle de toute la Bible

class RevolutionaryPlanConfig {
  /// Nombre de jours de lecture par mois
  static const int readingDaysPerMonth = 25;

  /// Nombre total de jours de lecture
  static const int totalReadingDays = 300;

  /// Livres de la Bible dans l'ordre canonique pour lecture séquentielle
  static const List<String> canonicalOrder = [
    // Ancien Testament
    'Genèse',
    'Exode',
    'Lévitique',
    'Nombres',
    'Deutéronome',
    'Josué',
    'Juges',
    'Ruth',
    '1 Samuel',
    '2 Samuel',
    '1 Rois',
    '2 Rois',
    '1 Chroniques',
    '2 Chroniques',
    'Esdras',
    'Néhémie',
    'Esther',
    'Job',
    'Psaumes',
    'Proverbes',
    'Ecclésiaste',
    'Cantique des cantiques',
    'Ésaïe',
    'Jérémie',
    'Lamentations',
    'Ézéchiel',
    'Daniel',
    'Osée',
    'Joël',
    'Amos',
    'Abdias',
    'Jonas',
    'Michée',
    'Nahum',
    'Habacuc',
    'Sophonie',
    'Aggée',
    'Zacharie',
    'Malachie',
    // Nouveau Testament
    'Matthieu',
    'Marc',
    'Luc',
    'Jean',
    'Actes',
    'Romains',
    '1 Corinthiens',
    '2 Corinthiens',
    'Galates',
    'Éphésiens',
    'Philippiens',
    'Colossiens',
    '1 Thessaloniciens',
    '2 Thessaloniciens',
    '1 Timothée',
    '2 Timothée',
    'Tite',
    'Philémon',
    'Hébreux',
    'Jacques',
    '1 Pierre',
    '2 Pierre',
    '1 Jean',
    '2 Jean',
    '3 Jean',
    'Jude',
    'Apocalypse',
  ];
}

/// Génère la liste complète des chapitres dans l'ordre canonique
List<Passage> _buildCanonicalChapterList() {
  final chapters = <Passage>[];

  for (final bookName in RevolutionaryPlanConfig.canonicalOrder) {
    final book = BibleData.getBook(bookName);
    if (book == null) continue;

    for (int chapter = 1; chapter <= book.chapters; chapter++) {
      chapters.add(Passage(
        book: bookName,
        fromChapter: chapter,
        toChapter: chapter,
      ));
    }
  }

  return chapters;
}

/// Cache pour les chapitres
List<Passage>? _cachedChapters;

List<Passage> get _allChapters {
  _cachedChapters ??= _buildCanonicalChapterList();
  return _cachedChapters!;
}

/// Calcule le nombre total de chapitres dans la Bible
int get totalBibleChapters => _allChapters.length;

/// Calcule le nombre moyen de chapitres par jour
double get chaptersPerDay =>
    totalBibleChapters / RevolutionaryPlanConfig.totalReadingDays;

/// Génère les passages pour un jour donné du plan Revolutionary
/// dayIndex: jour de lecture 0-based (0 = jour 1)
/// Retourne les chapitres pour ce jour (environ 4 chapitres par jour)
List<Passage> generateRevolutionaryDayPassages(int dayIndex) {
  final totalChapters = totalBibleChapters;
  final totalDays = RevolutionaryPlanConfig.totalReadingDays;

  // Calcule les indices de début et fin pour ce jour
  // Distribution équitable des chapitres sur les 300 jours
  final startIndex = (dayIndex * totalChapters / totalDays).floor();
  final endIndex = ((dayIndex + 1) * totalChapters / totalDays).floor();

  // Récupère les chapitres pour ce jour
  final dayChapters = <Passage>[];
  for (int i = startIndex; i < endIndex && i < totalChapters; i++) {
    dayChapters.add(_allChapters[i]);
  }

  // Fusionne les passages consécutifs du même livre
  return _mergeConsecutivePassages(dayChapters);
}

/// Fusionne les passages consécutifs du même livre
List<Passage> _mergeConsecutivePassages(List<Passage> passages) {
  if (passages.isEmpty) return passages;

  final merged = <Passage>[];
  Passage current = passages.first;

  for (int i = 1; i < passages.length; i++) {
    final next = passages[i];

    // Si même livre et chapitre consécutif, fusionner
    if (next.book == current.book &&
        next.fromChapter == current.toChapter + 1) {
      current = Passage(
        book: current.book,
        fromChapter: current.fromChapter,
        toChapter: next.toChapter,
      );
    } else {
      // Sinon, sauvegarder le passage courant et commencer un nouveau
      merged.add(current);
      current = next;
    }
  }

  // Ajouter le dernier passage
  merged.add(current);

  return merged;
}

/// Génère le plan complet de 300 jours de lecture
List<List<Passage>> generateFullRevolutionaryPlan() {
  return List.generate(
    RevolutionaryPlanConfig.totalReadingDays,
    (dayIndex) => generateRevolutionaryDayPassages(dayIndex),
  );
}

/// Convertit un jour de lecture en jour du mois
/// dayIndex: jour de lecture 0-based
/// Retourne (mois 1-based, jour du mois 1-based)
(int month, int dayOfMonth) getMonthAndDay(int dayIndex) {
  final month = (dayIndex ~/ RevolutionaryPlanConfig.readingDaysPerMonth) + 1;
  final dayOfMonth =
      (dayIndex % RevolutionaryPlanConfig.readingDaysPerMonth) + 1;
  return (month, dayOfMonth);
}

/// Informations sur le plan
Map<String, dynamic> getRevolutionaryPlanInfo() {
  return {
    'totalChapters': totalBibleChapters,
    'totalReadingDays': RevolutionaryPlanConfig.totalReadingDays,
    'chaptersPerDay': chaptersPerDay.toStringAsFixed(1),
    'readingDaysPerMonth': RevolutionaryPlanConfig.readingDaysPerMonth,
    'restDaysPerMonth': '5-6',
    'totalMonths': 12,
  };
}
