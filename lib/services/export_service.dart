/// Export service — PDF and Image export for Panchanga data.
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/panchanga_data.dart';
import '../i18n/app_locale.dart';

class ExportService {
  /// Export Panchanga as PDF
  static Future<void> exportPdf(PanchangaData data, DateTime date) async {
    final pdf = pw.Document();
    final dateStr = '${date.day}/${date.month}/${date.year}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Bharatiyam Panchanga',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(child: pw.Text(dateStr, style: const pw.TextStyle(fontSize: 16))),
              pw.Divider(),
              pw.SizedBox(height: 12),
              _pdfRow('Date', dateStr),
              _pdfRow('Sunrise', data.sunrise),
              _pdfRow('Sunset', data.sunset),
              pw.SizedBox(height: 8),
              pw.Text('Panchanga', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              _pdfRow('Tithi', AppLocale.t(data.tithi)),
              _pdfRow('Vara', AppLocale.t(data.vara)),
              _pdfRow('Nakshatra', AppLocale.t(data.nakshatra)),
              _pdfRow('Yoga', AppLocale.t(data.yoga)),
              _pdfRow('Karana', AppLocale.t(data.karana)),
              pw.SizedBox(height: 8),
              pw.Text('Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              _pdfRow('Tithi End', '${data.tithiEndTime}${data.tithiEndsNextDay ? " (Next Day)" : ""}'),
              _pdfRow('Nakshatra End', '${data.nakEndTime}${data.nakEndsNextDay ? " (Next Day)" : ""}'),
              _pdfRow('Yoga End', '${data.yogaEndTime}${data.yogaEndsNextDay ? " (Next Day)" : ""}'),
              _pdfRow('Karana End', '${data.karanaEndTime}${data.karanaEndsNextDay ? " (Next Day)" : ""}'),
              pw.SizedBox(height: 8),
              _pdfRow('Chandra Rashi', AppLocale.t(data.chandraRashi)),
              _pdfRow('Soura Masa', AppLocale.t(data.souraMasa)),
              _pdfRow('Divamana', data.divamana),
              _pdfRow('Ratrimana', data.ratrimana),
            ],
          );
        },
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/panchanga_$dateStr.pdf');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], text: 'Bharatiyam Panchanga - $dateStr');
    } catch (e) {
      debugPrint('PDF export error: $e');
    }
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 150, child: pw.Text(label, style: const pw.TextStyle(fontSize: 12))),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  /// Export screen as image using RepaintBoundary
  static Future<void> exportImage(GlobalKey repaintKey) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/panchanga_export.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles([XFile(file.path)], text: 'Bharatiyam Panchanga');
    } catch (e) {
      debugPrint('Image export error: $e');
    }
  }
}
