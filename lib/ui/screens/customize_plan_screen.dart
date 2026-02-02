import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/bible_data.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
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
    _tabController = TabController(length: 3, vsync: this);

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

    _titleController = TextEditingController(text: _workingPlan.title);
  }

  /// Génère un plan avec les options par défaut pour un template
  GeneratedPlan _generateDefaultPlan(String templateId) {
    final year = DateTime.now().year;
    final defaultOptions = _getDefaultOptions(templateId);

    return _generator.generate(
      templateId: templateId,
      title: '${_template.title} $year',
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
      case 'jewish-plan':
        return BibleData.books
            .where((b) => b.isOldTestament)
            .map((b) => b.name)
            .toList();
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
      case 'jewish-plan':
        return OrderType.jewish;
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
      'genesis-to-revelation',
    ].contains(_workingPlan.templateId);
  }

  bool get _isCustomizablePlan {
    return [
      'canonical-plan',
      'chronological-plan',
      'jewish-plan',
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

  bool get _showOtNtOverlap => !_isFixedPlan && _hasOldTestament && _hasNewTestament;

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
  }

  // ============================================================================
  // SAUVEGARDE
  // ============================================================================

  Future<void> _savePlan() async {
    if (_workingPlan.options.schedule.startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de début'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

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
        await provider.createPlan(
          templateId: _workingPlan.templateId,
          title: planToSave.title,
          options: _workingPlan.options,
        );
        if (mounted) {
          context.go('/?tab=0');
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
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isEditMode ? 'Modifier le plan' : 'Personnaliser le plan'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec aperçu du plan
                  Container(
                    color: AppTheme.backgroundLight,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'APERÇU DU PLAN',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
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
                  labelColor: AppTheme.textPrimary,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorColor: AppTheme.seedGold,
                  indicatorWeight: 3,
                  tabs: const [
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
          children: [
            _buildBooksTab(),
            _buildDistributionTab(),
            _buildDisplayTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
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
                foregroundColor: AppTheme.deepNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.isEditMode ? 'Enregistrer les modifications' : 'Créer le plan',
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
            AppTheme.deepNavy.withValues(alpha: 0.15),
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
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du template
          _template.image.isNotEmpty
              ? Image.network(
                  _template.image,
                  width: double.infinity,
                  height: 180,
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

          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _template.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.seedGold,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _template.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
                if (_template.porte.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _template.porte,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
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
            color: AppTheme.textPrimary,
          ),
    );
  }

  Widget _buildDateSection() {
    final startDate = _workingPlan.options.schedule.startDate;

    return Container(
      color: AppTheme.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Date de début'),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final selected = await showDatePicker(
                context: context,
                initialDate: startDate,
                firstDate: now,
                lastDate: now.add(const Duration(days: 730)),
                locale: const Locale('fr', 'FR'),
              );

              if (selected != null && mounted) {
                _regeneratePlan(
                  schedule: ScheduleOptions(
                    startDate: selected,
                    totalDays: _workingPlan.options.schedule.totalDays,
                    readingDays: _workingPlan.options.schedule.readingDays,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.borderSubtle),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _dateFormat.format(startDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const Icon(Icons.calendar_today,
                      size: 20, color: AppTheme.mistGreyBlue),
                ],
              ),
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
      color: AppTheme.backgroundLight,
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
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.seedGold : AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? null
                        : Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day['fullLabel']!,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.deepNavy
                              : AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        day['label']!,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.deepNavy
                              : AppTheme.textMuted,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
      color: AppTheme.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Format d\'affichage'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.deepNavy.withValues(alpha: 0.1),
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
                color: isSelected ? AppTheme.deepNavy : AppTheme.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.deepNavy : AppTheme.textMuted,
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
    if (!_isCustomizablePlan) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'La sélection des livres n\'est pas disponible pour ce plan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      children: [
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

  Widget _buildDistributionTab() {
    if (_isFixedPlan) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Les options de distribution ne sont pas disponibles pour ce plan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
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
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppTheme.seedGold.withValues(alpha: 0.3)
              : AppTheme.borderSubtle,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? AppTheme.seedGold.withValues(alpha: 0.1)
                : AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: value ? AppTheme.seedGold : AppTheme.mistGreyBlue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: AppTheme.seedGold,
        inactiveThumbColor: AppTheme.textMuted,
        inactiveTrackColor: AppTheme.surface,
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
      color: AppTheme.backgroundLight,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
