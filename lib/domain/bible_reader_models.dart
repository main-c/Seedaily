class BibleVersion {
  final String id;
  final String name;
  final String shortName;
  final int year;
  final String description;
  final String storagePath; // chemin Firebase Storage vers le zip

  const BibleVersion({
    required this.id,
    required this.name,
    required this.shortName,
    required this.year,
    required this.description,
    required this.storagePath,
  });

  static const List<BibleVersion> available = [
    BibleVersion(
      id: 'lsg',
      name: 'Louis Segond 1910',
      shortName: 'LSG',
      year: 1910,
      description: 'Traduction classique, la plus répandue en France',
      storagePath: 'bibles/lsg/lsg.zip',
    ),
    BibleVersion(
      id: 'martin',
      name: 'Bible Martin',
      shortName: 'Martin',
      year: 1744,
      description: 'Traduction de David Martin, fidèle au texte reçu',
      storagePath: 'bibles/martin/martin.zip',
    ),
    BibleVersion(
      id: 'ostervald',
      name: 'Bible Ostervald',
      shortName: 'Ost.',
      year: 1744,
      description: 'Révision d\'Ostervald, style classique',
      storagePath: 'bibles/ostervald/ostervald.zip',
    ),
    BibleVersion(
      id: 'epee',
      name: 'Bible de l\'Épée',
      shortName: 'Épée',
      year: 2005,
      description: 'Traduction moderne fidèle à l\'original',
      storagePath: 'bibles/epee/epee.zip',
    ),
    BibleVersion(
      id: 'kjv',
      name: 'King James Version',
      shortName: 'KJV',
      year: 1611,
      description: 'Classic English translation, public domain',
      storagePath: 'bibles/kjv/kjv.zip',
    ),
    BibleVersion(
      id: 'asv',
      name: 'American Standard Version',
      shortName: 'ASV',
      year: 1901,
      description: 'American revision of the KJV, public domain',
      storagePath: 'bibles/asv/asv.zip',
    ),
  ];

  bool get isEnglish => id == 'kjv' || id == 'asv';

  static BibleVersion? fromId(String id) {
    try {
      return available.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Traduit un nom de livre français vers l'anglais (pour KJV/ASV).
  static String localizedBookName(String frenchName, {bool english = false}) {
    if (!english) return frenchName;
    return _frToEn[frenchName] ?? frenchName;
  }

  static const Map<String, String> _frToEn = {
    'Genèse': 'Genesis', 'Exode': 'Exodus', 'Lévitique': 'Leviticus',
    'Nombres': 'Numbers', 'Deutéronome': 'Deuteronomy', 'Josué': 'Joshua',
    'Juges': 'Judges', 'Ruth': 'Ruth', '1 Samuel': '1 Samuel',
    '2 Samuel': '2 Samuel', '1 Rois': '1 Kings', '2 Rois': '2 Kings',
    '1 Chroniques': '1 Chronicles', '2 Chroniques': '2 Chronicles',
    'Esdras': 'Ezra', 'Néhémie': 'Nehemiah', 'Esther': 'Esther',
    'Job': 'Job', 'Psaumes': 'Psalms', 'Proverbes': 'Proverbs',
    'Ecclésiaste': 'Ecclesiastes', 'Cantique des Cantiques': 'Song of Solomon',
    'Ésaïe': 'Isaiah', 'Jérémie': 'Jeremiah', 'Lamentations': 'Lamentations',
    'Ézéchiel': 'Ezekiel', 'Daniel': 'Daniel', 'Osée': 'Hosea',
    'Joël': 'Joel', 'Amos': 'Amos', 'Abdias': 'Obadiah', 'Jonas': 'Jonah',
    'Michée': 'Micah', 'Nahum': 'Nahum', 'Habacuc': 'Habakkuk',
    'Sophonie': 'Zephaniah', 'Aggée': 'Haggai', 'Zacharie': 'Zechariah',
    'Malachie': 'Malachi', 'Matthieu': 'Matthew', 'Marc': 'Mark',
    'Luc': 'Luke', 'Jean': 'John', 'Actes': 'Acts', 'Romains': 'Romans',
    '1 Corinthiens': '1 Corinthians', '2 Corinthiens': '2 Corinthians',
    'Galates': 'Galatians', 'Éphésiens': 'Ephesians', 'Philippiens': 'Philippians',
    'Colossiens': 'Colossians', '1 Thessaloniciens': '1 Thessalonians',
    '2 Thessaloniciens': '2 Thessalonians', '1 Timothée': '1 Timothy',
    '2 Timothée': '2 Timothy', 'Tite': 'Titus', 'Philémon': 'Philemon',
    'Hébreux': 'Hebrews', 'Jacques': 'James', '1 Pierre': '1 Peter',
    '2 Pierre': '2 Peter', '1 Jean': '1 John', '2 Jean': '2 John',
    '3 Jean': '3 John', 'Jude': 'Jude', 'Apocalypse': 'Revelation',
  };
}

/// Données d'un chapitre chargé depuis le JSON local.
/// chapters[chapterIndex][verseIndex] — tous deux 0-indexés.
class BibleChapterData {
  final String book;
  final int chapter; // 1-indexed
  final List<String> verses; // index 0 = verset 1

  const BibleChapterData({
    required this.book,
    required this.chapter,
    required this.verses,
  });

  int get verseCount => verses.length;

  /// Texte d'un verset (1-indexed). Retourne null si hors plage.
  String? verse(int number) {
    final idx = number - 1;
    if (idx < 0 || idx >= verses.length) return null;
    return verses[idx];
  }

  factory BibleChapterData.fromJson(
    String bookName,
    int chapterNumber,
    List<dynamic> verseList,
  ) {
    return BibleChapterData(
      book: bookName,
      chapter: chapterNumber,
      verses: verseList.map((v) => v.toString()).toList(),
    );
  }
}

/// Représente un chapitre à afficher avec les versets à surligner.
class ReaderChapter {
  final BibleChapterData data;
  final int? highlightFrom; // verset de début du passage (1-indexed, null = tout)
  final int? highlightTo;   // verset de fin du passage

  const ReaderChapter({
    required this.data,
    this.highlightFrom,
    this.highlightTo,
  });

  bool isHighlighted(int verseNumber) {
    if (highlightFrom == null && highlightTo == null) return true;
    final from = highlightFrom ?? 1;
    final to = highlightTo ?? data.verseCount;
    return verseNumber >= from && verseNumber <= to;
  }
}
