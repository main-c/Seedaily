import 'package:flutter_test/flutter_test.dart';
import 'package:seedaily/domain/group_models.dart';

GroupMember member(String id, {bool host = false}) => GroupMember(
      userId: id,
      displayName: id,
      role: host ? GroupMemberRole.host : GroupMemberRole.member,
      joinedAt: DateTime(2026),
    );

GroupProgress read(String id, int day) => GroupProgress(
      userId: id,
      displayName: id,
      dayIndex: day,
      completedAt: DateTime(2026, 11, 8, 7, 30),
    );

void main() {
  test("« lu aujourd'hui » = jour du plan prévu, pas n'importe quelle coche",
      () {
    final s = GroupDayStatus.compute(
      members: [member('a'), member('h', host: true), member('b')],
      // a rattrape le jour 3 (hier) aujourd'hui ; b lit le jour 4 (aujourd'hui)
      progress: [read('a', 0), read('a', 1), read('a', 2), read('a', 3),
        read('b', 4), read('b', 4)],
      todayDayIndex: 4,
      expectedDays: 5,
      totalDays: 100,
    );

    expect(s.map((x) => x.member.userId), ['h', 'b', 'a']); // hôte, puis lus
    final a = s.firstWhere((x) => x.member.userId == 'a');
    final b = s.firstWhere((x) => x.member.userId == 'b');
    expect(a.hasCompleted, isFalse);
    expect(a.daysBehind, 1);
    expect(b.hasCompleted, isTrue);
    expect(b.completedDays, 1); // doublon compté une fois
    expect(b.daysBehind, 4);
    expect(b.completedAt, isNotNull);
  });

  test('aucune lecture prévue aujourd\'hui : personne n\'est « lu »', () {
    final s = GroupDayStatus.compute(
      members: [member('a')],
      progress: [read('a', 0)],
      todayDayIndex: null,
      expectedDays: 1,
      totalDays: 10,
    );
    expect(s.single.hasCompleted, isFalse);
    expect(s.single.daysBehind, 0);
    expect(s.single.progress, 0.1);
  });
}
