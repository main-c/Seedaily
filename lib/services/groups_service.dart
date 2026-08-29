import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../domain/group_models.dart';
import '../domain/models.dart';
import 'plan_snapshot_service.dart';

class GroupsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _uuid = Uuid();

  // ── Collections ───────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('groups');

  DocumentReference<Map<String, dynamic>> _groupDoc(String groupId) =>
      _groups.doc(groupId);

  CollectionReference<Map<String, dynamic>> _members(String groupId) =>
      _groupDoc(groupId).collection('members');

  CollectionReference<Map<String, dynamic>> _progress(String groupId) =>
      _groupDoc(groupId).collection('progress');

  // ── Créer un groupe ───────────────────────────────────────────────────────
  // Le inviteCode est généré côté client (6 chars uppercase).
  // La Cloud Function onGroupCreate le valide et garantit l'unicité en prod.

  Future<Group> createGroup({
    required String name,
    required String hostId,
    required String hostDisplayName,
    required String? hostAvatarUrl,
    required GeneratedPlan plan,
  }) async {
    final groupId = _uuid.v4();
    final inviteCode = _generateInviteCode();
    final snapshot = PlanSnapshotService.fromPlan(plan);
    final meta = GroupPlanMeta(
      templateId: plan.templateId,
      title: plan.title,
      totalDays: snapshot.length,
    );

    final group = Group(
      id: groupId,
      name: name,
      hostId: hostId,
      inviteCode: inviteCode,
      status: GroupStatus.active,
      planMeta: meta,
      planSnapshot: snapshot,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();

    // Document principal du groupe
    batch.set(_groupDoc(groupId), group.toFirestore());

    // L'hôte comme premier membre
    final hostMember = GroupMember(
      userId: hostId,
      displayName: hostDisplayName,
      avatarUrl: hostAvatarUrl,
      role: GroupMemberRole.host,
      joinedAt: DateTime.now(),
    );
    batch.set(_members(groupId).doc(hostId), hostMember.toFirestore());

    await batch.commit();
    return group;
  }

  // ── Rejoindre un groupe via code d'invitation ─────────────────────────────

  Future<Group?> joinGroup({
    required String inviteCode,
    required String userId,
    required String displayName,
    required String? avatarUrl,
  }) async {
    final code = inviteCode.trim().toUpperCase();

    final query = await _groups
        .where('inviteCode', isEqualTo: code)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final groupDoc = query.docs.first;
    final group = Group.fromFirestore(groupDoc);

    // Vérifie si déjà membre
    final memberDoc = await _members(group.id).doc(userId).get();
    if (memberDoc.exists) return group;

    final member = GroupMember(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      role: GroupMemberRole.member,
      joinedAt: DateTime.now(),
    );

    await _members(group.id).doc(userId).set(member.toFirestore());
    return group;
  }

  // ── Enregistrer la progression d'un membre ────────────────────────────────

  Future<void> markDayComplete({
    required String groupId,
    required String userId,
    required String displayName,
    required int dayIndex,
  }) async {
    final progress = GroupProgress(
      userId: userId,
      displayName: displayName,
      dayIndex: dayIndex,
      completedAt: DateTime.now(),
    );
    await _progress(groupId)
        .doc(GroupProgress.docId(userId, dayIndex))
        .set(progress.toFirestore());
  }

  Future<void> unmarkDayComplete({
    required String groupId,
    required String userId,
    required int dayIndex,
  }) async {
    await _progress(groupId)
        .doc(GroupProgress.docId(userId, dayIndex))
        .delete();
  }

  // ── Streams temps réel ────────────────────────────────────────────────────

  Stream<List<Group>> watchUserGroups(String userId) {
    return _db
        .collectionGroup('members')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((membersSnap) async {
      final groupIds = membersSnap.docs.map((d) => d.reference.parent.parent!.id).toSet();
      if (groupIds.isEmpty) return <Group>[];

      final groups = await Future.wait(
        groupIds.map((id) => _groupDoc(id).get()),
      );
      return groups
          .where((d) => d.exists)
          .map((d) => Group.fromFirestore(d))
          .toList();
    });
  }

  Stream<List<GroupMember>> watchMembers(String groupId) {
    return _members(groupId).snapshots().map(
          (snap) => snap.docs.map((d) => GroupMember.fromFirestore(d)).toList(),
        );
  }

  // Progression du jour courant pour tous les membres d'un groupe.
  Stream<List<GroupProgress>> watchTodayProgress(String groupId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _progress(groupId)
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GroupProgress.fromFirestore(d)).toList());
  }

  // Tous les progrès d'un membre (pour reconstruire la progression locale).
  Future<Set<int>> getMemberCompletedDays({
    required String groupId,
    required String userId,
  }) async {
    final snap = await _progress(groupId)
        .where('userId', isEqualTo: userId)
        .get();
    return snap.docs
        .map((d) => (d.data()['dayIndex'] as int))
        .toSet();
  }

  // ── Quitter / supprimer ───────────────────────────────────────────────────

  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    await _members(groupId).doc(userId).delete();
  }

  Future<void> deleteGroup(String groupId) async {
    final membersSnap = await _members(groupId).get();
    final progressSnap = await _progress(groupId).get();
    final allRefs = [
      ...membersSnap.docs.map((d) => d.reference),
      ...progressSnap.docs.map((d) => d.reference),
      _groupDoc(groupId),
    ];
    // Firestore batch : max 500 opérations
    for (var i = 0; i < allRefs.length; i += 499) {
      final chunk = allRefs.sublist(i, i + 499 > allRefs.length ? allRefs.length : i + 499);
      final batch = _db.batch();
      for (final ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  // ── Récupérer un groupe par ID ─────────────────────────────────────────────

  Future<Group?> getGroup(String groupId) async {
    final doc = await _groupDoc(groupId).get();
    if (!doc.exists) return null;
    return Group.fromFirestore(doc);
  }

  // ── Helpers privés ────────────────────────────────────────────────────────

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // sans O, 0, I, 1
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
