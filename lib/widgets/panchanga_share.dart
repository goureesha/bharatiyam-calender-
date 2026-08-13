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
import '../core/shraddha_calculator.dart';
import '../i18n/app_locale.dart';

class PanchangaShare {
  static final GlobalKey _repaintKey = GlobalKey();

  /// Show the share preview dialog, then capture & share
  static Future<void> showShareDialog(
    BuildContext context,
    PanchangaData d,
    List<AstroEvent> events, {
    List<KalaTiming> kalas = const [],
    String purohitDetails = '',
    ShraddhaInfo? shraddha,
  }) async {
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
                child: _ShareCard(d: d, events: events, kalas: kalas, purohitDetails: purohitDetails, shraddha: shraddha),
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
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ',
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }
}

class _ShareCard extends StatelessWidget {
  final PanchangaData d;
  final List<AstroEvent> events;
  final List<KalaTiming> kalas;
  final String purohitDetails;
  final ShraddhaInfo? shraddha;
  const _ShareCard({required this.d, required this.events, this.kalas = const [], this.purohitDetails = '', this.shraddha});

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

    // Find Rahu Kala, Gulika Kala, Abhijit from kalas list
    String rahuKala = '', gulikaKala = '', abhijit = '';
    for (final k in kalas) {
      final name = k.name.toLowerCase();
      if (name.contains('rahu') || name.contains('ರಾಹು')) {
        rahuKala = '${k.startTime} - ${k.endTime}';
      } else if (name.contains('gulika') || name.contains('ಗುಳಿಕ')) {
        gulikaKala = '${k.startTime} - ${k.endTime}';
      } else if (name.contains('abhijit') || name.contains('ಅಭಿಜಿತ್') || name.contains('abhijin')) {
        abhijit = '${k.startTime} - ${k.endTime}';
      }
    }

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
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // Purohit details (left-aligned)
                if (purohitDetails.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 100,
                      child: Text(purohitDetails,
                        style: const TextStyle(fontSize: 7, color: Color(0xFF666666), height: 1.3)),
                    ),
                  ),
                // Title (always centered)
                Column(children: [
                  Text('✦ ಭಾರತೀಯಮ್ ✦',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00)),
                    textAlign: TextAlign.center),
                  Text('ಪಂಚಾಂಗ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00)),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Container(height: 1.5, width: 110, color: const Color(0xFFFF6B00)),
                ]),
              ],
            ),
            const SizedBox(height: 8),

            // ── Date + Vara ──
            Builder(builder: (_) {
              final dt = DateTime.fromMillisecondsSinceEpoch(
                ((d.sunriseJd - 2440587.5) * 86400000).round(), isUtc: true,
              ).add(const Duration(hours: 5, minutes: 30));
              return Text(
                '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              );
            }),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(AppLocale.t(d.vara),
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
            const SizedBox(height: 3),
            _row('ಸಂವತ್ಸರ', AppLocale.t(d.samvatsara)),
            _row('ವಾರ', AppLocale.t(d.vara)),
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

            // ── Rahu Kala, Gulika Kala, Abhijit ──
            if (rahuKala.isNotEmpty || gulikaKala.isNotEmpty || abhijit.isNotEmpty) ...[
              _divider(),
              const SizedBox(height: 3),
              const Text('⚠ ಕಾಲ ಸಮಯ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))),
              const SizedBox(height: 3),
              if (rahuKala.isNotEmpty) _kalaRow('ರಾಹು ಕಾಲ', rahuKala, Colors.red),
              if (gulikaKala.isNotEmpty) _kalaRow('ಗುಳಿಕ ಕಾಲ', gulikaKala, Colors.red),
              if (abhijit.isNotEmpty) _kalaRow('ಅಭಿಜಿತ್ ಮುಹೂರ್ತ', abhijit, Colors.green),
            ],

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

            // ── Shraddha Nirnaya ──
            if (shraddha != null) ...[
              _divider(),
              const SizedBox(height: 3),
              const Text('🪔 ಶ್ರಾದ್ಧ ನಿರ್ಣಯ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))),
              const SizedBox(height: 2),
              Text('ನಿಯಮ: ${shraddha!.ruleText.isNotEmpty ? shraddha!.ruleText : "ಶ್ರಾದ್ಧ ತಿಥಿ ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇರಬೇಕು"}',
                style: TextStyle(fontSize: 7, color: Colors.grey[600], fontStyle: FontStyle.italic)),
              const SizedBox(height: 4),
              // Kutupa Kala
              Text('ಕುತುಪ ಕಾಲ: ${shraddha!.aparahnaStart} — ${shraddha!.aparahnaEnd}  (${shraddha!.aparahnaStartGhati})',
                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              const SizedBox(height: 2),
              // Aparahna
              Text('ಅಪರಾಹ್ಣ: ${shraddha!.aparahnaTimeStart} — ${shraddha!.aparahnaTimeEnd}',
                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              const SizedBox(height: 2),
              // Tithi end
              if (shraddha!.sunriseTithiName.isNotEmpty)
                Text('${shraddha!.sunriseTithiName} ತಿಥಿ ಅಂತ್ಯ: ${shraddha!.tithiEndTimeForRule}',
                  style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              const SizedBox(height: 4),
              // Tithi in Kutupa check
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                decoration: BoxDecoration(
                  color: shraddha!.isTithiPresentAtAparahna ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  shraddha!.tithiStatusAtAparahna.isNotEmpty
                    ? '☑ ${shraddha!.tithiStatusAtAparahna}'
                    : (shraddha!.isTithiPresentAtAparahna
                      ? '☑ ${shraddha!.sunriseTithiName} — ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ'
                      : '☐ ${shraddha!.sunriseTithiName} — ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇಲ್ಲ'),
                  style: TextStyle(
                    fontSize: 8, fontWeight: FontWeight.bold,
                    color: shraddha!.isTithiPresentAtAparahna ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Amanta
              if (shraddha!.varshikaChandraAmanta.isNotEmpty)
                Row(children: [
                  Text('⚠️ ', style: TextStyle(fontSize: 8)),
                  Text('ಅಮಾಂತ: ', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Color(0xFF795548))),
                  Expanded(child: Text(shraddha!.varshikaChandraAmanta,
                    style: TextStyle(fontSize: 7.5, color: Color(0xFF333333)))),
                ]),
              const SizedBox(height: 2),
              // Pournimanta
              if (shraddha!.varshikaChandraPournimanta.isNotEmpty)
                Row(children: [
                  Text('⚠️ ', style: TextStyle(fontSize: 8)),
                  Text('ಪೌರ್ಣಿಮಾಂತ: ', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Color(0xFF795548))),
                  Expanded(child: Text(shraddha!.varshikaChandraPournimanta,
                    style: TextStyle(fontSize: 7.5, color: Color(0xFF333333)))),
                ]),
              const SizedBox(height: 2),
              // Sauramana
              if (shraddha!.varshikaSoura.isNotEmpty)
                Row(children: [
                  Text('⚠️ ', style: TextStyle(fontSize: 8)),
                  Text('ಸೌರಮಾನ: ', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Color(0xFF795548))),
                  Expanded(child: Text(shraddha!.varshikaSoura,
                    style: TextStyle(fontSize: 7.5, color: Color(0xFF333333)))),
                ]),
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

  Widget _kalaRow(String label, String time, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(children: [
        Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 8.5, color: Color(0xFF666666)))),
        Expanded(child: Text(time, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF333333)))),
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
