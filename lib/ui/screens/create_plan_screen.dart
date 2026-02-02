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
  @override
  Widget build(BuildContext context) {
    final allTemplates = context.read<PlansProvider>().templates;

    // SECTION 1 : Bible intégrale (Plans personnalisables)
    final section1 = allTemplates
        .where((t) => [
              'canonical-plan',
              'chronological-plan',
              'jewish-plan',
              'new-testament',
              'old-testament',
              'gospels',
              'psalms',
            ].contains(t.id))
        .toList();

    // SECTION 2 : Plans de lecture de la bible en un an (Plans fixes)
    final section2 = allTemplates
        .where((t) =>
            ['mcheyne', 'bible-year-ligue', 'revolutionary', 'horner']
                .contains(t.id))
        .toList();

    // SECTION 3 : Plans par livres
    final section3 = allTemplates
        .where((t) => [
              'new-testament',
              'old-testament',
              'gospels',
              'psalms',
              'proverbs',
              'genesis-to-revelation'
            ].contains(t.id))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Découvrir',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_outlined),
                    onPressed: () {
                      // TODO: Implémenter la recherche
                    },
                  ),
                ],
              ),
            ),

            // Contenu des plans avec sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  // Section 1: Bible intégrale
                  if (section1.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Bible intégrale',
                      onSeeAll: () {
                        // TODO: Navigation
                      },
                    ),
                    const SizedBox(height: 12),
                    ...section1.map((template) => _PlanListCard(
                          template: template,
                          onTap: () =>
                              context.push('/customize-plan/${template.id}'),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Section 2: Plans en un an
                  if (section2.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Plans de lecture en un an',
                      onSeeAll: () {
                        // TODO: Navigation
                      },
                    ),
                    const SizedBox(height: 12),
                    ...section2.map((template) => _PlanListCard(
                          template: template,
                          onTap: () =>
                              context.push('/customize-plan/${template.id}'),
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
                          onTap: () =>
                              context.push('/customize-plan/${template.id}'),
                        )),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
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
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppTheme.textPrimary,
                  ),
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Icon(
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

// Widget pour une carte de plan avec image
class _PlanListCard extends StatelessWidget {
  final ReadingPlanTemplate template;
  final VoidCallback onTap;

  const _PlanListCard({
    required this.template,
    required this.onTap,
  });

  /// Widget placeholder avec icône (fallback si image non disponible)
  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
        size: 36,
        color: AppTheme.seedGold.withValues(alpha: 0.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image du plan (URL avec fallback icône)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: template.image.isNotEmpty
                      ? Image.network(
                          template.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildImagePlaceholder();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        )
                      : _buildImagePlaceholder(),
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
                                  color: AppTheme.textPrimary,
                                  height: 1.3,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

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

                // Chevron pour indiquer qu'on peut cliquer
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textMuted,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
