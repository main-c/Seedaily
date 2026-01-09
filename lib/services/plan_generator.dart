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
    // Redirection pour compatibilité : bible-complete → canonical-plan
    var actualTemplateId = templateId;
    if (templateId == 'bible-complete' || templateId == 'chronological') {
      actualTemplateId = templateId == 'chronological'
          ? 'chronological-plan'
          : 'canonical-plan';
    }

    // Plans fixes avec structure prédéfinie
    switch (actualTemplateId) {
      case 'mcheyne':
        return _generateFixedPlan(
          templateId: actualTemplateId,
          title: title,
          options: options,
          dayDefinitions: mcheynePlanDays.map((d) => (d.dayIndex, d.passages)).toList(),
        );
      case 'bible-year-ligue':
        return _generateFixedPlan(
          templateId: actualTemplateId,
          title: title,
          options: options,
          dayDefinitions: liguePlanDays.map((d) => (d.dayIndex, d.passages)).toList(),
        );
      case 'revolutionary':
        return _generateFixedPlan(
          templateId: actualTemplateId,
          title: title,
          options: options,
          dayDefinitions: revolutionaryPlanDays.map((d) => (d.dayIndex, d.passages)).toList(),
        );
      case 'horner':
        return _generateHornerPlan(
          templateId: actualTemplateId,
          title: title,
          options: options,
        );
    }

    // Plans personnalisables (tous les autres templates)
    final passages = _buildPassagesList(options);
    final readingDays = _generateReadingDays(passages, options);

    return GeneratedPlan(
      id: _uuid.v4(),
      templateId: actualTemplateId,
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
    var passages = <Passage>[];

    // Construire passages par chapitres (MVP)
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

    // Appliquer OT/NT Overlap si livres AT+NT sélectionnés
    if (options.content.hasOldTestament && options.content.hasNewTestament) {
      passages = _applyOtNtOverlap(passages, options.distribution.otNtOverlap);
    }

    // Appliquer Reverse
    if (options.distribution.reverse) {
      passages = passages.reversed.toList();
    }

    return passages;
  }

  List<String> _getBookNames(ContentOptions content) {
    // Utiliser selectedBooks directement (nouvelle structure)
    if (content.selectedBooks.isNotEmpty) {
      return content.selectedBooks;
    }

    // Fallback pour anciens plans (compatibilité)
    switch (content.scope) {
      case ContentScope.custom:
        return content.selectedBooks;
      case ContentScope.preset:
        // Plans fixes : retourner tous les livres
        return BibleData.books.map((b) => b.name).toList();
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
        bookNames.sort((a, b) {
          final bookA = BibleData.getBook(a);
          final bookB = BibleData.getBook(b);
          if (bookA == null || bookB == null) return 0;
          final orderA = bookA.jewishOrder ?? 999;
          final orderB = bookB.jewishOrder ?? 999;
          return orderA.compareTo(orderB);
        });
        return bookNames;
    }
  }

  List<Passage> _applyOtNtOverlap(
    List<Passage> passages,
    OtNtOverlapMode mode,
  ) {
    if (mode == OtNtOverlapMode.sequential) return passages;

    // Séparer AT et NT
    final ot = passages.where((p) {
      final book = BibleData.getBook(p.book);
      return book?.isOldTestament ?? false;
    }).toList();

    final nt = passages.where((p) {
      final book = BibleData.getBook(p.book);
      return book?.isNewTestament ?? false;
    }).toList();

    // Alterner : [OT, NT, OT, NT, ...]
    return _interleave(ot, nt);
  }

  List<Passage> _interleave(List<Passage> list1, List<Passage> list2) {
    final result = <Passage>[];
    final maxLength = list1.length > list2.length ? list1.length : list2.length;

    for (int i = 0; i < maxLength; i++) {
      if (i < list1.length) result.add(list1[i]);
      if (i < list2.length) result.add(list2[i]);
    }

    return result;
  }

  List<ReadingDay> _generateReadingDays(
    List<Passage> passages,
    GeneratorOptions options,
  ) {
    final schedule = options.schedule;
    final distribution = options.distribution;
    final readingDays = <ReadingDay>[];

    final actualReadingDays = _calculateActualReadingDays(schedule);
    final passagesPerDay = _distributePassages(passages, actualReadingDays);

    DateTime currentDate = schedule.startDate;
    int passageIndex = 0;
    int psalmIndex = 1; // Pour DailyPsalmMode.sequential

    while (passageIndex < passages.length) {
      if (_isReadingDay(currentDate, schedule.readingDays)) {
        final dayPassages = <Passage>[];
        final count = passagesPerDay[readingDays.length % passagesPerDay.length];

        for (int i = 0; i < count && passageIndex < passages.length; i++) {
          dayPassages.add(passages[passageIndex]);
          passageIndex++;
        }

        // Ajouter Daily Psalm si activé
        if (distribution.dailyPsalm == DailyPsalmMode.one) {
          dayPassages.add(Passage(
            book: 'Psaumes',
            fromChapter: psalmIndex,
            toChapter: psalmIndex,
          ));
          psalmIndex++;
          if (psalmIndex > 150) psalmIndex = 1; // Boucler
        } else if (distribution.dailyPsalm == DailyPsalmMode.sequential) {
          dayPassages.add(Passage(
            book: 'Psaumes',
            fromChapter: psalmIndex,
            toChapter: psalmIndex,
          ));
          psalmIndex++;
          if (psalmIndex > 150) psalmIndex = 1;
        }

        // Ajouter Daily Proverb si activé
        if (distribution.dailyProverb == DailyProverbMode.one) {
          final proverbChapter = (readingDays.length % 31) + 1;
          dayPassages.add(Passage(
            book: 'Proverbes',
            fromChapter: proverbChapter,
            toChapter: proverbChapter,
          ));
        } else if (distribution.dailyProverb == DailyProverbMode.dayOfMonth) {
          final proverbChapter = currentDate.day;
          if (proverbChapter <= 31) {
            dayPassages.add(Passage(
              book: 'Proverbes',
              fromChapter: proverbChapter,
              toChapter: proverbChapter,
            ));
          }
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
      // Plans personnalisables avec sélection de livres
      ReadingPlanTemplate(
        id: 'canonical-plan',
        title: 'Plan Canonique',
        image: 'assets/images/canonical.jpg',
        description: 'Bible dans l\'ordre traditionnel',
        porte:
            'Lisez la Bible dans l\'ordre canonique avec sélection personnalisée des livres.',
      ),
      ReadingPlanTemplate(
        id: 'chronological-plan',
        title: 'Plan Chronologique',
        image: 'assets/images/chronological_plan.png',
        description: 'Bible dans l\'ordre historique',
        porte:
            'Suivez l\'histoire biblique telle qu\'elle s\'est déroulée, de la création à l\'Église primitive.',
      ),
      ReadingPlanTemplate(
        id: 'jewish-plan',
        title: 'Plan Juif (Tanakh)',
        image: 'assets/images/jewish.png',
        description: 'Torah → Neviim → Ketuvim',
        porte:
            'Lisez la Bible hébraïque selon l\'ordre traditionnel juif : Torah, Prophètes, Écrits.',
      ),

      // Plans simples (anciens templates conservés pour compatibilité)
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
        id: 'genesis-to-revelation',
        title: 'De la Genèse à l\'Apocalypse',
        image: 'assets/images/straight.png',
        description: 'Lecture simple dans l\'ordre canonique',
        porte:
            'Le plan le plus simple : lisez la Bible du début à la fin, à votre rythme.',
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
