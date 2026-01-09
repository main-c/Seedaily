import 'bible_data.dart';

// ============================================================================
// ENUMS
// ============================================================================

enum ContentScope {
  custom,    // Sélection personnalisée (canonical, chronological, jewish)
  preset,    // Plan fixe (M'Cheyne, Ligue, Revolutionary, Horner)
}

enum OrderType {
  canonical,
  chronological,
  jewish,
  reverse,
  custom,
}

enum DistributionUnit {
  chapters,    // ✅ MVP : Uniquement chapters pour le MVP
  // words,    // ⏸️ Phase 2 : Commenté pour MVP
  // pericopes, // ⏸️ Phase 2 : Commenté pour MVP
}

enum DailyPsalmMode {
  none,
  one,
  sequential,
}

enum DailyProverbMode {
  none,
  one,
  dayOfMonth,
}

enum OtNtOverlapMode {
  sequential,
  alternate,
}

enum BalanceType {
  even,
  frontLoaded,
  backLoaded,
}

enum OutputFormat {
  calendar,
  list,
  weekly,
  byBook,
  circle,
}

// DEPRECATED: Remplacé par DailyPsalmMode
@Deprecated('Use DailyPsalmMode instead')
enum PsalmsStrategy {
  daily,
  spread,
  none,
}

// DEPRECATED: Remplacé par DailyProverbMode
@Deprecated('Use DailyProverbMode instead')
enum ProverbsStrategy {
  daily,
  monthly,
  none,
}

// DEPRECATED: Remplacé par OtNtOverlapMode
@Deprecated('Use OtNtOverlapMode instead')
enum OtNtMode {
  together,
  separate,
}

// ============================================================================
// MODELS
// ============================================================================

class ReadingPlanTemplate {
  final String id;
  final String title;
  final String image;
  final String description;
  final String porte;

  ReadingPlanTemplate({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
    required this.porte,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'description': description,
        'porte': porte,
      };

  factory ReadingPlanTemplate.fromJson(Map<String, dynamic> json) =>
      ReadingPlanTemplate(
        id: json['id'] as String,
        title: json['title'] as String,
        image: json['image'] as String,
        description: json['description'] as String,
        porte: json['porte'] as String,
      );
}

class ContentOptions {
  final ContentScope scope;
  final List<String> selectedBooks;
  final bool includeApocrypha;

  // Getters calculés
  bool get hasOldTestament => selectedBooks.any((b) {
        final book = BibleData.getBook(b);
        return book?.isOldTestament ?? false;
      });

  bool get hasNewTestament => selectedBooks.any((b) {
        final book = BibleData.getBook(b);
        return book?.isNewTestament ?? false;
      });

  ContentOptions({
    this.scope = ContentScope.custom,
    this.selectedBooks = const [],
    this.includeApocrypha = false,
  });

  // Helper : tous les livres sélectionnés par défaut
  factory ContentOptions.allBooks({bool includeApocrypha = false}) {
    final books = BibleData.books.map((b) => b.name).toList();
    if (includeApocrypha) {
      books.addAll(BibleData.deuterocanonicalBooks.map((b) => b.name));
    }
    return ContentOptions(
      scope: ContentScope.custom,
      selectedBooks: books,
      includeApocrypha: includeApocrypha,
    );
  }

  // Helper : tous les livres de l'AT
  factory ContentOptions.oldTestamentBooks({bool includeApocrypha = false}) {
    final books = BibleData.getOldTestamentBooks().map((b) => b.name).toList();
    if (includeApocrypha) {
      books.addAll(BibleData.deuterocanonicalBooks.map((b) => b.name));
    }
    return ContentOptions(
      scope: ContentScope.custom,
      selectedBooks: books,
      includeApocrypha: includeApocrypha,
    );
  }

