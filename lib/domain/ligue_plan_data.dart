import 'models.dart';
import 'bible_data.dart';

/// Plan Bible en 1 an de la Ligue pour la Lecture de la Bible
/// 4 pistes parallèles : AT (hors Psaumes/Proverbes) + Psaumes + Proverbes + NT
/// Chaque piste avance indépendamment et boucle à la fin
/// 365 jours

class LigueReadingTrack {
  final String id;
  final String name;
  final List<String> books;

  const LigueReadingTrack({
    required this.id,
    required this.name,
    required this.books,
  });

  /// Calcule le nombre total de chapitres dans cette piste
  int get totalChapters {
    return books.fold(0, (total, bookName) {
      final book = BibleData.getBook(bookName);
      return total + (book?.chapters ?? 0);
    });
  }

  /// Récupère le passage pour un index de chapitre donné (0-based)
  Passage? getPassageAtIndex(int chapterIndex) {
    int currentIndex = 0;

    for (final bookName in books) {
      final book = BibleData.getBook(bookName);
      if (book == null) continue;

      if (chapterIndex < currentIndex + book.chapters) {
        final chapterInBook = chapterIndex - currentIndex + 1;
        return Passage(
          book: bookName,
          fromChapter: chapterInBook,
          toChapter: chapterInBook,
        );
      }

      currentIndex += book.chapters;
    }

    return null;
  }
}

/// Les 4 pistes de lecture du plan Ligue
final List<LigueReadingTrack> ligueTracks = [
  // Piste 1: Ancien Testament (hors Psaumes et Proverbes)
  // ~892 chapitres - cycle tous les ~2.4 ans
  LigueReadingTrack(
    id: 'old_testament',
    name: 'Ancien Testament',
    books: [
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
    ],
  ),

  // Piste 2: Psaumes (150 chapitres) - cycle ~2.4 fois par an
  LigueReadingTrack(
    id: 'psalms',
    name: 'Psaumes',
    books: ['Psaumes'],
  ),

  // Piste 3: Proverbes (31 chapitres) - cycle ~12 fois par an
  LigueReadingTrack(
    id: 'proverbs',
    name: 'Proverbes',
    books: ['Proverbes'],
  ),

  // Piste 4: Nouveau Testament (260 chapitres) - cycle ~1.4 fois par an
  LigueReadingTrack(
    id: 'new_testament',
    name: 'Nouveau Testament',
    books: [
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
    ],
  ),
];

/// Génère les passages pour un jour donné du plan Ligue
/// dayIndex: jour 0-based (0 = jour 1)
/// Retourne 4 passages : 1 AT + 1 Psaume + 1 Proverbe + 1 NT
List<Passage> generateLigueDayPassages(int dayIndex) {
  final passages = <Passage>[];

  for (final track in ligueTracks) {
    // Calcule l'index du chapitre dans cette piste (avec bouclage)
    final chapterIndex = dayIndex % track.totalChapters;
    final passage = track.getPassageAtIndex(chapterIndex);

    if (passage != null) {
      passages.add(passage);
    }
  }

  return passages;
}

/// Génère le plan complet de 365 jours
List<List<Passage>> generateFullLiguePlan({int days = 365}) {
  return List.generate(days, (dayIndex) => generateLigueDayPassages(dayIndex));
}

/// Informations sur les cycles de lecture
Map<String, dynamic> getLigueTrackInfo() {
  return {
    for (final track in ligueTracks)
      track.id: {
        'name': track.name,
        'totalChapters': track.totalChapters,
        'cyclesPerYear': (365 / track.totalChapters).toStringAsFixed(2),
        'books': track.books,
      },
  };
}
