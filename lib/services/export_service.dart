import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../domain/models.dart';

const String _appName = 'Seedaily';
const String _appTagline = 'Générez vos plans de lecture biblique';
const String _appUrl = 'seedaily.app';

class ExportService {
  static const double _cellPassageFontSize = 12;
  static const double _cellDayFontSize = 12;
  static const double _headerFontSize = 13;
  static const double _cellPadding = 3.0;

  // Palette app
  static final _primaryColor = PdfColor.fromHex('#EF9D10');
  static final _navyColor = PdfColor.fromHex('#3B4D61');
  static final _lightBg = PdfColor.fromHex('#F7F8FA');
  static final _borderColor = PdfColor.fromHex('#E0E4EA');
  static final _mutedColor = PdfColor.fromHex('#7A8699');
  static final _textColor = PdfColor.fromHex('#1E242C');

  // Couleurs par genre
  static final _colorLaw = PdfColor.fromHex('#8B7355');
  static final _colorHistory = PdfColor.fromHex('#2E86AB');
  static final _colorWisdom = PdfColor.fromHex('#A23B72');
  static final _colorProphets = PdfColor.fromHex('#F18F01');
  static final _colorNT = PdfColor.fromHex('#3BAE6E');

  // Livres par genre (noms français complets depuis models.dart)
  static const _lawBooks = {
    'Genèse',
    'Exode',
    'Lévitique',
    'Nombres',
    'Deutéronome',
  };
  static const _wisdomBooks = {
    'Job',
    'Psaumes',
    'Proverbes',
    'Ecclésiaste',
    'Cantique des Cantiques',
  };
  static const _prophetBooks = {
    'Ésaïe',
    'Jérémie',
    'Lamentations',
    'Ézéchiel',
    'Daniel',
    'Osée',
    'Joël',
    'Amos',
    'Abdias',
    'Jonas',
    'Michée',
    'Nahum',
    'Habacuc',
    'Sophonie',
    'Aggée',
    'Zacharie',
    'Malachie',
  };
  static const _ntBooks = {
    'Matthieu',
    'Marc',
    'Luc',
    'Jean',
    'Actes',
    'Romains',
    '1 Corinthiens',
    '2 Corinthiens',
    'Galates',
    'Éphésiens',
    'Philippiens',
    'Colossiens',
    '1 Thessaloniciens',
    '2 Thessaloniciens',
    '1 Timothée',
    '2 Timothée',
    'Tite',
    'Philémon',
    'Hébreux',
    'Jacques',
    '1 Pierre',
    '2 Pierre',
    '1 Jean',
    '2 Jean',
    '3 Jean',
    'Jude',
    'Apocalypse',
  };

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> exportToPdf(GeneratedPlan plan) async {
    final logo = await _loadLogo();
    final pdf = await _buildPdf(plan, logo);
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${plan.title}.pdf',
    );
  }

  Future<bool> sharePdf(GeneratedPlan plan) async {
    final logo = await _loadLogo();
    final pdf = await _buildPdf(plan, logo);
    return Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${plan.title}.pdf',
    );
  }

  // ─── Logo ──────────────────────────────────────────────────────────────────

  Future<pw.ImageProvider?> _loadLogo() async {
    try {
      final data = await rootBundle.load('assets/icons/icon.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  // ─── Document ──────────────────────────────────────────────────────────────

  Future<pw.Document> _buildPdf(
      GeneratedPlan plan, pw.ImageProvider? logo) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4.landscape;
    const margin = 20.0;

    // Page de couverture
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
    final totalPages = months.length + 1; // +1 couverture

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
            _buildPageHeader(month, logo, pageNumber, totalPages),
            pw.SizedBox(height: 8),
            pw.Expanded(child: _buildMonthGrid(month, daysByDate)),
            if (isLastPage) ...[
              pw.SizedBox(height: 8),
              _buildLegend(),
            ],
            pw.SizedBox(height: 6),
            _buildPageFooter(logo),
          ],
        ),
      ));
    }

    return pdf;
  }

  // ─── Page de couverture ────────────────────────────────────────────────────

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
          // Logo + nom app
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logo != null) ...[
                pw.Image(logo, width: 56, height: 56),
                pw.SizedBox(width: 16),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _appName,
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  pw.Text(
                    _appTagline,
                    style: pw.TextStyle(fontSize: 10, color: _mutedColor),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 36),
          pw.Container(width: 320, height: 1.5, color: _primaryColor),
          pw.SizedBox(height: 36),

          // Titre du plan
          pw.Text(
            plan.title,
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
              color: _navyColor,
            ),
          ),

          if (hasRange) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              '$startDate  —  $endDate',
              style: pw.TextStyle(fontSize: 11, color: _navyColor),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '${plan.days.length} jours de lecture',
              style: pw.TextStyle(fontSize: 9, color: _mutedColor),
            ),
          ],

          pw.SizedBox(height: 52),

          // Bandeau app
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _lightBg,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'Généré avec l\'app $_appName',
                  style: pw.TextStyle(fontSize: 8, color: _mutedColor),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Téléchargez gratuitement · $_appUrl',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── En-tête de page calendrier ───────────────────────────────────────────

  pw.Widget _buildPageHeader(
      DateTime month, pw.ImageProvider? logo, int page, int total) {
    final label = DateFormat('MMMM yyyy', 'fr_FR').format(month);
    final capitalized = label[0].toUpperCase() + label.substring(1);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          capitalized,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: _navyColor,
          ),
        ),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logo != null) ...[
              pw.Image(logo, width: 16, height: 16),
              pw.SizedBox(width: 5),
            ],
            pw.Text(
              _appName,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: _navyColor,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Text(
              '$page / $total',
              style: pw.TextStyle(fontSize: 8, color: _mutedColor),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Pied de page ─────────────────────────────────────────────────────────

  pw.Widget _buildPageFooter(pw.ImageProvider? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logo != null) ...[
          pw.Image(logo, width: 9, height: 9),
          pw.SizedBox(width: 4),
        ],
        pw.Text(
          '$_appName · $_appTagline · $_appUrl',
          style: pw.TextStyle(fontSize: 6, color: _mutedColor),
        ),
      ],
    );
  }

  // ─── Grille calendrier ────────────────────────────────────────────────────

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
      DateTime month, Map<DateTime, ReadingDay> daysByDate) {
    const weekDays = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];

    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Dim
    final numWeeks = (daysInMonth + startWeekday + 6) ~/ 7;

    return pw.LayoutBuilder(builder: (context, constraints) {
      final availableH = constraints?.maxHeight ?? 500.0;
      const headerH = 26.0;
      final rowH = (availableH - headerH) / numWeeks;

      // Rangée d'en-têtes
      final headerRow = pw.TableRow(
        decoration: pw.BoxDecoration(color: _navyColor),
        children: weekDays
            .map((d) => pw.Container(
                  height: headerH,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    d,
                    style: pw.TextStyle(
                      fontSize: _headerFontSize,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
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
            cells.add(_buildDayCell(dayNumber, daysByDate[date], rowH));
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

  // ─── Cellules ─────────────────────────────────────────────────────────────

  pw.Widget _buildOutOfMonthCell(double height) =>
      pw.Container(height: height, color: _lightBg);

  pw.Widget _buildDayCell(
      int dayNumber, ReadingDay? readingDay, double height) {
    final passages = readingDay?.passages ?? [];
    final isCompleted = readingDay?.completed ?? false;

    final today = DateTime.now();
    final isToday = readingDay != null &&
        readingDay.date.year == today.year &&
        readingDay.date.month == today.month &&
        readingDay.date.day == today.day;

    return pw.Container(
      height: height,
      padding: pw.EdgeInsets.all(_cellPadding),
      color: PdfColors.white,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '$dayNumber',
                style: pw.TextStyle(
                  fontSize: _cellDayFontSize,
                  fontWeight: pw.FontWeight.bold,
                  color: isToday ? _primaryColor : _navyColor,
                ),
              ),
              if (isCompleted)
                pw.Text(
                  '✓',
                  style: pw.TextStyle(
                    fontSize: 7,
                    color: _colorNT,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 2),
          ...passages.map((p) => _buildPassageLine(p, isChecked: isCompleted)),
        ],
      ),
    );
  }

  pw.Widget _buildPassageLine(Passage passage, {bool isChecked = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 2.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Point couleur genre
          pw.Container(
            width: 5,
            height: 5,
            decoration: pw.BoxDecoration(
              color: _genreColor(passage.book),
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 3),
          // Checkbox imprimable
          _buildCheckbox(isChecked: isChecked),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              passage.shortReference,
              style: pw.TextStyle(
                fontSize: _cellPassageFontSize,
                color: _textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCheckbox({bool isChecked = false}) {
    return pw.Container(
      width: 8,
      height: 8,
      decoration: pw.BoxDecoration(
        color: isChecked ? _colorNT : PdfColors.white,
        border: pw.Border.all(color: _navyColor, width: 0.8),
        borderRadius: pw.BorderRadius.circular(1.5),
      ),
      child: isChecked
          ? pw.Center(
              child: pw.Text(
                '✓',
                style: pw.TextStyle(
                  fontSize: 6,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  // ─── Genre → couleur ──────────────────────────────────────────────────────

  PdfColor _genreColor(String bookName) {
    if (_ntBooks.contains(bookName)) return _colorNT;
    if (_lawBooks.contains(bookName)) return _colorLaw;
    if (_wisdomBooks.contains(bookName)) return _colorWisdom;
    if (_prophetBooks.contains(bookName)) return _colorProphets;
    return _colorHistory;
  }

  // ─── Légende ──────────────────────────────────────────────────────────────

  pw.Widget _buildLegend() {
    final items = [
      ('Loi / Torah', _colorLaw),
      ('Historiques', _colorHistory),
      ('Sapientiaux', _colorWisdom),
      ('Prophètes', _colorProphets),
      ('Nouveau Testament', _colorNT),
    ];

    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: _lightBg,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 8,
                      height: 8,
                      decoration: pw.BoxDecoration(
                        color: item.$2,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Text(
                      item.$1,
                      style: pw.TextStyle(fontSize: 7, color: _navyColor),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