  // Helper : tous les livres du NT
  factory ContentOptions.newTestamentBooks() {
    return ContentOptions(
      scope: ContentScope.custom,
      selectedBooks:
          BibleData.getNewTestamentBooks().map((b) => b.name).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'scope': scope.name,
        'selectedBooks': selectedBooks,
        'includeApocrypha': includeApocrypha,
      };

  factory ContentOptions.fromJson(Map<String, dynamic> json) {
    // Migration: ancien format avec 'books' → 'selectedBooks'
    final books = json.containsKey('selectedBooks')
        ? (json['selectedBooks'] as List<dynamic>).cast<String>()
        : json.containsKey('books')
            ? (json['books'] as List<dynamic>).cast<String>()
            : <String>[];

    return ContentOptions(
      scope: ContentScope.values.firstWhere(
        (e) => e.name == json['scope'] as String,
        orElse: () => ContentScope.custom,
      ),
      selectedBooks: books,
      includeApocrypha: json['includeApocrypha'] as bool? ?? false,
    );
  }
}

class OrderOptions {
  final OrderType type;

  final List<String> customOrder;

  OrderOptions({
    required this.type,
    this.customOrder = const [],
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'customOrder': customOrder,
      };

  factory OrderOptions.fromJson(Map<String, dynamic> json) => OrderOptions(
        type: OrderType.values
            .firstWhere((e) => e.name == json['type'] as String),
        customOrder: (json['customOrder'] as List<dynamic>).cast<String>(),
      );
}

class ScheduleOptions {
  final DateTime startDate;

  final int totalDays;

  final List<String> readingDays;

  ScheduleOptions({
    required this.startDate,
    required this.totalDays,
    this.readingDays = const [
      'mon',
      'tue',
      'wed',
      'thu',
      'fri',
      'sat',
      'sun'
    ],
  });

  Map<String, dynamic> toJson() => {
        'startDate': startDate.toIso8601String(),
        'totalDays': totalDays,
        'readingDays': readingDays,
      };

  factory ScheduleOptions.fromJson(Map<String, dynamic> json) =>
      ScheduleOptions(
        startDate: DateTime.parse(json['startDate'] as String),
        totalDays: json['totalDays'] as int,
        readingDays: (json['readingDays'] as List<dynamic>).cast<String>(),
      );
}

class DistributionOptions {
  final DistributionUnit unit;
  final OtNtOverlapMode otNtOverlap;
  final DailyPsalmMode dailyPsalm;
  final DailyProverbMode dailyProverb;
  final bool reverse;
  final BalanceType balance;

  DistributionOptions({
    this.unit = DistributionUnit.chapters,
    this.otNtOverlap = OtNtOverlapMode.sequential,
    this.dailyPsalm = DailyPsalmMode.none,
    this.dailyProverb = DailyProverbMode.none,
    this.reverse = false,
    this.balance = BalanceType.even,
  });

  Map<String, dynamic> toJson() => {
        'unit': unit.name,
        'otNtOverlap': otNtOverlap.name,
        'dailyPsalm': dailyPsalm.name,
        'dailyProverb': dailyProverb.name,
        'reverse': reverse,
        'balance': balance.name,
      };

  factory DistributionOptions.fromJson(Map<String, dynamic> json) {
    // Migration : anciennes strategies → nouveaux modes
    DailyPsalmMode psalmMode = DailyPsalmMode.none;
    if (json.containsKey('psalmsStrategy')) {
      final oldStrategy = json['psalmsStrategy'] as String;
      psalmMode = switch (oldStrategy) {
        'daily' => DailyPsalmMode.one,
        'spread' => DailyPsalmMode.sequential,
        _ => DailyPsalmMode.none,
      };
    } else if (json.containsKey('dailyPsalm')) {
      psalmMode = DailyPsalmMode.values
          .firstWhere((e) => e.name == json['dailyPsalm'] as String);
    }

    DailyProverbMode proverbMode = DailyProverbMode.none;
    if (json.containsKey('proverbsStrategy')) {
      final oldStrategy = json['proverbsStrategy'] as String;
      proverbMode = switch (oldStrategy) {
        'daily' => DailyProverbMode.one,
        'monthly' => DailyProverbMode.dayOfMonth,
        _ => DailyProverbMode.none,
      };
    } else if (json.containsKey('dailyProverb')) {
      proverbMode = DailyProverbMode.values
          .firstWhere((e) => e.name == json['dailyProverb'] as String);
    }

    OtNtOverlapMode overlapMode = OtNtOverlapMode.sequential;
    if (json.containsKey('otNtMode')) {
      final oldMode = json['otNtMode'] as String;
      overlapMode = oldMode == 'together'
          ? OtNtOverlapMode.alternate
          : OtNtOverlapMode.sequential;
    } else if (json.containsKey('otNtOverlap')) {
      overlapMode = OtNtOverlapMode.values
          .firstWhere((e) => e.name == json['otNtOverlap'] as String);
    }

    return DistributionOptions(
      unit: DistributionUnit.values.firstWhere(
        (e) => e.name == (json['unit'] as String? ?? 'chapters'),
        orElse: () => DistributionUnit.chapters,
      ),
      otNtOverlap: overlapMode,
      dailyPsalm: psalmMode,
      dailyProverb: proverbMode,
      reverse: json['reverse'] as bool? ?? false,
      balance: BalanceType.values.firstWhere(
        (e) => e.name == (json['balance'] as String? ?? 'even'),
        orElse: () => BalanceType.even,
      ),
    );
  }
}

class DisplayOptions {
  final bool includeCheckbox;
  final bool showStats;
  final bool removeDates;
  final bool sectionColors;
  final bool addReadingLinks;
  final OutputFormat format;

