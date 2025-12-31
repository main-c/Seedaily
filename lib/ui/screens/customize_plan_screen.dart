import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../domain/bible_data.dart';
import '../../domain/models.dart';
import '../../providers/plans_provider.dart';
import '../../services/plan_generator.dart';

class CustomizePlanScreen extends StatefulWidget {
  const CustomizePlanScreen({
    super.key,
    required this.templateId,
  });

  final String templateId;

  @override
  State<CustomizePlanScreen> createState() => _CustomizePlanScreenState();
}

class _CustomizePlanScreenState extends State<CustomizePlanScreen> {
  late ReadingPlanTemplate _template;
  late TextEditingController _titleController;
  late TextEditingController _totalDaysController;

  // Options de base
  DateTime? _startDate;
  int _totalDays = 365;

  // Jours de lecture
  final Set<String> _readingDays = {
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun'
  };

  // Options de contenu
  ContentScope _contentScope = ContentScope.bibleComplete;

  // Options d'ordre
  OrderType _orderType = OrderType.canonical;
  bool _reverse = false;

  // Options de distribution
  DistributionUnit _distributionUnit = DistributionUnit.chapters;
  OtNtMode _otNtMode = OtNtMode.together;
  PsalmsStrategy _psalmsStrategy = PsalmsStrategy.spread;
  ProverbsStrategy _proverbsStrategy = ProverbsStrategy.none;

  // Options d'affichage
  OutputFormat _outputFormat = OutputFormat.calendar;
  bool _showCheckboxes = true;
  bool _showStatistics = true;
  bool _sectionColors = true;

  // État de la preview
  bool _isGenerating = false;
  Map<String, dynamic>? _previewStats;
  List<ReadingDay> _previewDays = [];

  final _dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

  @override
  void initState() {
    super.initState();
    final templates = context.read<PlansProvider>().templates;
    _template = templates.firstWhere((t) => t.id == widget.templateId);

    final year = DateTime.now().year;
    _titleController = TextEditingController(text: '${_template.title} $year');
    _totalDaysController = TextEditingController(text: _totalDays.toString());

    // Initialiser avec des valeurs par défaut
    _startDate = DateTime.now();
    _contentScope = _getDefaultContentScope();

    // Générer immédiatement la prévisualisation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generatePreview();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalDaysController.dispose();
    super.dispose();
  }

  ContentScope _getDefaultContentScope() {
    switch (widget.templateId) {
      case 'new-testament':
        return ContentScope.newTestament;
      case 'old-testament':
        return ContentScope.oldTestament;
      case 'bible-complete':
        return ContentScope.bibleComplete;
      default:
        return ContentScope.bibleComplete;
    }
  }

  bool get _isFixedPlan {
    return [
      'mcheyne',
      'bible-year-ligue',
      'revolutionary',
      'horner',
      'genesis-to-revelation',
    ].contains(widget.templateId);
  }

  bool get _canCustomizeContent {
    return !_isFixedPlan;
  }

  bool get _canCustomizeOrder {
    return !_isFixedPlan;
  }

  bool get _canCustomizeDuration {
    return !_isFixedPlan;
  }

  bool get _canCustomizeDistribution {
    return !_isFixedPlan;
  }

  bool get _showPsalmsStrategy {
    return !_isFixedPlan &&
        (_contentScope == ContentScope.bibleComplete ||
            _contentScope == ContentScope.oldTestament);
  }

  bool get _showProverbsStrategy {
    return !_isFixedPlan &&
        (_contentScope == ContentScope.bibleComplete ||
            _contentScope == ContentScope.oldTestament);
  }

  bool get _showOtNtMode {
    return !_isFixedPlan && _contentScope == ContentScope.bibleComplete;
  }

