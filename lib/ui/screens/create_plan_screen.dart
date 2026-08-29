import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../core/theme.dart';

class CreatePlanScreen extends StatefulWidget {
  final GlobalKey? customPlanBtnKey;
  final GlobalKey? templateSectionKey;

  const CreatePlanScreen({
    super.key,
    this.customPlanBtnKey,
    this.templateSectionKey,
  });

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
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

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 50), () => _focusNode.requestFocus());
  }

  void _closeSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _isSearching = false;
      _query = '';
    });
  }

  bool _matches(ReadingPlanTemplate t, String q) {
    final lower = q.toLowerCase();
    return t.title.toLowerCase().contains(lower) ||
        t.description.toLowerCase().contains(lower);
  }

  @override
  Widget build(BuildContext context) {
    final allTemplates = context.read<PlansProvider>().templates;
    final hasQuery = _query.trim().isNotEmpty;

    final fixedPlans = allTemplates
        .where((t) => _fixedIds.contains(t.id))
        .where((t) => !hasQuery || _matches(t, _query))
        .toList();
    final thematicPlans = allTemplates
        .where((t) => _thematicIds.contains(t.id))
        .where((t) => !hasQuery || _matches(t, _query))
        .toList();

    final noResults = hasQuery && fixedPlans.isEmpty && thematicPlans.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête : titre + loupe ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 4),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: _isSearching
                        ? const SizedBox.shrink()
                        : Text(
                            'Découvrir',
                            key: const ValueKey('title'),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SizeTransition(
                              sizeFactor: anim,
                              axis: Axis.horizontal,
                              child: child)),
                      child: _isSearching
                          ? Padding(
                              key: const ValueKey('search'),
                              padding: const EdgeInsets.only(right: 8),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                onChanged: (v) => setState(() => _query = v),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                decoration: InputDecoration(
                                  hintText: 'Rechercher...',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                    fontSize: 14,
                                  ),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppTheme.seedGold, width: 1.5),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  // Bouton loupe / fermer
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      size: 22,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: _isSearching ? _closeSearch : _openSearch,
                  ),
                ],
              ),
            ),
            if (!_isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Choisissez un plan ou créez le vôtre',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
            if (_isSearching) const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  // ── Bouton "Créer un plan personnalisé" — masqué en recherche
                  if (!hasQuery) _buildCustomButton(context),
                  if (!hasQuery) const SizedBox(height: 32),

                  // ── Aucun résultat ─────────────────────────────────────
                  if (noResults) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'Aucun plan trouvé pour "$_query"',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                      ),
                    ),
                    _buildCustomButton(context),
                  ],

                  // ── Section : Plans structurés ─────────────────────────
                  if (fixedPlans.isNotEmpty) ...[
                    _SectionHeader(
                      key: widget.templateSectionKey,
                      title: 'Plans structurés',
                      subtitle: 'Structure fixe — choisissez simplement votre date de début',
                    ),
                    const SizedBox(height: 10),
                    ...fixedPlans.map((t) => _PlanCard(
                          template: t,
                          onTap: () => context.push('/customize-plan/${t.id}'),
                        )),
                    const SizedBox(height: 32),
                  ],

                  // ── Section : Plans thématiques ────────────────────────
                  if (thematicPlans.isNotEmpty) ...[
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
        key: widget.customPlanBtnKey,
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
            Container(
              width: 6,
              height: 80,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.seedGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, color: AppTheme.seedGold, size: 24),
            ),
            const SizedBox(width: 14),
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
                    'Vous choisirez vous-mêmes les livres, la durée, le rythme de lecture',
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

  const _SectionHeader({super.key, required this.title, required this.subtitle});

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