  DisplayOptions({
    this.includeCheckbox = true,
    this.showStats = true,
    this.removeDates = false,
    this.sectionColors = false,
    this.addReadingLinks = false,
    this.format = OutputFormat.calendar,
  });

  Map<String, dynamic> toJson() => {
        'includeCheckbox': includeCheckbox,
        'showStats': showStats,
        'removeDates': removeDates,
        'sectionColors': sectionColors,
        'addReadingLinks': addReadingLinks,
        'format': format.name,
      };

  factory DisplayOptions.fromJson(Map<String, dynamic> json) {
    return DisplayOptions(
      includeCheckbox: json['includeCheckbox'] as bool? ?? true,
      showStats: json['showStats'] as bool? ?? true,
      removeDates: json['removeDates'] as bool? ?? false,
      sectionColors: json['sectionColors'] as bool? ?? false,
      addReadingLinks: json['addReadingLinks'] as bool? ?? false,
      format: OutputFormat.values.firstWhere(
        (e) => e.name == (json['format'] as String? ?? 'calendar'),
        orElse: () => OutputFormat.calendar,
      ),
    );
  }
}

// DEPRECATED: Remplacé par DisplayOptions
@Deprecated('Use DisplayOptions instead')
class OutputOptions {
  final OutputFormat format;
  final bool showCheckboxes;
  final bool showStatistics;
  final String colorTheme;

  OutputOptions({
    this.format = OutputFormat.calendar,
    this.showCheckboxes = true,
    this.showStatistics = true,
    this.colorTheme = 'default',
  });

  Map<String, dynamic> toJson() => {
        'format': format.name,
        'showCheckboxes': showCheckboxes,
        'showStatistics': showStatistics,
        'colorTheme': colorTheme,
      };

  factory OutputOptions.fromJson(Map<String, dynamic> json) => OutputOptions(
        format: OutputFormat.values
            .firstWhere((e) => e.name == json['format'] as String),
        showCheckboxes: json['showCheckboxes'] as bool,
        showStatistics: json['showStatistics'] as bool,
        colorTheme: json['colorTheme'] as String,
      );
}

class GeneratorOptions {
  final ContentOptions content;
  final OrderOptions order;
  final ScheduleOptions schedule;
  final DistributionOptions distribution;
  final DisplayOptions display;

  GeneratorOptions({
    required this.content,
    required this.order,
    required this.schedule,
    required this.distribution,
    required this.display,
  });

  Map<String, dynamic> toJson() => {
        'content': content.toJson(),
        'order': order.toJson(),
        'schedule': schedule.toJson(),
        'distribution': distribution.toJson(),
        'display': display.toJson(),
      };

