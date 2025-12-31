import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlansProvider>().loadPlans();
    });
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

          return RefreshIndicator(
            onRefresh: () => plansProvider.loadPlans(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: plansProvider.plans.length,
              itemBuilder: (context, index) {
                final plan = plansProvider.plans[index];
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
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-plan'),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau plan'),
      ),
    );
  }
}
