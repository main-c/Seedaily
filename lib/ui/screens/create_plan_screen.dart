import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../core/theme.dart';

class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = context.read<PlansProvider>().templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un plan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choisissez un type de plan',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Découvrez les différents plans éditoriaux puis personnalisez le vôtre.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 24),
          ...templates.map(
            (template) => _TemplateListCard(template: template),
          ),
        ],
      ),
    );
  }
}

class _TemplateListCard extends StatelessWidget {
  const _TemplateListCard({required this.template});

  final ReadingPlanTemplate template;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/templates/${template.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                template.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}
