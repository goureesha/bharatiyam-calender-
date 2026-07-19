/// Mahiti (Info) Screen — Astronomical information: Grahana, Guru/Shukra Asta, etc.
import 'package:flutter/material.dart';
import '../core/asta_calculator.dart';
import '../core/adhika_masa_calculator.dart';
import '../core/grahana_calculator.dart';
import '../widgets/common.dart';

class MahitiScreen extends StatefulWidget {
  const MahitiScreen({super.key});

  @override
  State<MahitiScreen> createState() => _MahitiScreenState();
}

class _MahitiScreenState extends State<MahitiScreen> {
  List<AstaPeriod> _guruAsta = [];
  List<AstaPeriod> _shukraAsta = [];
  List<MasaPeriodInfo> _masaPeriods = [];
  List<GrahanaInfo> _grahanas = [];
  bool _loading = true;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _computeAsta();
  }

  Future<void> _computeAsta() async {
    setState(() => _loading = true);
    await Future.delayed(Duration.zero);
    try {
      final guru = AstaCalculator.calculateGuruAsta(_year);
      final shukra = AstaCalculator.calculateShukraAsta(_year);
      final masas = AdhikaMasaCalculator.calculateForYear(_year);
      final grahanas = GrahanaCalculator.calculateForYear(_year);
      if (mounted) {
        setState(() {
          _guruAsta = guru;
          _shukraAsta = shukra;
          _masaPeriods = masas;
          _grahanas = grahanas;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      debugPrint('Mahiti calc error: $e');
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

            // ── Grahana (Eclipses — Dynamic) ──
            _buildGrahanaSection(),

            // ── Adhika / Kshaya Masa (Dynamic) ──
            _buildMasaSection(),

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

  /// Build dynamic Adhika/Kshaya Masa section
  /// Build dynamic Grahana (Eclipse) section
  Widget _buildGrahanaSection() {
    const color = Color(0xFFE53935);
    final suryaGrahanas = _grahanas.where((g) => g.type == GrahanaType.surya).toList();
    final chandraGrahanas = _grahanas.where((g) => g.type == GrahanaType.chandra).toList();

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
          leading: Icon(Icons.dark_mode_rounded, color: color, size: 20),
          title: Text('ಗ್ರಹಣ (Eclipses) $_year', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          iconColor: color,
          collapsedIconColor: color.withAlpha(150),
          children: [
            if (_grahanas.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withAlpha(30)),
                ),
                child: Text('✅ $_year ರಲ್ಲಿ ಗ್ರಹಣ ಇಲ್ಲ', style: TextStyle(fontSize: 11, color: kMuted)),
              )
            else ...[
              // Solar eclipses
              if (suryaGrahanas.isNotEmpty)
                ...suryaGrahanas.map((g) => _buildEclipseCard(g, '🌑')),
              // Lunar eclipses
              if (chandraGrahanas.isNotEmpty)
                ...chandraGrahanas.map((g) => _buildEclipseCard(g, '🌕')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEclipseCard(GrahanaInfo g, String emoji) {
    const color = Color(0xFFE53935);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: g.visibleInIndia ? color.withAlpha(60) : color.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text('$emoji ${g.summary}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: g.visibleInIndia ? color : kMuted)),
          const SizedBox(height: 6),
          // Phases
          ...g.phases.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text('   ⏰ ${p.name}: ${p.time}', style: TextStyle(fontSize: 10, color: kMuted)),
          )),
          const SizedBox(height: 4),
          // Moon latitude
          Text('   🌙 ಚಂದ್ರ ಅಕ್ಷಾಂಶ: ${g.moonLatitude.toStringAsFixed(3)}°', style: TextStyle(fontSize: 9, color: kMuted)),
          // Magnitude
          Text('   📏 ಪ್ರಮಾಣ: ${(g.magnitude * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 9, color: kMuted)),
          // Duration
          Text('   ⏱️ ಅವಧಿ: ${g.durationText} (${g.totalDurationMin} ನಿಮಿಷ)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 4),
          // Visibility
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: g.visibleInIndia ? const Color(0xFF388E3C).withAlpha(15) : kMuted.withAlpha(15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: g.visibleInIndia ? const Color(0xFF388E3C).withAlpha(40) : kMuted.withAlpha(30)),
            ),
            child: Text('📍 ${g.visibilityNote}',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                color: g.visibleInIndia ? const Color(0xFF388E3C) : kMuted)),
          ),
        ],
      ),
    );
  }

  Widget _buildMasaSection() {
    final adhikaPeriods = _masaPeriods.where((m) => m.masaType == 'adhika').toList();
    final kshayaPeriods = _masaPeriods.where((m) => m.masaType == 'kshaya').toList();
    final hasAdhika = adhikaPeriods.isNotEmpty;
    final hasKshaya = kshayaPeriods.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCard.withAlpha(178),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF26A69A).withAlpha(60)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
          leading: Icon(Icons.calendar_month_outlined, color: const Color(0xFF26A69A), size: 20),
          title: Text(
            'ಅಧಿಕ / ಕ್ಷಯ ಮಾಸ  $_year',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF26A69A)),
          ),
          iconColor: const Color(0xFF26A69A),
          collapsedIconColor: const Color(0xFF26A69A).withAlpha(150),
          children: [
            // Summary
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF26A69A).withAlpha(10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF26A69A).withAlpha(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasAdhika) ...[
                    Text('✨ ಅಧಿಕ ಮಾಸ (Leap Month)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF26A69A))),
                    const SizedBox(height: 4),
                    ...adhikaPeriods.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('   📅 ಅಧಿಕ ${p.masaName}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kText)),
                          Text('   📆 ${AdhikaMasaCalculator.formatDateFull(p.amavasya1)} — ${AdhikaMasaCalculator.formatDateFull(p.amavasya2)}',
                            style: TextStyle(fontSize: 10, color: kMuted)),
                          Text('   ⚡ ಸಂಕ್ರಾಂತಿ: ಈ ಅವಧಿಯಲ್ಲಿ ಯಾವ ಸಂಕ್ರಾಂತಿಯೂ ಇಲ್ಲ',
                            style: TextStyle(fontSize: 10, color: kMuted)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 6),
                  ] else ...[
                    Text('✅ $_year ರಲ್ಲಿ ಅಧಿಕ ಮಾಸ ಇಲ್ಲ', style: TextStyle(fontSize: 11, color: kMuted)),
                    const SizedBox(height: 6),
                  ],

                  if (hasKshaya) ...[
                    Text('⚠️ ಕ್ಷಯ ಮಾಸ (Lost Month)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kAshubha)),
                    const SizedBox(height: 4),
                    ...kshayaPeriods.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('   📅 ಕ್ಷಯ ${p.masaName}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kAshubha)),
                          Text('   📆 ${AdhikaMasaCalculator.formatDateFull(p.amavasya1)} — ${AdhikaMasaCalculator.formatDateFull(p.amavasya2)}',
                            style: TextStyle(fontSize: 10, color: kMuted)),
                          Text('   ⚡ ಎರಡು ಸಂಕ್ರಾಂತಿ: ${p.sankrantiDetails.join(", ")}',
                            style: TextStyle(fontSize: 10, color: kMuted)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 6),
                  ] else ...[
                    Text('✅ $_year ರಲ್ಲಿ ಕ್ಷಯ ಮಾಸ ಇಲ್ಲ', style: TextStyle(fontSize: 11, color: kMuted)),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),

            // Full masa table
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kBg.withAlpha(100),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorder.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📋 ಮಾಸ ಪಟ್ಟಿ $_year', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kText)),
                  const SizedBox(height: 8),
                  ..._masaPeriods.map((p) {
                    final isAdhika = p.masaType == 'adhika';
                    final isKshaya = p.masaType == 'kshaya';
                    final color = isAdhika ? const Color(0xFF26A69A)
                        : isKshaya ? kAshubha
                        : kMuted;
                    final prefix = isAdhika ? 'ಅಧಿಕ ' : isKshaya ? 'ಕ್ಷಯ ' : '';
                    final badge = isAdhika ? ' ✨' : isKshaya ? ' ⚠️' : '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isAdhika || isKshaya ? color.withAlpha(15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isAdhika || isKshaya
                            ? Border.all(color: color.withAlpha(40))
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              '$prefix${p.masaName}$badge',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isAdhika || isKshaya ? FontWeight.bold : FontWeight.normal,
                                color: isAdhika || isKshaya ? color : kText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${_shortDate(p.amavasya1)} — ${_shortDate(p.amavasya2)}',
                              style: TextStyle(fontSize: 9, color: kMuted),
                            ),
                          ),
                          Text(
                            '${p.sankrantiCount} ಸಂ',
                            style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(DateTime dt) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[dt.month]} ${dt.day}';
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
