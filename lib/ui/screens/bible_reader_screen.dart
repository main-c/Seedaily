import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../domain/bible_reader_models.dart';
import '../../domain/models.dart';
import '../../providers/bible_reader_provider.dart';
import '../../services/bible_reader_service.dart';
import 'bible_library_screen.dart';

class BibleReaderScreen extends StatefulWidget {
  final List<Passage> passages;
  final int initialPassageIndex;
  final void Function(int passageIndex)? onPassageComplete;

  const BibleReaderScreen({
    super.key,
    required this.passages,
    this.initialPassageIndex = 0,
    this.onPassageComplete,
  });

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  late PageController _pageController;
  late List<_ReaderPage> _pages;

  int _currentPassageIndex = 0;
  BibleChapterData? _currentChapterData;
  bool _loading = true;
  String? _error;

  final Set<int> _completedInSession = {};

  @override
  void initState() {
    super.initState();
    _currentPassageIndex = widget.initialPassageIndex;
    _pages = _buildPages();
    final initialPage = _pageIndexForPassage(_currentPassageIndex);
    _pageController = PageController(initialPage: initialPage);
    _loadChapter(initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Pages ──────────────────────────────────────────────────────────────────

  List<_ReaderPage> _buildPages() {
    final pages = <_ReaderPage>[];
    for (var pi = 0; pi < widget.passages.length; pi++) {
      final p = widget.passages[pi];
      for (var ch = p.fromChapter; ch <= p.toChapter; ch++) {
        pages.add(_ReaderPage(
          book: p.book,
          chapter: ch,
          highlightFrom: ch == p.fromChapter ? p.fromVerse : null,
          highlightTo: ch == p.toChapter ? p.toVerse : null,
          passageIndex: pi,
        ));
      }
    }
    return pages;
  }

  int _pageIndexForPassage(int passageIndex) {
    for (var i = 0; i < _pages.length; i++) {
      if (_pages[i].passageIndex == passageIndex) return i;
    }
    return 0;
  }

  int get _currentPageIndex =>
      _pageController.hasClients ? (_pageController.page?.round() ?? 0) : 0;

  _ReaderPage? get _currentPage {
    final idx = _currentPageIndex;
    if (idx < 0 || idx >= _pages.length) return null;
    return _pages[idx];
  }

  // ── Chargement ─────────────────────────────────────────────────────────────

  Future<void> _loadChapter(int pageIndex) async {
    if (pageIndex < 0 || pageIndex >= _pages.length) return;
    final page = _pages[pageIndex];
    final versionId = context.read<BibleReaderProvider>().selectedVersionId;

    setState(() {
      _loading = true;
      _error = null;
      _currentPassageIndex = page.passageIndex;
    });

    final data = await BibleReaderService.instance
        .getChapter(versionId, page.book, page.chapter);

    if (!mounted) return;
    setState(() {
      _currentChapterData = data;
      _loading = false;
      if (data == null) _error = 'Chapitre introuvable.\nVérifiez que la version est bien téléchargée.';
    });
  }

  void _previousChapter() {
    final prev = _currentPageIndex - 1;
    if (prev >= 0) {
      _pageController.animateToPage(prev,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _nextChapter() {
    final next = _currentPageIndex + 1;
    if (next < _pages.length) {
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // ── Marquer lu + auto-avance ───────────────────────────────────────────────

  void _markPassageAndAdvance() {
    final idx = _currentPassageIndex;
    _completedInSession.add(idx);
    widget.onPassageComplete?.call(idx);

    final nextIdx = idx + 1;
    if (nextIdx < widget.passages.length) {
      setState(() => _currentPassageIndex = nextIdx);
      _pageController.animateToPage(
        _pageIndexForPassage(nextIdx),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BibleReaderProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, provider, isDark),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _loadChapter,
                itemBuilder: (context, index) {
                  if (_loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.seedGold, strokeWidth: 2),
                    );
                  }
                  if (_error != null) return _buildError(context);
                  if (_currentChapterData == null) return const SizedBox();
                  return _buildChapterView(
                      context, _pages[index], _currentChapterData!, provider, isDark);
                },
              ),
            ),
            _buildBottomNav(context, isDark),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, BibleReaderProvider provider, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        border: Border(
            bottom: BorderSide(color: cs.outline.withValues(alpha: 0.12))),
      ),
      child: Row(
        children: [
          // Retour
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: cs.onSurface.withValues(alpha: 0.7), size: 22),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const Spacer(),
          // Outils (police, thème)
          IconButton(
            icon: Icon(Icons.text_fields,
                color: cs.onSurface.withValues(alpha: 0.6), size: 22),
            onPressed: () => _showToolsSheet(context, provider),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 4),
          // Sélecteur version → ouvre la bibliothèque
          GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: const BibleLibraryScreen(),
                  ),
                ),
              );
              // Recharger avec la version potentiellement changée
              if (mounted) _loadChapter(_currentPageIndex);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppTheme.seedGold.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language,
                      size: 14,
                      color: AppTheme.seedGold.withValues(alpha: 0.8)),
                  const SizedBox(width: 4),
                  Text(
                    provider.selectedVersion?.shortName ?? 'LSG',
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.seedGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contenu du chapitre ────────────────────────────────────────────────────

  Widget _buildChapterView(BuildContext context, _ReaderPage page,
      BibleChapterData data, BibleReaderProvider provider, bool isDark) {
    final hasPartialHighlight = page.highlightFrom != null || page.highlightTo != null;
    final dimmedColor = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.3);
    final activeColor =
        isDark ? Colors.white.withValues(alpha: 0.92) : const Color(0xFF1C1C1E);

    // Construire le texte continu avec numéros inline
    final spans = <InlineSpan>[];
    for (var v = 1; v <= data.verseCount; v++) {
      final text = data.verse(v) ?? '';
      final isHighlighted = page.isHighlighted(v);
      // Les versets hors-passage sont atténués quand il y a une sélection partielle
      final verseColor = (hasPartialHighlight && !isHighlighted) ? dimmedColor : activeColor;
      final verseNumColor = isHighlighted
          ? AppTheme.seedGold.withValues(alpha: 0.85)
          : (hasPartialHighlight ? dimmedColor : dimmedColor);

      // Numéro de verset en superscript
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.top,
        child: Padding(
          padding: const EdgeInsets.only(right: 3, top: 3),
          child: Text(
            '$v',
            style: GoogleFonts.sourceSerif4(
              fontSize: provider.fontSize * 0.58,
              color: verseNumColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ));

      // Texte du verset
      spans.add(TextSpan(
        text: '$text ',
        style: GoogleFonts.sourceSerif4(
          fontSize: provider.fontSize,
          color: verseColor,
          height: 1.8,
          decoration: TextDecoration.none,
        ),
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nom du livre (petit, centré) — traduit si version anglaise
          Text(
            BibleVersion.localizedBookName(page.book,
                english: provider.selectedVersion?.isEnglish ?? false),
            style: GoogleFonts.sourceSerif4(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.4),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          // Numéro de chapitre (grand, centré)
          Text(
            '${page.chapter}',
            style: GoogleFonts.sourceSerif4(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.85)
                  : const Color(0xFF1C1C1E),
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          // Texte continu
          RichText(
            text: TextSpan(children: spans),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // ── Barre de navigation bas ────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<BibleReaderProvider>();
    final page = _currentPage;
    final isEn = provider.selectedVersion?.isEnglish ?? false;
    final label = page != null
        ? '${BibleVersion.localizedBookName(page.book, english: isEn)} ${page.chapter}'
        : '';
    final isAlreadyDone = _completedInSession.contains(_currentPassageIndex);
    final hasPrev = _currentPageIndex > 0;
    final hasNext = _currentPageIndex < _pages.length - 1;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22223A) : Colors.white,
        border: Border(
            top: BorderSide(color: cs.outline.withValues(alpha: 0.12))),
      ),
      child: Row(
        children: [
          // Chapitre précédent
          IconButton(
            icon: Icon(Icons.chevron_left,
                color: hasPrev
                    ? cs.onSurface.withValues(alpha: 0.7)
                    : cs.onSurface.withValues(alpha: 0.2),
                size: 28),
            onPressed: hasPrev ? _previousChapter : null,
          ),
          // Nom livre + chapitre
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Chapitre suivant
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: hasNext
                    ? cs.onSurface.withValues(alpha: 0.7)
                    : cs.onSurface.withValues(alpha: 0.2),
                size: 28),
            onPressed: hasNext ? _nextChapter : null,
          ),
          // Séparateur
          Container(
              width: 1,
              height: 28,
              color: cs.outline.withValues(alpha: 0.2)),
          // Bouton "Lu" (icône seulement)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: Icon(
                isAlreadyDone
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: isAlreadyDone
                    ? cs.onSurface.withValues(alpha: 0.3)
                    : AppTheme.seedGold,
                size: 26,
              ),
              onPressed: isAlreadyDone ? null : _markPassageAndAdvance,
              tooltip: isAlreadyDone ? 'Déjà lu' : 'Marquer comme lu',
            ),
          ),
        ],
      ),
    );
  }

