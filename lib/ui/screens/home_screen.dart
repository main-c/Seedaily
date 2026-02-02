import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../core/theme.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlansProvider>().loadPlans();
    });
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
      backgroundColor: AppTheme.backgroundLight,
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
            final activePlansCount =
                allPlans.where((p) => p.progress < 100).length;

            return Column(
              children: [
                // Header avec avatar et streak
                _buildHeader(context, activePlansCount, totalStreak),

                // Filtres : Tous, En cours, Terminés
                _buildFilters(context),

                const SizedBox(height: 8),

                // Liste des plans ou état vide
                Expanded(
                  child: allPlans.isEmpty
                      ? EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: 'Aucun plan de lecture',
                          message: 'Créez votre premier plan pour commencer',
                          actionLabel: 'Créer un plan',
                          onAction: _goToDiscover,
                        )
                      : filteredPlans.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'Aucun plan dans cette catégorie',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textMuted,
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
                                    onTap: () =>
                                        context.push('/plan/${plan.id}'),
                                    onDelete: () async {
                                      await plansProvider.deletePlan(plan.id);
                                    },
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

  Widget _buildHeader(
      BuildContext context, int activePlansCount, int totalStreak) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.seedGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.seedGold,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.seedGold,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),

          // Titre et sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes Plans',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                Text(
                  '$activePlansCount PLAN${activePlansCount > 1 ? 'S' : ''} ACTIF${activePlansCount > 1 ? 'S' : ''}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),

          // Badge streak
          if (totalStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.seedGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.seedGold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: AppTheme.seedGold,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalStreak',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    '🔥',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
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
            label: 'Tous',
            value: 'all',
            isSelected: _selectedFilter == 'all',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'En cours',
            value: 'in_progress',
            isSelected: _selectedFilter == 'in_progress',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Terminés',
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
            color: isSelected ? AppTheme.seedGold : AppTheme.borderSubtle,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
