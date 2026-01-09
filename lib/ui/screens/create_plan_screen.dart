import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../core/theme.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  String _selectedFilter = 'discover'; // 'my', 'discover', 'saved', 'completed'

  @override
  Widget build(BuildContext context) {
    final allTemplates = context.read<PlansProvider>().templates;

    // SECTION 1 : Plans de lecture de la bible en un an (Plans fixes)
    final section1 = allTemplates.where((t) =>
      ['mcheyne', 'bible-year-ligue', 'revolutionary', 'horner'].contains(t.id)
    ).toList();

    // SECTION 2 : Bible intégrale (Plans personnalisables)
    final section2 = allTemplates.where((t) =>
      ['canonical-plan', 'chronological-plan', 'jewish-plan'].contains(t.id)
    ).toList();

    // SECTION 3 : Plans par livres
    final section3 = allTemplates.where((t) =>
      ['new-testament', 'old-testament', 'gospels', 'psalms', 'proverbs', 'genesis-to-revelation'].contains(t.id)
    ).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.deepNavy,
        elevation: 0,
        title: Text(
          'Plans',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_outlined, color: AppTheme.deepNavy),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres horizontaux
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  label: 'Mes plans',
                  value: 'my',
                  isSelected: _selectedFilter == 'my',
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

          const Divider(height: 1),

          // Contenu des plans avec sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16),
              children: [
                // Section 1: Plans de lecture de la bible en un an
                if (section1.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Plans de lecture de la bible en un an',
                    onSeeAll: () {
                      // TODO: Navigation
                    },
                  ),
                  const SizedBox(height: 12),
                  ...section1.map((template) => _PlanListCard(
                    template: template,
                    onTap: () => context.push('/templates/${template.id}'),
                  )),
                  const SizedBox(height: 24),
                ],

                // Section 2: Bible intégrale
                if (section2.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Bible intégrale',
                    onSeeAll: () {
                      // TODO: Navigation
                    },
                  ),
                  const SizedBox(height: 12),
                  ...section2.map((template) => _PlanListCard(
                    template: template,
                    onTap: () => context.push('/templates/${template.id}'),
                  )),
                  const SizedBox(height: 24),
                ],

                // Section 3: Plans par livres
                if (section3.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Plans par livres',
                    onSeeAll: () {
                      // TODO: Navigation
                    },
                  ),
                  const SizedBox(height: 12),
                  ...section3.map((template) => _PlanListCard(
                    template: template,
                    onTap: () => context.push('/templates/${template.id}'),
                  )),
                  const SizedBox(height: 24),
                ],
              ],
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.deepNavy : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.deepNavy : AppTheme.borderSubtle,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Widget pour l'en-tête de section avec "Voir tout"
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepNavy,
                  ),
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Icon(
                Icons.chevron_right,
                color: AppTheme.seedGold,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}

// Widget pour une carte de plan (image à gauche + titre + description)
class _PlanListCard extends StatelessWidget {
  final ReadingPlanTemplate template;
  final VoidCallback onTap;

  const _PlanListCard({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image du plan (carrée)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.seedGold.withValues(alpha: 0.3),
                        AppTheme.deepNavy.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 45,
                    color: AppTheme.seedGold.withValues(alpha: 0.6),
                  ),
                ),

                const SizedBox(width: 16),

                // Informations du plan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Titre du plan
                      Text(
                        template.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.deepNavy,
                                  height: 1.3,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Text(
                        template.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
