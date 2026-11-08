import 'package:cloud_firestore/cloud_firestore.dart';

// ── Rôle d'un membre dans un groupe ──────────────────────────────────────────

enum GroupMemberRole { host, member }

// ── Statut d'un groupe ────────────────────────────────────────────────────────

enum GroupStatus { active, archived }

// ── Snapshot compact d'un jour de lecture ────────────────────────────────────
// Structure stockée dans Firestore : { d: dayIndex, p: [{b, s, e}] }

class SnapshotPassage {
  final String bookId;
  final int startChapter;
  final int endChapter;

  const SnapshotPassage({
    required this.bookId,
    required this.startChapter,
    required this.endChapter,
  });

  Map<String, dynamic> toMap() => {
        'b': bookId,
        's': startChapter,
        'e': endChapter,
      };

  factory SnapshotPassage.fromMap(Map<String, dynamic> m) => SnapshotPassage(
        bookId: m['b'] as String,
        startChapter: m['s'] as int,
        endChapter: m['e'] as int,
      );
}

class SnapshotDay {
  final int dayIndex; // 0-based, correspond à plan.days[dayIndex]
  final DateTime date;
  final List<SnapshotPassage> passages;

  const SnapshotDay({
    required this.dayIndex,
    required this.date,
    required this.passages,
  });

  Map<String, dynamic> toMap() => {
        'd': dayIndex,
        'dt': date.toIso8601String(),
        'p': passages.map((p) => p.toMap()).toList(),
      };

  factory SnapshotDay.fromMap(Map<String, dynamic> m) => SnapshotDay(
        dayIndex: m['d'] as int,
        date: DateTime.parse(m['dt'] as String),
        passages: (m['p'] as List<dynamic>)
            .map((p) => SnapshotPassage.fromMap(p as Map<String, dynamic>))
            .toList(),
      );
}

// ── Méta-données du plan (affichage uniquement, pas de logique) ───────────────

class GroupPlanMeta {
  final String templateId;
  final String title;
  final int totalDays;

  const GroupPlanMeta({
    required this.templateId,
    required this.title,
    required this.totalDays,
  });

  Map<String, dynamic> toMap() => {
        'templateId': templateId,
        'title': title,
        'totalDays': totalDays,
      };

  factory GroupPlanMeta.fromMap(Map<String, dynamic> m) => GroupPlanMeta(
        templateId: m['templateId'] as String,
        title: m['title'] as String,
        totalDays: m['totalDays'] as int,
      );
}

// ── Groupe ────────────────────────────────────────────────────────────────────

class Group {
  final String id;
  final String name;
  final String hostId;
  final String inviteCode;
  final GroupStatus status;
  final GroupPlanMeta planMeta;
  final List<SnapshotDay> planSnapshot;
  final DateTime createdAt;
  final bool notifyOnMemberProgress;

  const Group({
    required this.id,
    required this.name,
    required this.hostId,
    required this.inviteCode,
    required this.status,
    required this.planMeta,
    required this.planSnapshot,
    required this.createdAt,
    this.notifyOnMemberProgress = true,
  });

  bool get isActive => status == GroupStatus.active;

  // Retourne les jours attendus jusqu'à aujourd'hui
  int get expectedCompletedDays {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    return planSnapshot.where((d) {
      final dayNorm = DateTime(d.date.year, d.date.month, d.date.day);
      return !dayNorm.isAfter(todayNorm);
    }).length;
  }

  // Index du jour du plan prévu aujourd'hui, null s'il n'y en a pas
  // (plan pas commencé, terminé, ou jour sans lecture).
  int? get todayDayIndex {
    final now = DateTime.now();
    return planSnapshot
        .where((d) =>
            d.date.year == now.year &&
            d.date.month == now.month &&
            d.date.day == now.day)
        .firstOrNull
        ?.dayIndex;
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'hostId': hostId,
        'inviteCode': inviteCode,
        'status': status.name,
        'planMeta': planMeta.toMap(),
        'planSnapshot': planSnapshot.map((d) => d.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'notifyOnMemberProgress': notifyOnMemberProgress,
      };

  factory Group.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'] as String,
      hostId: data['hostId'] as String,
      inviteCode: data['inviteCode'] as String,
      status: GroupStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'active'),
        orElse: () => GroupStatus.active,
      ),
      planMeta: GroupPlanMeta.fromMap(data['planMeta'] as Map<String, dynamic>),
      planSnapshot: (data['planSnapshot'] as List<dynamic>)
          .map((d) => SnapshotDay.fromMap(d as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notifyOnMemberProgress: data['notifyOnMemberProgress'] as bool? ?? true,
    );
  }
}

