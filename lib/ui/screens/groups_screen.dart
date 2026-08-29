import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/group_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/plan_card.dart';
import 'main_shell_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isSignedIn) {
          return _SignInPrompt(isLoading: auth.isLoading);
        }
        return const _GroupsList();
      },
    );
  }
}

// ── Invite à se connecter ─────────────────────────────────────────────────────

class _SignInPrompt extends StatelessWidget {
  final bool isLoading;
  const _SignInPrompt({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groupes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.seedGold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.group_outlined,
                    size: 40, color: AppTheme.seedGold),
              ),
              const SizedBox(height: 24),
              Text(
                'Lecture en groupe',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Lisez avec vos proches et votre communauté. '
                'Connectez-vous pour créer ou rejoindre un groupe.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => context.read<AuthProvider>().signInWithGoogle(),
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Image.asset('assets/icons/google_icon.png', width: 18, height: 18),
                  label: Text(
                      isLoading ? 'Connexion…' : 'Continuer avec Google'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.deepNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Liste des groupes ─────────────────────────────────────────────────────────

class _GroupsList extends StatelessWidget {
  const _GroupsList();

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupsProvider>(
      builder: (context, groups, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Groupes'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_outlined),
                tooltip: 'Rejoindre un groupe',
                onPressed: () => context.push('/groups/join'),
              ),
            ],
          ),
          body: groups.isLoading
              ? const Center(child: CircularProgressIndicator())
              : groups.groups.isEmpty
                  ? EmptyState(
                      icon: Icons.groups_outlined,
                      title: 'Aucun groupe pour l\'instant',
                      message:
                          'Choisissez un plan dans Découvrir, puis sélectionnez "Avec des amis" pour lire avec votre communauté.',
                      actionLabel: 'Découvrir des plans',
                      onAction: () =>
                          mainShellKey.currentState?.navigateToIndex(1),
                    )
                  : _GroupListBody(groups: groups.groups),
          floatingActionButton: groups.groups.isNotEmpty
              ? FloatingActionButton.extended(
                  heroTag: 'fab_groups',
                  onPressed: () =>
                      mainShellKey.currentState?.navigateToIndex(1),
                  backgroundColor: AppTheme.seedGold,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Nouveau plan de groupe'),
                )
              : null,
        );
      },
    );
  }
}

class _GroupListBody extends StatelessWidget {
  final List<Group> groups;
  const _GroupListBody({required this.groups});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _GroupCard(group: groups[i]),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final totalDays = group.planMeta.totalDays;
    final elapsed = group.planSnapshot.where((d) {
      final dn = DateTime(d.date.year, d.date.month, d.date.day);
      return !dn.isAfter(todayNorm);
    }).length;
    final pct = totalDays > 0 ? elapsed / totalDays : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/group/${group.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image cover avec badge membres
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    PlanImages.getImageForPlan(group.id),
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 130,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.seedGold.withValues(alpha: 0.3),
                            cs.onSurface.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.groups_rounded,
                            size: 48,
                            color: AppTheme.seedGold.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ),
                // Badge "Groupe"
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.groups, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('Groupe',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                // Badge progression en haut à droite
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(pct * 100).toStringAsFixed(0)} %',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            // Contenu texte
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(group.planMeta.title,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurface.withValues(alpha: 0.55)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 4,
                      backgroundColor: cs.outline.withValues(alpha: 0.15),
                      color: AppTheme.seedGold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Jour $elapsed sur $totalDays',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.45)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
