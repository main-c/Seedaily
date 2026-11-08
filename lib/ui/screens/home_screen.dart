import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../../providers/plans_provider.dart';
import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import '../widgets/plan_card.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToDiscover;

  const HomeScreen({
    super.key,
    this.onNavigateToDiscover,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'all'; // 'all', 'in_progress', 'completed'
  PlansProvider? _plansProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _plansProvider = context.read<PlansProvider>();
      _plansProvider!.loadPlans();
      _plansProvider!.addListener(_onProviderChange);
    });
  }

  @override
  void dispose() {
    _plansProvider?.removeListener(_onProviderChange);
    super.dispose();
  }

  // Supprimer un plan de groupe = quitter le groupe, sinon le membre reste
  // « en retard » chez les autres et reçoit encore les rappels.
  // L'admin doit supprimer le groupe depuis son écran.
  Future<void> _deletePlan(GeneratedPlan plan) async {
    final plans = context.read<PlansProvider>();
    if (plan.isGroupPlan) {
      final uid = context.read<AuthProvider>().uid;
      final groups = context.read<GroupsProvider>();
      if (groups.findByPlanGroupId(plan.groupId!)?.hostId == uid) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.homeDeleteGroupPlanHost),
        ));
        return;
      }
      if (uid != null) {
        await groups.leaveGroup(groupId: plan.groupId!, userId: uid);
      }
    }
    await plans.deletePlan(plan.id);
  }

  void _onProviderChange() {
    final provider = context.read<PlansProvider>();
    final milestone = provider.pendingMilestone;
    if (milestone != null && mounted) {
      provider.clearPendingMilestone();
      _showMilestoneDialog(milestone);
    }
  }

  void _showMilestoneDialog(int milestone) {
    showDialog(
      context: context,
      builder: (ctx) => _MilestoneDialog(streakDays: milestone),
    );
  }

  List<GeneratedPlan> _getFilteredPlans(List<GeneratedPlan> allPlans) {
    switch (_selectedFilter) {
      case 'in_progress':
        return allPlans.where((plan) => plan.progress < 100).toList();
      case 'completed':
        return allPlans.where((plan) => plan.progress >= 100).toList();
      case 'all':
      default:
        return allPlans;
    }
  }

  int _getTotalStreak(List<GeneratedPlan> plans) {
    if (plans.isEmpty) return 0;
    // Retourne le streak le plus élevé parmi tous les plans
    return plans.map((p) => p.currentStreak).reduce((a, b) => a > b ? a : b);
  }

  void _goToDiscover() {
    if (widget.onNavigateToDiscover != null) {
      widget.onNavigateToDiscover!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<PlansProvider>(
          builder: (context, plansProvider, child) {
            if (plansProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final allPlans = plansProvider.plans;
            final filteredPlans = _getFilteredPlans(allPlans);
            final totalStreak = _getTotalStreak(allPlans);
            final bestStreak = plansProvider.bestStreak;
            final activePlansCount =
                allPlans.where((p) => p.progress < 100).length;

            return Column(
              children: [
                // Header avec avatar et streak
                _buildHeader(context, activePlansCount, totalStreak, bestStreak),

                // Filtres : Tous, En cours, Terminés
                _buildFilters(context),

                const SizedBox(height: 8),

                // Liste des plans ou état vide
                Expanded(
                  child: allPlans.isEmpty
                      ? EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: context.l10n.homeEmptyTitle,
                          message: context.l10n.homeEmptyMessage,
                          actionLabel: context.l10n.notifActionCreatePlan,
                          onAction: _goToDiscover,
                        )
                      : filteredPlans.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  context.l10n.homeEmptyFilter,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => plansProvider.loadPlans(),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: filteredPlans.length,
                                itemBuilder: (context, index) {
                                  final plan = filteredPlans[index];
                                  return PlanCard(
                                    plan: plan,
                                    onTap: () => context.push('/plan/${plan.id}'),
                                    onDelete: () => _deletePlan(plan),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: context.l10n.groupJoinTitle,
      child: InkWell(
        onTap: () => context.push('/groups/join'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group_add_outlined, size: 18, color: cs.onSurface),
              const SizedBox(width: 6),
              Text(
                context.l10n.groupJoinSubmit,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int activePlansCount,
      int totalStreak, int bestStreak) {
    final authProvider = context.watch<AuthProvider>();
    final isSignedIn = authProvider.isSignedIn;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Logo Seedaily
          if (!isSignedIn) ...[
            Image.asset(
              'assets/icons/play_store_512.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            Text(
              'Seedaily',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const Spacer(),
            _buildJoinButton(context),
          ],

          // Espace pour l'avatar et le streak si connecté
          if (isSignedIn) ...[
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.seedGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.seedGold, width: 2),
              ),
              child: const Icon(Icons.person, color: AppTheme.seedGold, size: 28),
            ),
            const SizedBox(width: 12),

            // Titre et sous-titre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.homeMyPlans,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  Text(
                    context.l10n.homeActivePlans(activePlansCount),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          letterSpacing: 1.2,
                        ),
                  ),
                ],
              ),
            ),

            // Bouton rejoindre un groupe
            _buildJoinButton(context),
            const SizedBox(width: 4),

            // Badge streak gamifié
            if (totalStreak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.seedGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.seedGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: AppTheme.seedGold, size: 18),
                    const SizedBox(width: 4),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.homeStreakDays(totalStreak),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        if (bestStreak > totalStreak)
                          Text(
                            context.l10n.homeBestStreak(bestStreak),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: context.l10n.homeFilterAll,
            value: 'all',
            isSelected: _selectedFilter == 'all',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: context.l10n.homeFilterInProgress,
            value: 'in_progress',
            isSelected: _selectedFilter == 'in_progress',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: context.l10n.homeFilterCompleted,
            value: 'completed',
            isSelected: _selectedFilter == 'completed',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.seedGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.seedGold : Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _MilestoneDialog extends StatelessWidget {
  final int streakDays;
  const _MilestoneDialog({required this.streakDays});

  String get _emoji {
    if (streakDays >= 365) return '🏆';
    if (streakDays >= 100) return '💎';
    if (streakDays >= 60) return '🌟';
    if (streakDays >= 30) return '🔥';
    if (streakDays >= 14) return '⚡';
    return '🎯';
  }

  String _message(AppLocalizations l10n) {
    if (streakDays >= 365) return l10n.milestone365;
    if (streakDays >= 100) return l10n.milestone100;
    if (streakDays >= 60) return l10n.milestone60;
    if (streakDays >= 30) return l10n.milestone30;
    if (streakDays >= 14) return l10n.milestone14;
    return l10n.milestone7;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              context.l10n.milestoneTitle(streakDays),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.seedGold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _message(context.l10n),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.seedGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.commonContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