// ── Membre d'un groupe ────────────────────────────────────────────────────────

class GroupMember {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final GroupMemberRole role;
  final DateTime joinedAt;
  final bool notifyOnMemberProgress;

  const GroupMember({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
    this.notifyOnMemberProgress = true,
  });

  bool get isHost => role == GroupMemberRole.host;

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'role': role.name,
        'joinedAt': FieldValue.serverTimestamp(),
        'notifyOnMemberProgress': notifyOnMemberProgress,
      };

  factory GroupMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupMember(
      userId: doc.id,
      displayName: data['displayName'] as String? ?? 'Membre',
      avatarUrl: data['avatarUrl'] as String?,
      role: GroupMemberRole.values.firstWhere(
        (r) => r.name == (data['role'] as String? ?? 'member'),
        orElse: () => GroupMemberRole.member,
      ),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notifyOnMemberProgress: data['notifyOnMemberProgress'] as bool? ?? true,
    );
  }
}

// ── Progression d'un membre pour un jour ─────────────────────────────────────

class GroupProgress {
  final String userId;
  final String displayName;
  final int dayIndex;
  final DateTime completedAt;

  const GroupProgress({
    required this.userId,
    required this.displayName,
    required this.dayIndex,
    required this.completedAt,
  });

  // ID du document Firestore : {userId}_{dayIndex}
  static String docId(String userId, int dayIndex) => '${userId}_$dayIndex';

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'displayName': displayName,
        'dayIndex': dayIndex,
        'completedAt': FieldValue.serverTimestamp(),
      };

  factory GroupProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupProgress(
      userId: data['userId'] as String,
      displayName: data['displayName'] as String? ?? 'Membre',
      dayIndex: data['dayIndex'] as int,
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ── Vue agrégée : état du jour pour un groupe ─────────────────────────────────
// Utilisée dans GroupDetailScreen pour afficher qui a lu aujourd'hui.

class GroupDayStatus {
  final GroupMember member;
  final bool hasCompleted; // a lu le jour du plan prévu aujourd'hui
  final DateTime? completedAt;
  final int completedDays; // jours lus au total
  final int expectedDays; // jours prévus jusqu'à aujourd'hui inclus
  final int totalDays;

  const GroupDayStatus({
    required this.member,
    required this.hasCompleted,
    this.completedAt,
    this.completedDays = 0,
    this.expectedDays = 0,
    this.totalDays = 0,
  });

  /// > 0 : en retard de N jours, < 0 : en avance, 0 : à jour.
  int get daysBehind => expectedDays - completedDays;
  double get progress => totalDays > 0 ? completedDays / totalDays : 0;

  /// Statut de chaque membre à partir de toute la progression du groupe.
  /// [todayDayIndex] est null quand aucune lecture n'est prévue aujourd'hui.
  /// Tri : hôte d'abord, puis ceux qui ont lu.
  static List<GroupDayStatus> compute({
    required List<GroupMember> members,
    required List<GroupProgress> progress,
    required int? todayDayIndex,
    required int expectedDays,
    required int totalDays,
  }) {
    final statuses = members.map((m) {
      final mine = progress.where((p) => p.userId == m.userId);
      final today = todayDayIndex == null
          ? null
          : mine.where((p) => p.dayIndex == todayDayIndex).firstOrNull;
      return GroupDayStatus(
        member: m,
        hasCompleted: today != null,
        completedAt: today?.completedAt,
        completedDays: mine.map((p) => p.dayIndex).toSet().length,
        expectedDays: expectedDays,
        totalDays: totalDays,
      );
    }).toList();
    statuses.sort((a, b) {
      if (a.member.isHost != b.member.isHost) return a.member.isHost ? -1 : 1;
      if (a.hasCompleted != b.hasCompleted) return a.hasCompleted ? -1 : 1;
      return 0;
    });
    return statuses;
  }
}
