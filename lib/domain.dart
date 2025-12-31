import 'package:flutter/foundation.dart';

/// Cœur métier Seedaily : modèles pour la génération de plans.
///
/// Ici, aucune validation métier forte : ces objets décrivent
/// les intentions éditoriales et les options de génération.

@immutable
class ReadingPlanTemplate {
  const ReadingPlanTemplate({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
    required this.porte,
  });

  final String id;
  final String title;
  final String image;
  final String description;
  final String porte;
}

enum ContentScope {
  bibleComplete,
  oldTestament,
  newTestament,
  custom,
}

@immutable
class ContentOptions {
  const ContentOptions({
    required this.scope,
    this.books = const [],
    this.includePsalms = false,
    this.includeProverbs = false,
    this.includeApocrypha = false,
  });

  final ContentScope scope;
  final List<String> books;
  final bool includePsalms;
  final bool includeProverbs;
  final bool includeApocrypha;
}

enum OrderType {
  canonical,
  chronological,
  jewish,
  reverse,
  custom,
}

@immutable
class OrderOptions {
  const OrderOptions({
    required this.type,
    this.customOrder = const [],
  });

  final OrderType type;
  final List<String> customOrder;
}

@immutable
class ScheduleOptions {
  const ScheduleOptions({
    required this.startDate,
    required this.totalDays,
    this.readingDays = const ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
  });

  final DateTime startDate;
  final int totalDays;
  final List<String> readingDays;
}

enum DistributionUnit { chapters, verses, pericopes }

enum OtNtMode { together, separate }

enum PsalmsStrategy { daily, spread, none }

enum ProverbsStrategy { daily, monthly, none }

enum BalanceStrategy { even, frontLoaded, backLoaded }

@immutable
class DistributionOptions {
  const DistributionOptions({
    this.unit = DistributionUnit.chapters,
    this.otNtMode = OtNtMode.together,
    this.psalmsStrategy = PsalmsStrategy.none,
    this.proverbsStrategy = ProverbsStrategy.none,
    this.balance = BalanceStrategy.even,
  });

  final DistributionUnit unit;
  final OtNtMode otNtMode;
  final PsalmsStrategy psalmsStrategy;
  final ProverbsStrategy proverbsStrategy;
  final BalanceStrategy balance;
}

enum OutputFormat { calendar, list, weekly, byBook, circle }

@immutable
class OutputOptions {
  const OutputOptions({
    this.format = OutputFormat.calendar,
    this.showCheckboxes = true,
    this.showStatistics = true,
    this.colorTheme = 'seedaily_default',
  });

  final OutputFormat format;
  final bool showCheckboxes;
  final bool showStatistics;
  final String colorTheme;
}

@immutable
class GeneratorOptions {
  const GeneratorOptions({
    required this.content,
    required this.order,
    required this.schedule,
    required this.distribution,
    required this.output,
  });

  final ContentOptions content;
  final OrderOptions order;
  final ScheduleOptions schedule;
  final DistributionOptions distribution;
  final OutputOptions output;
}

@immutable
class Passage {
  const Passage({
    required this.book,
    required this.fromChapter,
    required this.toChapter,
    this.fromVerse,
    this.toVerse,
  });

  final String book;
  final int fromChapter;
  final int toChapter;
  final int? fromVerse;
  final int? toVerse;
}

@immutable
class ReadingDay {
  const ReadingDay({
    required this.date,
    required this.passages,
    this.completed = false,
  });

  final DateTime date;
  final List<Passage> passages;
  final bool completed;
}

@immutable
class GeneratedPlan {
  const GeneratedPlan({
    required this.id,
    required this.templateId,
    required this.options,
    required this.days,
  });

  final String id;
  final String templateId;
  final GeneratorOptions options;
  final List<ReadingDay> days;
}






