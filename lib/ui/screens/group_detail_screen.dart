import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import '../../domain/group_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../../providers/plans_provider.dart';
import '../widgets/plan_card.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _timedOut = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupsProvider = context.watch<GroupsProvider>();
    final group = groupsProvider.findById(widget.groupId);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: _timedOut
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.l10n.groupDetailLoadError),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/'),
                      child: Text(context.l10n.groupDetailBackHome),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    return _GroupDetailBody(group: group);
  }
}

class _GroupDetailBody extends StatelessWidget {
  final Group group;
  const _GroupDetailBody({required this.group});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isHost = group.hostId == auth.uid;

    return Scaffold(
      body: StreamBuilder<List<GroupMember>>(
        stream: context.read<GroupsProvider>().watchMembers(group.id),
        builder: (context, membersSnap) {
          final members = membersSnap.data ?? [];
          return StreamBuilder<List<GroupProgress>>(
            stream: context.read<GroupsProvider>().watchTodayProgress(group.id),
            builder: (context, progressSnap) {
              final todayProgress = progressSnap.data ?? [];
              final completedUserIds =
                  todayProgress.map((p) => p.userId).toSet();

              final statuses = members.map((m) => GroupDayStatus(
                    member: m,
                    hasCompleted: completedUserIds.contains(m.userId),
                    completedAt: todayProgress
                        .where((p) => p.userId == m.userId)
                        .map((p) => p.completedAt)
                        .firstOrNull,
                  )).toList();

              statuses.sort((a, b) {
                if (a.member.isHost != b.member.isHost) {
                  return a.member.isHost ? -1 : 1;
                }
                if (a.hasCompleted != b.hasCompleted) {
                  return a.hasCompleted ? -1 : 1;
                }
                return 0;
              });

              return SafeArea(
                top: false,
                bottom: true,
                child: CustomScrollView(
                  slivers: [
                    // ── AppBar avec image cover ──────────────────────────────
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      backgroundColor:
                          Theme.of(context).colorScheme.surface,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurface,
                      title: Text(group.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          tooltip: context.l10n.groupDetailShareLink,
                          onPressed: () =>
                              _showInviteDialog(context, group.inviteCode),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'delete') _confirmDelete(context);
                            if (v == 'leave') _confirmLeave(context, auth.uid!);
                          },
                          itemBuilder: (_) => [
                            if (isHost)
                              PopupMenuItem(
                                  value: 'delete',
                                  child: Text(context.l10n.groupDetailDelete,
                                      style: const TextStyle(color: Colors.red)))
                            else
                              PopupMenuItem(
                                  value: 'leave',
                                  child: Text(context.l10n.groupDetailLeave,
                                      style: const TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              PlanImages.getImageForPlan(group.id),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.seedGold
                                          .withValues(alpha: 0.35),
                                      Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(Icons.groups_rounded,
                                      size: 64,
                                      color: AppTheme.seedGold
                                          .withValues(alpha: 0.5)),
                                ),
                              ),
                            ),
                            // Dégradé pour lisibilité du titre
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black26,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ── Résumé plan ──────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _PlanSummaryCard(group: group),
                      ),
                    ),
                    // ── Titre section membres ────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Row(
                          children: [
                            Text(context.l10n.today,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.seedGold
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${completedUserIds.length}/${members.length}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.seedGold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ── Liste membres ────────────────────────────────────────
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: _MemberTile(
                            status: statuses[i],
                            isCurrentUser:
                                statuses[i].member.userId == auth.uid,
                          ),
                        ),
                        childCount: statuses.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showInviteDialog(BuildContext context, String code) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.groupDetailInviteCode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
                color: AppTheme.seedGold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.groupDetailShareCode,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.groupDetailCodeCopied)),
              );
            },
            child: Text(l10n.groupDetailCopy),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.seedGold),
            child: Text(l10n.commonClose,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.groupDetailDeleteConfirmTitle),
        content: Text(l10n.groupDetailDeleteConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () async {
              final groups = context.read<GroupsProvider>();
              final plans = context.read<PlansProvider>();
              Navigator.pop(context);
              await groups.deleteGroup(group.id);
              await plans.deletePlanByGroupId(group.id);
              if (context.mounted) context.go('/');
            },
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child:
                Text(l10n.commonDelete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, String userId) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.groupDetailLeaveConfirmTitle),
        content: Text(l10n.groupDetailLeaveConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () async {
              final groups = context.read<GroupsProvider>();
              final plans = context.read<PlansProvider>();
              Navigator.pop(context);
              await groups.leaveGroup(groupId: group.id, userId: userId);
              await plans.deletePlanByGroupId(group.id);
              if (context.mounted) context.go('/');
            },
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child:
                Text(l10n.groupDetailLeaveAction, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Carte résumé plan ─────────────────────────────────────────────────────────

class _PlanSummaryCard extends StatelessWidget {
  final Group group;
  const _PlanSummaryCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final elapsed = group.planSnapshot.where((d) {
      final dn = DateTime(d.date.year, d.date.month, d.date.day);
      return !dn.isAfter(todayNorm);
    }).length;
    final total = group.planMeta.totalDays;
    final pct = total > 0 ? elapsed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined,
                  size: 18, color: AppTheme.seedGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(group.planMeta.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: cs.outline.withValues(alpha: 0.15),
              color: AppTheme.seedGold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${context.l10n.dayOfTotal(elapsed, total)} · ${context.l10n.percent((pct * 100).round())}',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: cs.onSurface.withValues(alpha: 0.45)),
          ),
        ],
      ),
    );
  }
}

// ── Tuile membre ──────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  final GroupDayStatus status;
  final bool isCurrentUser;
  const _MemberTile({required this.status, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final member = status.member;
    final done = status.hasCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: done
            ? AppTheme.seedGold.withValues(alpha: 0.06)
            : cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? AppTheme.seedGold.withValues(alpha: 0.2)
              : cs.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.seedGold.withValues(alpha: 0.15),
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    member.displayName.isNotEmpty
                        ? member.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.seedGold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCurrentUser ? context.l10n.commonMe : member.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCurrentUser ? AppTheme.seedGold : null),
                    ),
                    if (member.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: cs.outline.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(context.l10n.groupDetailAdminBadge,
                            style: TextStyle(
                                fontSize: 10,
                                color: cs.onSurface.withValues(alpha: 0.4))),
                      ),
                    ],
                  ],
                ),
                if (done && status.completedAt != null)
                  Text(
                    _formatTime(context, status.completedAt!),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.4)),
                  ),
              ],
            ),
          ),
          // Indicateur lu / pas lu
          done
              ? Icon(Icons.check_circle, color: AppTheme.seedGold, size: 22)
              : Icon(Icons.radio_button_unchecked,
                  color: cs.outline.withValues(alpha: 0.4), size: 22),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return context.l10n.groupDetailReadAt('$h:$m');
  }
}
