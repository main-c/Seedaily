import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../domain/models.dart';
import 'analytics_service.dart';

const String _appName = 'Seedaily';
const String _appTagline = 'Générez vos plans de lecture biblique';
const String _appUrl = 'seedaily.app';

class ExportService {
  // ── Typographie ──────────────────────────────────────────────────────────────
  static const double _titleFontSize = 24.0;
  static const double _subtitleFontSize = 10.0;
  static const double _brandFontSize = 12.0;
  static const double _dayHeaderFontSize = 7.5;
  static const double _cellDayFontSize = 7.0;
  static const double _cellPassageFontSize = 9.5;
  static const double _cellPadding = 5.0;

  // ── Palette de base ──────────────────────────────────────────────────────────
  static final _primaryColor = PdfColor.fromHex('#EF9D10');   // seedGold
  static final _textColor = PdfColor.fromHex('#1E242C');
  static final _mutedColor = PdfColor.fromHex('#7A8699');
  static final _borderColor = PdfColor.fromHex('#E0E4EA');
  static final _lightBg = PdfColor.fromHex('#F7F8FA');
  static final _emptyCell = PdfColor.fromHex('#F4F4F4');

  // ── Couleurs pastel de fond par genre ────────────────────────────────────────
  // Loi / Torah
  static final _bgLaw = PdfColor.fromHex('#EDE3C5');
  // Historiques
  static final _bgHistory = PdfColor.fromHex('#C5E2D2');
  // Sapientiaux
  static final _bgWisdom = PdfColor.fromHex('#D8CDE8');
  // Prophètes
  static final _bgProphets = PdfColor.fromHex('#F0D5B0');
  // Évangiles & Actes
  static final _bgGospelsActs = PdfColor.fromHex('#BDD9EB');
  // Épîtres
  static final _bgEpistles = PdfColor.fromHex('#F0D4B0');
  // Apocalypse
  static final _bgRevelation = PdfColor.fromHex('#F0C5C8');

  // ── Couleurs de texte foncées pour chaque genre (lisibles sur fond pastel) ──
  static final _fgLaw = PdfColor.fromHex('#6B5A2E');
  static final _fgHistory = PdfColor.fromHex('#2C6048');
  static final _fgWisdom = PdfColor.fromHex('#4A3870');
  static final _fgProphets = PdfColor.fromHex('#7A4A18');
  static final _fgGospelsActs = PdfColor.fromHex('#1A5070');
  static final _fgEpistles = PdfColor.fromHex('#7A4A18');
  static final _fgRevelation = PdfColor.fromHex('#70282C');

  // ── Classification des livres ────────────────────────────────────────────────
  static const _lawBooks = {
    'Genèse', 'Exode', 'Lévitique', 'Nombres', 'Deutéronome',
  };
  static const _wisdomBooks = {
    'Job', 'Psaumes', 'Proverbes', 'Ecclésiaste', 'Cantique des Cantiques',
  };
  static const _prophetBooks = {
    'Ésaïe', 'Jérémie', 'Lamentations', 'Ézéchiel', 'Daniel',
    'Osée', 'Joël', 'Amos', 'Abdias', 'Jonas', 'Michée', 'Nahum',
    'Habacuc', 'Sophonie', 'Aggée', 'Zacharie', 'Malachie',
  };
  static const _gospelActsBooks = {
    'Matthieu', 'Marc', 'Luc', 'Jean', 'Actes',
  };
  static const _epistleBooks = {
    'Romains', '1 Corinthiens', '2 Corinthiens', 'Galates', 'Éphésiens',
    'Philippiens', 'Colossiens', '1 Thessaloniciens', '2 Thessaloniciens',
    '1 Timothée', '2 Timothée', 'Tite', 'Philémon', 'Hébreux',
    'Jacques', '1 Pierre', '2 Pierre', '1 Jean', '2 Jean', '3 Jean', 'Jude',
  };
  static const _revelationBooks = {'Apocalypse'};

  // ── Tous les AT hors Loi/Sagesse/Prophètes = Historiques ────────────────────
  static const _historyBooks = {
    'Josué', 'Juges', 'Ruth', '1 Samuel', '2 Samuel', '1 Rois', '2 Rois',
    '1 Chroniques', '2 Chroniques', 'Esdras', 'Néhémie', 'Esther',
    'Tobie', 'Judith', '1 Maccabées', '2 Maccabées',
  };

  // ── Public API ────────────────────────────────────────────────────────────────

