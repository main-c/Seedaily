import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models.dart';
import '../../domain/group_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../../providers/plans_provider.dart';
import '../../services/export_service.dart';
import '../../core/theme.dart';
import '../widgets/month_calendar_widget.dart';
import '../widgets/list_view_widget.dart';
import '../widgets/weekly_view_widget.dart';
import '../widgets/by_book_view_widget.dart';

class PlanDetailScreen extends StatefulWidget {
  final String planId;

  const PlanDetailScreen({
    super.key,
    required this.planId,
  });

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  final _exportService = ExportService();
  int? _selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlansProvider>().getPlanById(widget.planId);

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plan introuvable')),
        body: const Center(
          child: Text('Ce plan n\'existe pas'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          if (plan.isGroupPlan)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Inviter',
              onPressed: () => _shareInvite(plan),
            )
          else
            IconButton(
              icon: const Icon(Icons.group_add_outlined),
              tooltip: 'Partager avec des amis',
              onPressed: () => _showConvertToGroupSheet(plan),
            ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/edit-plan/${widget.planId}'),
            tooltip: 'Configuration',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _showExportBottomSheet(context, plan),
            tooltip: 'Exporter',
          ),
        ],
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressHeader(plan),
          Expanded(
            child: _buildCurrentView(plan),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(GeneratedPlan plan) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final expectedDays = plan.days.where((d) {
      final dayNorm = DateTime(d.date.year, d.date.month, d.date.day);
      return !dayNorm.isAfter(todayNorm);
    }).length;
    final delta = plan.completedDays - expectedDays;

    if (!plan.isGroupPlan) {
      return _buildProgressCard(
        plan: plan,
        delta: delta,
        expectedDays: expectedDays,
      );
    }

    // Plan de groupe : on enveloppe dans StreamBuilders pour les données membres
    final gp = context.read<GroupsProvider>();
    return StreamBuilder<List<GroupMember>>(
      stream: gp.watchMembers(plan.groupId!),
      builder: (context, membersSnap) {
        final members = membersSnap.data ?? [];
        return StreamBuilder<List<GroupProgress>>(
          stream: gp.watchTodayProgress(plan.groupId!),
          builder: (context, progressSnap) {
            final todayProgress = progressSnap.data ?? [];
            final completedCount = todayProgress.length;
            final totalCount = members.isEmpty ? 1 : members.length;
            final groupPct = completedCount / totalCount;

            return _buildProgressCard(
              plan: plan,
              delta: delta,
              expectedDays: expectedDays,
              groupPct: groupPct,
              completedCount: completedCount,
              totalCount: totalCount,
              members: members,
              todayProgress: todayProgress,
            );
          },
        );
      },
    );
  }

