import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/config.dart';
import '../core/utils.dart';
import '../models/test_record.dart';

class PdfService {
  /// Testi PDF yapar ve paylaşım / kaydetme penceresini açar.
  /// Türkçe karakterler için Roboto fontu internetten indirilir.
  static Future<void> share(TestRecord r, {required bool explanations}) async {
    final base = await PdfGoogleFonts.robotoRegular();
    final bold = await PdfGoogleFonts.robotoBold();
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: base, bold: bold),
    );
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (ctx) => pw.Center(
          child: pw.Text(
            '${AppConfig.footerText}  -  Sayfa ${ctx.pageNumber}/${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        build: (ctx) => [
          pw.Text('${r.lesson} - ${r.topic}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(
            '${r.field}  |  Seviye: ${Levels.label(r.level)}  |  ${fmtDate(r.createdAt)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Divider(),
          pw.SizedBox(height: 6),
          for (var i = 0; i < r.questions.length; i++)
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 14),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${i + 1}. ${r.questions[i].text}',
                      style: pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  for (var o = 0; o < r.questions[i].options.length; o++)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 12, top: 2),
                      child: pw.Text(
                          '${letters[o]}) ${r.questions[i].options[o]}',
                          style: const pw.TextStyle(fontSize: 10.5)),
                    ),
                ],
              ),
            ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.Text('Cevap Anahtarı',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(
            [
              for (var i = 0; i < r.questions.length; i++)
                '${i + 1}-${letters[r.questions[i].correctIndex]}'
            ].join('   '),
            style: const pw.TextStyle(fontSize: 11),
          ),
          if (explanations) ...[
            pw.SizedBox(height: 12),
            pw.Text('Cevap Açıklamaları',
                style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            for (var i = 0; i < r.questions.length; i++)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text(
                  '${i + 1}) ${letters[r.questions[i].correctIndex]}: ${r.questions[i].explanation}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
          ],
        ],
      ),
    );

    final bytes = await doc.save();
    final safe = r.topic
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'test_${safe.isEmpty ? 'soru' : safe}_${r.id}.pdf',
    );
  }
}
