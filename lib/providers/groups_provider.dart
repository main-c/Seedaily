import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../domain/group_models.dart';
import '../domain/models.dart';
import '../services/groups_service.dart';
import '../services/plan_snapshot_service.dart';

class GroupsProvider extends ChangeNotifier {
  final GroupsService _service = GroupsService();
  static const _uuid = Uuid();

  List<Group> _groups = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Group>>? _groupsSub;
  String? _initializedForUserId;

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasGroups => _groups.isNotEmpty;

  // ── Initialisation ────────────────────────────────────────────────────────
  // Appelé depuis main.dart dès que l'utilisateur est connecté.

  void init(String userId) {
    if (_initializedForUserId == userId) return;
    _initializedForUserId = userId;
    _groupsSub?.cancel();
    _groupsSub = _service.watchUserGroups(userId).listen(
      (groups) {
        _groups = groups..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Impossible de charger les groupes.';
        notifyListeners();
      },
    );
  }

  void clear() {
    _groupsSub?.cancel();
    _groupsSub = null;
    _initializedForUserId = null;
    _groups = [];
    notifyListeners();
  }

  // ── Créer un groupe ───────────────────────────────────────────────────────
  // Retourne le Group créé (contient le plan local à sauvegarder dans Hive).

  Future<Group?> createGroup({
    required String name,
    required String hostId,
    required String hostDisplayName,
    required String? hostAvatarUrl,
    required GeneratedPlan plan,
  }) async {
    _setLoading(true);
    try {
      final group = await _service.createGroup(
        name: name,
        hostId: hostId,
        hostDisplayName: hostDisplayName,
        hostAvatarUrl: hostAvatarUrl,
        plan: plan,
      );
      // Optimistic update : disponible immédiatement sans attendre le listener Firestore
      _groups = [group, ..._groups];
      notifyListeners();
      _setLoading(false);
      return group;
    } catch (e) {
      _error = 'Impossible de créer le groupe. Réessayez.';
      _setLoading(false);
      return null;
    }
  }

  // ── Rejoindre un groupe ───────────────────────────────────────────────────
  // Retourne le GeneratedPlan reconstruit depuis le snapshot (à sauvegarder dans Hive).

  Future<({Group group, GeneratedPlan plan})?> joinGroup({
    required String inviteCode,
    required String userId,
    required String displayName,
    required String? avatarUrl,
  }) async {
    _setLoading(true);
    try {
      final group = await _service.joinGroup(
        inviteCode: inviteCode,
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

      if (group == null) {
        _error = 'Code invalide ou groupe introuvable.';
        _setLoading(false);
        return null;
      }

      // Reconstruit le plan local depuis le snapshot Firestore.
      final planId = _uuid.v4();
      final plan = PlanSnapshotService.toPlan(
        snapshot: group.planSnapshot,
        meta: group.planMeta,
        planId: planId,
        groupId: group.id,
      );

      // Synchronise la progression déjà enregistrée sur Firestore.
      final completedDays = await _service.getMemberCompletedDays(
        groupId: group.id,
        userId: userId,
      );
      for (final idx in completedDays) {
        if (idx < plan.days.length) {
          plan.days[idx].completed = true;
        }
      }

      _setLoading(false);
      return (group: group, plan: plan);
    } catch (e) {
      _error = 'Impossible de rejoindre le groupe. Réessayez.';
      _setLoading(false);
      return null;
    }
  }

  // ── Marquer un jour comme lu (double-écriture) ────────────────────────────
  // La mise à jour Hive est gérée par PlansProvider — ici on écrit dans Firestore.

  Future<void> syncProgressToFirestore({
    required String groupId,
    required String userId,
    required String displayName,
    required int dayIndex,
    required bool completed,
  }) async {
    try {
      if (completed) {
        await _service.markDayComplete(
          groupId: groupId,
          userId: userId,
          displayName: displayName,
          dayIndex: dayIndex,
        );
      } else {
        await _service.unmarkDayComplete(
          groupId: groupId,
          userId: userId,
          dayIndex: dayIndex,
        );
      }
    } catch (_) {
      // Échec silencieux — Firestore réessaiera automatiquement si offline.
    }
  }

  // ── Quitter / supprimer un groupe ────────────────────────────────────────

  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _service.leaveGroup(groupId: groupId, userId: userId);
    } catch (_) {
      _error = 'Impossible de quitter le groupe.';
      notifyListeners();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _service.deleteGroup(groupId);
    } catch (_) {
      _error = 'Impossible de supprimer le groupe.';
      notifyListeners();
    }
  }

  // ── Streams pour les écrans ───────────────────────────────────────────────

  Stream<List<GroupMember>> watchMembers(String groupId) =>
      _service.watchMembers(groupId);

  Stream<List<GroupProgress>> watchTodayProgress(String groupId) =>
      _service.watchTodayProgress(groupId);

  Future<Group?> getGroup(String groupId) => _service.getGroup(groupId);

  Group? findById(String groupId) {
    try {
      return _groups.firstWhere((g) => g.id == groupId);
    } catch (_) {
      return null;
    }
  }

  // Trouve un groupe par l'ID que le plan stocke dans plan.groupId
  Group? findByPlanGroupId(String groupId) => findById(groupId);

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _groupsSub?.cancel();
    super.dispose();
  }
}
