import 'models.dart';
import 'bible_data.dart';

/// Plan du Professeur Grant Horner
/// 10 listes distinctes, 1 chapitre par liste par jour = 10 chapitres/jour
/// Chaque liste avance indépendamment et boucle à la fin

class HornerList {
  final String id;
  final String name;
  final List<String> books;

  const HornerList({
    required this.id,
    required this.name,
    required this.books,
  });

  /// Calcule le nombre total de chapitres dans cette liste
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

/// Les 10 listes OFFICIELLES du plan Horner
final List<HornerList> hornerLists = [
  // Liste 1: Évangiles (89 chapitres total)
  HornerList(
    id: 'gospels',
    name: 'Évangiles',
    books: ['Matthieu', 'Marc', 'Luc', 'Jean'],
  ),

  // Liste 2: Actes → Apocalypse (50 chapitres)
  HornerList(
    id: 'acts_to_revelation',
    name: 'Actes à Apocalypse',
    books: ['Actes', 'Apocalypse'],
  ),

  // Liste 3: Psaumes (150 chapitres)
  HornerList(
    id: 'psalms',
    name: 'Psaumes',
    books: ['Psaumes'],
  ),

  // Liste 4: Proverbes (31 chapitres)
  HornerList(
    id: 'proverbs',
    name: 'Proverbes',
    books: ['Proverbes'],
  ),

  // Liste 5: Pentateuque (187 chapitres)
  HornerList(
    id: 'pentateuch',
    name: 'Pentateuque',
    books: ['Genèse', 'Exode', 'Lévitique', 'Nombres', 'Deutéronome'],
  ),

  // Liste 6: Histoire - Josué à Esther (249 chapitres)
  HornerList(
    id: 'history',
    name: 'Livres historiques',
    books: [
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
    ],
  ),

  // Liste 7: Job → Cantique (62 chapitres)
  HornerList(
    id: 'wisdom',
    name: 'Livres de sagesse',
    books: ['Job', 'Ecclésiaste', 'Cantique des cantiques'],
  ),

  // Liste 8: Prophètes majeurs (183 chapitres)
  HornerList(
    id: 'major_prophets',
    name: 'Prophètes majeurs',
    books: ['Ésaïe', 'Jérémie', 'Lamentations', 'Ézéchiel', 'Daniel'],
  ),

  // Liste 9: Prophètes mineurs (67 chapitres)
  HornerList(
    id: 'minor_prophets',
    name: 'Prophètes mineurs',
    books: [
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

  // Liste 10: Épîtres - Romains à Jude (87 chapitres)
  HornerList(
    id: 'epistles',
    name: 'Épîtres',
    books: [
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
    ],
  ),
];

/// Génère les passages pour un jour donné du plan Horner
/// dayIndex: jour 0-based
List<Passage> generateHornerDayPassages(int dayIndex) {
  final passages = <Passage>[];

  for (final list in hornerLists) {
    // Calcule l'index du chapitre dans cette liste (avec bouclage)
    final chapterIndex = dayIndex % list.totalChapters;
    final passage = list.getPassageAtIndex(chapterIndex);

    if (passage != null) {
      passages.add(passage);
    }
  }

  return passages;
}
