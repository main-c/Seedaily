import 'package:flutter_test/flutter_test.dart';
import 'package:seedaily/domain/group_models.dart';
import 'package:seedaily/domain/models.dart';
import 'package:seedaily/services/plan_generator.dart';
import 'package:seedaily/services/plan_snapshot_service.dart';

// Toute la synchro d'un groupe repose sur : jour N de l'hôte == jour N du membre.
void main() {
  test('un plan de 1189 jours arrive entier et identique chez le membre', () {
    final host = PlanGenerator().generate(
      templateId: 'canonical-plan',
      title: 'Bible à 1 chapitre par jour',
      options: GeneratorOptions(
        content: ContentOptions.allBooks(),
        order: OrderOptions(type: OrderType.canonical),
        schedule: ScheduleOptions(startDate: DateTime(2026, 1, 1), totalDays: 1189),
        distribution: DistributionOptions(),
        display: DisplayOptions(),
      ),
    );
    expect(host.days.length, greaterThan(365));

    // Aller-retour complet, comme via Firestore.
    final stored = PlanSnapshotService.toFirestore(
        PlanSnapshotService.fromPlan(host));
    final snapshot = PlanSnapshotService.fromFirestore(stored);
    final member = PlanSnapshotService.toPlan(
      snapshot: snapshot,
      meta: GroupPlanMeta(
          templateId: host.templateId,
          title: host.title,
          totalDays: snapshot.length),
      planId: 'm',
      groupId: 'g',
    );

    expect(member.days.length, host.days.length);
    for (var i = 0; i < host.days.length; i++) {
      expect(member.days[i].date, host.days[i].date, reason: 'jour $i');
      expect(
        member.days[i].passages.map((p) => '${p.book} ${p.fromChapter}-${p.toChapter}'),
        host.days[i].passages.map((p) => '${p.book} ${p.fromChapter}-${p.toChapter}'),
        reason: 'jour $i',
      );
    }
  });
}
