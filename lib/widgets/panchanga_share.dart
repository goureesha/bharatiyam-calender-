/// Panchanga Share — Generates a shareable image of daily panchanga for WhatsApp status.
/// Uses RepaintBoundary to capture a styled widget as an image.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/panchanga_data.dart';
import '../core/events.dart';
import '../i18n/app_locale.dart';

class PanchangaShare {
  static final GlobalKey _repaintKey = GlobalKey();

  /// Show the share preview dialog, then capture & share
  static Future<void> showShareDialog(BuildContext context, PanchangaData d, List<AstroEvent> events, {String purohitDetails = ''}) async {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: _repaintKey,
                child: _ShareCard(d: d, events: events, purohitDetails: purohitDetails),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await _captureAndShare();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _captureAndShare() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/panchanga_share.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ',
        ),
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }
}

class _ShareCard extends StatelessWidget {
  final PanchangaData d;
  final List<AstroEvent> events;
  final String purohitDetails;
  const _ShareCard({required this.d, required this.events, this.purohitDetails = ''});

  @override
  Widget build(BuildContext context) {
    // Vaidika Rutu
    const vaidikaMap = {
      'cm0': 'ವಸಂತ', 'cm1': 'ವಸಂತ',
      'cm2': 'ಗ್ರೀಷ್ಮ', 'cm3': 'ಗ್ರೀಷ್ಮ',
      'cm4': 'ವರ್ಷಾ', 'cm5': 'ವರ್ಷಾ',
      'cm6': 'ಶರದ್', 'cm7': 'ಶರದ್',
      'cm8': 'ಹೇಮಂತ', 'cm9': 'ಹೇಮಂತ',
      'cm10': 'ಶಿಶಿರ', 'cm11': 'ಶಿಶಿರ',
    };
    final vaidikaRutu = vaidikaMap[d.pournimantaMasa] ?? '';

    // Next-day marker
    String nd(bool nextDay) => nextDay ? ' (+)' : '';

    return Container(
      width: 380,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF8F0), Color(0xFFFFF0E0)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B00), width: 2.5),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (purohitDetails.isNotEmpty)
                  Expanded(flex: 3, child: Text(purohitDetails,
                    style: const TextStyle(fontSize: 7, color: Color(0xFF666666), height: 1.3))),
                Expanded(flex: 4, child: Column(children: [
                  Text('✦ ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ ✦',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00)),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Container(height: 1.5, width: 110, color: const Color(0xFFFF6B00)),
                ])),
                if (purohitDetails.isNotEmpty) const Spacer(flex: 1),
              ],
            ),
            const SizedBox(height: 8),

            // ── Date ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${AppLocale.t(d.vara)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 8),

            // ── Sun/Moon ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _iconTime('🌅', 'ಸೂರ್ಯೋದಯ', d.sunrise),
                _iconTime('🌇', 'ಸೂರ್ಯಾಸ್ತ', d.sunset),
                _iconTime('🌙', 'ಚಂದ್ರೋದಯ', d.chandraUdaya),
                _iconTime('🌑', 'ಚಂದ್ರಾಸ್ತ', d.chandraAsta),
              ],
            ),
            const SizedBox(height: 6),
            _divider(),

            // ── Calendar info ──
            const SizedBox(height: 4),
            _row('ಸಂವತ್ಸರ', AppLocale.t(d.samvatsara)),
            _row('ಅಮಾಂತ ಮಾಸ', AppLocale.t(d.amantaMasa)),
            _row('ಪೂರ್ಣಿಮಾಂತ ಮಾಸ', AppLocale.t(d.pournimantaMasa)),
            _row('ಸೌರ ಮಾಸ', '${AppLocale.t(d.souraMasa)} (${d.souraMasaGataDina} ದಿನ)'),
            _row('ಪಕ್ಷ', d.paksha == 'shukla' ? 'ಶುಕ್ಲ ಪಕ್ಷ' : 'ಕೃಷ್ಣ ಪಕ್ಷ'),
            _row('ಋತು', '${AppLocale.t(d.rutu)} (ಸೌರ) / $vaidikaRutu (ವೈದಿಕ)'),
            _row('ಅಯನ', AppLocale.t(d.ayana)),
            _divider(),

            // ── Panchanga limbs with end times ──
            const SizedBox(height: 3),
            _limbRow('ತಿಥಿ', AppLocale.t(d.tithi), '${d.tithiEndTime} (${d.tithiEndGhati})${nd(d.tithiEndsNextDay)}'),
            _limbRow('ನಕ್ಷತ್ರ', AppLocale.t(d.nakshatra), '${d.nakEndTime} (${d.nakEndGhati})${nd(d.nakEndsNextDay)}'),
            _limbRow('ಯೋಗ', AppLocale.t(d.yoga), '${d.yogaEndTime} (${d.yogaEndGhati})${nd(d.yogaEndsNextDay)}'),
            _limbRow('ಕರಣ', AppLocale.t(d.karana), '${d.karanaEndTime} (${d.karanaEndGhati})${nd(d.karanaEndsNextDay)}'),

            // ── Events ──
            if (events.isNotEmpty) ...[
              _divider(),
              const SizedBox(height: 3),
              const Text('🪔 ಹಬ್ಬ / ವಿಶೇಷ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))),
              const SizedBox(height: 3),
              ...events.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('• ${e.name}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                  textAlign: TextAlign.center),
              )),
            ],

            const SizedBox(height: 5),
            Text('(+) = ಮರುದಿನ ಮುಗಿಯುತ್ತದೆ',
              style: TextStyle(fontSize: 6, color: Colors.grey[500], fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _iconTime(String icon, String label, String time) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      Text(label, style: const TextStyle(fontSize: 6.5, color: Color(0xFF888888))),
      Text(time, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
    ]);
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 8.5, color: Color(0xFF666666)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF333333)))),
      ]),
    );
  }

  Widget _limbRow(String label, String value, String endTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 55, child: Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF333333)))),
        Text(endTime, style: const TextStyle(fontSize: 7.5, color: Color(0xFF666666))),
      ]),
    );
  }

  Widget _divider() {
    return Container(
      height: 1, margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(gradient: LinearGradient(
        colors: [Colors.transparent, const Color(0xFFFF6B00).withAlpha(100), Colors.transparent],
      )),
    );
  }
}
