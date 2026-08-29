import '../domain/group_models.dart';
import '../domain/models.dart';

// Limite Horner : durée infinie → on cap à 365 jours dans le snapshot.
// Au-delà le pattern est cyclique, reconstructible si besoin.
const int _maxSnapshotDays = 365;

class PlanSnapshotService {
  // ── Sérialisation : GeneratedPlan → List<SnapshotDay> ─────────────────────
  // Appelée par le host au moment de créer un groupe.
  static List<SnapshotDay> fromPlan(GeneratedPlan plan) {
    final days = plan.days.length > _maxSnapshotDays
        ? plan.days.sublist(0, _maxSnapshotDays)
        : plan.days;

    return days.asMap().entries.map((entry) {
      final i = entry.key;
      final day = entry.value;
      return SnapshotDay(
        dayIndex: i,
        date: day.date,
        passages: day.passages.map((p) => SnapshotPassage(
              bookId: p.book,
              startChapter: p.fromChapter,
              endChapter: p.toChapter,
            )).toList(),
      );
    }).toList();
  }

  // ── Désérialisation : List<SnapshotDay> → GeneratedPlan ──────────────────
  // Appelée par un membre qui rejoint un groupe.
  // Reconstruit un GeneratedPlan local identique à celui du host.
  static GeneratedPlan toPlan({
    required List<SnapshotDay> snapshot,
    required GroupPlanMeta meta,
    required String planId,
    required String groupId,
  }) {
    final days = snapshot.map((sd) {
      return ReadingDay(
        date: sd.date,
        passages: sd.passages.map((sp) => Passage(
              book: sp.bookId,
              fromChapter: sp.startChapter,
              toChapter: sp.endChapter,
            )).toList(),
        completed: false,
      );
    }).toList();

    final startDate = snapshot.isNotEmpty ? snapshot.first.date : DateTime.now();

    return GeneratedPlan(
      id: planId,
      templateId: meta.templateId,
      title: meta.title,
      options: GeneratorOptions.stub(
        startDate: startDate,
        totalDays: meta.totalDays,
      ),
      days: days,
      createdAt: DateTime.now(),
      groupId: groupId,
    );
  }

  // ── Sérialisation Firestore : List<SnapshotDay> → List<Map> ──────────────
  static List<Map<String, dynamic>> toFirestore(List<SnapshotDay> snapshot) {
    return snapshot.map((d) => d.toMap()).toList();
  }

  // ── Désérialisation Firestore : List<Map> → List<SnapshotDay> ────────────
  static List<SnapshotDay> fromFirestore(List<dynamic> data) {
    return data
        .map((d) => SnapshotDay.fromMap(d as Map<String, dynamic>))
        .toList();
  }
}
