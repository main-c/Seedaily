import 'package:uuid/uuid.dart';
import '../domain/models.dart';
import '../domain/bible_data.dart';
import '../domain/mcheyne_plan_data.dart';
import '../domain/ligue_plan_data.dart';
import '../domain/revolutionary_plan_data.dart';
import '../domain/horner_plan_data.dart';

class PlanGenerator {
  final _uuid = const Uuid();

  GeneratedPlan generate({
    required String templateId,
    required String title,
    required GeneratorOptions options,
  }) {
    // Plans fixes avec structure prédéfinie
    switch (templateId) {
      case 'mcheyne':
        return _generateFixedPlan(
          templateId: templateId,
          title: title,
          options: options,
          dayDefinitions: mcheynePlanDays.map((d) => (d.dayIndex, d.passages)).toList(),
        );
      case 'bible-year-ligue':
        return _generateFixedPlan(
          templateId: templateId,
          title: title,
          options: options,
          dayDefinitions: liguePlanDays.map((d) => (d.dayIndex, d.passages)).toList(),
        );
      case 'revolutionary':
        return _generateFixedPlan(
          templateId: templateId,
          title: title,
          options: options,
          dayDefinitions: revolutionaryPlanDays.map((d) => (d.dayIndex, d.passages)).toList(),
        );
      case 'horner':
        return _generateHornerPlan(
          templateId: templateId,
          title: title,
          options: options,
        );
    }

    // Plans personnalisables
    final passages = _buildPassagesList(options);
    final readingDays = _generateReadingDays(passages, options);

    return GeneratedPlan(
      id: _uuid.v4(),
      templateId: templateId,
      title: title,
      options: options,
      days: readingDays,
      createdAt: DateTime.now(),
    );
  }

  GeneratedPlan _generateFixedPlan({
    required String templateId,
    required String title,
    required GeneratorOptions options,
    required List<(int, List<Passage>)> dayDefinitions,
  }) {
    final schedule = options.schedule;
    final days = <ReadingDay>[];

    for (final (dayIndex, passages) in dayDefinitions) {
      final date = schedule.startDate.add(Duration(days: dayIndex));
      days.add(
        ReadingDay(
          date: date,
          passages: passages,
        ),
      );
    }

    return GeneratedPlan(
      id: _uuid.v4(),
      templateId: templateId,
      title: title,
      options: options,
      days: days,
      createdAt: DateTime.now(),
    );
  }

  GeneratedPlan _generateHornerPlan({
    required String templateId,
    required String title,
    required GeneratorOptions options,
  }) {
    final schedule = options.schedule;
    final days = <ReadingDay>[];

    // Le plan Horner est infini (boucle indéfiniment)
    // On génère selon le totalDays du schedule (par défaut 365 jours)
    for (int dayIndex = 0; dayIndex < schedule.totalDays; dayIndex++) {
      final date = schedule.startDate.add(Duration(days: dayIndex));
      final passages = generateHornerDayPassages(dayIndex);

      days.add(
        ReadingDay(
          date: date,
          passages: passages,
        ),
      );
    }

    return GeneratedPlan(
      id: _uuid.v4(),
      templateId: templateId,
      title: title,
      options: options,
      days: days,
      createdAt: DateTime.now(),
    );
  }

  List<Passage> _buildPassagesList(GeneratorOptions options) {
    final List<String> bookNames = _getBookNames(options.content);
    final orderedBooks = _applyOrder(bookNames, options.order);
    final passages = <Passage>[];

    for (final bookName in orderedBooks) {
      final book = BibleData.getBook(bookName);
      if (book == null) continue;

      for (int chapter = 1; chapter <= book.chapters; chapter++) {
        passages.add(Passage(
          book: bookName,
          fromChapter: chapter,
          toChapter: chapter,
        ));
      }
    }

    return passages;
  }