  Future<void> _generatePreview() async {
    if (_startDate == null) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Calculer les statistiques
      final bookCount = _getBookCount(_contentScope);
      final totalChapters = _getTotalChapters(_contentScope);
      final readingDaysCount = _calculateReadingDaysCount(
        _totalDays,
        _readingDays,
        _startDate,
      );
      final avgChaptersPerDay = readingDaysCount > 0
          ? totalChapters / readingDaysCount
          : 0.0;
      final endDate = _calculateEndDate(_startDate, _totalDays, _readingDays);

      // Générer les premiers jours RÉELS
      final previewDays = await _generatePreviewDays(7);

      if (mounted) {
        setState(() {
          _previewStats = {
            'bookCount': bookCount,
            'totalChapters': totalChapters,
            'readingDaysCount': readingDaysCount,
            'avgChaptersPerDay': avgChaptersPerDay.toStringAsFixed(1),
            'endDate': endDate,
          };
          _previewDays = previewDays;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<List<ReadingDay>> _generatePreviewDays(int count) async {
    final options = GeneratorOptions(
      content: ContentOptions(scope: _contentScope),
      order: OrderOptions(type: _reverse ? OrderType.reverse : _orderType),
      schedule: ScheduleOptions(
        startDate: _startDate!,
        totalDays: _totalDays,
        readingDays: _readingDays.toList(),
      ),
      distribution: DistributionOptions(
        unit: _distributionUnit,
        otNtMode: _otNtMode,
        psalmsStrategy: _psalmsStrategy,
        proverbsStrategy: _proverbsStrategy,
      ),
      output: OutputOptions(
        format: _outputFormat,
        showCheckboxes: _showCheckboxes,
        showStatistics: _showStatistics,
        colorTheme: _sectionColors ? 'sections' : 'default',
      ),
    );

    final generator = PlanGenerator();
    final fullPlan = generator.generate(
      templateId: widget.templateId,
      title: _titleController.text,
      options: options,
    );

    return fullPlan.days.take(count).toList();
  }

  int _getBookCount(ContentScope scope) {
    switch (scope) {
      case ContentScope.bibleComplete:
        return 66;
      case ContentScope.oldTestament:
        return 39;
      case ContentScope.newTestament:
        return 27;
      default:
        return 0;
    }
  }

  int _getTotalChapters(ContentScope scope) {
    final books = _getBooksForScope(scope);
    return books.fold(0, (sum, book) => sum + book.chapters);
  }

  List<BibleBook> _getBooksForScope(ContentScope scope) {
    switch (scope) {
      case ContentScope.bibleComplete:
        return BibleData.books;
      case ContentScope.oldTestament:
        return BibleData.getOldTestamentBooks();
      case ContentScope.newTestament:
        return BibleData.getNewTestamentBooks();
      default:
        return [];
    }
  }

  int _calculateReadingDaysCount(
      int totalDays, Set<String> readingDays, DateTime? startDate) {
    if (startDate == null) return 0;
    if (readingDays.isEmpty || readingDays.length == 7) {
      return totalDays;
    }

    int count = 0;
    DateTime current = startDate;
    for (int i = 0; i < totalDays; i++) {
      if (_isReadingDay(current, readingDays.toList())) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  DateTime _calculateEndDate(
      DateTime? startDate, int totalDays, Set<String> readingDays) {
    if (startDate == null) return DateTime.now();
    return startDate.add(Duration(days: totalDays - 1));
  }

  bool _isReadingDay(DateTime date, List<String> readingDays) {
    if (readingDays.isEmpty || readingDays.length == 7) {
      return true;
    }

    final dayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final weekday = date.weekday - 1;
    final dayName = dayNames[weekday];

    return readingDays.contains(dayName);
  }

  Future<void> _createPlan() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de début'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final effectiveOrderType = _reverse ? OrderType.reverse : _orderType;

    final options = GeneratorOptions(
      content: ContentOptions(scope: _contentScope),
      order: OrderOptions(type: effectiveOrderType),
      schedule: ScheduleOptions(
        startDate: _startDate!,
        totalDays: _totalDays,
        readingDays: _readingDays.toList(),
      ),
      distribution: DistributionOptions(
        unit: _distributionUnit,
        otNtMode: _otNtMode,
        psalmsStrategy: _psalmsStrategy,
        proverbsStrategy: _proverbsStrategy,
      ),
      output: OutputOptions(
        format: _outputFormat,
        showCheckboxes: _showCheckboxes,
        showStatistics: _showStatistics,
        colorTheme: _sectionColors ? 'sections' : 'default',
      ),
    );

    try {
      await context.read<PlansProvider>().createPlan(
            templateId: widget.templateId,
            title: _titleController.text,
            options: options,
          );
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création du plan: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildOptionsSheet(scrollController);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Aperçu du plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showOptionsSheet,
            tooltip: 'Personnaliser',
          ),
        ],
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTemplateHeader(),
                  const SizedBox(height: 32),
                  _buildTimelineSection(),
                  const SizedBox(height: 32),
                  _buildPreviewDaysSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPlan,
        icon: const Icon(Icons.check),
        label: const Text('Créer le plan'),
      ),
    );
  }

  Widget _buildTemplateHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _titleController.text,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _template.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
      ],
    );
  }


  Widget _buildTimelineSection() {
    if (_previewStats == null || _startDate == null) {
      return const SizedBox.shrink();
    }

    final endDate = _previewStats!['endDate'] as DateTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chronologie'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.seedGold.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Début',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy', 'fr_FR').format(_startDate!),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward, color: AppTheme.seedGold),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Fin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy', 'fr_FR').format(endDate),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewDaysSection() {
    if (_previewDays.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Aperçu (format: ${_getFormatLabel()})'),
        const SizedBox(height: 16),
        // Afficher selon le format choisi
        _buildPreviewByFormat(),
      ],
    );
  }

  String _getFormatLabel() {
    switch (_outputFormat) {
      case OutputFormat.calendar:
        return 'Calendrier';
      case OutputFormat.list:
        return 'Liste';
      case OutputFormat.weekly:
        return 'Semaines';
      case OutputFormat.byBook:
        return 'Par livre';
      default:
        return 'Calendrier';
    }
  }

  Widget _buildPreviewByFormat() {
    switch (_outputFormat) {
      case OutputFormat.calendar:
        return _buildCalendarPreview();
      case OutputFormat.list:
        return _buildListPreview();
      case OutputFormat.weekly:
        return _buildWeeklyPreview();
      case OutputFormat.byBook:
        return _buildByBookPreview();
      default:
        return _buildCalendarPreview();
    }
  }

  Widget _buildCalendarPreview() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: min(7, _previewDays.length),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final day = _previewDays[index];
        return _buildCalendarDayCard(day);
      },
    );
  }

  Widget _buildCalendarDayCard(ReadingDay day) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_showCheckboxes) ...[
                  Checkbox(
                    value: false,
                    onChanged: null,
                    fillColor: WidgetStateProperty.all(Colors.grey[300]),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(day.date),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...day.passages.map((passage) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (_showCheckboxes) const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        _formatPassage(passage),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildListPreview() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: min(7, _previewDays.length),
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final day = _previewDays[index];
        return ListTile(
          leading: _showCheckboxes
              ? Checkbox(
                  value: false,
                  onChanged: null,
                  fillColor: WidgetStateProperty.all(Colors.grey[300]),
                )
              : null,
          title: Text(
            DateFormat('d MMMM yyyy', 'fr_FR').format(day.date),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: day.passages
                .map((p) => Text(_formatPassage(p)))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyPreview() {
    // Regrouper par semaine
    final weekGroups = <int, List<ReadingDay>>{};
    for (var day in _previewDays.take(7)) {
      final weekNumber = ((day.date.difference(_startDate!).inDays) / 7).floor();
      weekGroups[weekNumber] = [...(weekGroups[weekNumber] ?? []), day];
    }

    return Column(
      children: weekGroups.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semaine ${entry.key + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.seedGold,
                      ),
                ),
                const SizedBox(height: 12),
                ...entry.value.map((day) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE d MMM', 'fr_FR').format(day.date),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        ...day.passages.map((p) => Text('  ${_formatPassage(p)}')),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildByBookPreview() {
    // Regrouper par livre
    final bookGroups = <String, List<String>>{};
    for (var day in _previewDays.take(7)) {
      for (var passage in day.passages) {
        final book = passage.book;
        final passageText = _formatPassage(passage);
        bookGroups[book] = [...(bookGroups[book] ?? []), passageText];
      }
    }

    return Column(
      children: bookGroups.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.seedGold,
                      ),
                ),
                const SizedBox(height: 8),
                ...entry.value.map((passage) => Text('  $passage')),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatPassage(Passage passage) {
    return passage.reference;
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  // Modal des options
  Widget _buildOptionsSheet(ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Options du plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),

          // Options content (scrollable)
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Message pour les plans fixes
                if (_isFixedPlan) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.seedGold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.seedGold,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ce plan suit une structure prédéfinie. Les options de personnalisation sont limitées.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.deepNavy,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Titre du plan
                _buildSectionTitle('Titre du plan'),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Mon plan de lecture',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Date de début
                _buildSectionTitle('Date de début'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 730)),
                      locale: const Locale('fr', 'FR'),
                    );

                    if (selected != null) {
                      setState(() {
                        _startDate = selected;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.mistGreyBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _startDate != null
                              ? DateFormat('dd MMMM yyyy', 'fr_FR')
                                  .format(_startDate!)
                              : 'Sélectionner une date',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: _startDate != null
                                    ? AppTheme.deepNavy
                                    : AppTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Jours de lecture
                _buildSectionTitle('Jours de lecture de la semaine'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    {'key': 'mon', 'label': 'Lun'},
                    {'key': 'tue', 'label': 'Mar'},
                    {'key': 'wed', 'label': 'Mer'},
                    {'key': 'thu', 'label': 'Jeu'},
                    {'key': 'fri', 'label': 'Ven'},
                    {'key': 'sat', 'label': 'Sam'},
                    {'key': 'sun', 'label': 'Dim'},
                  ].map((day) {
                    final isSelected = _readingDays.contains(day['key']);
                    return FilterChip(
                      label: Text(day['label']!),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _readingDays.add(day['key']!);
                          } else {
                            _readingDays.remove(day['key']!);
                          }
                        });
                      },
                      selectedColor:
                          AppTheme.seedGold.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.seedGold,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Durée totale (plans personnalisables uniquement)
                if (_canCustomizeDuration) ...[
                  _buildSectionTitle('Durée totale (en jours)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _totalDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '365',
                      border: OutlineInputBorder(),
                      suffixText: 'jours',
                    ),
                    onChanged: (value) {
                      final days = int.tryParse(value);
                      if (days != null && days >= 1 && days <= 730) {
                        setState(() {
                          _totalDays = days;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Minimum 1 jour, maximum 730 jours (2 ans)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Format d'affichage
                _buildSectionTitle('Format d\'affichage'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    {
                      'value': OutputFormat.calendar,
                      'label': 'Calendrier',
                      'icon': Icons.calendar_month
                    },
                    {'value': OutputFormat.list, 'label': 'Liste', 'icon': Icons.list},
                    {
                      'value': OutputFormat.weekly,
                      'label': 'Semaines',
                      'icon': Icons.view_week
                    },
                    {
                      'value': OutputFormat.byBook,
                      'label': 'Par livre',
                      'icon': Icons.menu_book
                    },
                  ].map((format) {
                    final isSelected = _outputFormat == format['value'];
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            format['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? AppTheme.seedGold
                                : AppTheme.mistGreyBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(format['label'] as String),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _outputFormat = format['value'] as OutputFormat;
                          });
                        }
                      },
                      selectedColor:
                          AppTheme.seedGold.withValues(alpha: 0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Options d'affichage
                _buildSectionTitle('Options d\'affichage'),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Cases à cocher'),
                  subtitle: const Text(
                      'Afficher des cases pour suivre votre progression'),
                  value: _showCheckboxes,
                  onChanged: (value) {
                    setState(() {
                      _showCheckboxes = value;
                    });
                  },
                  activeColor: AppTheme.seedGold,
                  activeTrackColor:
                      AppTheme.seedGold.withValues(alpha: 0.5),
                ),
                SwitchListTile(
                  title: const Text('Statistiques'),
                  subtitle:
                      const Text('Afficher le nombre de versets par jour'),
                  value: _showStatistics,
                  onChanged: (value) {
                    setState(() {
                      _showStatistics = value;
                    });
                  },
                  activeColor: AppTheme.seedGold,
                  activeTrackColor:
                      AppTheme.seedGold.withValues(alpha: 0.5),
                ),
                SwitchListTile(
                  title: const Text('Couleurs par section'),
                  subtitle:
                      const Text('Colorier selon les genres bibliques'),
                  value: _sectionColors,
                  onChanged: (value) {
                    setState(() {
                      _sectionColors = value;
                    });
                  },
                  activeColor: AppTheme.seedGold,
                  activeTrackColor:
                      AppTheme.seedGold.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),

                // Contenu biblique (plans personnalisables uniquement)
                if (_canCustomizeContent) ...[
                  _buildSectionTitle('Contenu biblique'),
                  const SizedBox(height: 12),
                  _buildRadioOption(
                    ContentScope.bibleComplete,
                    _contentScope,
                    'Bible complète',
                    'Ancien et Nouveau Testament (66 livres)',
                    (value) => setState(() => _contentScope = value),
                  ),
                  const SizedBox(height: 8),
                  _buildRadioOption(
                    ContentScope.newTestament,
                    _contentScope,
                    'Nouveau Testament',
                    '27 livres (Matthieu à Apocalypse)',
                    (value) => setState(() => _contentScope = value),
                  ),
                  const SizedBox(height: 8),
                  _buildRadioOption(
                    ContentScope.oldTestament,
                    _contentScope,
                    'Ancien Testament',
                    '39 livres (Genèse à Malachie)',
                    (value) => setState(() => _contentScope = value),
                  ),
                  const SizedBox(height: 24),
                ],

                // Distribution et ordre (plans personnalisables uniquement)
                if (_canCustomizeOrder) ...[
                  _buildSectionTitle('Distribution de la lecture'),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      ListTile(
                        title: const Text('Unité de distribution'),
                        subtitle: Text(_getDistributionUnitLabel(_distributionUnit)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showDistributionUnitDialog,
                      ),
                      if (_showOtNtMode) ...[
                        const Divider(),
                        ListTile(
                          title: const Text('Mode AT/NT'),
                          subtitle: Text(_getOtNtModeLabel(_otNtMode)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showOtNtModeDialog,
                        ),
                      ],
                      if (_showPsalmsStrategy) ...[
                        const Divider(),
                        ListTile(
                          title: const Text('Stratégie Psaumes'),
                          subtitle:
                              Text(_getPsalmsStrategyLabel(_psalmsStrategy)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showPsalmsStrategyDialog,
                        ),
                      ],
                      if (_showProverbsStrategy) ...[
                        const Divider(),
                        ListTile(
                          title: const Text('Stratégie Proverbes'),
                          subtitle: Text(
                              _getProverbsStrategyLabel(_proverbsStrategy)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showProverbsStrategyDialog,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Ordre de lecture'),
                  const SizedBox(height: 12),
                  _buildRadioOption(
                    OrderType.canonical,
                    _orderType,
                    'Ordre canonique',
                    'Ordre traditionnel des livres bibliques',
                    (value) => setState(() => _orderType = value),
                  ),
                  const SizedBox(height: 8),
                  _buildRadioOption(
                    OrderType.chronological,
                    _orderType,
                    'Ordre chronologique',
                    'Ordre historique des événements',
                    (value) => setState(() => _orderType = value),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Inverser l\'ordre'),
                    subtitle: const Text(
                        'Lire de l\'Apocalypse vers la Genèse'),
                    value: _reverse,
                    onChanged: (value) {
                      setState(() {
                        _reverse = value;
                      });
                    },
                    activeColor: AppTheme.seedGold,
                    activeTrackColor:
                        AppTheme.seedGold.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 80), // Espace pour le bouton
              ],
            ),
          ),

          // Bouton de validation
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Mettre à jour l\'aperçu'),
                onPressed: () {
                  Navigator.pop(context);
                  _generatePreview();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption<T>(
    T value,
    T groupValue,
    String title,
    String subtitle,
    ValueChanged<T> onChanged,
  ) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.seedGold : AppTheme.mistGreyBlue,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppTheme.seedGold.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.seedGold : AppTheme.mistGreyBlue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogs pour les sélecteurs
  Future<void> _showDistributionUnitDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unité de distribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<DistributionUnit>(
              title: const Text('Chapitres'),
              subtitle: const Text('Distribuer par nombre de chapitres'),
              value: DistributionUnit.chapters,
              groupValue: _distributionUnit,
              onChanged: (value) {
                setState(() => _distributionUnit = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<DistributionUnit>(
              title: const Text('Versets'),
              subtitle: const Text('Distribuer par nombre de versets'),
              value: DistributionUnit.verses,
              groupValue: _distributionUnit,
              onChanged: (value) {
                setState(() => _distributionUnit = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<DistributionUnit>(
              title: const Text('Péricopes'),
              subtitle: const Text('Distribuer par sections logiques'),
              value: DistributionUnit.pericopes,
              groupValue: _distributionUnit,
              onChanged: (value) {
                setState(() => _distributionUnit = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOtNtModeDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mode AT/NT'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<OtNtMode>(
              title: const Text('Ensemble'),
              subtitle: const Text('Alterner AT et NT chaque jour'),
              value: OtNtMode.together,
              groupValue: _otNtMode,
              onChanged: (value) {
                setState(() => _otNtMode = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<OtNtMode>(
              title: const Text('Séparé'),
              subtitle: const Text('Lire tout l\'AT puis tout le NT'),
              value: OtNtMode.separate,
              groupValue: _otNtMode,
              onChanged: (value) {
                setState(() => _otNtMode = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPsalmsStrategyDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stratégie Psaumes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<PsalmsStrategy>(
              title: const Text('Un par jour'),
              subtitle: const Text('Lire un psaume chaque jour'),
              value: PsalmsStrategy.daily,
              groupValue: _psalmsStrategy,
              onChanged: (value) {
                setState(() => _psalmsStrategy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<PsalmsStrategy>(
              title: const Text('Répartis'),
              subtitle: const Text('Répartir les psaumes sur la période'),
              value: PsalmsStrategy.spread,
              groupValue: _psalmsStrategy,
              onChanged: (value) {
                setState(() => _psalmsStrategy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<PsalmsStrategy>(
              title: const Text('Aucune'),
              subtitle: const Text('Ne pas traiter les psaumes spécialement'),
              value: PsalmsStrategy.none,
              groupValue: _psalmsStrategy,
              onChanged: (value) {
                setState(() => _psalmsStrategy = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProverbsStrategyDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stratégie Proverbes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ProverbsStrategy>(
              title: const Text('Un par jour'),
              subtitle: const Text('Lire un proverbe chaque jour'),
              value: ProverbsStrategy.daily,
              groupValue: _proverbsStrategy,
              onChanged: (value) {
                setState(() => _proverbsStrategy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ProverbsStrategy>(
              title: const Text('Un par mois'),
              subtitle: const Text('Lire le proverbe du jour du mois'),
              value: ProverbsStrategy.monthly,
              groupValue: _proverbsStrategy,
              onChanged: (value) {
                setState(() => _proverbsStrategy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ProverbsStrategy>(
              title: const Text('Aucune'),
              subtitle: const Text('Ne pas traiter les proverbes spécialement'),
              value: ProverbsStrategy.none,
              groupValue: _proverbsStrategy,
              onChanged: (value) {
                setState(() => _proverbsStrategy = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getDistributionUnitLabel(DistributionUnit unit) {
    switch (unit) {
      case DistributionUnit.chapters:
        return 'Par chapitres';
      case DistributionUnit.verses:
        return 'Par versets';
      case DistributionUnit.pericopes:
        return 'Par péricopes';
    }
  }

  String _getOtNtModeLabel(OtNtMode mode) {
    switch (mode) {
      case OtNtMode.together:
        return 'Ensemble (alternance quotidienne)';
      case OtNtMode.separate:
        return 'Séparé (AT puis NT)';
    }
  }

  String _getPsalmsStrategyLabel(PsalmsStrategy strategy) {
    switch (strategy) {
      case PsalmsStrategy.daily:
        return 'Un psaume par jour';
      case PsalmsStrategy.spread:
        return 'Répartis sur la période';
      case PsalmsStrategy.none:
        return 'Aucune stratégie particulière';
    }
  }

  String _getProverbsStrategyLabel(ProverbsStrategy strategy) {
    switch (strategy) {
      case ProverbsStrategy.daily:
        return 'Un proverbe par jour';
      case ProverbsStrategy.monthly:
        return 'Un proverbe par mois (selon le jour)';
      case ProverbsStrategy.none:
        return 'Aucune stratégie particulière';
    }
  }
}