  factory GeneratorOptions.fromJson(Map<String, dynamic> json) =>
      GeneratorOptions(
        content: ContentOptions.fromJson(
            json['content'] as Map<String, dynamic>),
        order: OrderOptions.fromJson(json['order'] as Map<String, dynamic>),
        schedule: ScheduleOptions.fromJson(
            json['schedule'] as Map<String, dynamic>),
        distribution: DistributionOptions.fromJson(
            json['distribution'] as Map<String, dynamic>),
        display: json.containsKey('display')
            ? DisplayOptions.fromJson(json['display'] as Map<String, dynamic>)
            : _migrateOutputToDisplay(
                json['output'] as Map<String, dynamic>),
      );

  // Migration automatique de OutputOptions → DisplayOptions
  static DisplayOptions _migrateOutputToDisplay(Map<String, dynamic> json) {
    final oldOutput = OutputOptions.fromJson(json);
    return DisplayOptions(
      includeCheckbox: oldOutput.showCheckboxes,
      showStats: oldOutput.showStatistics,
      removeDates: false,
      sectionColors: false,
      addReadingLinks: false,
      format: oldOutput.format,
    );
  }
}

class Passage {
  final String book;

  final int fromChapter;

  final int toChapter;

  final int? fromVerse;

  final int? toVerse;

  Passage({
    required this.book,
    required this.fromChapter,
    required this.toChapter,
    this.fromVerse,
    this.toVerse,
  });

  String get reference {
    if (fromChapter == toChapter) {
      if (fromVerse != null && toVerse != null) {
        if (fromVerse == toVerse) {
          return '$book $fromChapter:$fromVerse';
        }
        return '$book $fromChapter:$fromVerse-$toVerse';
      }
      return '$book $fromChapter';
    } else {
      if (fromVerse != null && toVerse != null) {
        return '$book $fromChapter:$fromVerse-$toChapter:$toVerse';
      }
      return '$book $fromChapter-$toChapter';
    }
  }

  /// Référence abrégée pour affichage compact (calendrier, etc.)
  String get shortReference {
    final bookAbbr = abbreviateBookName(book);
    if (fromChapter == toChapter) {
      return '$bookAbbr $fromChapter';
    } else {
      return '$bookAbbr $fromChapter-$toChapter';
    }
  }

  /// Regroupe une liste de passages consécutifs du même livre
  /// Ex: [Gen 9, Gen 10, Gen 11, Ex 1] -> ["Gen 9-11", "Ex 1"]
  static List<String> groupConsecutivePassages(List<Passage> passages, {bool useAbbreviations = false}) {
    if (passages.isEmpty) return [];

    final grouped = <String>[];
    var i = 0;

    while (i < passages.length) {
      final current = passages[i];
      final currentBook = current.book;
      var startChapter = current.fromChapter;
      var endChapter = current.toChapter;

      // Chercher les passages consécutifs du même livre
      var j = i + 1;
      while (j < passages.length && passages[j].book == currentBook) {
        final next = passages[j];
        // Si le chapitre suivant est consécutif
        if (next.fromChapter == endChapter + 1 && next.toChapter == next.fromChapter) {
          endChapter = next.toChapter;
          j++;
        } else {
          break;
        }
      }

      // Formater le groupe
      final bookName = useAbbreviations ? abbreviateBookName(currentBook) : currentBook;
      if (startChapter == endChapter) {
        grouped.add('$bookName $startChapter');
      } else {
        grouped.add('$bookName $startChapter-$endChapter');
      }

      i = j;
    }

    return grouped;
  }

