import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../core/theme.dart';

class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  static const _fixedIds = [
    'mcheyne',
    'bible-year-ligue',
    'revolutionary',
    'horner'
  ];
  static const _thematicIds = [
    'new-testament',
    'old-testament',
    'gospels',
    'psalms',
    'proverbs'
  ];

  @override
  Widget build(BuildContext context) {
    final allTemplates = context.read<PlansProvider>().templates;

    final fixedPlans =
        allTemplates.where((t) => _fixedIds.contains(t.id)).toList();
    final thematicPlans =
        allTemplates.where((t) => _thematicIds.contains(t.id)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                'Découvrir',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Choisissez un plan ou créez le vôtre',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  // ── Bouton "Créer un plan personnalisé" ──────────────────
                  _buildCustomButton(context),

                  const SizedBox(height: 32),

                  // ── Section : Plans structurés ───────────────────────────
                  _SectionHeader(
                    title: 'Plans structurés',
                    subtitle:
                        'Structure fixe — choisissez simplement votre date de début',
                  ),
                  const SizedBox(height: 10),
                  ...fixedPlans.map((t) => _PlanCard(
                        template: t,
                        onTap: () => context.push('/customize-plan/${t.id}'),
                      )),

                  const SizedBox(height: 32),

                  // ── Section : Plans thématiques ──────────────────────────
                  _SectionHeader(
                    title: 'Plans thématiques',
                    subtitle: 'Livres ciblés — ajustez la durée et le rythme',
                  ),
                  const SizedBox(height: 10),
                  ...thematicPlans.map((t) => _PlanCard(
                        template: t,
                        onTap: () => context.push('/customize-plan/${t.id}'),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push('/customize-plan/canonical-plan'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bande gauche or
            Container(
              padding: const EdgeInsets.all(12),
              width: 6,
              height: 80,
              decoration: BoxDecoration(
                // color: AppTheme.seedGold,
                borderRadius:  BorderRadius.circular(12)
              ),
            ),
            const SizedBox(width: 16),
            // Icône
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.seedGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, color: AppTheme.seedGold, size: 24),
            ),
            const SizedBox(width: 14),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Créer un plan personnalisé',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Vous Choisirez vous memes les livres, la durée, le rythme de lecture',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_forward_ios,
                  color: cs.onSurface.withValues(alpha: 0.4), size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final ReadingPlanTemplate template;
  final VoidCallback onTap;

  const _PlanCard({required this.template, required this.onTap});

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppTheme.seedGold.withValues(alpha: 0.3),
            AppTheme.deepNavy.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Icon(Icons.menu_book_rounded,
          size: 32, color: AppTheme.seedGold.withValues(alpha: 0.6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: template.image.isNotEmpty
                      ? Image.asset(
                          template.image,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        template.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                 Icon(Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
