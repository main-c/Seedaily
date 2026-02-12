import 'package:uuid/uuid.dart';
import '../domain/models.dart';
import '../domain/bible_data.dart';
import '../domain/bible_verses_data.dart';
import '../domain/mcheyne_plan_data.dart';
import '../domain/ligue_plan_data.dart';
import '../domain/revolutionary_plan_data.dart';
import '../domain/horner_plan_data.dart';

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
    return [
      // Plans personnalisables — l'utilisateur peut modifier livres, durée et jours de lecture
      ReadingPlanTemplate(
        id: 'canonical-plan',
        title: 'Plan Canonique',
        image:
            'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=800&q=80',
        description:
            'Lecture de toute la Bible dans l’ordre traditionnel de Genèse a Apocalypse.',
        porte:
            '''Ce plan suit l’ordre classique des livres bibliques tel que présenté dans la plupart des Bibles chrétiennes.
Vous pouvez modifier la durée (6 mois, 1 an, 2 ans…), sélectionner certains livres seulement, ou choisir vos jours de lecture.
Idéal comme base flexible pour construire votre propre parcours complet.''',
        type: 'custom',
        difficulty: 'modéré',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'chronological-plan',
        title: 'Plan Chronologique',
        image:
            'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=800&q=80',
        description:
            'Lecture de la Bible selon l’ordre historique des événements et de rédaction.',
        porte:
            '''Ce plan replace les livres et passages dans leur contexte historique présumé afin de mieux comprendre la progression de l’histoire biblique.
Parfait pour suivre le fil narratif de la révélation biblique.
Vous pouvez ajuster la durée, retirer ou ajouter des livres selon votre objectif d’étude.''',
        type: 'custom',
        difficulty: 'modéré',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'jewish-plan',
        title: 'Plan Juif (Tanakh)',
        image:
            'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80',
        description:
            'Lecture selon l’ordre hébraïque traditionnel : Torah, Neviim, Ketuvim.',
        porte:
            '''Ce parcours suit l’organisation du Tanakh (Bible hébraïque) utilisée dans la tradition juive :

Torah (Loi)

Neviim (Prophètes)

Ketuvim (Écrits)

Vous pouvez lire l’ensemble ou vous concentrer sur une section spécifique. La durée et les jours de lecture sont entièrement personnalisables.''',
        type: 'custom',
        difficulty: 'modéré',
        estimatedDays: 365,
      ),

      // Plans thématiques — points de départ personnalisables
      ReadingPlanTemplate(
        id: 'new-testament',
        title: 'Nouveau Testament',
        image:
            'https://images.unsplash.com/photo-1529070538774-1843cb3265df?w=800&q=80',
        description:
            'Les 27 livres du Nouveau Testament dans un parcours adaptable à votre rythme.',
        porte:
            '''Découvrez la vie de Jésus, la naissance de l’Église et l’enseignement apostolique.
Vous pouvez lire en format intensif (30 jours) ou progressif (3 à 6 mois).
Ajoutez des livres de l’Ancien Testament si vous souhaitez enrichir votre parcours.''',
        type: 'custom',
        difficulty: 'modéré',
        estimatedDays: 90,
      ),
      ReadingPlanTemplate(
        id: 'old-testament',
        title: 'Ancien Testament',
        image:
            'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=800&q=80',
        description:
            'Les 39 livres de l’Ancien Testament, ajustables selon votre durée.',
        porte:
            '''Explorez la Loi, l’histoire d’Israël, les livres poétiques et les prophètes.
Vous pouvez étendre la lecture sur 1 à 2 ans ou sélectionner uniquement certaines sections.
Un plan exigeant mais fondamental pour comprendre le Nouveau Testament.''',
        type: 'custom',
        difficulty: 'intense',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'gospels',
        title: 'Les Évangiles',
        image:
            'https://images.unsplash.com/photo-1499652848871-1527a310b13a?w=800&q=80',
        description:
            'Matthieu, Marc, Luc et Jean dans un parcours centré sur la vie de Jésus.',
        porte:
            '''Idéal pour découvrir ou redécouvrir la personne et l’œuvre du Christ.
Vous pouvez compléter avec le livre des Actes ou adapter la durée (2 semaines à 3 mois).
Parfait pour un groupe de croissance ou un nouveau croyant.''',
        type: 'custom',
        difficulty: 'léger',
        estimatedDays: 30,
      ),
      ReadingPlanTemplate(
        id: 'psalms',
        title: 'Les Psaumes',
        image:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
        description: '150 psaumes pour nourrir la prière et la méditation.',
        porte:
            '''Un parcours spirituel centré sur l’adoration, la repentance et la confiance en Dieu.
Choisissez votre rythme : 1 psaume par jour ou plusieurs par lecture.
Peut être combiné avec Proverbes pour un équilibre entre prière et sagesse.''',
        type: 'custom',
        difficulty: 'léger',
        estimatedDays: 150,
      ),
      ReadingPlanTemplate(
        id: 'proverbs',
        title: 'Les Proverbes',
        image:
            'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&q=80',
        description:
            '31 chapitres de sagesse pratique pour la vie quotidienne.',
        porte:
            '''Un plan idéal pour une lecture mensuelle (1 chapitre par jour).
Peut être associé à Ecclésiaste ou Cantique des cantiques pour approfondir la littérature sapientielle.
Simple, court et applicable immédiatement.''',
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
        title: 'Plan M\'Cheyne',
        image:
            'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&q=80',
        description:
            'Une lecture parallèle de l’Ancien et du Nouveau Testament.',
        porte:
            '''Créé par Robert Murray M’Cheyne, ce plan propose une lecture parallèle de l’Ancien et du Nouveau Testament.
Les passages sont prédéfinis et suivent la structure originale.
Vous choisissez simplement la date de début.''',
        type: 'fixed',
        difficulty: 'intense',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'bible-year-ligue',
        title: 'Bible en 1 an (Ligue)',
        image:
            'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80',
        description:
            '''Lecture quotidienne équilibrée de l'ancien testament, les Psaumes, Les Proverbes et du nouveau testament''',
        porte:
            '''Chaque jour propose un passage de l’Ancien Testament, un Psaume, un Proverbe et un passage du Nouveau Testament.
Plan structuré et prédéfini, idéal pour une lecture communautaire en Église.''',
        type: 'fixed',
        difficulty: 'modéré',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'revolutionary',
        title: 'Plan révolutionnaire',
        image:
            'https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=800&q=80',
        description: '25 lectures par mois avec jours de repos intégrés..',
        porte: '''Plan structuré pour favoriser la régularité sans surcharge.
Les jours de pause permettent de rattraper ou méditer.
Structure fixe : il suffit de choisir votre date de départ.''',
        type: 'fixed',
        difficulty: 'léger',
        estimatedDays: 365,
      ),
      ReadingPlanTemplate(
        id: 'horner',
        title: 'Plan Horner',
        image:
            'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=800&q=80',
        description:
            'Méthode intensive : 10 chapitres par jour en lectures parallèles.',
        porte:
            '''Conçu par le Professeur Grant Horner, ce plan divise la Bible en 10 listes distinctes lues simultanément.
Très exigeant, il favorise l’immersion et la répétition des textes.
Structure entièrement prédéfinie.''',
        type: 'fixed',
        difficulty: 'intense',
        estimatedDays: 365,
      ),
    ];
  }
}