  List<String> _getBookNames(ContentOptions content) {
    switch (content.scope) {
      case ContentScope.bibleComplete:
        return BibleData.books.map((b) => b.name).toList();

      case ContentScope.oldTestament:
        return BibleData.getOldTestamentBooks().map((b) => b.name).toList();

      case ContentScope.newTestament:
        return BibleData.getNewTestamentBooks().map((b) => b.name).toList();

      case ContentScope.custom:
        return content.books;
    }
  }

  List<String> _applyOrder(List<String> bookNames, OrderOptions order) {
    switch (order.type) {
      case OrderType.canonical:
        bookNames.sort((a, b) {
          final bookA = BibleData.getBook(a);
          final bookB = BibleData.getBook(b);
          if (bookA == null || bookB == null) return 0;
          return bookA.canonicalOrder.compareTo(bookB.canonicalOrder);
        });
        return bookNames;

      case OrderType.chronological:
        bookNames.sort((a, b) {
          final bookA = BibleData.getBook(a);
          final bookB = BibleData.getBook(b);
          if (bookA == null || bookB == null) return 0;
          return bookA.chronologicalOrder.compareTo(bookB.chronologicalOrder);
        });
        return bookNames;

      case OrderType.reverse:
        return bookNames.reversed.toList();

      case OrderType.custom:
        if (order.customOrder.isNotEmpty) {
          final customBooks = <String>[];
          for (final name in order.customOrder) {
            if (bookNames.contains(name)) {
              customBooks.add(name);
            }
          }
          for (final name in bookNames) {
            if (!customBooks.contains(name)) {
              customBooks.add(name);
            }
          }
          return customBooks;
        }
        return bookNames;

      case OrderType.jewish:
        return bookNames;
    }
  }