  // ── Sheet Outils ───────────────────────────────────────────────────────────

  void _showToolsSheet(BuildContext context, BibleReaderProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apparence',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('A',
                      style: GoogleFonts.sourceSerif4(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5))),
                  Expanded(
                    child: Slider(
                      value: provider.fontSize,
                      min: 13,
                      max: 26,
                      divisions: 13,
                      activeColor: AppTheme.seedGold,
                      inactiveColor:
                          AppTheme.seedGold.withValues(alpha: 0.2),
                      onChanged: (v) {
                        provider.setFontSize(v);
                        setSheet(() {});
                      },
                    ),
                  ),
                  Text('A',
                      style: GoogleFonts.sourceSerif4(
                          fontSize: 22,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7))),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Aperçu — "${_currentPage?.book ?? ''}"',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: provider.fontSize,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Erreur ────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Impossible de charger ce chapitre',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}

// ── Modèles internes ──────────────────────────────────────────────────────────

class _ReaderPage {
  final String book;
  final int chapter;
  final int? highlightFrom;
  final int? highlightTo;
  final int passageIndex;

  const _ReaderPage({
    required this.book,
    required this.chapter,
    this.highlightFrom,
    this.highlightTo,
    required this.passageIndex,
  });

  bool isHighlighted(int verseNumber) {
    if (highlightFrom == null && highlightTo == null) return true;
    final from = highlightFrom ?? 1;
    final to = highlightTo ?? 999;
    return verseNumber >= from && verseNumber <= to;
  }
}