  Future<void> exportToPdf(
    GeneratedPlan plan, {
    bool sectionColors = true,
    bool includeCheckbox = true,
  }) async {
    final logo = await _loadLogo();
    final pdf = await _buildPdf(plan, logo,
        sectionColors: sectionColors, includeCheckbox: includeCheckbox);
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${plan.title}.pdf',
    );
  }

  Future<bool> sharePdf(
    GeneratedPlan plan, {
    bool sectionColors = true,
    bool includeCheckbox = true,
  }) async {
    final logo = await _loadLogo();
    final pdf = await _buildPdf(plan, logo,
        sectionColors: sectionColors, includeCheckbox: includeCheckbox);
    final result = await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${plan.title}.pdf',
    );
    if (result) AnalyticsService.instance.logPlanExported();
    return result;
  }

  // ── Logo ──────────────────────────────────────────────────────────────────────

  Future<pw.ImageProvider?> _loadLogo() async {
    try {
      final data = await rootBundle.load('assets/icons/icon.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  // ── Document ──────────────────────────────────────────────────────────────────

  Future<pw.Document> _buildPdf(
    GeneratedPlan plan,
    pw.ImageProvider? logo, {
    bool sectionColors = true,
    bool includeCheckbox = true,
  }) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4.landscape;
    const margin = 24.0;

    pdf.addPage(pw.Page(
      pageFormat: pageFormat,
      margin: pw.EdgeInsets.all(margin),
      build: (_) => _buildCoverPage(plan, logo),
    ));

    if (plan.days.isEmpty) return pdf;

    final daysByDate = {
      for (final d in plan.days)
        DateTime(d.date.year, d.date.month, d.date.day): d,
    };

    final months = _getMonthsInRange(plan.days.first.date, plan.days.last.date);
    final totalPages = months.length + 1;

    // Genres présents dans ce plan (pour la légende)
    final presentGenres = _detectPresentGenres(plan.days);

    for (var i = 0; i < months.length; i++) {
      final month = months[i];
      final isLastPage = i == months.length - 1;
      final pageNumber = i + 2;

      pdf.addPage(pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(margin),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader(plan, month),
            pw.SizedBox(height: 12),
            pw.Expanded(
              child: _buildMonthGrid(
                month,
                daysByDate,
                sectionColors: sectionColors,
                includeCheckbox: includeCheckbox,
              ),
            ),
            if (sectionColors && isLastPage) ...[
              pw.SizedBox(height: 8),
              _buildLegend(presentGenres),
            ],
            pw.SizedBox(height: 4),
            _buildPageFooter(pageNumber, totalPages),
          ],
        ),
      ));
    }

    return pdf;
  }

  // ── Page de couverture ────────────────────────────────────────────────────────

  pw.Widget _buildCoverPage(GeneratedPlan plan, pw.ImageProvider? logo) {
    final fmt = DateFormat('d MMMM yyyy', 'fr_FR');
    final hasRange = plan.days.isNotEmpty;
    final startDate = hasRange ? fmt.format(plan.days.first.date) : '';
    final endDate = hasRange ? fmt.format(plan.days.last.date) : '';

    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logo != null) ...[
                pw.Image(logo, width: 52, height: 52),
                pw.SizedBox(width: 16),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _appName,
                    style: pw.TextStyle(
                      fontSize: 30,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  pw.Text(
                    _appTagline,
                    style: pw.TextStyle(fontSize: 9, color: _mutedColor),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 36),
          pw.Container(width: 280, height: 1.5, color: _primaryColor),
          pw.SizedBox(height: 36),
          pw.Text(
            plan.title,
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
              color: _textColor,
            ),
          ),
          if (hasRange) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              '$startDate  -  $endDate',
              style: pw.TextStyle(fontSize: 11, color: _mutedColor),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '${plan.days.length} jours de lecture',
              style: pw.TextStyle(fontSize: 9, color: _mutedColor),
            ),
          ],
          pw.SizedBox(height: 48),
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _lightBg,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              'Généré avec $_appName · $_appUrl',
              style: pw.TextStyle(fontSize: 9, color: _mutedColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── En-tête de page calendrier (style screenshot) ─────────────────────────────
  // Gauche : titre du plan (grand bold) + "Plan de Lecture • Mois Année"
  // Droite : "Seedaily" en or muet

  pw.Widget _buildPageHeader(GeneratedPlan plan, DateTime month) {
    final monthLabel = DateFormat('MMMM yyyy', 'fr_FR').format(month);
    final monthCap = monthLabel[0].toUpperCase() + monthLabel.substring(1);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              plan.title,
              style: pw.TextStyle(
                fontSize: _titleFontSize,
                fontWeight: pw.FontWeight.bold,
                color: _textColor,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Plan de Lecture - $monthCap',
              style: pw.TextStyle(fontSize: _subtitleFontSize, color: _mutedColor),
            ),
          ],
        ),
        pw.Text(
          _appName,
          style: pw.TextStyle(
            fontSize: _brandFontSize,
            fontWeight: pw.FontWeight.bold,
            color: _primaryColor,
          ),
        ),
      ],
    );
  }

  // ── Pied de page ──────────────────────────────────────────────────────────────

  pw.Widget _buildPageFooter(int page, int total) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          '$_appName · $_appUrl · $page / $total',
          style: pw.TextStyle(fontSize: 6, color: _mutedColor),
        ),
      ],
    );
  }

  // ── Grille mensuelle ──────────────────────────────────────────────────────────
  // Semaine commence le lundi (standard français)

  List<DateTime> _getMonthsInRange(DateTime start, DateTime end) {
    final months = <DateTime>[];
    var current = DateTime(start.year, start.month);
    final last = DateTime(end.year, end.month);
    while (!current.isAfter(last)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }
    return months;
  }

  pw.Widget _buildMonthGrid(
    DateTime month,
    Map<DateTime, ReadingDay> daysByDate, {
    bool sectionColors = true,
    bool includeCheckbox = true,
  }) {
    // Lundi = 0 … Dimanche = 6
    const weekDays = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];

    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // DateTime.weekday : 1=lun … 7=dim → décalage 0-based
    final startWeekday = firstDay.weekday - 1;
    final numWeeks = ((daysInMonth + startWeekday) / 7).ceil();

    return pw.LayoutBuilder(builder: (context, constraints) {
      final availableH = constraints?.maxHeight ?? 500.0;
      const headerH = 22.0;
      final rowH = (availableH - headerH) / numWeeks;

      // ── Rangée d'en-têtes (lundi–dimanche) ────────────────────────
      final headerRow = pw.TableRow(
        children: weekDays
            .map((d) => pw.Container(
                  height: headerH,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    d,
                    style: pw.TextStyle(
                      fontSize: _dayHeaderFontSize,
                      fontWeight: pw.FontWeight.bold,
                      color: _mutedColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ))
            .toList(),
      );

      final rows = <pw.TableRow>[headerRow];

      for (var week = 0; week < numWeeks; week++) {
        final cells = <pw.Widget>[];
        for (var col = 0; col < 7; col++) {
          final dayNumber = week * 7 + col - startWeekday + 1;
          if (dayNumber < 1 || dayNumber > daysInMonth) {
            cells.add(_buildOutOfMonthCell(rowH));
          } else {
            final date = DateTime(month.year, month.month, dayNumber);
            cells.add(_buildDayCell(
              dayNumber,
              daysByDate[date],
              rowH,
              sectionColors: sectionColors,
              includeCheckbox: includeCheckbox,
            ));
          }
        }
        rows.add(pw.TableRow(children: cells));
      }

      return pw.Table(
        border: pw.TableBorder.all(color: _borderColor, width: 0.5),
        columnWidths: {
          for (var i = 0; i < 7; i++) i: const pw.FlexColumnWidth(1),
        },
        children: rows,
      );
    });
  }

  // ── Cellule hors mois ─────────────────────────────────────────────────────────

  pw.Widget _buildOutOfMonthCell(double height) =>
      pw.Container(height: height, color: _emptyCell);

  // ── Cellule d'un jour ─────────────────────────────────────────────────────────

  pw.Widget _buildDayCell(
    int dayNumber,
    ReadingDay? readingDay,
    double height, {
    bool sectionColors = true,
    bool includeCheckbox = true,
  }) {
    final passages = readingDay?.passages ?? [];
    final isCompleted = readingDay?.completed ?? false;
    final hasPassages = passages.isNotEmpty;

    // Couleur de fond : genre du premier passage (si l'option est activée)
    final bgColor = (sectionColors && hasPassages)
        ? _genreBgColor(passages.first.book)
        : PdfColors.white;

    final today = DateTime.now();
    final isToday = readingDay != null &&
        readingDay.date.year == today.year &&
        readingDay.date.month == today.month &&
        readingDay.date.day == today.day;

    return pw.Container(
      height: height,
      color: bgColor,
      padding: pw.EdgeInsets.all(_cellPadding),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          // Numéro du jour + coche si complété
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '$dayNumber',
                style: pw.TextStyle(
                  fontSize: _cellDayFontSize,
                  color: isToday ? _primaryColor : _mutedColor,
                  fontWeight: isToday ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
              if (isCompleted && includeCheckbox)
                pw.Text(
                  '✓',
                  style: pw.TextStyle(
                    fontSize: 7,
                    color: _mutedColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 3),
          // Passages
          ...passages.map((p) => _buildPassageLine(
                p,
                sectionColors: sectionColors,
                includeCheckbox: includeCheckbox && !isCompleted,
              )),
        ],
      ),
    );
  }

  // ── Ligne de passage ──────────────────────────────────────────────────────────

  pw.Widget _buildPassageLine(
    Passage passage, {
    bool sectionColors = true,
    bool includeCheckbox = true,
  }) {
    final fgColor = sectionColors ? _genreFgColor(passage.book) : _textColor;

    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 2.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (includeCheckbox) ...[
            _buildCheckbox(),
            pw.SizedBox(width: 3),
          ],
          pw.Expanded(
            child: pw.Text(
              passage.shortReference,
              style: pw.TextStyle(
                fontSize: _cellPassageFontSize,
                fontWeight: pw.FontWeight.bold,
                color: fgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCheckbox() {
    return pw.Container(
      width: 7,
      height: 7,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _mutedColor, width: 0.7),
        borderRadius: pw.BorderRadius.circular(1.5),
      ),
    );
  }

  // ── Genre → couleur de fond ───────────────────────────────────────────────────

  PdfColor _genreBgColor(String bookName) {
    if (_gospelActsBooks.contains(bookName)) return _bgGospelsActs;
    if (_epistleBooks.contains(bookName)) return _bgEpistles;
    if (_revelationBooks.contains(bookName)) return _bgRevelation;
    if (_lawBooks.contains(bookName)) return _bgLaw;
    if (_wisdomBooks.contains(bookName)) return _bgWisdom;
    if (_prophetBooks.contains(bookName)) return _bgProphets;
    if (_historyBooks.contains(bookName)) return _bgHistory;
    return _bgHistory; // fallback Historiques pour tout AT non classifié
  }

  // ── Genre → couleur de texte ──────────────────────────────────────────────────

  PdfColor _genreFgColor(String bookName) {
    if (_gospelActsBooks.contains(bookName)) return _fgGospelsActs;
    if (_epistleBooks.contains(bookName)) return _fgEpistles;
    if (_revelationBooks.contains(bookName)) return _fgRevelation;
    if (_lawBooks.contains(bookName)) return _fgLaw;
    if (_wisdomBooks.contains(bookName)) return _fgWisdom;
    if (_prophetBooks.contains(bookName)) return _fgProphets;
    return _fgHistory;
  }

  // ── Détecte quels genres sont présents dans le plan ───────────────────────────

  Set<String> _detectPresentGenres(List<ReadingDay> days) {
    final genres = <String>{};
    for (final day in days) {
      for (final p in day.passages) {
        final name = p.book;
        if (_gospelActsBooks.contains(name)) {
          genres.add('gospels');
        } else if (_epistleBooks.contains(name)) {
          genres.add('epistles');
        } else if (_revelationBooks.contains(name)) {
          genres.add('revelation');
        } else if (_lawBooks.contains(name)) {
          genres.add('law');
        } else if (_wisdomBooks.contains(name)) {
          genres.add('wisdom');
        } else if (_prophetBooks.contains(name)) {
          genres.add('prophets');
        } else {
          genres.add('history');
        }
      }
    }
    return genres;
  }

  // ── Légende ───────────────────────────────────────────────────────────────────

  pw.Widget _buildLegend(Set<String> presentGenres) {
    final allItems = [
      ('gospels',    'Évangiles & Actes', _bgGospelsActs),
      ('epistles',   'Épîtres',           _bgEpistles),
      ('revelation', 'Apocalypse',        _bgRevelation),
      ('law',        'Loi / Torah',       _bgLaw),
      ('history',    'Historiques',       _bgHistory),
      ('wisdom',     'Sapientiaux',       _bgWisdom),
      ('prophets',   'Prophètes',         _bgProphets),
    ];

    final items = allItems.where((i) => presentGenres.contains(i.$1)).toList();
    if (items.isEmpty) return pw.SizedBox();

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) pw.SizedBox(width: 16),
          _buildLegendChip(items[i].$2, items[i].$3),
        ],
      ],
    );
  }

  pw.Widget _buildLegendChip(String label, PdfColor color) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 14,
          height: 10,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 7.5, color: _mutedColor),
        ),
      ],
    );
  }
}
