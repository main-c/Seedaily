import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';

class PlanTemplateDetailScreen extends StatelessWidget {
  const PlanTemplateDetailScreen({
    super.key,
    required this.templateId,
  });

  final String templateId;

  @override
  Widget build(BuildContext context) {
    final templates = context.read<PlansProvider>().templates;
    final template = templates.firstWhere((t) => t.id == templateId,
        orElse: () => throw ArgumentError('Template not found'));

    final year = DateTime.now().year;
    final defaultTitle = '${template.title} $year';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(template.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Partager',
            onPressed: () async {
              final text =
                  'Plan Seedaily – ${template.title}\n\n${template.description}\n\n${template.porte}';
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Description copiée. Prête à être partagée.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppTheme.backgroundLight,
                ),
                clipBehavior: Clip.antiAlias,
                child: template.image.isNotEmpty
                    ? Image.asset(
                        template.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _TemplateImagePlaceholder(),
                      )
                    : _TemplateImagePlaceholder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              template.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              defaultTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_stories_rounded),
                label: const Text('Générer mon plan'),
                onPressed: () => _onGeneratePlanPressed(
                  context: context,
                  template: template,
                  defaultTitle: defaultTitle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'À propos de ce plan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              template.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              template.porte,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _onGeneratePlanPressed({
    required BuildContext context,
    required ReadingPlanTemplate template,
    required String defaultTitle,
  }) {
    context.push('/customize-plan/${template.id}');
  }
}

class _TemplateImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.seedGold,
            AppTheme.backgroundLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 64,
          color: AppTheme.deepNavy.withOpacity(0.85),
        ),
      ),
    );
  }
}
