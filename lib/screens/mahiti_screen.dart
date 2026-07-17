/// Mahiti (Info) Screen — Astronomical information: Grahana, Guru/Shukra Asta, etc.
import 'package:flutter/material.dart';
import '../core/asta_calculator.dart';
import '../widgets/common.dart';

class MahitiScreen extends StatefulWidget {
  const MahitiScreen({super.key});

  @override
  State<MahitiScreen> createState() => _MahitiScreenState();
}

class _MahitiScreenState extends State<MahitiScreen> {
  List<AstaPeriod> _guruAsta = [];
  List<AstaPeriod> _shukraAsta = [];
  bool _loading = true;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _computeAsta();
  }

  Future<void> _computeAsta() async {
    setState(() => _loading = true);
    await Future.delayed(Duration.zero); // Allow UI to render loading
    try {
      final guru = AstaCalculator.calculateGuruAsta(_year);
      final shukra = AstaCalculator.calculateShukraAsta(_year);
      if (mounted) {
        setState(() {
          _guruAsta = guru;
          _shukraAsta = shukra;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      debugPrint('Asta calc error: $e');
    }
  }

  void _changeYear(int delta) {
    _year += delta;
    _computeAsta();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Year selector
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: kGold, size: 22),
                const SizedBox(width: 8),
                Text('ಮಾಹಿತಿ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGold)),
                const Spacer(),
                // Year selector
                IconButton(
                  icon: Icon(Icons.chevron_left, color: kGold, size: 20),
                  onPressed: () => _changeYear(-1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                Text('$_year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold)),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: kGold, size: 20),
                  onPressed: () => _changeYear(1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),

          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ))
          else ...[
            // ── Guru Asta (Jupiter Combustion) ──
            _buildAstaSection(
              icon: Icons.brightness_7_rounded,
              title: 'ಗುರು ಅಸ್ತ (Jupiter Combustion)',
              color: const Color(0xFFFF9800),
              planetEmoji: '🪐',
              planetName: 'ಗುರು',
              limitDeg: '9°',
              periods: _guruAsta,
              warnings: const [
                '⚠️ ಗುರು ಅಸ್ತ ಸಮಯದಲ್ಲಿ:',
                '   • ಶುಭ ಕಾರ್ಯಗಳನ್ನು ಮಾಡಬಾರದು',
                '   • ವಿವಾಹ, ಉಪನಯನ ನಿಷೇಧ',
                '   • ಗೃಹ ಪ್ರವೇಶ ಮಾಡಬಾರದು',
              ],
            ),

            // ── Shukra Asta (Venus Combustion) ──
            _buildAstaSection(
              icon: Icons.brightness_5_rounded,
              title: 'ಶುಕ್ರ ಅಸ್ತ (Venus Combustion)',
              color: const Color(0xFFAB47BC),
              planetEmoji: '💎',
              planetName: 'ಶುಕ್ರ',
              limitDeg: '6.6°',
              periods: _shukraAsta,
              warnings: const [
                '⚠️ ಶುಕ್ರ ಅಸ್ತ ಸಮಯದಲ್ಲಿ:',
                '   • ವಿವಾಹ ನಿಷೇಧ',
                '   • ಶುಭ ಕಾರ್ಯಗಳಿಗೆ ಅಶುಭ',
                '   • ಹೊಸ ವಸ್ತು ಖರೀದಿ ಮಾಡಬಾರದು',
              ],
            ),

            // ── Grahana (Eclipses) ──
            _InfoSection(
              icon: Icons.dark_mode_rounded,
              title: 'ಗ್ರಹಣ (Eclipses)',
              color: const Color(0xFFE53935),
              items: const [
                _InfoItem(
                  title: 'ಸೂರ್ಯ ಗ್ರಹಣ — 2026',
                  details: [
                    '🌑 ಫೆಬ್ರವರಿ 17, 2026 — ಕಂಕಣ ಸೂರ್ಯ ಗ್ರಹಣ',
                    '   ⏰ ಸ್ಪರ್ಶ: 12:52 PM IST',
                    '   ⏰ ಮಧ್ಯ: 02:24 PM IST',
                    '   ⏰ ಮೋಕ್ಷ: 03:56 PM IST',
                    '   📍 ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಹೌದು (ಭಾಗಶಃ)',
                    '',
                    '🌑 ಆಗಸ್ಟ್ 12, 2026 — ಪೂರ್ಣ ಸೂರ್ಯ ಗ್ರಹಣ',
                    '   ⏰ ಸ್ಪರ್ಶ: 11:17 PM IST',
                    '   📍 ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಇಲ್ಲ',
                  ],
                ),
                _InfoItem(
                  title: 'ಚಂದ್ರ ಗ್ರಹಣ — 2026',
                  details: [
                    '🌕 ಮಾರ್ಚ್ 03, 2026 — ಪೂರ್ಣ ಚಂದ್ರ ಗ್ರಹಣ',
                    '   ⏰ ಸ್ಪರ್ಶ: 09:20 PM IST',
                    '   ⏰ ಗ್ರಾಸ: 10:39 PM IST',
                    '   ⏰ ಮಧ್ಯ: 11:33 PM IST',
                    '   ⏰ ಮೋಕ್ಷ: 01:47 AM IST (ಮರುದಿನ)',
                    '   📍 ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಹೌದು (ಪೂರ್ಣ)',
                    '',
                    '🌕 ಆಗಸ್ಟ್ 28, 2026 — ಭಾಗಶಃ ಚಂದ್ರ ಗ್ರಹಣ',
                    '   ⏰ ಸ್ಪರ್ಶ: 07:35 AM IST',
                    '   📍 ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಇಲ್ಲ',
                  ],
                ),
              ],
            ),

            // ── Adhika Masa ──
            _InfoSection(
              icon: Icons.add_circle_outline_rounded,
              title: 'ಅಧಿಕ ಮಾಸ (Leap Month)',
              color: const Color(0xFF26A69A),
              items: const [
                _InfoItem(
                  title: 'ಅಧಿಕ ಮಾಸ ವಿವರ',
                  details: [
                    'ℹ️ ಅಧಿಕ ಮಾಸ ಎಂದರೆ:',
                    '   • ಎರಡು ಅಮಾವಾಸ್ಯೆಗಳ ನಡುವೆ ಸಂಕ್ರಾಂತಿ ಇಲ್ಲದಿದ್ದರೆ',
                    '   • ಆ ಮಾಸವನ್ನು ಅಧಿಕ ಮಾಸ ಎಂದು ಕರೆಯುತ್ತಾರೆ',
                    '   • ಅಧಿಕ ಮಾಸದಲ್ಲಿ ಶುಭ ಕಾರ್ಯ ಮಾಡಬಾರದು',
                    '   • ದಾನ, ಜಪ, ತಪಸ್ಸಿಗೆ ವಿಶೇಷ ಫಲ',
                  ],
                ),
              ],
            ),

            // ── Kshaya Masa ──
            _InfoSection(
              icon: Icons.remove_circle_outline_rounded,
              title: 'ಕ್ಷಯ ಮಾಸ (Lost Month)',
              color: const Color(0xFFEF5350),
              items: const [
                _InfoItem(
                  title: 'ಕ್ಷಯ ಮಾಸ ವಿವರ',
                  details: [
                    'ℹ️ ಕ್ಷಯ ಮಾಸ ಎಂದರೆ:',
                    '   • ಎರಡು ಅಮಾವಾಸ್ಯೆಗಳ ನಡುವೆ ಎರಡು ಸಂಕ್ರಾಂತಿ ಬಂದರೆ',
                    '   • ಒಂದು ಮಾಸ ಕ್ಷಯವಾಗುತ್ತದೆ (ಬಿಡುತ್ತದೆ)',
                    '   • ಇದು ಬಹಳ ಅಪರೂಪ (19-141 ವರ್ಷಕ್ಕೊಮ್ಮೆ)',
                  ],
                ),
              ],
            ),

            // ── Uttarayana / Dakshinayana ──
            _InfoSection(
              icon: Icons.swap_vert_rounded,
              title: 'ಅಯನ (Solstice)',
              color: const Color(0xFF42A5F5),
              items: const [
                _InfoItem(
                  title: 'ಅಯನ ವಿವರ',
                  details: [
                    'ℹ️ ಉತ್ತರಾಯಣ = ಶುಭ ಕಾಲ (ದೇವರ ಹಗಲು)',
                    '   • ಮಕರ ಸಂಕ್ರಾಂತಿಯಿಂದ ಕರ್ಕ ಸಂಕ್ರಾಂತಿಯವರೆಗೆ',
                    '',
                    'ℹ️ ದಕ್ಷಿಣಾಯನ = ಪಿತೃ ಕಾಲ (ದೇವರ ರಾತ್ರಿ)',
                    '   • ಕರ್ಕ ಸಂಕ್ರಾಂತಿಯಿಂದ ಮಕರ ಸಂಕ್ರಾಂತಿಯವರೆಗೆ',
                  ],
                ),
              ],
            ),

            // ── Shraddha Niyama ──
            _InfoSection(
              icon: Icons.self_improvement_rounded,
              title: 'ಶ್ರಾದ್ಧ ನಿಯಮ',
              color: const Color(0xFFFFD54F),
              items: const [
                _InfoItem(
                  title: 'ಶ್ರಾದ್ಧ ನಿಯಮಗಳು',
                  details: [
                    '📜 ಕುತುಪ ಕಾಲ:',
                    '   • 15 ಮುಹೂರ್ತಗಳಲ್ಲಿ 8ನೇ ಮುಹೂರ್ತ',
                    '   • ಶ್ರಾದ್ಧ ತಿಥಿ ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇರಬೇಕು',
                    '',
                    '📜 ದ್ವಿತೀಯಾ ಶ್ರಾದ್ಧ ನಿಯಮ:',
                    '   • ತಿಥಿ ಎರಡು ದಿನ ಕುತುಪದಲ್ಲಿ ಇದ್ದರೆ → ಪ್ರಥಮ ದಿನ',
                    '',
                    '📜 ಕ್ಷಯೇ ಪೂರ್ವ:',
                    '   • ಕ್ಷಯ ತಿಥಿ (ಕುತುಪ ಕಾಲ ಎರಡು ದಿನವೂ ಇಲ್ಲ)',
                    '   • ಪ್ರಥಮ ದಿನ (ಹಿಂದಿನ ದಿನ) ಶ್ರಾದ್ಧ ಮಾಡಬೇಕು',
                    '',
                    '📜 ಅಪರಾಹ್ನ ಕಾಲ:',
                    '   • ಹಗಲಿನ 5 ಭಾಗಗಳಲ್ಲಿ 4ನೇ ಭಾಗ',
                    '   • ಶ್ರಾದ್ಧ ಅಪರಾಹ್ನ ಕಾಲದಲ್ಲಿ ಮಾಡಬೇಕು',
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  /// Build dynamic Asta section from calculated periods
  Widget _buildAstaSection({
    required IconData icon,
    required String title,
    required Color color,
    required String planetEmoji,
    required String planetName,
    required String limitDeg,
    required List<AstaPeriod> periods,
    required List<String> warnings,
  }) {
    final details = <String>[];

    if (periods.isEmpty) {
      details.add('✅ $_year ರಲ್ಲಿ $planetName ಅಸ್ತ ಇಲ್ಲ');
    } else {
      for (int i = 0; i < periods.length; i++) {
        final p = periods[i];
        final days = AstaCalculator.durationDays(p);
        details.add('$planetEmoji $planetName ಅಸ್ತ (ಸೂರ್ಯನಿಂದ $limitDeg ಒಳಗೆ):');
        details.add('   📅 ${AstaCalculator.formatDate(p.start)} — ${AstaCalculator.formatDate(p.end)}');
        details.add('   📍 ${ p.rashi} ರಾಶಿ');
        details.add('   ⏱️ $days ದಿನಗಳು');
        if (i < periods.length - 1) details.add('');
      }
      details.add('');
      details.addAll(warnings);
    }

    // Check if currently in asta
    final now = DateTime.now();
    bool isCurrentlyAsta = false;
    for (final p in periods) {
      if (now.isAfter(p.start) && now.isBefore(p.end)) {
        isCurrentlyAsta = true;
        break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCard.withAlpha(178),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCurrentlyAsta ? color : color.withAlpha(60), width: isCurrentlyAsta ? 1.5 : 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
          leading: Icon(icon, color: color, size: 20),
          title: Row(
            children: [
              Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color))),
              if (isCurrentlyAsta)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withAlpha(80)),
                  ),
                  child: Text('ಈಗ ಅಸ್ತ', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
                ),
            ],
          ),
          iconColor: color,
          collapsedIconColor: color.withAlpha(150),
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withAlpha(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$planetName ಅಸ್ತ $_year', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kText)),
                  const SizedBox(height: 6),
                  ...details.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontSize: 10,
                        color: line.startsWith('⚠') ? kAshubha : kMuted,
                        fontWeight: line.startsWith('⚠') ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Info Section (Expandable) ───

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCard.withAlpha(178),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
          leading: Icon(icon, color: color, size: 20),
          title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          iconColor: color,
          collapsedIconColor: color.withAlpha(150),
          children: items.map((item) => _buildInfoItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoItem(_InfoItem item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 6),
          ...item.details.map((line) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 10,
                color: line.startsWith('⚠') ? kAshubha : kMuted,
                fontWeight: line.startsWith('⚠') ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String title;
  final List<String> details;

  const _InfoItem({required this.title, required this.details});
}
