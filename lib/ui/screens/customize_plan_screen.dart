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
import '../widgets/reading_day_card.dart';
import '../widgets/reading_stats_bar.dart';
import '../widgets/month_calendar_widget.dart';
import '../widgets/list_view_widget.dart';
import '../widgets/weekly_view_widget.dart';
import '../widgets/by_book_view_widget.dart';

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

  // Options de contenu (NOUVELLE STRUCTURE MVP)
  Set<String> _selectedBooks = {};
  bool _includeApocrypha = false;

  // Options d'ordre
  OrderType _orderType = OrderType.canonical;

  // Options de distribution (NOUVELLE STRUCTURE MVP)
  OtNtOverlapMode _otNtOverlap = OtNtOverlapMode.sequential;
  DailyPsalmMode _dailyPsalm = DailyPsalmMode.none;
  DailyProverbMode _dailyProverb = DailyProverbMode.none;
  bool _reverse = false;
  BalanceType _balance = BalanceType.even;

  // Options d'affichage (NOUVELLE STRUCTURE MVP)
  OutputFormat _outputFormat = OutputFormat.calendar;
  bool _showCheckboxes = true;
  bool _showStatistics = true;
  bool _removeDates = false;
  bool _sectionColors = false;
  bool _addReadingLinks = false;

  // État de la preview
  bool _isGenerating = false;
  Map<String, dynamic>? _previewStats;
  List<ReadingDay> _previewDays = [];
  int _selectedDayIndex = 0; // Jour actuellement affiché dans "Lecture du jour"

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
    _initializeSelectedBooks();
    _initializeOrderType();

    // Générer immédiatement la prévisualisation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generatePreview();
    });
  }

  void _initializeSelectedBooks() {
    // Initialiser la sélection selon le template
    switch (widget.templateId) {
      case 'canonical-plan':
      case 'chronological-plan':
      case 'bible-complete':
        // Par défaut : tous les livres (66)
        _selectedBooks = Set.from(BibleData.books.map((b) => b.name));
        break;
      case 'jewish-plan':
        // Par défaut : tous les livres AT (39) pour le plan juif
        _selectedBooks = Set.from(
          BibleData.books.where((b) => b.isOldTestament).map((b) => b.name),
        );
        break;
      case 'new-testament':
        _selectedBooks =
            Set.from(BibleData.getNewTestamentBooks().map((b) => b.name));
        break;
      case 'old-testament':
        _selectedBooks =
            Set.from(BibleData.getOldTestamentBooks().map((b) => b.name));
        break;
      default:
        // Plans fixes : tous les livres
        _selectedBooks = Set.from(BibleData.books.map((b) => b.name));
    }
  }

  void _initializeOrderType() {
    // Initialiser l'ordre selon le template
    switch (widget.templateId) {
      case 'canonical-plan':
      case 'bible-complete':
        _orderType = OrderType.canonical;
        break;
      case 'chronological-plan':
        _orderType = OrderType.chronological;
        break;
      case 'jewish-plan':
        _orderType = OrderType.jewish;
        break;
      default:
        _orderType = OrderType.canonical;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalDaysController.dispose();
    super.dispose();
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

  bool get _isNewTemplatePlan {
    return [
      'canonical-plan',
      'chronological-plan',
      'jewish-plan',
    ].contains(widget.templateId);
  }

  bool get _canCustomizeContent {
    return !_isFixedPlan;
  }

  bool get _canCustomizeOrder {
    return !_isFixedPlan && !_isNewTemplatePlan;
  }

  bool get _canCustomizeDuration {
    return !_isFixedPlan;
  }

  bool get _canCustomizeDistribution {
    return !_isFixedPlan;
  }

  bool get _hasOldTestament {
    return _selectedBooks.any((bookName) {
      final book = BibleData.getBook(bookName);
      return book?.isOldTestament ?? false;
    });
  }

  bool get _hasNewTestament {
    return _selectedBooks.any((bookName) {
      final book = BibleData.getBook(bookName);
      return book?.isNewTestament ?? false;
    });
  }

  bool get _showDailyPsalmProverb {
    return !_isFixedPlan && _hasOldTestament;
  }

  bool get _showOtNtOverlap {
    return !_isFixedPlan && _hasOldTestament && _hasNewTestament;
  }

  Future<void> _generatePreview() async {
    if (_startDate == null) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Calculer les statistiques
      final bookCount = _selectedBooks.length;
      final totalChapters = _getTotalChapters();
      final readingDaysCount = _calculateReadingDaysCount(
        _totalDays,
        _readingDays,
        _startDate,
      );
      final avgChaptersPerDay =
          readingDaysCount > 0 ? totalChapters / readingDaysCount : 0.0;
      final endDate = _calculateEndDate(_startDate, _totalDays, _readingDays);

      // Générer les premiers jours RÉELS pour l'aperçu (90 jours = 3 mois)
      final previewDays = await _generatePreviewDays(90);

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
          _selectedDayIndex = 0; // Reset to first day on regeneration
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
      content: ContentOptions(
        scope: ContentScope.custom,
        selectedBooks: _selectedBooks.toList(),
        includeApocrypha: _includeApocrypha,
      ),
      order: OrderOptions(type: _orderType),
      schedule: ScheduleOptions(
        startDate: _startDate!,
        totalDays: _totalDays,
        readingDays: _readingDays.toList(),
      ),
      distribution: DistributionOptions(
        unit: DistributionUnit.chapters,
        otNtOverlap: _otNtOverlap,
        dailyPsalm: _dailyPsalm,
        dailyProverb: _dailyProverb,
        reverse: _reverse,
        balance: _balance,
      ),
      display: DisplayOptions(
        includeCheckbox: _showCheckboxes,
        showStats: _showStatistics,
        removeDates: _removeDates,
        sectionColors: _sectionColors,
        addReadingLinks: _addReadingLinks,
        format: _outputFormat,
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

  int _getTotalChapters() {
    int total = 0;
    for (final bookName in _selectedBooks) {
      final book = BibleData.getBook(bookName);
      if (book != null) {
        total += book.chapters;
      }
    }
    return total;
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

    if (_selectedBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un livre biblique'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final options = GeneratorOptions(
      content: ContentOptions(
        scope: ContentScope.custom,
        selectedBooks: _selectedBooks.toList(),
        includeApocrypha: _includeApocrypha,
      ),
      order: OrderOptions(type: _orderType),
      schedule: ScheduleOptions(
        startDate: _startDate!,
        totalDays: _totalDays,
        readingDays: _readingDays.toList(),
      ),
      distribution: DistributionOptions(
        unit: DistributionUnit.chapters,
        otNtOverlap: _otNtOverlap,
        dailyPsalm: _dailyPsalm,
        dailyProverb: _dailyProverb,
        reverse: _reverse,
        balance: _balance,
      ),
      display: DisplayOptions(
        includeCheckbox: _showCheckboxes,
        showStats: _showStatistics,
        removeDates: _removeDates,
        sectionColors: _sectionColors,
        addReadingLinks: _addReadingLinks,
        format: _outputFormat,
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
        title: Text(_titleController.text),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showOptionsSheet,
            tooltip: 'Options',
          ),
        ],
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats bar
                  if (_previewStats != null) ...[
                    ReadingStatsBar(
                      totalDays: _previewStats!['readingDaysCount'] as int,
                      bookCount: _previewStats!['bookCount'] as int,
                      totalChapters: _previewStats!['totalChapters'] as int,
                      avgChaptersPerDay: double.tryParse(
                        _previewStats!['avgChaptersPerDay'] as String,
                      ),
                      showProgress: false, // Preview mode - no progress
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ═══════════════════════════════════════════════════
                  // SECTION 1 : LECTURE DU JOUR
                  // ═══════════════════════════════════════════════════
                  if (_previewDays.isNotEmpty) ...[
                    _buildSectionTitle('Lecture du jour'),
                    const SizedBox(height: 12),
                    ReadingDayCard(
                      day: _previewDays[_selectedDayIndex],
                      isPreviewMode: true, // Preview mode - checkboxes disabled
                      showCheckbox: _showCheckboxes,
                      showDayCheckbox: true, // Checkbox per day by default
                    ),
                    const SizedBox(height: 32),
                  ],

                  // ═══════════════════════════════════════════════════
                  // SECTION 2 : VUE GLOBALE (CALENDRIER)
                  // ═══════════════════════════════════════════════════
                  if (_previewDays.isNotEmpty) ...[
                    _buildSectionTitle('Vue globale'),
                    const SizedBox(height: 12),
                    MonthCalendarWidget(
                      days: _previewDays,
                      currentDayIndex: 0, // Toujours le jour 1 en preview
                      selectedDayIndex:
                          _selectedDayIndex, // Le jour sélectionné par l'utilisateur
                      selectedReadingDays: _readingDays,
                      isPreviewMode: true, // Mode aperçu avec badge
                      onDayTap: (index) {
                        setState(() {
                          _selectedDayIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.deepNavy,
          ),
    );
  }

  // Modal des options
  Widget _buildOptionsSheet(ScrollController scrollController) {
    return StatefulBuilder(
      builder: (context, setModalState) {
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

                // ═══════════════════════════════════════════════════
                // SECTION 1 : INFORMATIONS GÉNÉRALES
                // ═══════════════════════════════════════════════════
                _buildSectionTitle('Informations générales'),
                const SizedBox(height: 16),

                // Titre du plan
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre du plan',
                    hintText: 'Mon plan de lecture',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // ═══════════════════════════════════════════════════
                // SECTION 2 : CALENDRIER ET PLANIFICATION
                // ═══════════════════════════════════════════════════
                _buildSectionTitle('Calendrier et planification'),
                const SizedBox(height: 16),

                // Date de début
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

                    if (selected != null && mounted) {
                      setState(() {
                        _startDate = selected;
                      });
                      setModalState(() {
                        // Mise à jour du modal pour afficher la nouvelle date
                      });
                      _generatePreview();
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date de début',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppTheme.textMuted,
                                    ),
                              ),
                              const SizedBox(height: 4),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Jours de lecture
                Text(
                  'Jours de lecture',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 8),
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
                        setModalState(() {});
                      },
                      selectedColor: AppTheme.seedGold.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.seedGold,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Durée totale (plans personnalisables uniquement)
                if (_canCustomizeDuration) ...[
                  TextField(
                    controller: _totalDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Durée totale',
                      hintText: '365',
                      border: OutlineInputBorder(),
                      suffixText: 'jours',
                      helperText: 'Entre 1 et 730 jours (2 ans)',
                    ),
                    onChanged: (value) {
                      final days = int.tryParse(value);
                      if (days != null && days >= 1 && days <= 730) {
                        setState(() {
                          _totalDays = days;
                        });
                        setModalState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),

                // ═══════════════════════════════════════════════════
                // SECTION 3 : SÉLECTION DES LIVRES
                // ═══════════════════════════════════════════════════
                if (_isNewTemplatePlan) ...[
                  _buildSectionTitle('Sélection des livres'),
                  const SizedBox(height: 16),
                  BookSelectorSection(
                    templateId: widget.templateId,
                    selectedBooks: _selectedBooks,
                    includeApocrypha: _includeApocrypha,
                    onBooksChanged: (newSelection) {
                      setState(() {
                        _selectedBooks = newSelection;
                        _generatePreview();
                      });
                      setModalState(() {});
                    },
                    onApocryphaSwitched: (value) {
                      setState(() {
                        _includeApocrypha = value;
                      });
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // ═══════════════════════════════════════════════════
                // SECTION 4 : OPTIONS DE DISTRIBUTION
                // ═══════════════════════════════════════════════════
                if (_canCustomizeDistribution) ...[
                  _buildSectionTitle('Options de distribution'),
                  const SizedBox(height: 16),

                  // OT/NT Overlap (si AT+NT sélectionnés)
                  if (_showOtNtOverlap)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Alternance AT/NT'),
                      subtitle: const Text(
                          'Alterner entre Ancien et Nouveau Testament'),
                      value: _otNtOverlap == OtNtOverlapMode.alternate,
                      onChanged: (value) {
                        setState(() {
                          _otNtOverlap = value == true
                              ? OtNtOverlapMode.alternate
                              : OtNtOverlapMode.sequential;
                        });
                        setModalState(() {});
                      },
                    ),

                  // Daily Psalm (si AT sélectionné)
                  if (_showDailyPsalmProverb)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Psaume quotidien'),
                      subtitle: const Text('Ajouter un psaume chaque jour'),
                      value: _dailyPsalm != DailyPsalmMode.none,
                      onChanged: (value) {
                        setState(() {
                          _dailyPsalm = value == true
                              ? DailyPsalmMode.one
                              : DailyPsalmMode.none;
                        });
                        setModalState(() {});
                      },
                    ),

                  // Daily Proverb
                  if (_showDailyPsalmProverb)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Proverbe quotidien'),
                      subtitle: const Text('Ajouter un proverbe chaque jour'),
                      value: _dailyProverb != DailyProverbMode.none,
                      onChanged: (value) {
                        setState(() {
                          _dailyProverb = value == true
                              ? DailyProverbMode.one
                              : DailyProverbMode.none;
                        });
                        setModalState(() {});
                      },
                    ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Options avancées
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Lecture inversée'),
                    subtitle: const Text('Lire les livres en ordre inverse'),
                    value: _reverse,
                    onChanged: (value) {
                      setState(() {
                        _reverse = value ?? false;
                      });
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // ═══════════════════════════════════════════════════
                // SECTION 5 : OPTIONS D'AFFICHAGE
                // ═══════════════════════════════════════════════════
                _buildSectionTitle('Options d\'affichage'),
                const SizedBox(height: 16),

                // Format d'affichage
                Text(
                  'Format',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    {
                      'value': OutputFormat.calendar,
                      'label': 'Calendrier',
                      'icon': Icons.calendar_month
                    },
                    {
                      'value': OutputFormat.list,
                      'label': 'Liste',
                      'icon': Icons.list
                    },
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
                          setModalState(() {});
                        }
                      },
                      selectedColor: AppTheme.seedGold.withValues(alpha: 0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Préférences d'affichage
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Cases à cocher'),
                  subtitle: const Text('Suivre votre progression de lecture'),
                  value: _showCheckboxes,
                  onChanged: (value) {
                    setState(() {
                      _showCheckboxes = value ?? true;
                    });
                    setModalState(() {});
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Statistiques'),
                  subtitle: const Text('Afficher les métriques du plan'),
                  value: _showStatistics,
                  onChanged: (value) {
                    setState(() {
                      _showStatistics = value ?? true;
                    });
                    setModalState(() {});
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Couleurs par section'),
                  subtitle:
                      const Text('Colorier selon les genres bibliques (PDF)'),
                  value: _sectionColors,
                  onChanged: (value) {
                    setState(() {
                      _sectionColors = value ?? false;
                    });
                    setModalState(() {});
                  },
                ),

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
      },
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

  // Labels pour les nouveaux modes
  String _getOtNtOverlapLabel(OtNtOverlapMode mode) {
    switch (mode) {
      case OtNtOverlapMode.sequential:
        return 'Séquentiel (AT puis NT)';
      case OtNtOverlapMode.alternate:
        return 'Alterné (AT et NT en parallèle)';
    }
  }

  String _getDailyPsalmLabel(DailyPsalmMode mode) {
    switch (mode) {
      case DailyPsalmMode.none:
        return 'Aucun psaume quotidien';
      case DailyPsalmMode.one:
        return 'Un psaume par jour';
      case DailyPsalmMode.sequential:
        return 'Psaumes séquentiels (1-150)';
    }
  }

  String _getDailyProverbLabel(DailyProverbMode mode) {
    switch (mode) {
      case DailyProverbMode.none:
        return 'Aucun proverbe quotidien';
      case DailyProverbMode.one:
        return 'Un proverbe par jour (1-31)';
      case DailyProverbMode.dayOfMonth:
        return 'Proverbe selon le jour du mois';
    }
  }
}