  Widget _buildProgressCard({
    required GeneratedPlan plan,
    required int delta,
    required int expectedDays,
    double? groupPct,
    int completedCount = 0,
    int totalCount = 0,
    List<GroupMember> members = const [],
    List<GroupProgress> todayProgress = const [],
  }) {
    final cs = Theme.of(context).colorScheme;
    final isGroup = groupPct != null;
    final myPct = plan.progress / 100;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ligne 1 : titre + badge rythme ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Ma progression',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
              ),
              const Spacer(),
              _buildPaceBadge(delta, expectedDays),
            ],
          ),
          const SizedBox(height: 16),

          // ── Ligne 2 : jours + pourcentage ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jour ${plan.completedDays} sur ${plan.totalDays}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '${plan.progress.toStringAsFixed(0)}% complété',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Barre de progression ────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: myPct,
              minHeight: 5,
              backgroundColor: cs.outline.withValues(alpha: 0.15),
              color: AppTheme.seedGold,
            ),
          ),

          // ── Ligne 3 : avatars membres + label (groupe seulement) ───
          if (isGroup) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showMembersSheet(
                members,
                todayProgress,
                context.read<GroupsProvider>().findByPlanGroupId(plan.groupId!)?.hostId ==
                    context.read<AuthProvider>().uid,
                context.read<AuthProvider>().uid,
              ),
              child: Row(
                children: [
                  _buildAvatarStack(members, cs),
                  const Spacer(),
                  Text(
                    'Amis qui lisent',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      size: 16, color: cs.onSurface.withValues(alpha: 0.35)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaceBadge(int delta, int expectedDays) {
    if (expectedDays == 0) return const SizedBox.shrink();

    final String label;
    final Color bg;
    final Color fg;

    if (delta == 0) {
      label = 'Vous êtes à jour';
      bg = AppTheme.seedGold.withValues(alpha: 0.13);
      fg = AppTheme.seedGold;
    } else if (delta > 0) {
      label = 'En avance de $delta j.';
      bg = Colors.green.withValues(alpha: 0.12);
      fg = Colors.green.shade700;
    } else {
      final behind = -delta;
      label = 'En retard de $behind j.';
      bg = behind <= 3
          ? Colors.orange.withValues(alpha: 0.12)
          : Colors.red.withValues(alpha: 0.10);
      fg = behind <= 3 ? Colors.orange.shade800 : Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildAvatarStack(List<GroupMember> members, ColorScheme cs) {
    const maxVisible = 3;
    final visible = members.take(maxVisible).toList();
    final extra = members.length - maxVisible;
    const size = 30.0;
    const overlap = 20.0;
    final totalWidth = visible.length * overlap + (extra > 0 ? overlap : 0) + (size - overlap);

    return SizedBox(
      height: size,
      width: totalWidth.clamp(size, 200.0),
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2),
                ),
                child: CircleAvatar(
                  radius: size / 2,
                  backgroundColor: AppTheme.seedGold.withValues(alpha: 0.18),
                  backgroundImage: visible[i].avatarUrl != null
                      ? NetworkImage(visible[i].avatarUrl!)
                      : null,
                  child: visible[i].avatarUrl == null
                      ? Text(
                          visible[i].displayName.isNotEmpty
                              ? visible[i].displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.seedGold),
                        )
                      : null,
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: visible.length * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.seedGold.withValues(alpha: 0.13),
                  border: Border.all(color: cs.surface, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.seedGold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Marque un jour comme complété/non-complété et sauvegarde dans Hive
  void _toggleDayCompletion(GeneratedPlan plan, int dayIndex) {
    final day = plan.days[dayIndex];
    context.read<PlansProvider>().toggleDayCompletion(
          widget.planId,
          day.date,
        );
  }

  /// Construit la vue actuellement sélectionnée
  Widget _buildCurrentView(GeneratedPlan plan) {
    // Trouver le jour correspondant à aujourd'hui (date calendaire)
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    int? currentDayIndex;
    for (int i = 0; i < plan.days.length; i++) {
      final d = plan.days[i].date;
      if (DateTime(d.year, d.month, d.day) == todayNorm) {
        currentDayIndex = i;
        break;
      }
    }
    // Fallback : premier jour non complété si aujourd'hui est hors du plan
    if (currentDayIndex == null) {
      for (int i = 0; i < plan.days.length; i++) {
        if (!plan.days[i].completed) {
          currentDayIndex = i;
          break;
        }
      }
    }

    // Afficher le widget selon le format du plan
    switch (plan.options.display.format) {
      case OutputFormat.calendar:
        return MonthCalendarWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex ?? 0,
          selectedDayIndex: _selectedDayIndex ?? currentDayIndex ?? 0,
          selectedReadingDays: const <String>{},
          isPreviewMode: false,
          onDayTap: (index) {
            setState(() {
              _selectedDayIndex = index;
            });
          },
          onDayComplete: (index) => _toggleDayCompletion(plan, index),
        );

      case OutputFormat.list:
        return ListViewWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex,
          selectedDayIndex: _selectedDayIndex,
          isPreviewMode: false,
          showCheckbox: true,
          onDayTap: (index) => _toggleDayCompletion(plan, index),
        );

      case OutputFormat.weekly:
        return WeekViewWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex,
          selectedDayIndex: _selectedDayIndex,
          isPreviewMode: false,
          showCheckbox: true,
          currentStreak: plan.currentStreak,
          progress: plan.progress,
          onDayTap: (index) => _toggleDayCompletion(plan, index),
        );

      case OutputFormat.byBook:
        return ByBookViewWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex,
          selectedDayIndex: _selectedDayIndex,
          isPreviewMode: false,
          showCheckbox: true,
          onDayTap: (index) => _toggleDayCompletion(plan, index),
        );

      case OutputFormat.circle:
        // Format Circle pas encore implémenté, utiliser liste par défaut
        return ListViewWidget(
          days: plan.days,
          currentDayIndex: currentDayIndex,
          selectedDayIndex: _selectedDayIndex,
          isPreviewMode: false,
          showCheckbox: true,
          onDayTap: (index) => _toggleDayCompletion(plan, index),
        );
    }
  }

  // ── Section Groupe ──────────────────────────────────────────────────────────

  void _showConvertToGroupSheet(GeneratedPlan plan) {
    final auth = context.read<AuthProvider>();

    // Pas connecté → on propose la connexion
    if (!auth.isSignedIn) {
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) {
          final cs = Theme.of(context).colorScheme;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 40,
                      color: cs.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Connexion requise',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous avec Google pour partager ce plan avec des amis.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                        ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await auth.signInWithGoogle();
                      },
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text('Se connecter',
                          style: TextStyle(color: Colors.white)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.seedGold,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    final nameCtrl = TextEditingController(text: plan.title);
    bool isCreating = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final cs = Theme.of(context).colorScheme;
          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, color: cs.onSurface, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text('Partager avec des amis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Créez un groupe depuis votre plan "${plan.title}". '
                  'Vos amis pourront vous rejoindre et vous suivrez votre progression ensemble.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),

                // ── Nom du groupe ──────────────────────────────────────
                Text('Nom du groupe',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.4)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ex : Famille, Cellule, Amis…',
                    filled: true,
                    fillColor: cs.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Bouton ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: isCreating
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) return;
                            setSheetState(() => isCreating = true);

                            final groupsProvider =
                                context.read<GroupsProvider>();
                            final plansProvider = context.read<PlansProvider>();

                            final group = await groupsProvider.createGroup(
                              name: name,
                              hostId: auth.uid!,
                              hostDisplayName: auth.displayName,
                              hostAvatarUrl: auth.avatarUrl,
                              plan: plan,
                            );

                            if (!ctx.mounted) return;

                            if (group == null) {
                              setSheetState(() => isCreating = false);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                    content: Text(groupsProvider.error ??
                                        'Erreur de création.')),
                              );
                              groupsProvider.clearError();
                              return;
                            }

                            // Lie le plan local au groupe
                            await plansProvider.linkPlanToGroup(
                                plan.id, group.id);

                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);

                            // Partage le lien d'invitation
                            Share.share(
                              'Lis la Bible avec moi sur Seedaily !\n\n'
                              'Rejoins mon plan "${plan.title}" :\n'
                              'https://seedaily.vercel.app/join?c=${group.inviteCode}\n\n'
                              'Télécharge l\'app :\n'
                              'https://play.google.com/store/apps/details?id=com.seedaily.app',
                              subject: 'Invitation à lire ensemble sur Seedaily',
                            );
                          },
                    icon: isCreating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.group_add_outlined,
                            color: Colors.white, size: 20),
                    label: Text(
                      isCreating ? 'Création…' : 'Créer le groupe et inviter',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.seedGold,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _shareInvite(GeneratedPlan plan) {
    final group = context.read<GroupsProvider>().findByPlanGroupId(plan.groupId!);
    if (group == null) return;
    Share.share(
      'Lis la Bible avec moi sur Seedaily !\n\n'
      'Rejoins mon plan "${plan.title}" en cliquant ici :\n'
      'https://seedaily.vercel.app/join?c=${group.inviteCode}\n\n'
      'Si tu n\'as pas encore l\'app :\n'
      'https://play.google.com/store/apps/details?id=com.seedaily.app',
      subject: 'Invitation à lire ensemble sur Seedaily',
    );
  }

  void _showMembersSheet(
    List<GroupMember> members,
    List<GroupProgress> todayProgress,
    bool isHost,
    String? currentUid,
  ) {
    final completedUserIds = todayProgress.map((p) => p.userId).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        final sorted = [...members]..sort((a, b) {
            if (a.isHost != b.isHost) return a.isHost ? -1 : 1;
            final aDone = completedUserIds.contains(a.userId);
            final bDone = completedUserIds.contains(b.userId);
            if (aDone != bDone) return aDone ? -1 : 1;
            return 0;
          });

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Membres du groupe',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...sorted.map((m) {
                  final done = completedUserIds.contains(m.userId);
                  final isMe = m.userId == currentUid;
                  final progress = todayProgress
                      .where((p) => p.userId == m.userId)
                      .firstOrNull;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              AppTheme.seedGold.withValues(alpha: 0.15),
                          backgroundImage: m.avatarUrl != null
                              ? NetworkImage(m.avatarUrl!)
                              : null,
                          child: m.avatarUrl == null
                              ? Text(
                                  m.displayName.isNotEmpty
                                      ? m.displayName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.seedGold,
                                      fontSize: 13))
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
                                    isMe ? 'Moi' : m.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isMe
                                                ? AppTheme.seedGold
                                                : null),
                                  ),
                                  if (m.isHost) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: cs.outline.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text('admin',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: cs.onSurface
                                                  .withValues(alpha: 0.4))),
                                    ),
                                  ],
                                ],
                              ),
                              // Heure de lecture : visible par tous si complété
                              if (done && progress?.completedAt != null)
                                Text(
                                  _formatTime(progress!.completedAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          color: cs.onSurface
                                              .withValues(alpha: 0.45)),
                                ),
                            ],
                          ),
                        ),
                        done
                            ? Icon(Icons.check_circle,
                                color: AppTheme.seedGold, size: 20)
                            : Icon(Icons.radio_button_unchecked,
                                color: cs.outline.withValues(alpha: 0.4),
                                size: 20),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return 'Lu à $h:$m';
  }

  void _showExportBottomSheet(BuildContext context, GeneratedPlan plan) {
    bool sectionColors = true;
    bool includeCheckbox = true;
    bool isExporting = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final cs = Theme.of(context).colorScheme;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header : X + titre ────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Icon(Icons.close, color: cs.onSurface, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Exporter mon plan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Description ───────────────────────────────────────
                  Text(
                    'Personnalisez l\'apparence de votre plan de lecture avant de le télécharger au format PDF.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // ── Toggle 1 : couleurs ───────────────────────────────
                  _buildExportToggle(
                    context: context,
                    cs: cs,
                    title: 'Colorer par genre biblique',
                    subtitle:
                        'Attribue une couleur spécifique à chaque type de livre comme la Loi, les Prophètes, les Évangiles.',
                    value: sectionColors,
                    onChanged: (v) => setSheetState(() => sectionColors = v),
                  ),
                  const SizedBox(height: 24),

                  // ── Toggle 2 : cases à cocher ─────────────────────────
                  _buildExportToggle(
                    context: context,
                    cs: cs,
                    title: 'Afficher les cases à cocher',
                    subtitle:
                        'Pour le suivi papier. Ajoute une case vide à côté de chaque session de lecture.',
                    value: includeCheckbox,
                    onChanged: (v) => setSheetState(() => includeCheckbox = v),
                  ),
                  const SizedBox(height: 36),

                  // ── Bouton Générer ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: isExporting
                          ? null
                          : () async {
                              setSheetState(() => isExporting = true);
                              Navigator.pop(ctx);
                              await _exportService.sharePdf(
                                plan,
                                sectionColors: sectionColors,
                                includeCheckbox: includeCheckbox,
                              );
                            },
                      icon: isExporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined,
                              color: Colors.white, size: 20),
                      label: Text(
                        isExporting ? 'Génération…' : 'Générer le PDF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.deepNavy,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExportToggle({
    required BuildContext context,
    required ColorScheme cs,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppTheme.seedGold,
          activeThumbColor: Colors.white,
          inactiveThumbColor: cs.onSurface.withValues(alpha: 0.4),
          inactiveTrackColor: cs.outline.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
