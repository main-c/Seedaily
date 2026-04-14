import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seedaily/ui/screens/main_shell_screen.dart';

import '../../core/theme.dart';
import '../../domain/bible_data.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/plan_generator.dart';
import '../widgets/book_selector_section.dart';

class CustomizePlanScreen extends StatefulWidget {
  const CustomizePlanScreen({
    super.key,
    this.templateId,
    this.planId,
  }) : assert(templateId != null || planId != null,
            'Either templateId or planId must be provided');

  /// Pour créer un nouveau plan à partir d'un template
  final String? templateId;

  /// Pour éditer un plan existant
  final String? planId;

  /// Mode édition si planId est fourni
  bool get isEditMode => planId != null;

  @override
  State<CustomizePlanScreen> createState() => _CustomizePlanScreenState();
}

class _CustomizePlanScreenState extends State<CustomizePlanScreen>
    with SingleTickerProviderStateMixin {
  final _generator = PlanGenerator();
  late TabController _tabController;
  late TextEditingController _titleController;

  /// Le plan de travail (local, pas encore sauvegardé en BD)
  late GeneratedPlan _workingPlan;

  /// Le template associé au plan
  late ReadingPlanTemplate _template;

  final _dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

  @override
  void initState() {
    super.initState();
    final provider = context.read<PlansProvider>();

    if (widget.isEditMode) {
      // Mode édition : charger le plan existant
      final existingPlan = provider.getPlanById(widget.planId!);
      if (existingPlan != null) {
        _workingPlan = existingPlan;
        _template = provider.templates.firstWhere(
          (t) => t.id == existingPlan.templateId,
          orElse: () => provider.templates.first,
        );
      } else {
        // Plan introuvable - créer un plan par défaut
        _template = provider.templates.first;
        _workingPlan = _generateDefaultPlan(_template.id);
      }
    } else {
      // Mode création : générer un plan avec options par défaut
      _template = provider.templates.firstWhere(
        (t) => t.id == widget.templateId,
        orElse: () => provider.templates.first,
      );
      _workingPlan = _generateDefaultPlan(_template.id);
    }

    // TabController : 1 onglet pour les plans fixes, 3 pour les autres
    _tabController = TabController(
      length: _isFixedPlan ? 1 : 3,
      vsync: this,
    );

    _titleController = TextEditingController(text: _workingPlan.title);
  }

  /// Génère un plan avec les options par défaut pour un template
  GeneratedPlan _generateDefaultPlan(String templateId) {
    final year = DateTime.now().year;
    final defaultOptions = _getDefaultOptions(templateId);
    final isCustomEntry = templateId == 'canonical-plan' && !widget.isEditMode;
    final title = isCustomEntry ? 'Mon plan $year' : '${_template.title} $year';

    return _generator.generate(
      templateId: templateId,
      title: title,
      options: defaultOptions,
    );
  }

  /// Retourne les options par défaut selon le template
  GeneratorOptions _getDefaultOptions(String templateId) {
    final selectedBooks = _getDefaultBooks(templateId);
    final orderType = _getDefaultOrderType(templateId);

    return GeneratorOptions(
      content: ContentOptions(
        scope: ContentScope.custom,
        selectedBooks: selectedBooks,
        includeApocrypha: false,
      ),
      order: OrderOptions(type: orderType),
      schedule: ScheduleOptions(
        startDate: DateTime.now(),
        totalDays: 365,
        readingDays: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      ),
      distribution: DistributionOptions(),
      display: DisplayOptions(),
    );
  }

  List<String> _getDefaultBooks(String templateId) {
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

  OrderType _getDefaultOrderType(String templateId) {
    switch (templateId) {
      case 'chronological-plan':
        return OrderType.chronological;
      default:
        return OrderType.canonical;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  bool get _isFixedPlan {
    return [
      'mcheyne',
      'bible-year-ligue',
      'revolutionary',
      'horner',
    ].contains(_workingPlan.templateId);
  }

  /// Plans dont les livres sont verrouillés (l'utilisateur ne peut pas en ajouter d'autres)
  bool get _isThematicPlan {
    return [
      'new-testament',
      'old-testament',
      'gospels',
      'psalms',
      'proverbs',
    ].contains(_workingPlan.templateId);
  }

  bool get _hasOldTestament {
    return _workingPlan.options.content.selectedBooks.any((bookName) {
      final book = BibleData.getBook(bookName);
      return book?.isOldTestament ?? false;
    });
  }

  bool get _hasNewTestament {
    return _workingPlan.options.content.selectedBooks.any((bookName) {
      final book = BibleData.getBook(bookName);
      return book?.isNewTestament ?? false;
    });
  }

  bool get _showDailyPsalmProverb => !_isFixedPlan && _hasOldTestament;

  bool get _showOtNtOverlap =>
      !_isFixedPlan && _hasOldTestament && _hasNewTestament;

  // ============================================================================
  // RÉGÉNÉRATION DU PLAN
  // ============================================================================

  /// Régénère le plan avec de nouvelles options
  void _regeneratePlan({
    ContentOptions? content,
    OrderOptions? order,
    ScheduleOptions? schedule,
    DistributionOptions? distribution,
    DisplayOptions? display,
  }) {
    final newOptions = GeneratorOptions(
      content: content ?? _workingPlan.options.content,
      order: order ?? _workingPlan.options.order,
      schedule: schedule ?? _workingPlan.options.schedule,
      distribution: distribution ?? _workingPlan.options.distribution,
      display: display ?? _workingPlan.options.display,
    );

    setState(() {
      _workingPlan = _generator.generate(
        templateId: _workingPlan.templateId,
        title: _titleController.text,
        options: newOptions,
        existingPlanId: _workingPlan.id, // Garder le même ID
      );
    });
    // debugPrint('[_regeneratePlan] orderType=${_workingPlan.options.order.type} selectedBooks=${_workingPlan.options.content.selectedBooks}');
  }

  // ============================================================================
  // SAUVEGARDE
  // ============================================================================

  Future<void> _savePlan() async {
    if (_workingPlan.options.content.selectedBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un livre biblique'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    try {
      final provider = context.read<PlansProvider>();

      // Mettre à jour le titre avant de sauvegarder
      final planToSave = _generator.generate(
        templateId: _workingPlan.templateId,
        title: _titleController.text,
        options: _workingPlan.options,
        existingPlanId: _workingPlan.id,
      );

      if (widget.isEditMode) {
        // Mode édition : mettre à jour le plan existant
        await provider.updatePlan(
          planId: widget.planId!,
          title: _titleController.text,
          options: _workingPlan.options,
        );
        if (mounted) {
          context.pop();
        }
      } else {
        // Mode création : créer un nouveau plan
        final isFirstPlan = provider.plans.isEmpty;
        await provider.createPlan(
          templateId: _workingPlan.templateId,
          title: planToSave.title,
          options: _workingPlan.options,
        );
        if (mounted) {
          context.pop();
          mainShellKey.currentState?.navigateToIndex(0);

          // Proposer d'activer les notifications au premier plan créé
          final settings = context.read<SettingsProvider>();
          if (isFirstPlan &&
              !settings.notificationsEnabled &&
              !settings.notifPromptShown) {
            await settings.markNotifPromptShown();
            if (mounted) {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Activer les rappels ?'),
                  content: const Text(
                    'Reçois un rappel quotidien pour ne jamais oublier ta lecture.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Plus tard'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        settings.setNotificationsEnabled(true);
                      },
                      child: const Text('Activer'),
                    ),
                  ],
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                  ? 'Erreur lors de la mise à jour du plan: $e'
                  : 'Erreur lors de la création du plan: $e',
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
            widget.isEditMode ? 'Modifier le plan' : 'Personnaliser le plan'),
      ),
      body: NestedScrollView(
        physics: const ClampingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec aperçu du plan
                  Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'APERÇU DU PLAN',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        _buildTemplateHeader(),
                      ],
                    ),
                  ),

                  // Date de début
                  _buildDateSection(),

                  // Jours de lecture
                  _buildReadingDaysSection(),

                  // Format d'affichage
                  _buildFormatSection(),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.onSurface,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  indicatorColor: AppTheme.seedGold,
                  indicatorWeight: 3,
                  tabs: _isFixedPlan
                      ? const [Tab(text: 'Affichage')]
                      : const [
                          Tab(text: 'Livres'),
                          Tab(text: 'Distribution'),
                          Tab(text: 'Affichage'),
                        ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _isFixedPlan
              ? [_buildDisplayTab()]
              : [_buildBooksTab(), _buildDistributionTab(), _buildDisplayTab()],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _savePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seedGold,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.isEditMode
                    ? 'Enregistrer les modifications'
                    : 'Créer le plan',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // WIDGETS - HEADER
  // ============================================================================

  Widget _buildImagePlaceholder({double height = 180}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.seedGold.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Icon(
        Icons.menu_book_rounded,
        size: 64,
        color: AppTheme.seedGold.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildTemplateHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du template
          _template.image.isNotEmpty
              ? Image.asset(
                  _template.image,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                )
              : _buildImagePlaceholder(),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _workingPlan.templateId == 'canonical-plan' && !widget.isEditMode
                      ? 'Plan personnalisé'
                      : _template.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.seedGold,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _workingPlan.templateId == 'canonical-plan' && !widget.isEditMode
                      ? 'Choisissez vos livres, l\'ordre et la durée'
                      : _template.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
                if (_template.porte.isNotEmpty &&
                    !(_workingPlan.templateId == 'canonical-plan' && !widget.isEditMode)) ...[
                  const SizedBox(height: 8),
                  Text(
                    _template.porte,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGETS - SECTIONS
  // ============================================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  DateTime get _endDate {
    final s = _workingPlan.options.schedule;
    return s.startDate.add(Duration(days: s.totalDays - 1));
  }

  Widget _buildDateSection() {
    final startDate = _workingPlan.options.schedule.startDate;
    final endDate = _endDate;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Période de lecture'),
          const SizedBox(height: 12),
          Row(
            children: [
              // Date de début
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Début',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: now.subtract(const Duration(days: 365)),
                          lastDate: now.add(const Duration(days: 1825)),
                          locale: const Locale('fr', 'FR'),
                        );

                        if (selected != null && mounted) {
                          final currentTotalDays =
                              _workingPlan.options.schedule.totalDays;
                          // Plans fixes : on garde la durée intacte, seule la date de début change
                          // Plans custom : on recalcule si la nouvelle date dépasse la fin actuelle
                          final newTotalDays = _isFixedPlan
                              ? currentTotalDays
                              : () {
                                  final currentEnd = _endDate;
                                  final newEnd = selected.isAfter(currentEnd)
                                      ? selected.add(const Duration(days: 364))
                                      : currentEnd;
                                  return newEnd.difference(selected).inDays + 1;
                                }();
                          _regeneratePlan(
                            schedule: ScheduleOptions(
                              startDate: selected,
                              totalDays: newTotalDays,
                              readingDays:
                                  _workingPlan.options.schedule.readingDays,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _dateFormat.format(startDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                             Icon(Icons.calendar_today,
                                size: 16, color: Theme.of(context).colorScheme.tertiary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Flèche
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Icon(Icons.arrow_forward,
                    size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 10),
              // Date de fin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _isFixedPlan
                          ? null
                          : () async {
                              final selected = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: startDate.add(const Duration(days: 1)),
                                lastDate: startDate
                                    .add(const Duration(days: 3650)),
                                locale: const Locale('fr', 'FR'),
                              );

                              if (selected != null && mounted) {
                                final newTotalDays =
                                    selected.difference(startDate).inDays + 1;
                                _regeneratePlan(
                                  schedule: ScheduleOptions(
                                    startDate: startDate,
                                    totalDays: newTotalDays,
                                    readingDays: _workingPlan
                                        .options.schedule.readingDays,
                                  ),
                                );
                              }
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isFixedPlan
                              ? Theme.of(context).colorScheme.surfaceContainerLowest
                              : Theme.of(context).colorScheme.surface,
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _dateFormat.format(endDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: _isFixedPlan
                                          ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                                          : Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            Icon(
                              _isFixedPlan
                                  ? Icons.lock_outline
                                  : Icons.calendar_today,
                              size: 16,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Résumé durée
          Text(
            '${_workingPlan.options.schedule.totalDays} jours au total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildReadingDaysSection() {
    final readingDays = _workingPlan.options.schedule.readingDays.toSet();

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Jours de lecture'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              {'key': 'mon', 'label': 'L', 'fullLabel': 'LUN'},
              {'key': 'tue', 'label': 'M', 'fullLabel': 'MAR'},
              {'key': 'wed', 'label': 'M', 'fullLabel': 'MER'},
              {'key': 'thu', 'label': 'J', 'fullLabel': 'JEU'},
              {'key': 'fri', 'label': 'V', 'fullLabel': 'VEN'},
              {'key': 'sat', 'label': 'S', 'fullLabel': 'SAM'},
              {'key': 'sun', 'label': 'D', 'fullLabel': 'DIM'},
            ].map((day) {
              final isSelected = readingDays.contains(day['key']);
              return GestureDetector(
                onTap: () {
                  final newDays = Set<String>.from(readingDays);
                  if (isSelected) {
                    newDays.remove(day['key']!);
                  } else {
                    newDays.add(day['key']!);
                  }
                  _regeneratePlan(
                    schedule: ScheduleOptions(
                      startDate: _workingPlan.options.schedule.startDate,
                      totalDays: _workingPlan.options.schedule.totalDays,
                      readingDays: newDays.toList(),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.seedGold : Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? null
                        : Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Center(
                    child: Text(
                      day['label']!,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFormatSection() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Format d\'affichage'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildFormatButton(OutputFormat.list, 'Liste', Icons.list),
                _buildFormatButton(
                    OutputFormat.calendar, 'Calendrier', Icons.calendar_month),
                _buildFormatButton(
                    OutputFormat.weekly, 'Semaine', Icons.view_week),
                _buildFormatButton(
                    OutputFormat.byBook, 'Livre', Icons.menu_book),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFormatButton(OutputFormat format, String label, IconData icon) {
    final isSelected = _workingPlan.options.display.format == format;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _regeneratePlan(
            display: DisplayOptions(
              includeCheckbox: _workingPlan.options.display.includeCheckbox,
              showStats: _workingPlan.options.display.showStats,
              removeDates: _workingPlan.options.display.removeDates,
              sectionColors: _workingPlan.options.display.sectionColors,
              addReadingLinks: _workingPlan.options.display.addReadingLinks,
              format: format,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.seedGold : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // TABS
  // ============================================================================

  Widget _buildBooksTab() {
    // Plans fixes : sélection de livres non disponible
    if (_isFixedPlan) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'La sélection des livres n\'est pas disponible pour ce plan.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Plans thématiques : livres verrouillés, affichage en lecture seule
    if (_isThematicPlan) {
      return _buildThematicBooksDisplay();
    }

    // Plans personnalisés : sélection de livres + bouton filtre pour l'ordre
    return ListView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Sélection des livres'),
            _buildOrderFilterButton(),
          ],
        ),
        const SizedBox(height: 12),
        BookSelectorSection(
          templateId: _workingPlan.templateId,
          selectedBooks: _workingPlan.options.content.selectedBooks.toSet(),
          includeApocrypha: _workingPlan.options.content.includeApocrypha,
          onBooksChanged: (newSelection) {
            _regeneratePlan(
              content: ContentOptions(
                scope: ContentScope.custom,
                selectedBooks: newSelection.toList(),
                includeApocrypha: _workingPlan.options.content.includeApocrypha,
              ),
            );
          },
          onApocryphaSwitched: (value) {
            _regeneratePlan(
              content: ContentOptions(
                scope: ContentScope.custom,
                selectedBooks: _workingPlan.options.content.selectedBooks,
                includeApocrypha: value,
              ),
            );
          },
        ),
      ],
    );
  }

  /// Bouton filtre compact qui ouvre le bottom sheet d'ordre de lecture
  Widget _buildOrderFilterButton() {
    final currentOrder = _workingPlan.options.order.type;
    final label = switch (currentOrder) {
      OrderType.canonical => 'Canonique',
      OrderType.chronological => 'Chronologique',
      OrderType.jewish => 'Hébreu',
      _ => 'Canonique',
    };

    return GestureDetector(
      onTap: () => _showOrderBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.seedGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.seedGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune, size: 14, color: AppTheme.seedGold),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.seedGold,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderBottomSheet() {
    final options = [
      (OrderType.canonical, 'Canonique', 'Genèse → Apocalypse', Icons.sort),
      (OrderType.chronological, 'Chronologique', 'Ordre historique des événements', Icons.history),
      (OrderType.jewish, 'Hébreu (Tanakh)', 'Ordre traditionnel du Tanakh', Icons.star_outline),
    ];

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentOrder = _workingPlan.options.order.type;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ordre de lecture',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 16),
                ...options.map((entry) {
                  final (type, label, desc, icon) = entry;
                  final isSelected = currentOrder == type;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _regeneratePlan(order: OrderOptions(type: type));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.seedGold.withValues(alpha: 0.08)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.seedGold
                              : Theme.of(context).colorScheme.outline,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(icon,
                              size: 20,
                              color: isSelected
                                  ? AppTheme.seedGold
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.onSurface
                                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                        )),
                                Text(desc,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: AppTheme.seedGold, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Affichage des livres verrouillés pour les plans thématiques
  Widget _buildThematicBooksDisplay() {
    final orderType = _workingPlan.options.order.type;
    final books = [..._workingPlan.options.content.selectedBooks]..sort((a, b) {
        final bookA = BibleData.getBook(a);
        final bookB = BibleData.getBook(b);
        if (bookA == null || bookB == null) return 0;
        return switch (orderType) {
          OrderType.chronological =>
            bookA.chronologicalOrder.compareTo(bookB.chronologicalOrder),
          OrderType.jewish => (bookA.jewishOrder ?? 999)
              .compareTo(bookB.jewishOrder ?? 999),
          _ => bookA.canonicalOrder.compareTo(bookB.canonicalOrder),
        };
      });

    // debugPrint('[ThematicDisplay] orderType=$orderType books=$books');

    return ListView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Livres inclus'),
            _buildOrderFilterButton(),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.seedGold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.seedGold.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline,
                  color: AppTheme.seedGold, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Les livres de ce plan sont fixes. Vous pouvez ajuster la durée et les jours de lecture.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...books.map((book) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Row(
                children: [
                   Icon(Icons.menu_book_outlined,
                      size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 10),
                  Text(
                    book,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDistributionTab() {
    if (_isFixedPlan) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Les options de distribution ne sont pas disponibles pour ce plan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final distribution = _workingPlan.options.distribution;

    return ListView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      children: [
        _buildSectionTitle('Options de contenu'),
        const SizedBox(height: 16),
        if (_showDailyPsalmProverb)
          _buildOptionCard(
            icon: Icons.auto_stories,
            title: 'Inclure les Psaumes',
            subtitle: 'Un chapitre par jour',
            value: distribution.dailyPsalm != DailyPsalmMode.none,
            onChanged: (value) {
              _regeneratePlan(
                distribution: DistributionOptions(
                  unit: distribution.unit,
                  otNtOverlap: distribution.otNtOverlap,
                  dailyPsalm: value ? DailyPsalmMode.one : DailyPsalmMode.none,
                  dailyProverb: distribution.dailyProverb,
                  reverse: distribution.reverse,
                  balance: distribution.balance,
                ),
              );
            },
          ),
        if (_showDailyPsalmProverb)
          _buildOptionCard(
            icon: Icons.lightbulb_outline,
            title: 'Inclure les Proverbes',
            subtitle: 'Lecture de sagesse quotidienne',
            value: distribution.dailyProverb != DailyProverbMode.none,
            onChanged: (value) {
              _regeneratePlan(
                distribution: DistributionOptions(
                  unit: distribution.unit,
                  otNtOverlap: distribution.otNtOverlap,
                  dailyPsalm: distribution.dailyPsalm,
                  dailyProverb:
                      value ? DailyProverbMode.one : DailyProverbMode.none,
                  reverse: distribution.reverse,
                  balance: distribution.balance,
                ),
              );
            },
          ),
        if (_showOtNtOverlap) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Alternance AT/NT'),
          const SizedBox(height: 16),
          _buildOptionCard(
            icon: Icons.swap_horiz,
            title: 'Alterner AT et NT',
            subtitle: 'Lectures parallèles des deux testaments',
            value: distribution.otNtOverlap == OtNtOverlapMode.alternate,
            onChanged: (value) {
              _regeneratePlan(
                distribution: DistributionOptions(
                  unit: distribution.unit,
                  otNtOverlap: value
                      ? OtNtOverlapMode.alternate
                      : OtNtOverlapMode.sequential,
                  dailyPsalm: distribution.dailyPsalm,
                  dailyProverb: distribution.dailyProverb,
                  reverse: distribution.reverse,
                  balance: distribution.balance,
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 24),
        _buildSectionTitle('Options avancées'),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.flip,
          title: 'Lecture inversée',
          subtitle: 'Lire les livres en ordre inverse',
          value: distribution.reverse,
          onChanged: (value) {
            _regeneratePlan(
              distribution: DistributionOptions(
                unit: distribution.unit,
                otNtOverlap: distribution.otNtOverlap,
                dailyPsalm: distribution.dailyPsalm,
                dailyProverb: distribution.dailyProverb,
                reverse: value,
                balance: distribution.balance,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDisplayTab() {
    final display = _workingPlan.options.display;

    return ListView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      children: [
        _buildSectionTitle('Options d\'affichage'),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.check_box_outlined,
          title: 'Cases à cocher',
          subtitle: 'Suivre votre progression de lecture',
          value: display.includeCheckbox,
          onChanged: (value) {
            _regeneratePlan(
              display: DisplayOptions(
                includeCheckbox: value,
                showStats: display.showStats,
                removeDates: display.removeDates,
                sectionColors: display.sectionColors,
                addReadingLinks: display.addReadingLinks,
                format: display.format,
              ),
            );
          },
        ),
        _buildOptionCard(
          icon: Icons.bar_chart,
          title: 'Statistiques',
          subtitle: 'Afficher les métriques du plan',
          value: display.showStats,
          onChanged: (value) {
            _regeneratePlan(
              display: DisplayOptions(
                includeCheckbox: display.includeCheckbox,
                showStats: value,
                removeDates: display.removeDates,
                sectionColors: display.sectionColors,
                addReadingLinks: display.addReadingLinks,
                format: display.format,
              ),
            );
          },
        ),
        _buildOptionCard(
          icon: Icons.palette_outlined,
          title: 'Couleurs par section',
          subtitle: 'Colorier selon les genres bibliques',
          value: display.sectionColors,
          onChanged: (value) {
            _regeneratePlan(
              display: DisplayOptions(
                includeCheckbox: display.includeCheckbox,
                showStats: display.showStats,
                removeDates: display.removeDates,
                sectionColors: value,
                addReadingLinks: display.addReadingLinks,
                format: display.format,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppTheme.seedGold.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? AppTheme.seedGold.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: value ? AppTheme.seedGold : Theme.of(context).colorScheme.tertiary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: AppTheme.seedGold,
        inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        inactiveTrackColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

// Delegate pour le TabBar sticky
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
