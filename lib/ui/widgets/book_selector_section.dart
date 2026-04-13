import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/bible_data.dart';

class BookSelectorSection extends StatelessWidget {
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

  // ── Helpers sélection ──────────────────────────────────────────

  bool get _allSelected {
    final all = [
      ...BibleData.getOldTestamentBooks(),
      ...BibleData.getNewTestamentBooks(),
      if (includeApocrypha) ...BibleData.deuterocanonicalBooks,
    ].map((b) => b.name);
    return all.every(selectedBooks.contains);
  }

  void _toggleAll(bool value) {
    final all = {
      ...BibleData.getOldTestamentBooks().map((b) => b.name),
      ...BibleData.getNewTestamentBooks().map((b) => b.name),
      if (includeApocrypha)
        ...BibleData.deuterocanonicalBooks.map((b) => b.name),
    };
    onBooksChanged(value ? all : {});
  }

  void _toggleBook(String name, bool value) {
    final next = Set<String>.from(selectedBooks);
    value ? next.add(name) : next.remove(name);
    onBooksChanged(next);
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final otBooks = BibleData.getOldTestamentBooks();
    final ntBooks = BibleData.getNewTestamentBooks();
    final deutBooks = BibleData.deuterocanonicalBooks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tout sélectionner ────────────────────────────────────
        _SelectAllTile(
          isAllSelected: _allSelected,
          onToggle: _toggleAll,
        ),
        const SizedBox(height: 8),

        // ── Ancien Testament ─────────────────────────────────────
        _SectionLabel(title: 'Ancien Testament', count: otBooks.length),
        ...otBooks.map((book) => _BookTile(
              book: book,
              isSelected: selectedBooks.contains(book.name),
              onToggle: (v) => _toggleBook(book.name, v),
            )),

        // ── Deutérocanoniques (optionnels) ───────────────────────
        if (includeApocrypha) ...[
          const SizedBox(height: 4),
          _SectionLabel(
              title: 'Deutérocanoniques', count: deutBooks.length),
          ...deutBooks.map((book) => _BookTile(
                book: book,
                isSelected: selectedBooks.contains(book.name),
                onToggle: (v) => _toggleBook(book.name, v),
              )),
        ],

        // ── Nouveau Testament ────────────────────────────────────
        const SizedBox(height: 4),
        _SectionLabel(title: 'Nouveau Testament', count: ntBooks.length),
        ...ntBooks.map((book) => _BookTile(
              book: book,
              isSelected: selectedBooks.contains(book.name),
              onToggle: (v) => _toggleBook(book.name, v),
            )),

        // ── Option deutérocanoniques ─────────────────────────────
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Inclure les deutérocanoniques'),
          subtitle: const Text('Livres de la Septante et de la Vulgate'),
          value: includeApocrypha,
          activeColor: AppTheme.seedGold,
          onChanged: (value) {
            onApocryphaSwitched(value ?? false);
            if (!(value ?? false)) {
              final next = Set<String>.from(selectedBooks)
                ..removeWhere(
                    (b) => BibleData.getBook(b)?.isDeuterocanonical ?? false);
              onBooksChanged(next);
            }
          },
        ),
      ],
    );
  }
}

// ── Widgets internes ───────────────────────────────────────────────

class _SelectAllTile extends StatelessWidget {
  final bool isAllSelected;
  final ValueChanged<bool> onToggle;

  const _SelectAllTile({required this.isAllSelected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAllSelected
              ? AppTheme.seedGold.withValues(alpha: 0.3)
              : AppTheme.borderSubtle,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Tout sélectionner',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
        value: isAllSelected,
        onChanged: onToggle,
        activeThumbColor: Colors.white,
        activeTrackColor: AppTheme.seedGold,
        inactiveThumbColor: AppTheme.textMuted,
        inactiveTrackColor: AppTheme.surface,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final int count;

  const _SectionLabel({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final BibleBook book;
  final bool isSelected;
  final ValueChanged<bool> onToggle;

  const _BookTile({
    required this.book,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(!isSelected),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (v) => onToggle(v ?? false),
              activeColor: AppTheme.seedGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Text(
                book.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
              ),
            ),
            Text(
              '${book.chapters} ch.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
