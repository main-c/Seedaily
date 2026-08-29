import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/bible_data.dart';
import '../../domain/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/groups_provider.dart';
import '../../providers/plans_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  ReadingPlanTemplate? _selectedTemplate;
  DateTime _startDate = DateTime.now();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  GeneratorOptions _buildOptions(ReadingPlanTemplate template) {
    final books = _defaultBooks(template.id);
    final orderType = template.id == 'chronological-plan'
        ? OrderType.chronological
        : OrderType.canonical;
    return GeneratorOptions(
      content: ContentOptions(
        scope: ContentScope.custom,
        selectedBooks: books,
      ),
      order: OrderOptions(type: orderType),
      schedule: ScheduleOptions(
        startDate: _startDate,
        totalDays: template.estimatedDays ?? 365,
      ),
      distribution: DistributionOptions(),
      display: DisplayOptions(),
    );
  }

  List<String> _defaultBooks(String templateId) {
    switch (templateId) {
      case 'new-testament':
        return BibleData.getNewTestamentBooks().map((b) => b.name).toList();
      case 'old-testament':
        return BibleData.getOldTestamentBooks().map((b) => b.name).toList();
      case 'gospels':
        return ['Matthieu', 'Marc', 'Luc', 'Jean'];
      case 'psalms':
        return ['Psaumes'];
      case 'proverbs':
        return ['Proverbes'];
      default:
        return BibleData.books.map((b) => b.name).toList();
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate() || _selectedTemplate == null) {
      if (_selectedTemplate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choisissez un plan pour le groupe.')),
        );
      }
      return;
    }

    setState(() => _isCreating = true);

    final auth = context.read<AuthProvider>();
    final groupsProvider = context.read<GroupsProvider>();
    final plansProvider = context.read<PlansProvider>();

    final options = _buildOptions(_selectedTemplate!);
    final plan = plansProvider.generatePlan(
      templateId: _selectedTemplate!.id,
      title: _selectedTemplate!.title,
      options: options,
    );

    final group = await groupsProvider.createGroup(
      name: _nameCtrl.text.trim(),
      hostId: auth.uid!,
      hostDisplayName: auth.displayName,
      hostAvatarUrl: auth.avatarUrl,
      plan: plan,
    );

    if (!mounted) return;

    if (group == null) {
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(groupsProvider.error ?? 'Erreur de création.')),
      );
      groupsProvider.clearError();
      return;
    }

    // Sauvegarde le plan dans Hive avec le groupId
    await plansProvider.importGroupPlan(plan.copyWith(groupId: group.id));

    if (!mounted) return;
    context.go('/group/${group.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final templates = context.read<PlansProvider>().templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un groupe'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
          children: [
            Text('Nom du groupe',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'Ex : Famille Martin, Cellule Alpha…',
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Donnez un nom.' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 28),

            Text('Plan de lecture',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            _PlanPicker(
              templates: templates,
              selected: _selectedTemplate,
              onSelect: (t) => setState(() => _selectedTemplate = t),
            ),
            const SizedBox(height: 28),

            Text('Date de début',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            Material(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 20, color: AppTheme.seedGold),
                      const SizedBox(width: 12),
                      Text(
                        '${_startDate.day.toString().padLeft(2, '0')}/'
                        '${_startDate.month.toString().padLeft(2, '0')}/'
                        '${_startDate.year}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: cs.outline),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isCreating ? null : _create,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.seedGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Créer le groupe',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Sélecteur de plan ─────────────────────────────────────────────────────────

class _PlanPicker extends StatelessWidget {
  final List<ReadingPlanTemplate> templates;
  final ReadingPlanTemplate? selected;
  final ValueChanged<ReadingPlanTemplate> onSelect;

  const _PlanPicker({
    required this.templates,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Plans custom non partageables en groupe v1
    final shareable = templates
        .where((t) => t.id != 'canonical-plan' && t.id != 'chronological-plan')
        .toList();

    return Column(
      children: shareable.map((t) {
        final isSelected = selected?.id == t.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isSelected
                ? AppTheme.seedGold.withValues(alpha: 0.08)
                : cs.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => onSelect(t),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppTheme.seedGold
                                          : cs.onSurface)),
                          if (t.description.isNotEmpty)
                            Text(t.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: cs.onSurface
                                            .withValues(alpha: 0.5)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle,
                          color: AppTheme.seedGold, size: 20)
                    else
                      Icon(Icons.radio_button_unchecked,
                          color: cs.outline, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
