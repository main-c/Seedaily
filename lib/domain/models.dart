// ============================================================================
// ENUMS
// ============================================================================

enum ContentScope {
  bibleComplete,
  oldTestament,
  newTestament,
  custom,
}

enum OrderType {
  canonical,
  chronological,
  jewish,
  reverse,
  custom,
}

enum DistributionUnit {
  chapters,
  verses,
  pericopes,
}

enum OtNtMode {
  together,
  separate,
}

enum PsalmsStrategy {
  daily,
  spread,
  none,
}

enum ProverbsStrategy {
  daily,
  monthly,
  none,
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

  final List<String> books;

  final bool includePsalms;

  final bool includeProverbs;

  final bool includeApocrypha;

  ContentOptions({
    required this.scope,
    this.books = const [],
    this.includePsalms = true,
    this.includeProverbs = true,
    this.includeApocrypha = false,
  });

  Map<String, dynamic> toJson() => {
        'scope': scope.name,
        'books': books,
        'includePsalms': includePsalms,
        'includeProverbs': includeProverbs,
        'includeApocrypha': includeApocrypha,
      };

  factory ContentOptions.fromJson(Map<String, dynamic> json) => ContentOptions(
        scope: ContentScope.values
            .firstWhere((e) => e.name == json['scope'] as String),
        books: (json['books'] as List<dynamic>).cast<String>(),
        includePsalms: json['includePsalms'] as bool,
        includeProverbs: json['includeProverbs'] as bool,
        includeApocrypha: json['includeApocrypha'] as bool,
      );
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

  final OtNtMode otNtMode;

  final PsalmsStrategy psalmsStrategy;

  final ProverbsStrategy proverbsStrategy;

  final BalanceType balance;

  DistributionOptions({
    this.unit = DistributionUnit.chapters,
    this.otNtMode = OtNtMode.together,
    this.psalmsStrategy = PsalmsStrategy.spread,
    this.proverbsStrategy = ProverbsStrategy.none,
    this.balance = BalanceType.even,
  });

  Map<String, dynamic> toJson() => {
        'unit': unit.name,
        'otNtMode': otNtMode.name,
        'psalmsStrategy': psalmsStrategy.name,
        'proverbsStrategy': proverbsStrategy.name,
        'balance': balance.name,
      };

  factory DistributionOptions.fromJson(Map<String, dynamic> json) =>
      DistributionOptions(
        unit: DistributionUnit.values
            .firstWhere((e) => e.name == json['unit'] as String),
        otNtMode: OtNtMode.values
            .firstWhere((e) => e.name == json['otNtMode'] as String),
        psalmsStrategy: PsalmsStrategy.values
            .firstWhere((e) => e.name == json['psalmsStrategy'] as String),
        proverbsStrategy: ProverbsStrategy.values
            .firstWhere((e) => e.name == json['proverbsStrategy'] as String),
        balance: BalanceType.values
            .firstWhere((e) => e.name == json['balance'] as String),
      );
}

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

  final OutputOptions output;

  GeneratorOptions({
    required this.content,
    required this.order,
    required this.schedule,
    required this.distribution,
    required this.output,
  });

  Map<String, dynamic> toJson() => {
        'content': content.toJson(),
        'order': order.toJson(),
        'schedule': schedule.toJson(),
        'distribution': distribution.toJson(),
        'output': output.toJson(),
      };

  factory GeneratorOptions.fromJson(Map<String, dynamic> json) =>
      GeneratorOptions(
        content: ContentOptions.fromJson(
            json['content'] as Map<String, dynamic>),
        order:
            OrderOptions.fromJson(json['order'] as Map<String, dynamic>),
        schedule: ScheduleOptions.fromJson(
            json['schedule'] as Map<String, dynamic>),
        distribution: DistributionOptions.fromJson(
            json['distribution'] as Map<String, dynamic>),
        output:
            OutputOptions.fromJson(json['output'] as Map<String, dynamic>),
      );
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
