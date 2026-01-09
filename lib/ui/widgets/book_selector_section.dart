import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/bible_data.dart';

class BookSelectorSection extends StatefulWidget {
  final String templateId;
  final Set<String> selectedBooks;
  final bool includeApocrypha;
  final ValueChanged<Set<String>> onBooksChanged;
  final ValueChanged<bool> onApocryphaSwitched;

  const BookSelectorSection({
    super.key,
    required this.templateId,
    required this.selectedBooks,
    required this.includeApocrypha,
    required this.onBooksChanged,
    required this.onApocryphaSwitched,
  });

  @override
  State<BookSelectorSection> createState() => _BookSelectorSectionState();
}

class _BookSelectorSectionState extends State<BookSelectorSection> {
  final List<int> _expandedPanels = [];

  @override
  Widget build(BuildContext context) {
    return _buildSelector();
  }

  Widget _buildSelector() {
    switch (widget.templateId) {
      case 'canonical-plan':
      case 'bible-complete':
        return _buildTraditionalSelector();
      case 'chronological-plan':
        return _buildChronologicalSelector();
      case 'jewish-plan':
        return _buildJewishSelector();
      default:
        return _buildSimpleSelector();
    }
  }

  // Section 1 : Sélecteur pour plan Traditional/Canonical
  Widget _buildTraditionalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernExpansionPanels(),
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Inclure les deutérocanoniques'),
          subtitle: const Text('Livres de la Septante et de la Vulgate'),
          value: widget.includeApocrypha,
          onChanged: (value) {
            widget.onApocryphaSwitched(value ?? false);
            if (!(value ?? false)) {
              final newSelection = Set<String>.from(widget.selectedBooks);
              newSelection.removeWhere((book) =>
                  BibleData.getBook(book)?.isDeuterocanonical ?? false);
              widget.onBooksChanged(newSelection);
            }
          },
        ),
      ],
    );
  }

  Widget _buildModernExpansionPanels() {
    return Column(
      children: [
        // Old Testament Panel
        _buildCleanExpansionTile(
          index: 0,
          title: 'Ancien Testament',
          subtitle: '39 livres',
          isAllSelected: _areAllOldTestamentSelected(),
          onToggleAll: _toggleOldTestament,
          books: BibleData.getOldTestamentBooks(),
        ),
        const SizedBox(height: 8),

        // Deuterocanonical Panel (conditional)
        if (widget.includeApocrypha) ...[
          _buildCleanExpansionTile(
            index: 1,
            title: 'Deutérocanoniques',
            subtitle: '${BibleData.deuterocanonicalBooks.length} livres',
            isAllSelected: _areAllDeuterocanonicalSelected(),
            onToggleAll: _toggleDeuterocanonical,
            books: BibleData.deuterocanonicalBooks,
          ),
          const SizedBox(height: 8),
        ],

        // New Testament Panel
        _buildCleanExpansionTile(
          index: widget.includeApocrypha ? 2 : 1,
          title: 'Nouveau Testament',
          subtitle: '27 livres',
          isAllSelected: _areAllNewTestamentSelected(),
          onToggleAll: _toggleNewTestament,
          books: BibleData.getNewTestamentBooks(),
        ),
      ],
    );
  }

  Widget _buildCleanExpansionTile({
    required int index,
    required String title,
    required String subtitle,
    required bool isAllSelected,
    required Function(bool?) onToggleAll,
    required List<BibleBook> books,
  }) {
    final isExpanded = _expandedPanels.contains(index);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppTheme.seedGold.withValues(alpha: 0.3) : AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedPanels.remove(index);
                } else {
                  _expandedPanels.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: isAllSelected,
                    onChanged: onToggleAll,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: AppTheme.seedGold,
                  ),
                  const SizedBox(width: 12),

                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Expand icon
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppTheme.seedGold,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildBooksList(books),
          ],
        ],
      ),
    );
  }

  Widget _buildBooksList(List<BibleBook> books) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: books.map((book) {
          final isSelected = widget.selectedBooks.contains(book.name);
          return InkWell(
            onTap: () => _toggleBook(book.name, !isSelected),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleBook(book.name, value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: AppTheme.seedGold,
                  ),
                  const SizedBox(width: 12),

                  // Book info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${book.chapters} ${book.chapters > 1 ? 'chapitres' : 'chapitre'}',
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
        }).toList(),
      ),
    );
  }

  // Widget spécial pour le plan juif avec subgroups (Torah, Neviim, Ketuvim)
  Widget _buildJewishExpansionTile({
    required int index,
    required String title,
    required String subtitle,
    required bool isAllSelected,
    required Function(bool?) onToggleAll,
  }) {
    final isExpanded = _expandedPanels.contains(index);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppTheme.seedGold.withValues(alpha: 0.3) : AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedPanels.remove(index);
                } else {
                  _expandedPanels.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: isAllSelected,
                    onChanged: onToggleAll,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: AppTheme.seedGold,
                  ),
                  const SizedBox(width: 12),

                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Expand icon
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppTheme.seedGold,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content with subgroups
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Torah subgroup
                  _buildHebrewSubgroup('Torah', BibleData.getBooksByHebrewGroup('Torah')),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  // Neviim subgroup
                  _buildHebrewSubgroup('Neviim', BibleData.getBooksByHebrewGroup('Neviim')),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  // Ketuvim subgroup
                  _buildHebrewSubgroup('Ketuvim', BibleData.getBooksByHebrewGroup('Ketuvim')),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Subgroup pour les sections hébraïques (Torah, Neviim, Ketuvim)
  Widget _buildHebrewSubgroup(String groupName, List<BibleBook> books) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.seedGold,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...books.map((book) {
            final isSelected = widget.selectedBooks.contains(book.name);
            return InkWell(
              onTap: () => _toggleBook(book.name, !isSelected),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleBook(book.name, value),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: AppTheme.seedGold,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.deepNavy,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${book.chapters} ${book.chapters > 1 ? 'chapitres' : 'chapitre'}',
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
          }),
        ],
      ),
    );
  }

  // Section 2 : Sélecteur pour plan Chronological
  Widget _buildChronologicalSelector() {
    return Column(
      children: [
        _buildCleanExpansionTile(
          index: 0,
          title: 'Ancien Testament',
          subtitle: '39 livres - Ordre chronologique',
          isAllSelected: _areAllOldTestamentSelected(),
          onToggleAll: _toggleOldTestament,
          books: _getChronologicalOldTestamentBooks(),
        ),
        const SizedBox(height: 8),
        _buildCleanExpansionTile(
          index: 1,
          title: 'Nouveau Testament',
          subtitle: '27 livres - Ordre chronologique',
          isAllSelected: _areAllNewTestamentSelected(),
          onToggleAll: _toggleNewTestament,
          books: _getChronologicalNewTestamentBooks(),
        ),
      ],
    );
  }

  // Section 3 : Sélecteur pour plan Jewish (Hebrew Tanakh)
  Widget _buildJewishSelector() {
    return Column(
      children: [
        _buildJewishExpansionTile(
          index: 0,
          title: 'Tanakh hébreu',
          subtitle: '39 livres - Torah, Neviim, Ketuvim',
          isAllSelected: _areAllHebrewBooksSelected(),
          onToggleAll: _toggleHebrewBooks,
        ),
        const SizedBox(height: 8),
        _buildCleanExpansionTile(
          index: 1,
          title: 'Auteurs des Évangiles',
          subtitle: '27 livres - Nouveau Testament',
          isAllSelected: _areAllGospelWritersSelected(),
          onToggleAll: _toggleGospelWriters,
          books: BibleData.getGospelWritersBooks(),
        ),
      ],
    );
  }

  Widget _buildSimpleSelector() {
    // Pour les templates anciens (new-testament, old-testament, etc.)
    return Text(
      'Sélection personnalisée disponible uniquement pour les nouveaux plans.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMuted,
          ),
    );
  }

  // Méthodes de toggle
  void _toggleBook(String bookName, bool? value) {
    final newSelection = Set<String>.from(widget.selectedBooks);
    if (value == true) {
      newSelection.add(bookName);
    } else {
      newSelection.remove(bookName);
    }
    widget.onBooksChanged(newSelection);
  }

  void _toggleOldTestament(bool? value) {
    final newSelection = Set<String>.from(widget.selectedBooks);
    if (value == true) {
      newSelection.addAll(
        BibleData.getOldTestamentBooks().map((b) => b.name),
      );
    } else {
      newSelection.removeWhere((book) {
        final b = BibleData.getBook(book);
        return b?.isOldTestament ?? false;
      });
    }
    widget.onBooksChanged(newSelection);
  }

  void _toggleNewTestament(bool? value) {
    final newSelection = Set<String>.from(widget.selectedBooks);
    if (value == true) {
      newSelection.addAll(
        BibleData.getNewTestamentBooks().map((b) => b.name),
      );
    } else {
      newSelection.removeWhere((book) {
        final b = BibleData.getBook(book);
        return b?.isNewTestament ?? false;
      });
    }
    widget.onBooksChanged(newSelection);
  }

  void _toggleDeuterocanonical(bool? value) {
    final newSelection = Set<String>.from(widget.selectedBooks);
    if (value == true) {
      newSelection.addAll(
        BibleData.deuterocanonicalBooks.map((b) => b.name),
      );
    } else {
      newSelection.removeWhere(
          (book) => BibleData.getBook(book)?.isDeuterocanonical ?? false);
    }
    widget.onBooksChanged(newSelection);
  }

  void _toggleHebrewBooks(bool? value) {
    final newSelection = Set<String>.from(widget.selectedBooks);
    if (value == true) {
      // Ajouter Torah + Neviim + Ketuvim
      newSelection.addAll(
        BibleData.books.where((b) => b.hebrewGroup != null).map((b) => b.name),
      );
    } else {
      newSelection.removeWhere((book) {
        final b = BibleData.getBook(book);
        return b?.hebrewGroup != null;
      });
    }
    widget.onBooksChanged(newSelection);
  }

  void _toggleGospelWriters(bool? value) {
    final newSelection = Set<String>.from(widget.selectedBooks);
    if (value == true) {
      newSelection.addAll(
        BibleData.getGospelWritersBooks().map((b) => b.name),
      );
    } else {
      final gospelWritersNames =
          BibleData.getGospelWritersBooks().map((b) => b.name).toSet();
      newSelection.removeWhere((book) => gospelWritersNames.contains(book));
    }
    widget.onBooksChanged(newSelection);
  }

  // Méthodes de vérification
  bool _areAllOldTestamentSelected() {
    final allOt = BibleData.getOldTestamentBooks().map((b) => b.name).toSet();
    return allOt.every((book) => widget.selectedBooks.contains(book));
  }

  bool _areAllNewTestamentSelected() {
    final allNt = BibleData.getNewTestamentBooks().map((b) => b.name).toSet();
    return allNt.every((book) => widget.selectedBooks.contains(book));
  }

  bool _areAllDeuterocanonicalSelected() {
    final allDeut = BibleData.deuterocanonicalBooks.map((b) => b.name).toSet();
    return allDeut.every((book) => widget.selectedBooks.contains(book));
  }

  bool _areAllHebrewBooksSelected() {
    final allHebrew = BibleData.books
        .where((b) => b.hebrewGroup != null)
        .map((b) => b.name)
        .toSet();
    return allHebrew.every((book) => widget.selectedBooks.contains(book));
  }

  bool _areAllGospelWritersSelected() {
    final allGw = BibleData.getGospelWritersBooks().map((b) => b.name).toSet();
    return allGw.every((book) => widget.selectedBooks.contains(book));
  }

  // Méthodes pour obtenir les livres triés par ordre chronologique
  List<BibleBook> _getChronologicalOldTestamentBooks() {
    final otBooks = BibleData.getOldTestamentBooks();
    otBooks
        .sort((a, b) => a.chronologicalOrder.compareTo(b.chronologicalOrder));
    return otBooks;
  }

  List<BibleBook> _getChronologicalNewTestamentBooks() {
    final ntBooks = BibleData.getNewTestamentBooks();
    ntBooks
        .sort((a, b) => a.chronologicalOrder.compareTo(b.chronologicalOrder));
    return ntBooks;
  }
}
