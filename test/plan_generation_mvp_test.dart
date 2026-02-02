import 'package:flutter_test/flutter_test.dart';
import 'package:seedaily/domain/models.dart';
import 'package:seedaily/services/plan_generator.dart';

void main() {
  group('Sprint 6 MVP - Nouveaux templates', () {
    final generator = PlanGenerator();

    test('Template canonical-plan génère un plan avec tous les livres', () {
      final options = GeneratorOptions(
        content: ContentOptions.allBooks(),
        order: OrderOptions(type: OrderType.canonical),
        schedule: ScheduleOptions(
          startDate: DateTime(2026, 1, 1),
          totalDays: 365,
          readingDays: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        ),
        distribution: DistributionOptions(
          unit: DistributionUnit.chapters,
          otNtOverlap: OtNtOverlapMode.sequential,
          dailyPsalm: DailyPsalmMode.none,
          dailyProverb: DailyProverbMode.none,
          reverse: false,
          balance: BalanceType.even,
        ),
        display: DisplayOptions(
          includeCheckbox: true,
          showStats: true,
          removeDates: false,
          sectionColors: false,
          addReadingLinks: false,
          format: OutputFormat.calendar,
        ),
      );

      final plan = generator.generate(
        templateId: 'canonical-plan',
        title: 'Test Canonical Plan',
        options: options,
      );

      expect(plan.title, 'Test Canonical Plan');
      expect(plan.days.isNotEmpty, true);
      expect(plan.totalDays, greaterThan(0));
    });

    test('Template chronological-plan génère un plan chronologique', () {
      final options = GeneratorOptions(
        content: ContentOptions.allBooks(),
        order: OrderOptions(type: OrderType.chronological),
        schedule: ScheduleOptions(
          startDate: DateTime(2026, 1, 1),
          totalDays: 365,
          readingDays: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        ),
        distribution: DistributionOptions(
          unit: DistributionUnit.chapters,
          otNtOverlap: OtNtOverlapMode.sequential,
          dailyPsalm: DailyPsalmMode.none,
          dailyProverb: DailyProverbMode.none,
          reverse: false,
          balance: BalanceType.even,
        ),
        display: DisplayOptions(
          includeCheckbox: true,
          showStats: true,
          removeDates: false,
          sectionColors: false,
          addReadingLinks: false,
          format: OutputFormat.calendar,
        ),
      );

      final plan = generator.generate(
        templateId: 'chronological-plan',
        title: 'Test Chronological Plan',
        options: options,
      );

      expect(plan.title, 'Test Chronological Plan');
      expect(plan.days.isNotEmpty, true);
    });

    test('Template jewish-plan génère un plan avec ordre juif', () {
      final options = GeneratorOptions(
        content: ContentOptions.oldTestamentBooks(),
        order: OrderOptions(type: OrderType.jewish),
        schedule: ScheduleOptions(
          startDate: DateTime(2026, 1, 1),
          totalDays: 365,
          readingDays: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        ),
        distribution: DistributionOptions(
          unit: DistributionUnit.chapters,
          otNtOverlap: OtNtOverlapMode.sequential,
          dailyPsalm: DailyPsalmMode.none,
          dailyProverb: DailyProverbMode.none,
          reverse: false,
          balance: BalanceType.even,
        ),
        display: DisplayOptions(
          includeCheckbox: true,
          showStats: true,
          removeDates: false,
          sectionColors: false,
          addReadingLinks: false,
          format: OutputFormat.calendar,
        ),
      );

      final plan = generator.generate(
        templateId: 'jewish-plan',
        title: 'Test Jewish Plan',
        options: options,
      );

      expect(plan.title, 'Test Jewish Plan');
      expect(plan.days.isNotEmpty, true);
    });

    test('Daily Psalm ajoute un psaume par jour', () {
      final options = GeneratorOptions(
        content: ContentOptions.oldTestamentBooks(),
        order: OrderOptions(type: OrderType.canonical),
        schedule: ScheduleOptions(
          startDate: DateTime(2026, 1, 1),
          totalDays: 30,
          readingDays: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        ),
        distribution: DistributionOptions(
          unit: DistributionUnit.chapters,
          otNtOverlap: OtNtOverlapMode.sequential,
          dailyPsalm: DailyPsalmMode.one,
          dailyProverb: DailyProverbMode.none,
          reverse: false,
          balance: BalanceType.even,
        ),
        display: DisplayOptions(
          includeCheckbox: true,
          showStats: true,
          removeDates: false,
          sectionColors: false,
          addReadingLinks: false,
          format: OutputFormat.calendar,
        ),
      );

      final plan = generator.generate(
        templateId: 'canonical-plan',
        title: 'Test Daily Psalm',
        options: options,
      );

      expect(plan.days.isNotEmpty, true);
      // Vérifier qu'au moins un jour contient un psaume
      final hasPsalm = plan.days.any((day) =>
          day.passages.any((passage) => passage.book == 'Psaumes'));
      expect(hasPsalm, true);
    });

    test('OT/NT Overlap alternate fonctionne correctement', () {
      final options = GeneratorOptions(
        content: ContentOptions.allBooks(),
        order: OrderOptions(type: OrderType.canonical),
        schedule: ScheduleOptions(
          startDate: DateTime(2026, 1, 1),
          totalDays: 365,
          readingDays: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        ),
        distribution: DistributionOptions(
          unit: DistributionUnit.chapters,
          otNtOverlap: OtNtOverlapMode.alternate,
          dailyPsalm: DailyPsalmMode.none,
          dailyProverb: DailyProverbMode.none,
          reverse: false,
          balance: BalanceType.even,
        ),
        display: DisplayOptions(
          includeCheckbox: true,
          showStats: true,
          removeDates: false,
          sectionColors: false,
          addReadingLinks: false,
          format: OutputFormat.calendar,
        ),
      );

      final plan = generator.generate(
        templateId: 'canonical-plan',
        title: 'Test OT/NT Alternate',
        options: options,
      );

      expect(plan.days.isNotEmpty, true);
    });

    test('Reverse order fonctionne correctement', () {
      final options = GeneratorOptions(
        content: ContentOptions.allBooks(),
        order: OrderOptions(type: OrderType.canonical),
        schedule: ScheduleOptions(
          startDate: DateTime(2026, 1, 1),
          totalDays: 365,
          readingDays: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        ),
        distribution: DistributionOptions(
          unit: DistributionUnit.chapters,
          otNtOverlap: OtNtOverlapMode.sequential,
          dailyPsalm: DailyPsalmMode.none,
          dailyProverb: DailyProverbMode.none,
          reverse: true,
          balance: BalanceType.even,
        ),
        display: DisplayOptions(
          includeCheckbox: true,
          showStats: true,
          removeDates: false,
          sectionColors: false,
          addReadingLinks: false,
          format: OutputFormat.calendar,
        ),
      );

      final plan = generator.generate(
        templateId: 'canonical-plan',
        title: 'Test Reverse Order',
        options: options,
      );

      expect(plan.days.isNotEmpty, true);
      // Vérifier que le premier livre est bien inversé
      // (devrait commencer par Apocalypse au lieu de Genèse)
      if (plan.days.isNotEmpty && plan.days.first.passages.isNotEmpty) {
        final firstBook = plan.days.first.passages.first.book;
        expect(firstBook, 'Apocalypse');
      }
    });
  });
}
