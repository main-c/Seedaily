import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../domain/models.dart';
import '../../domain/group_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../../providers/plans_provider.dart';
import '../../services/export_service.dart';
import '../../core/share_invite.dart';
import '../../core/theme.dart';
import '../../l10n/error_texts.dart';
import '../../l10n/l10n.dart';
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
        appBar: AppBar(title: Text(context.l10n.planNotFoundTitle)),
        body: Center(
          child: Text(context.l10n.planNotFoundBody),
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
              tooltip: context.l10n.planInvite,
              onPressed: () => _shareInvite(plan),
            )
          else
            IconButton(
              icon: const Icon(Icons.group_add_outlined),
              tooltip: context.l10n.planShareWithFriends,
              onPressed: () => _showConvertToGroupSheet(plan),
            ),
          // Un plan de groupe doit rester identique pour tous : pas de réglages.
          if (!plan.isGroupPlan)
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => context.push('/edit-plan/${widget.planId}'),
              tooltip: context.l10n.planSettings,
            ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _showExportBottomSheet(context, plan),
            tooltip: context.l10n.planExport,
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
          stream: gp.watchProgress(plan.groupId!),
          builder: (context, progressSnap) {
            // Le plan local a les mêmes jours que le snapshot du groupe.
            final todayIdx = plan.days.indexWhere((d) =>
                d.date.year == today.year &&
                d.date.month == today.month &&
                d.date.day == today.day);
            final statuses = GroupDayStatus.compute(
              members: members,
              progress: progressSnap.data ?? [],
              todayDayIndex: todayIdx == -1 ? null : todayIdx,
              expectedDays: expectedDays,
              totalDays: plan.days.length,
            );
            final completedCount =
                statuses.where((s) => s.hasCompleted).length;
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
              statuses: statuses,
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
    List<GroupDayStatus> statuses = const [],
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
                context.l10n.planMyProgress,
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
                context.l10n.dayOfTotal(plan.completedDays, plan.totalDays),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                context.l10n.planPercentComplete(plan.progress.round()),
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
              // Ouvre l'écran du groupe : membres, retard, lecture du jour.
              onTap: () => context.push('/group/${plan.groupId}'),
              child: Row(
                children: [
                  _buildAvatarStack(members, cs),
                  const Spacer(),
                  Text(
                    context.l10n.planFriendsReading,
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
      label = context.l10n.planPaceOnTrack;
      bg = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06);
      fg = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    } else if (delta > 0) {
      label = context.l10n.planPaceAhead(delta);
      bg = Colors.green.withValues(alpha: 0.12);
      fg = Colors.green.shade700;
    } else {
      final behind = -delta;
      label = context.l10n.planPaceBehind(behind);
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
                  // La bordure de 2 px doit tenir dans `size`, sinon le Stack coupe le cercle.
                  radius: size / 2 - 2,
                  backgroundColor: cs.onSurface.withValues(alpha: 0.08),
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
                              color: cs.onSurface.withValues(alpha: 0.7)),
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
                  color: cs.onSurface.withValues(alpha: 0.08),
                  border: Border.all(color: cs.surface, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface.withValues(alpha: 0.7)),
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
                  Text(context.l10n.planSignInRequired,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.planSignInRequiredBody,
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
                      label: Text(context.l10n.settingsSignIn,
                          style: const TextStyle(color: Colors.white)),
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
                    Text(context.l10n.planShareWithFriends,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.planConvertBody(plan.title),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),

                // ── Nom du groupe ──────────────────────────────────────
                Text(context.l10n.groupCreateNameLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.4)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: context.l10n.planGroupNameHint,
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
                                    content: Text(groupsErrorText(ctx.l10n,
                                        groupsProvider.error, ctx.l10n.groupCreateError))),
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
                            shareGroupInvite(plan.title, group.inviteCode);
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
                      isCreating ? context.l10n.planCreating : context.l10n.planCreateAndInvite,
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
    if (group == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.planGroupUnavailable)),
      );
      return;
    }
    shareGroupInvite(plan.title, group.inviteCode);
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
                        context.l10n.planExportTitle,
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
                    context.l10n.planExportBody,
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
                    title: context.l10n.planExportColorsTitle,
                    subtitle: context.l10n.planExportColorsBody,
                    value: sectionColors,
                    onChanged: (v) => setSheetState(() => sectionColors = v),
                  ),
                  const SizedBox(height: 24),

                  // ── Toggle 2 : cases à cocher ─────────────────────────
                  _buildExportToggle(
                    context: context,
                    cs: cs,
                    title: context.l10n.planExportCheckboxesTitle,
                    subtitle: context.l10n.planExportCheckboxesBody,
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
                        isExporting ? context.l10n.planExportGenerating : context.l10n.planExportGenerate,
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