  /// Abrège un nom de livre biblique
  static String abbreviateBookName(String book) {
    const abbreviations = {
      'Genèse': 'Gen',
      'Exode': 'Ex',
      'Lévitique': 'Lev',
      'Nombres': 'Nom',
      'Deutéronome': 'Deut',
      'Josué': 'Jos',
      'Juges': 'Jug',
      'Ruth': 'Ruth',
      '1 Samuel': '1Sam',
      '2 Samuel': '2Sam',
      '1 Rois': '1Rois',
      '2 Rois': '2Rois',
      '1 Chroniques': '1Chr',
      '2 Chroniques': '2Chr',
      'Esdras': 'Esd',
      'Néhémie': 'Neh',
      'Esther': 'Est',
      'Job': 'Job',
      'Psaumes': 'Ps',
      'Proverbes': 'Prov',
      'Ecclésiaste': 'Ecc',
      'Cantique des Cantiques': 'Cant',
      'Ésaïe': 'Es',
      'Jérémie': 'Jer',
      'Lamentations': 'Lam',
      'Ézéchiel': 'Ez',
      'Daniel': 'Dan',
      'Osée': 'Os',
      'Joël': 'Joel',
      'Amos': 'Am',
      'Abdias': 'Abd',
      'Jonas': 'Jon',
      'Michée': 'Mic',
      'Nahum': 'Nah',
      'Habacuc': 'Hab',
      'Sophonie': 'Soph',
      'Aggée': 'Agg',
      'Zacharie': 'Zach',
      'Malachie': 'Mal',
      'Matthieu': 'Matt',
      'Marc': 'Marc',
      'Luc': 'Luc',
      'Jean': 'Jean',
      'Actes': 'Act',
      'Romains': 'Rom',
      '1 Corinthiens': '1Cor',
      '2 Corinthiens': '2Cor',
      'Galates': 'Gal',
      'Éphésiens': 'Eph',
      'Philippiens': 'Phil',
      'Colossiens': 'Col',
      '1 Thessaloniciens': '1Thes',
      '2 Thessaloniciens': '2Thes',
      '1 Timothée': '1Tim',
      '2 Timothée': '2Tim',
      'Tite': 'Tite',
      'Philémon': 'Phm',
      'Hébreux': 'Heb',
      'Jacques': 'Jac',
      '1 Pierre': '1Pi',
      '2 Pierre': '2Pi',
      '1 Jean': '1Jean',
      '2 Jean': '2Jean',
      '3 Jean': '3Jean',
      'Jude': 'Jude',
      'Apocalypse': 'Apoc',
    };
    return abbreviations[book] ?? book;
  }

  Map<String, dynamic> toJson() => {
        'book': book,
        'fromChapter': fromChapter,
        'toChapter': toChapter,
        'fromVerse': fromVerse,
        'toVerse': toVerse,
      };

  factory Passage.fromJson(Map<String, dynamic> json) => Passage(
        book: json['book'] as String,
        fromChapter: json['fromChapter'] as int,
        toChapter: json['toChapter'] as int,
        fromVerse: json['fromVerse'] as int?,
        toVerse: json['toVerse'] as int?,
      );
}

class ReadingDay {
  final DateTime date;

  final List<Passage> passages;

  bool completed;

  ReadingDay({
    required this.date,
    required this.passages,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'passages': passages.map((p) => p.toJson()).toList(),
        'completed': completed,
      };

  factory ReadingDay.fromJson(Map<String, dynamic> json) => ReadingDay(
        date: DateTime.parse(json['date'] as String),
        passages: (json['passages'] as List<dynamic>)
            .map((p) => Passage.fromJson(p as Map<String, dynamic>))
            .toList(),
        completed: json['completed'] as bool,
      );
}

class GeneratedPlan {
  final String id;

  final String templateId;

  final String title;

  final GeneratorOptions options;

  final List<ReadingDay> days;

  final DateTime createdAt;

  GeneratedPlan({
    required this.id,
    required this.templateId,
    required this.title,
    required this.options,
    required this.days,
    required this.createdAt,
  });

  int get totalDays => days.length;

  int get completedDays => days.where((d) => d.completed).length;

  double get progress =>
      totalDays > 0 ? (completedDays / totalDays) * 100 : 0.0;

  int get currentStreak {
    int streak = 0;
    final today = DateTime.now();
    final sortedDays = days.toList()..sort((a, b) => b.date.compareTo(a.date));

    for (final day in sortedDays) {
      if (day.date.isAfter(today)) continue;
      if (day.completed) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'templateId': templateId,
        'title': title,
        'options': options.toJson(),
        'days': days.map((d) => d.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedPlan.fromJson(Map<String, dynamic> json) => GeneratedPlan(
        id: json['id'] as String,
        templateId: json['templateId'] as String,
        title: json['title'] as String,
        options: GeneratorOptions.fromJson(
            json['options'] as Map<String, dynamic>),
        days: (json['days'] as List<dynamic>)
            .map((d) => ReadingDay.fromJson(d as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
