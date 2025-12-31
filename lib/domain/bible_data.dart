class BibleBook {
  final String name;
  final int chapters;
  final bool isOldTestament;
  final bool isNewTestament;
  final int canonicalOrder;
  final int chronologicalOrder;

  const BibleBook({
    required this.name,
    required this.chapters,
    required this.isOldTestament,
    required this.isNewTestament,
    required this.canonicalOrder,
    required this.chronologicalOrder,
  });
}

class BibleData {
  static const List<BibleBook> books = [
    // Ancien Testament
    BibleBook(
        name: 'Genèse',
        chapters: 50,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 1,
        chronologicalOrder: 1),
    BibleBook(
        name: 'Exode',
        chapters: 40,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 2,
        chronologicalOrder: 2),
    BibleBook(
        name: 'Lévitique',
        chapters: 27,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 3,
        chronologicalOrder: 3),
    BibleBook(
        name: 'Nombres',
        chapters: 36,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 4,
        chronologicalOrder: 4),
    BibleBook(
        name: 'Deutéronome',
        chapters: 34,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 5,
        chronologicalOrder: 5),
    BibleBook(
        name: 'Josué',
        chapters: 24,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 6,
        chronologicalOrder: 6),
    BibleBook(
        name: 'Juges',
        chapters: 21,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 7,
        chronologicalOrder: 7),
    BibleBook(
        name: 'Ruth',
        chapters: 4,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 8,
        chronologicalOrder: 8),
    BibleBook(
        name: '1 Samuel',
        chapters: 31,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 9,
        chronologicalOrder: 9),
    BibleBook(
        name: '2 Samuel',
        chapters: 24,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 10,
        chronologicalOrder: 10),
    BibleBook(
        name: '1 Rois',
        chapters: 22,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 11,
        chronologicalOrder: 11),
    BibleBook(
        name: '2 Rois',
        chapters: 25,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 12,
        chronologicalOrder: 12),
    BibleBook(
        name: '1 Chroniques',
        chapters: 29,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 13,
        chronologicalOrder: 13),
    BibleBook(
        name: '2 Chroniques',
        chapters: 36,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 14,
        chronologicalOrder: 14),
    BibleBook(
        name: 'Esdras',
        chapters: 10,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 15,
        chronologicalOrder: 15),
    BibleBook(
        name: 'Néhémie',
        chapters: 13,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 16,
        chronologicalOrder: 16),
    BibleBook(
        name: 'Esther',
        chapters: 10,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 17,
        chronologicalOrder: 17),
    BibleBook(
        name: 'Job',
        chapters: 42,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 18,
        chronologicalOrder: 18),
    BibleBook(
        name: 'Psaumes',
        chapters: 150,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 19,
        chronologicalOrder: 19),
    BibleBook(
        name: 'Proverbes',
        chapters: 31,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 20,
        chronologicalOrder: 20),
    BibleBook(
        name: 'Ecclésiaste',
        chapters: 12,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 21,
        chronologicalOrder: 21),
    BibleBook(
        name: 'Cantique des cantiques',
        chapters: 8,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 22,
        chronologicalOrder: 22),
    BibleBook(
        name: 'Ésaïe',
        chapters: 66,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 23,
        chronologicalOrder: 23),
    BibleBook(
        name: 'Jérémie',
        chapters: 52,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 24,
        chronologicalOrder: 24),
    BibleBook(
        name: 'Lamentations',
        chapters: 5,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 25,
        chronologicalOrder: 25),
    BibleBook(
        name: 'Ézéchiel',
        chapters: 48,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 26,
        chronologicalOrder: 26),
    BibleBook(
        name: 'Daniel',
        chapters: 12,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 27,
        chronologicalOrder: 27),
    BibleBook(
        name: 'Osée',
        chapters: 14,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 28,
        chronologicalOrder: 28),
    BibleBook(
        name: 'Joël',
        chapters: 3,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 29,
        chronologicalOrder: 29),
    BibleBook(
        name: 'Amos',
        chapters: 9,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 30,
        chronologicalOrder: 30),
    BibleBook(
        name: 'Abdias',
        chapters: 1,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 31,
        chronologicalOrder: 31),
    BibleBook(
        name: 'Jonas',
        chapters: 4,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 32,
        chronologicalOrder: 32),
    BibleBook(
        name: 'Michée',
        chapters: 7,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 33,
        chronologicalOrder: 33),
    BibleBook(
        name: 'Nahum',
        chapters: 3,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 34,
        chronologicalOrder: 34),
    BibleBook(
        name: 'Habacuc',
        chapters: 3,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 35,
        chronologicalOrder: 35),
    BibleBook(
        name: 'Sophonie',
        chapters: 3,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 36,
        chronologicalOrder: 36),
    BibleBook(
        name: 'Aggée',
        chapters: 2,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 37,
        chronologicalOrder: 37),
    BibleBook(
        name: 'Zacharie',
        chapters: 14,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 38,
        chronologicalOrder: 38),
    BibleBook(
        name: 'Malachie',
        chapters: 4,
        isOldTestament: true,
        isNewTestament: false,
        canonicalOrder: 39,
        chronologicalOrder: 39),

    // Nouveau Testament
    BibleBook(
        name: 'Matthieu',
        chapters: 28,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 40,
        chronologicalOrder: 40),
    BibleBook(
        name: 'Marc',
        chapters: 16,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 41,
        chronologicalOrder: 41),
    BibleBook(
        name: 'Luc',
        chapters: 24,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 42,
        chronologicalOrder: 42),
    BibleBook(
        name: 'Jean',
        chapters: 21,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 43,
        chronologicalOrder: 43),
    BibleBook(
        name: 'Actes',
        chapters: 28,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 44,
        chronologicalOrder: 44),
    BibleBook(
        name: 'Romains',
        chapters: 16,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 45,
        chronologicalOrder: 45),
    BibleBook(
        name: '1 Corinthiens',
        chapters: 16,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 46,
        chronologicalOrder: 46),
    BibleBook(
        name: '2 Corinthiens',
        chapters: 13,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 47,
        chronologicalOrder: 47),
    BibleBook(
        name: 'Galates',
        chapters: 6,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 48,
        chronologicalOrder: 48),
    BibleBook(
        name: 'Éphésiens',
        chapters: 6,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 49,
        chronologicalOrder: 49),
    BibleBook(
        name: 'Philippiens',
        chapters: 4,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 50,
        chronologicalOrder: 50),
    BibleBook(
        name: 'Colossiens',
        chapters: 4,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 51,
        chronologicalOrder: 51),
    BibleBook(
        name: '1 Thessaloniciens',
        chapters: 5,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 52,
        chronologicalOrder: 52),
    BibleBook(
        name: '2 Thessaloniciens',
        chapters: 3,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 53,
        chronologicalOrder: 53),
    BibleBook(
        name: '1 Timothée',
        chapters: 6,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 54,
        chronologicalOrder: 54),
    BibleBook(
        name: '2 Timothée',
        chapters: 4,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 55,
        chronologicalOrder: 55),
    BibleBook(
        name: 'Tite',
        chapters: 3,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 56,
        chronologicalOrder: 56),
    BibleBook(
        name: 'Philémon',
        chapters: 1,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 57,
        chronologicalOrder: 57),
    BibleBook(
        name: 'Hébreux',
        chapters: 13,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 58,
        chronologicalOrder: 58),
    BibleBook(
        name: 'Jacques',
        chapters: 5,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 59,
        chronologicalOrder: 59),
    BibleBook(
        name: '1 Pierre',
        chapters: 5,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 60,
        chronologicalOrder: 60),
    BibleBook(
        name: '2 Pierre',
        chapters: 3,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 61,
        chronologicalOrder: 61),
    BibleBook(
        name: '1 Jean',
        chapters: 5,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 62,
        chronologicalOrder: 62),
    BibleBook(
        name: '2 Jean',
        chapters: 1,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 63,
        chronologicalOrder: 63),
    BibleBook(
        name: '3 Jean',
        chapters: 1,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 64,
        chronologicalOrder: 64),
    BibleBook(
        name: 'Jude',
        chapters: 1,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 65,
        chronologicalOrder: 65),
    BibleBook(
        name: 'Apocalypse',
        chapters: 22,
        isOldTestament: false,
        isNewTestament: true,
        canonicalOrder: 66,
        chronologicalOrder: 66),
  ];

  static BibleBook? getBook(String name) {
    try {
      return books.firstWhere(
        (book) => book.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static List<BibleBook> getOldTestamentBooks() {
    return books.where((book) => book.isOldTestament).toList();
  }

  static List<BibleBook> getNewTestamentBooks() {
    return books.where((book) => book.isNewTestament).toList();
  }

  static int getTotalChapters(List<String> bookNames) {
    int total = 0;
    for (final name in bookNames) {
      final book = getBook(name);
      if (book != null) {
        total += book.chapters;
      }
    }
    return total;
  }
}
