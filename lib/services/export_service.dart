import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../domain/models.dart';

class ExportService {
  Future<void> exportToPdf(GeneratedPlan plan) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(plan),
          pw.SizedBox(height: 20),
          _buildSummary(plan),
          pw.SizedBox(height: 30),
          _buildReadingSchedule(plan),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${plan.title}.pdf',
    );
  }

  pw.Widget _buildHeader(GeneratedPlan plan) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Seedaily',
          style: pw.TextStyle(
            fontSize: 32,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#EF9D10'),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          plan.title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#3B4D61'),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 3,
          width: 100,
          color: PdfColor.fromHex('#EF9D10'),
        ),
      ],
    );
  }

  pw.Widget _buildSummary(GeneratedPlan plan) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
    final startDate = plan.days.isNotEmpty
        ? dateFormat.format(plan.days.first.date)
        : '-';
    final endDate = plan.days.isNotEmpty
        ? dateFormat.format(plan.days.last.date)
        : '-';

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F7F8FA'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Résumé du plan',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#3B4D61'),
            ),
          ),
          pw.SizedBox(height: 12),
          _buildSummaryRow('Durée totale', '${plan.totalDays} jours'),
          _buildSummaryRow('Date de début', startDate),
          _buildSummaryRow('Date de fin', endDate),
          _buildSummaryRow(
            'Nombre de passages',
            '${plan.days.fold<int>(0, (sum, day) => sum + day.passages.length)}',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColor.fromHex('#7A8699'),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1E242C'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReadingSchedule(GeneratedPlan plan) {
    final dateFormat = DateFormat('EEE dd MMM', 'fr_FR');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Programme de lecture',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#3B4D61'),
          ),
        ),
        pw.SizedBox(height: 16),
        ...plan.days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColor.fromHex('#E0E4EA'),
                width: 1,
              ),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 20,
                  height: 20,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#EF9D10'),
                      width: 2,
                    ),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Jour ${index + 1} - ${dateFormat.format(day.date)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#3B4D61'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        day.passages.map((p) => p.reference).join(', '),
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColor.fromHex('#7A8699'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Partage le PDF via les canaux disponibles sur la plateforme.
  ///
  /// La fonction [Printing.sharePdf] retourne un booléen indiquant si
  /// le partage a été lancé avec succès. On relaie simplement cette valeur.
  Future<bool> sharePdf(GeneratedPlan plan) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(plan),
          pw.SizedBox(height: 20),
          _buildSummary(plan),
          pw.SizedBox(height: 30),
          _buildReadingSchedule(plan),
        ],
      ),
    );

    return await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${plan.title}.pdf',
    );
  }
}