  List<ReadingDay> _generateReadingDays(
    List<Passage> passages,
    GeneratorOptions options,
  ) {
    final schedule = options.schedule;
    final readingDays = <ReadingDay>[];

    final actualReadingDays = _calculateActualReadingDays(schedule);
    final passagesPerDay = _distributePassages(passages, actualReadingDays);

    DateTime currentDate = schedule.startDate;
    int passageIndex = 0;

    while (passageIndex < passages.length) {
      if (_isReadingDay(currentDate, schedule.readingDays)) {
        final dayPassages = <Passage>[];
        final count = passagesPerDay[readingDays.length % passagesPerDay.length];

        for (int i = 0; i < count && passageIndex < passages.length; i++) {
          dayPassages.add(passages[passageIndex]);
          passageIndex++;
        }

        if (dayPassages.isNotEmpty) {
          readingDays.add(ReadingDay(
            date: currentDate,
            passages: dayPassages,
          ));
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return readingDays;
  }

  int _calculateActualReadingDays(ScheduleOptions schedule) {
    int count = 0;
    DateTime currentDate = schedule.startDate;

    for (int i = 0; i < schedule.totalDays; i++) {
      if (_isReadingDay(currentDate, schedule.readingDays)) {
        count++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return count > 0 ? count : schedule.totalDays;
  }

  bool _isReadingDay(DateTime date, List<String> readingDays) {
    if (readingDays.isEmpty ||
        readingDays.length == 7 ||
        readingDays.contains('all')) {
      return true;
    }

    final dayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final weekday = date.weekday - 1;
    final dayName = dayNames[weekday];

    return readingDays.contains(dayName);
  }

  List<int> _distributePassages(List<Passage> passages, int readingDays) {
    if (readingDays == 0) return [passages.length];

    final baseCount = passages.length ~/ readingDays;
    final remainder = passages.length % readingDays;

    final distribution = List<int>.filled(readingDays, baseCount);

    for (int i = 0; i < remainder; i++) {
      distribution[i]++;
    }

    return distribution;
  }

  List<ReadingPlanTemplate> getDefaultTemplates() {
    return [
      // Plans personnalisables
      ReadingPlanTemplate(
        id: 'bible-complete',
        title: 'Bible complète',
        image: 'assets/images/bible_complete.png',
        description:
            'Lisez toute la Bible de la Genèse à l\'Apocalypse, à votre rythme',
        porte:
            'Un voyage complet à travers toute la Parole de Dieu. Configurez la durée selon vos besoins.',
      ),
      ReadingPlanTemplate(
        id: 'new-testament',
        title: 'Nouveau Testament',
        image: 'assets/images/new_testament.png',
        description: '27 livres de Matthieu à l\'Apocalypse',
        porte:
            'Découvrez la vie de Jésus, les premiers chrétiens et l\'enseignement des apôtres.',
      ),
      ReadingPlanTemplate(
        id: 'old-testament',
        title: 'Ancien Testament',
        image: 'assets/images/old_testament.png',
        description: '39 livres de la Genèse à Malachie',
        porte:
            'L\'histoire du peuple de Dieu, des origines aux prophètes d\'Israël.',
      ),
      ReadingPlanTemplate(
        id: 'gospels',
        title: 'Les Évangiles',
        image: 'assets/images/gospels.png',
        description: 'Les quatre récits de la vie de Jésus',
        porte:
            'Matthieu, Marc, Luc et Jean : quatre regards sur le Christ.',
      ),
      ReadingPlanTemplate(
        id: 'psalms',
        title: 'Les Psaumes',
        image: 'assets/images/psalms.png',
        description: '150 prières et louanges d\'Israël',
        porte:
            'Le livre de prière de Jésus. Chants de louange, de supplication et de sagesse.',
      ),
      ReadingPlanTemplate(
        id: 'proverbs',
        title: 'Les Proverbes',
        image: 'assets/images/proverbs.png',
        description: '31 chapitres de sagesse pratique',
        porte:
            'La sagesse de Salomon pour la vie quotidienne. Un chapitre par jour du mois.',
      ),
      ReadingPlanTemplate(
        id: 'chronological',
        title: 'Bible chronologique',
        image: 'assets/images/chronological.png',
        description: 'La Bible dans l\'ordre historique des événements',
        porte:
            'Suivez l\'histoire biblique telle qu\'elle s\'est déroulée, de la création à l\'Église primitive.',
      ),

      // Plans fixes (challenges)
      ReadingPlanTemplate(
        id: 'mcheyne',
        title: 'Plan M\'Cheyne',
        image: 'assets/images/mcheyne.png',
        description:
            '4 chapitres par jour · 365 jours · AT 1x, NT et Psaumes 2x',
        porte:
            'Un classique depuis 1842. Marchez au rythme de milliers de chrétiens à travers le monde.',
      ),
      ReadingPlanTemplate(
        id: 'bible-year-ligue',
        title: 'Bible en 1 an de la Ligue',
        image: 'assets/images/ligue.png',
        description:
            'AT + Psaume + Proverbe + NT chaque jour',
        porte:
            'Une lecture équilibrée quotidienne : un passage de chaque partie de la Bible.',
      ),
      ReadingPlanTemplate(
        id: 'revolutionary',
        title: 'Plan révolutionnaire',
        image: 'assets/images/revolutionary.png',
        description:
            '25 lectures par mois avec jours de repos',
        porte:
            'Pour ceux qui préfèrent moins de lecture quotidienne avec des jours de rattrapage.',
      ),
      ReadingPlanTemplate(
        id: 'horner',
        title: 'Plan du Professeur Horner',
        image: 'assets/images/horner.png',
        description:
            '10 chapitres par jour dans 10 listes différentes',
        porte:
            'Lecture intensive qui révèle les connexions entre les livres bibliques.',
      ),
      ReadingPlanTemplate(
        id: 'genesis-to-revelation',
        title: 'De la Genèse à l\'Apocalypse',
        image: 'assets/images/straight.png',
        description:
            'Lecture simple dans l\'ordre canonique',
        porte:
            'Le plan le plus simple : lisez la Bible du début à la fin, à votre rythme.',
      ),
    ];
  }
}
