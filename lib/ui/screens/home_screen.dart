import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:seedaily/domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../core/theme.dart';
import '../widgets/plan_card.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'all'; // 'all', 'discover', 'saved', 'completed'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlansProvider>().loadPlans();
    });
  }

  List<GeneratedPlan> _getFilteredPlans(List<GeneratedPlan> allPlans) {
    switch (_selectedFilter) {
      case 'completed':
        return allPlans.where((plan) => plan.progress >= 100).toList();
      case 'discover':
        // Vous pouvez adapter cette logique selon vos besoins
        return allPlans.where((plan) => plan.progress < 10).toList();
      case 'saved':
        // Vous pouvez ajouter une propriété 'isSaved' dans votre modèle
        return allPlans;
      case 'all':
      default:
        return allPlans;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Seedaily',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.seedGold,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              // Implémenter la recherche
            },
            tooltip: 'Rechercher',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: Consumer<PlansProvider>(
        builder: (context, plansProvider, child) {
          if (plansProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (plansProvider.plans.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Aucun plan de lecture',
              message: 'Créez votre premier plan pour commencer',
              actionLabel: 'Créer un plan',
              onAction: () => context.push('/create-plan'),
            );
          }

          final filteredPlans = _getFilteredPlans(plansProvider.plans);

          return Column(
            children: [
              // Filtres horizontaux
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(
                      label: 'Mes plans',
                      value: 'all',
                      isSelected: _selectedFilter == 'all',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Découvre les plans',
                      value: 'discover',
                      isSelected: _selectedFilter == 'discover',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Enregistré',
                      value: 'saved',
                      isSelected: _selectedFilter == 'saved',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Terminé le',
                      value: 'completed',
                      isSelected: _selectedFilter == 'completed',
                    ),
                  ],
                ),
              ),

              // Séparateur
              const Divider(height: 1),

              // Liste des plans
              Expanded(
                child: filteredPlans.isEmpty
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredPlans.length,
                          itemBuilder: (context, index) {
                            final plan = filteredPlans[index];
                            return PlanCard(
                              plan: plan,
                              onTap: () => context.push('/plan/${plan.id}'),
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Supprimer le plan'),
                                    content: const Text(
                                      'Êtes-vous sûr de vouloir supprimer ce plan?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppTheme.error,
                                        ),
                                        child: const Text('Supprimer'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && context.mounted) {
                                  await plansProvider.deletePlan(plan.id);
                                }
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
      floatingActionButton:
          Consumer<PlansProvider>(builder: (context, plansProvider, child) {
        if (plansProvider.plans.isNotEmpty) {
          return FloatingActionButton(
            onPressed: () => context.push('/create-plan'),
            child: const Icon(Icons.add),
            tooltip: 'Créer un plan',
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Si c'est "Découvre les plans", naviguer vers la création
        if (value == 'discover') {
          context.push('/create-plan');
          return;
        }

        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.deepNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textMuted,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 14,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.deepNavy : AppTheme.borderSubtle,
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
