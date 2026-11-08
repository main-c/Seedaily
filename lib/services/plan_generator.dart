import 'package:uuid/uuid.dart';
import '../domain/models.dart';
import '../domain/bible_data.dart';
import '../domain/bible_verses_data.dart';
import '../domain/mcheyne_plan_data.dart';
import '../domain/ligue_plan_data.dart';
import '../domain/revolutionary_plan_data.dart';
import '../domain/horner_plan_data.dart';
import '../l10n/l10n.dart';

/// Passage avec son poids (nombre de versets) pour une distribution équilibrée
class WeightedPassage {
  final Passage passage;
  final int weight; // Nombre de versets

  const WeightedPassage({required this.passage, required this.weight});
}

class PlanGenerator {
  final _uuid = const Uuid();

  GeneratedPlan generate({
    required String templateId,
    required String title,
    required GeneratorOptions options,
    String? existingPlanId,
  }) {
    final planId = existingPlanId ?? _uuid.v4();
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
          planId: planId,
          templateId: actualTemplateId,
          title: title,
          options: options,
          dayDefinitions:
              mcheynePlanDays.map((d) => (d.dayIndex, d.passages)).toList(),
        );
      case 'bible-year-ligue':
        return _generateLiguePlan(
          planId: planId,
          templateId: actualTemplateId,
          title: title,
          options: options,
        );
      case 'revolutionary':
        return _generateRevolutionaryPlan(
          planId: planId,
          templateId: actualTemplateId,
          title: title,
          options: options,
        );
      case 'horner':
        return _generateHornerPlan(
          planId: planId,
          templateId: actualTemplateId,
          title: title,
          options: options,
        );
    }

    // Plans personnalisables (tous les autres templates)
    final weightedPassages = _buildWeightedPassagesList(options);
    final readingDays = _generateReadingDaysBalanced(weightedPassages, options);

    return GeneratedPlan(
      id: planId,
      templateId: actualTemplateId,
      title: title,
      options: options,
      days: readingDays,
      createdAt: DateTime.now(),
    );
  }

  GeneratedPlan _generateFixedPlan({
    required String planId,
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
      id: planId,
      templateId: templateId,
      title: title,
      options: options,
      days: days,
      createdAt: DateTime.now(),
    );
  }

  GeneratedPlan _generateHornerPlan({
    required String planId,
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
      id: planId,
      templateId: templateId,
      title: title,
      options: options,
      days: days,
      createdAt: DateTime.now(),
    );
  }

  GeneratedPlan _generateLiguePlan({
    required String planId,
    required String templateId,
    required String title,
    required GeneratorOptions options,
  }) {
    final schedule = options.schedule;
    final days = <ReadingDay>[];

    // Le plan Ligue génère 365 jours avec 4 pistes parallèles
    for (int dayIndex = 0; dayIndex < schedule.totalDays; dayIndex++) {
      final date = schedule.startDate.add(Duration(days: dayIndex));
      final passages = generateLigueDayPassages(dayIndex);

      days.add(
        ReadingDay(
          date: date,
          passages: passages,
        ),
      );
    }

    return GeneratedPlan(
      id: planId,
      templateId: templateId,
      title: title,
      options: options,
      days: days,
      createdAt: DateTime.now(),
    );
  }

  GeneratedPlan _generateRevolutionaryPlan({
    required String planId,
    required String templateId,
    required String title,
    required GeneratorOptions options,
  }) {
    final schedule = options.schedule;
    final days = <ReadingDay>[];

    // Le plan Revolutionary a 300 jours de lecture (25 par mois)
    // On mappe les jours de lecture aux dates réelles
    final totalReadingDays = RevolutionaryPlanConfig.totalReadingDays;

    for (int dayIndex = 0;
        dayIndex < totalReadingDays && dayIndex < schedule.totalDays;
        dayIndex++) {
      final date = schedule.startDate.add(Duration(days: dayIndex));
      final passages = generateRevolutionaryDayPassages(dayIndex);

      days.add(
        ReadingDay(
          date: date,
          passages: passages,
        ),
      );
    }

    return GeneratedPlan(
      id: planId,
      templateId: templateId,
      title: title,
      options: options,
      days: days,
      createdAt: DateTime.now(),
    );
  }

  /// Construit la liste des passages pondérés (avec nombre de versets)
  List<WeightedPassage> _buildWeightedPassagesList(GeneratorOptions options) {
    final List<String> bookNames = _getBookNames(options.content);
    final orderedBooks = _applyOrder(bookNames, options.order);
    var passages = <WeightedPassage>[];

    // Construire passages par chapitres avec leur poids (nombre de versets)
    for (final bookName in orderedBooks) {
      final book = BibleData.getBook(bookName);
      if (book == null) continue;

      for (int chapter = 1; chapter <= book.chapters; chapter++) {
        final verseCount = BibleVersesData.getVerseCount(bookName, chapter);
        passages.add(WeightedPassage(
          passage: Passage(
            book: bookName,
            fromChapter: chapter,
            toChapter: chapter,
          ),
          weight: verseCount > 0 ? verseCount : 20, // Fallback: 20 versets
        ));
      }
    }

    // Appliquer OT/NT Overlap si livres AT+NT sélectionnés
    if (options.content.hasOldTestament && options.content.hasNewTestament) {
      passages =
          _applyWeightedOtNtOverlap(passages, options.distribution.otNtOverlap);
    }

    // Appliquer Reverse
    if (options.distribution.reverse) {
      passages = passages.reversed.toList();
    }

    return passages;
  }

  /// Version pondérée de _applyOtNtOverlap
  List<WeightedPassage> _applyWeightedOtNtOverlap(
    List<WeightedPassage> passages,
    OtNtOverlapMode mode,
  ) {
    if (mode == OtNtOverlapMode.sequential) return passages;

    // Séparer AT et NT
    final ot = passages.where((wp) {
      final book = BibleData.getBook(wp.passage.book);
      return book?.isOldTestament ?? false;
    }).toList();

    final nt = passages.where((wp) {
      final book = BibleData.getBook(wp.passage.book);
      return book?.isNewTestament ?? false;
    }).toList();

    // Alterner : [OT, NT, OT, NT, ...]
    return _interleaveWeighted(ot, nt);
  }

  List<WeightedPassage> _interleaveWeighted(
      List<WeightedPassage> list1, List<WeightedPassage> list2) {
    final result = <WeightedPassage>[];
    final maxLength = list1.length > list2.length ? list1.length : list2.length;

    for (int i = 0; i < maxLength; i++) {
      if (i < list1.length) result.add(list1[i]);
      if (i < list2.length) result.add(list2[i]);
    }

    return result;
  }

  List<String> _getBookNames(ContentOptions content) {
    // Utiliser selectedBooks si non-vide
    if (content.selectedBooks.isNotEmpty) {
      return content.selectedBooks;
    }

    // Fallback : retourner tous les livres de la Bible
    return BibleData.books.map((b) => b.name).toList();
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

  /// Génère les jours de lecture avec distribution équilibrée par poids (versets)
  List<ReadingDay> _generateReadingDaysBalanced(
    List<WeightedPassage> weightedPassages,
    GeneratorOptions options,
  ) {
    final schedule = options.schedule;
    final distribution = options.distribution;
    final readingDays = <ReadingDay>[];

    if (weightedPassages.isEmpty) return readingDays;

    // Calculer le nombre réel de jours de lecture
    final actualReadingDays = _calculateActualReadingDays(schedule);
    if (actualReadingDays == 0) return readingDays;

    // Mode chapitres/jour : distribuer exactement N chapitres par jour
    final cpd = distribution.chaptersPerDay;
    if (cpd != null && cpd > 0) {
      return _generateReadingDaysByChapterCount(
          weightedPassages, options, cpd);
    }

    // Calculer le poids total et le poids cible par jour
    final totalWeight = weightedPassages.fold(0, (sum, wp) => sum + wp.weight);
    final targetWeightPerDay = totalWeight / actualReadingDays;

    // Tolérance : on accepte de dépasser de 50% du poids cible
    final tolerance = targetWeightPerDay * 0.5;

    DateTime currentDate = schedule.startDate;
    int passageIndex = 0;
    int psalmIndex = 1;
    int dayCount = 0;

    while (passageIndex < weightedPassages.length &&
        dayCount < schedule.totalDays) {
      if (_isReadingDay(currentDate, schedule.readingDays)) {
        final dayPassages = <Passage>[];
        int currentDayWeight = 0;

        // Ajouter des passages jusqu'à atteindre le poids cible
        while (passageIndex < weightedPassages.length) {
          final wp = weightedPassages[passageIndex];

          // Si on a déjà des passages et qu'ajouter le prochain dépasserait trop
          if (dayPassages.isNotEmpty &&
              currentDayWeight + wp.weight > targetWeightPerDay + tolerance) {
            break;
          }

          dayPassages.add(wp.passage);
          currentDayWeight += wp.weight;
          passageIndex++;

          // Si on a atteint ou dépassé la cible, passer au jour suivant
          if (currentDayWeight >= targetWeightPerDay) {
            break;
          }
        }

        // Ajouter Daily Psalm si activé
        if (distribution.dailyPsalm == DailyPsalmMode.one ||
            distribution.dailyPsalm == DailyPsalmMode.sequential) {
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
      dayCount++;
    }

    // Si on n'a pas fini tous les passages, les ajouter aux derniers jours
    while (passageIndex < weightedPassages.length) {
      if (readingDays.isNotEmpty) {
        readingDays.last.passages.add(weightedPassages[passageIndex].passage);
      }
      passageIndex++;
    }

    return readingDays;
  }

  /// Distribution par nombre exact de chapitres par jour
  List<ReadingDay> _generateReadingDaysByChapterCount(
    List<WeightedPassage> weightedPassages,
    GeneratorOptions options,
    int chaptersPerDay,
  ) {
    final schedule = options.schedule;
    final distribution = options.distribution;
    final readingDays = <ReadingDay>[];

    DateTime currentDate = schedule.startDate;
    int passageIndex = 0;
    int psalmIndex = 1;
    int dayCount = 0;

    while (passageIndex < weightedPassages.length &&
        dayCount < schedule.totalDays) {
      if (_isReadingDay(currentDate, schedule.readingDays)) {
        final dayPassages = <Passage>[];

        for (int i = 0; i < chaptersPerDay && passageIndex < weightedPassages.length; i++) {
          dayPassages.add(weightedPassages[passageIndex].passage);
          passageIndex++;
        }

        if (distribution.dailyPsalm == DailyPsalmMode.one ||
            distribution.dailyPsalm == DailyPsalmMode.sequential) {
          dayPassages.add(Passage(
            book: 'Psaumes',
            fromChapter: psalmIndex,
            toChapter: psalmIndex,
          ));
          psalmIndex++;
          if (psalmIndex > 150) psalmIndex = 1;
        }

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
      dayCount++;
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
    if (readingDays.isEmpty || readingDays.length == 7) {
      return true;
    }

    final dayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final weekday = date.weekday - 1;
    final dayName = dayNames[weekday];

    return readingDays.contains(dayName);
  }

  List<ReadingPlanTemplate> getDefaultTemplates() {
    final l10n = appL10n;
    return [
      // Plans personnalisables — l'utilisateur peut modifier livres, durée et jours de lecture
      ReadingPlanTemplate(
        id: 'canonical-plan',
        title: l10n.templateCanonicalPlanTitle,
        image: 'assets/images/plans/bible.jpg',
        description: l10n.templateCanonicalPlanDescription,
        porte: l10n.templateCanonicalPlanDetails,
        type: 'custom',
        difficulty: 'modéré',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'chronological-plan',
        title: l10n.templateChronologicalPlanTitle,
        image: 'assets/images/plans/mountains_golden.jpg',
        description: l10n.templateChronologicalPlanDescription,
        porte: l10n.templateChronologicalPlanDetails,
        type: 'custom',
        difficulty: 'modéré',
        estimatedDays: 365,
      ),

      // Plans thématiques — points de départ personnalisables
      ReadingPlanTemplate(
        id: 'new-testament',
        title: l10n.templateNewTestamentTitle,
        image: 'assets/images/plans/desert.jpg',
        description: l10n.templateNewTestamentDescription,
        porte: l10n.templateNewTestamentDetails,
        type: 'custom',
        difficulty: 'modéré',
        estimatedDays: 90,
      ),
      ReadingPlanTemplate(
        id: 'old-testament',
        title: l10n.templateOldTestamentTitle,
        image: 'assets/images/plans/path.jpg',
        description: l10n.templateOldTestamentDescription,
        porte: l10n.templateOldTestamentDetails,
        type: 'custom',
        difficulty: 'intense',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'gospels',
        title: l10n.templateGospelsTitle,
        image: 'assets/images/plans/sunrise.jpg',
        description: l10n.templateGospelsDescription,
        porte: l10n.templateGospelsDetails,
        type: 'custom',
        difficulty: 'léger',
        estimatedDays: 30,
      ),
      ReadingPlanTemplate(
        id: 'psalms',
        title: l10n.templatePsalmsTitle,
        image: 'assets/images/plans/mountains_clouds.jpg',
        description: l10n.templatePsalmsDescription,
        porte: l10n.templatePsalmsDetails,
        type: 'custom',
        difficulty: 'léger',
        estimatedDays: 150,
      ),
      ReadingPlanTemplate(
        id: 'proverbs',
        title: l10n.templateProverbsTitle,
        image: 'assets/images/plans/book.jpg',
        description: l10n.templateProverbsDescription,
        porte: l10n.templateProverbsDetails,
        type: 'custom',
        difficulty: 'léger',
        estimatedDays: 31,
      ),

      // // Rythmes de lecture — personnalisez selon votre disponibilité
      // ReadingPlanTemplate(
      //   id: 'one-chapter-a-day',
      //   title: 'Un chapitre par jour',
      //   image:
      //       'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?w=800&q=80',
      //   description:
      //       'Rythme doux : 1 chapitre quotidien. Sélectionnez les livres que vous voulez lire et ajustez la durée.',
      //   porte:
      //       'Approche progressive et personnalisable. Commencez par le NT en 260 jours ou toute la Bible en 3 ans — c\'est vous qui décidez.',
      //   type: 'custom',
      //   difficulty: 'léger',
      //   estimatedDays: 1189,
      // ),
      // ReadingPlanTemplate(
      //   id: '90-day',
      //   title: 'Plan 90 jours',
      //   image:
      //       'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=800&q=80',
      //   description:
      //       'Lecture intensive de la Bible. Modifiez la durée (60, 90 ou 120 jours) ou sélectionnez certains livres.',
      //   porte:
      //       'Challenge adaptable pour votre groupe. Lisez le NT en 30 jours ou toute la Bible en 90 — personnalisez l\'intensité.',
      //   type: 'custom',
      //   difficulty: 'intense',
      //   estimatedDays: 90,
      // ),
      // ReadingPlanTemplate(
      //   id: 'wisdom',
      //   title: 'Sagesse',
      //   image:
      //       'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=80',
      //   description:
      //       'Proverbes, Psaumes et Ecclésiaste. Ajoutez Job ou Cantique, modifiez la durée selon vos besoins.',
      //   porte:
      //       'Parcours thématique personnalisable. Idéal pour un groupe de croissance — adaptez les livres et la durée.',
      //   type: 'custom',
      //   difficulty: 'léger',
      //   estimatedDays: 60,
      // ),
      // ReadingPlanTemplate(
      //   id: 'prophecies',
      //   title: 'Prophéties',
      //   image:
      //       'https://images.unsplash.com/photo-1484981184820-2e84ea0e5d7e?w=800&q=80',
      //   description:
      //       'Livres prophétiques : Isaïe à Malachie. Ajoutez Daniel ou l\'Apocalypse, personnalisez votre parcours.',
      //   porte:
      //       'Explorez les prophètes à votre rythme. Sélectionnez uniquement les petits prophètes ou incluez les grands — à vous de choisir.',
      //   type: 'custom',
      //   difficulty: 'modéré',
      //   estimatedDays: 90,
      // ),

      // Plans fixes (challenges historiques) — structure prédéfinie, choisissez la date de début
      ReadingPlanTemplate(
        id: 'mcheyne',
        title: l10n.templateMcheyneTitle,
        image: 'assets/images/plans/hills_mist.jpg',
        description: l10n.templateMcheyneDescription,
        porte: l10n.templateMcheyneDetails,
        type: 'fixed',
        difficulty: 'intense',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'bible-year-ligue',
        title: l10n.templateBibleYearLigueTitle,
        image: 'assets/images/plans/nature_sun.jpg',
        description: l10n.templateBibleYearLigueDescription,
        porte: l10n.templateBibleYearLigueDetails,
        type: 'fixed',
        difficulty: 'modéré',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'revolutionary',
        title: l10n.templateRevolutionaryTitle,
        image: 'assets/images/plans/lake_forest.jpg',
        description: l10n.templateRevolutionaryDescription,
        porte: l10n.templateRevolutionaryDetails,
        type: 'fixed',
        difficulty: 'léger',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'horner',
        title: l10n.templateHornerTitle,
        image: 'assets/images/plans/forest.jpg',
        description: l10n.templateHornerDescription,
        porte: l10n.templateHornerDetails,
        type: 'fixed',
        difficulty: 'intense',
        estimatedDays: 365,
      ),
    ];
  }
}
