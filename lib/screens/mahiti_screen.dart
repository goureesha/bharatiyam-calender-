/// Mahiti (Info) Screen — Astronomical information: Grahana, Guru/Shukra Asta, Events, etc.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../i18n/app_locale.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/asta_calculator.dart';
import '../core/adhika_masa_calculator.dart';
import '../core/grahana_calculator.dart';
import '../core/panchanga_calculator.dart';
import '../core/masa_calculator.dart';
import '../core/sankalpa_generator.dart';
import '../services/ad_service.dart';
import '../core/ephemeris.dart';
import '../core/events.dart';
import '../models/panchanga_data.dart';
import '../services/location_service.dart';
import '../services/panchanga_cache.dart';
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
  List<DateTime> _purnimas = [];
  List<Map<String, dynamic>> _sankrantis = [];
  List<GrahanaInfo> _grahanas = []; // Grahana section hidden for now
  Map<String, List<DateTime>> _yearEvents = {};
  bool _loading = true;
  bool _eventsLoading = false;
  int _eventsProgress = 0; // 0-12 months done
  int _year = DateTime.now().year;
  String? _selectedKarya;
  bool _sankalpaExpanded = false;

  @override
  void initState() {
    super.initState();
    _computeAsta();
  }

  Future<void> _computeAsta() async {
    setState(() => _loading = true);
    await Future.delayed(Duration.zero);
    try {
      // Fast calculations — show immediately
      final guru = AstaCalculator.calculateGuruAsta(_year);
      final shukra = AstaCalculator.calculateShukraAsta(_year);
      final masas = AdhikaMasaCalculator.calculateForYear(_year);
      final purnimas = AdhikaMasaCalculator.findAllPurnimas(_year);
      final sankrantis = AdhikaMasaCalculator.findAllSankrantisForYear(_year);

      if (mounted) {
        setState(() {
          _guruAsta = guru;
          _shukraAsta = shukra;
          _masaPeriods = masas;
          _purnimas = purnimas;
          _sankrantis = sankrantis;
          _loading = false;
        });
      }

      // Slow event computation — runs in background
      _computeYearEvents();
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      debugPrint('Mahiti calc error: $e');
    }
  }

  Future<void> _computeYearEvents() async {
    setState(() { _eventsLoading = true; _eventsProgress = 0; _yearEvents = {}; });

    // Try loading from local cache first
    final cacheKey = _year;
    final cached = await _loadEventsCache(cacheKey);
    if (cached != null && mounted) {
      setState(() {
        _yearEvents = cached;
        _eventsLoading = false;
        _eventsProgress = 12;
      });
      debugPrint('Loaded $_year events from cache (${cached.length} events)');
      return;
    }

    // Compute fresh — January to December
    final cache = PanchangaCache();
    final now = DateTime.now();
    final yearEvents = <String, List<DateTime>>{};
    int monthsDone = 0;

    for (int m = 1; m <= 12; m++) {
      final y = _year;
      final dim = DateUtils.getDaysInMonth(y, m);
      final useCache = cache.isInitialized && y >= now.year - 1 && y <= now.year + 1;
      for (int d = 1; d <= dim; d++) {
        if (!mounted) return;
        try {
          List<AstroEvent> dayEvents;
          if (useCache) {
            dayEvents = cache.getEvents(y, m, d);
          } else {
            final data = PanchangaCalculator.calculate(
              year: y, month: m, day: d,
              lat: LocationService.lat, lon: LocationService.lon,
              tzOffset: LocationService.tzOffset,
            );
            final amanta = MasaCalculator.calculateAmanta(
              jdSunrise: data.sunriseJd,
              lat: LocationService.lat, lon: LocationService.lon,
              tzOffset: LocationService.tzOffset,
            );
            final masaKey = amanta['masa'] as String;
            final isAdhika = amanta['isAdhika'] as bool;
            final masaName = EventCalculator.masaKeyToKannada(masaKey);
            final sunsetTithi = PanchangaCalculator.tithiAtJd(data.sunsetJd);
            int? prevTithi, nextTithi;
            try { prevTithi = PanchangaCalculator.tithiAtJd(data.sunriseJd - 1.0); } catch (_) {}
            try { nextTithi = PanchangaCalculator.tithiAtJd(data.sunriseJd + 1.0); } catch (_) {}
            int? moonriseTithi;
            try {
              final mr = Ephemeris.findMoonriseSet(y, m, d, LocationService.lat, LocationService.lon, LocationService.tzOffset);
              if (mr[0] != null) moonriseTithi = PanchangaCalculator.tithiAtJd(mr[0]!);
            } catch (_) {}
            int? noonTithi;
            try { noonTithi = PanchangaCalculator.tithiAtJd((data.sunriseJd + data.sunsetJd) / 2); } catch (_) {}
            int? midnightTithi;
            try { midnightTithi = PanchangaCalculator.tithiAtJd(data.sunsetJd + 0.25); } catch (_) {}
            dayEvents = EventCalculator.getEvents(
              masa: masaName, tIdx: data.tithiIndex,
              sunsetTithiIdx: sunsetTithi,
              nextDayTithiIdx: nextTithi,
              prevDayTithiIdx: prevTithi,
              moonriseTithiIdx: moonriseTithi,
              noonTithiIdx: noonTithi,
              midnightTithiIdx: midnightTithi,
              varaIndex: data.varaIndex,
              isAdhika: isAdhika,
            );
          }
          for (final ev in dayEvents) {
            yearEvents.putIfAbsent(ev.name, () => []);
            yearEvents[ev.name]!.add(DateTime(y, m, d));
          }
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 1));
      }
      monthsDone++;
      if (mounted) {
        setState(() {
          _eventsProgress = monthsDone;
          _yearEvents = Map.from(yearEvents);
        });
      }
    }

    if (mounted) {
      setState(() {
        _yearEvents = yearEvents;
        _eventsLoading = false;
      });
    }

    // Save to cache for next time
    _saveEventsCache(cacheKey, yearEvents);
  }

  /// Get cache file path for a year
  static Future<File> _cacheFile(int year) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/events_cache_$year.json');
  }

  /// Load events from local cache file
  static Future<Map<String, List<DateTime>>?> _loadEventsCache(int year) async {
    try {
      final file = await _cacheFile(year);
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final result = <String, List<DateTime>>{};
      for (final entry in json.entries) {
        result[entry.key] = (entry.value as List)
            .map((s) => DateTime.parse(s as String))
            .toList();
      }
      return result;
    } catch (e) {
      debugPrint('Events cache load error: $e');
      return null;
    }
  }

  /// Save events to local cache file
  static Future<void> _saveEventsCache(int year, Map<String, List<DateTime>> events) async {
    try {
      final file = await _cacheFile(year);
      final json = <String, dynamic>{};
      for (final entry in events.entries) {
        json[entry.key] = entry.value.map((d) => d.toIso8601String()).toList();
      }
      await file.writeAsString(jsonEncode(json));
      debugPrint('Events cache saved for $year (${events.length} events)');
    } catch (e) {
      debugPrint('Events cache save error: $e');
    }
  }

  /// Build the Maha Sankalpa section
  Widget _buildSankalpaSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () {
              if (!_sankalpaExpanded) {
                // Show interstitial ad when opening Maha Sankalpa
                AdService.showInterstitial(onAdDismissed: () {
                  if (mounted) setState(() => _sankalpaExpanded = true);
                });
              } else {
                setState(() => _sankalpaExpanded = false);
              }
            },
            child: Row(
              children: [
                Text('🙏', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(AppLocale.t('mahaSankalpa'), style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: kGold)),
                ),
                Icon(
                  _sankalpaExpanded ? Icons.expand_less : Icons.expand_more,
                  color: kGold, size: 24,
                ),
              ],
            ),
          ),

          if (_sankalpaExpanded) ...[
            const SizedBox(height: 12),

            // Vishesha Sankalpa dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kBg, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedKarya,
                  hint: Text(AppLocale.t('selectVisheshaSankalpa'), style: TextStyle(color: kMuted, fontSize: 13)),
                  isExpanded: true,
                  dropdownColor: kCard,
                  style: TextStyle(color: kText, fontSize: 13),
                  items: SankalpaGenerator.karyaNames.map((k) =>
                    DropdownMenuItem(value: k, child: Text(AppLocale.transliterate(k))),
                  ).toList(),
                  onChanged: (v) => setState(() => _selectedKarya = v),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sankalpa text
            Builder(builder: (_) {
              final today = DateTime.now();
              PanchangaData? data;
              String masaName = '';
              try {
                data = PanchangaCalculator.calculate(
                  year: today.year, month: today.month, day: today.day,
                  lat: LocationService.lat, lon: LocationService.lon,
                  tzOffset: LocationService.tzOffset,
                );
                final amanta = MasaCalculator.calculateAmanta(
                  jdSunrise: data.sunriseJd,
                  lat: LocationService.lat, lon: LocationService.lon,
                  tzOffset: LocationService.tzOffset,
                );
                masaName = EventCalculator.masaKeyToKannada(amanta['masa'] as String);
              } catch (_) {}

              if (data == null) {
                return Text(AppLocale.t('panchaangaDataUnavailable'), style: TextStyle(color: kMuted));
              }

              final sankalpaText = SankalpaGenerator.generate(
                data: data,
                masaName: masaName,
                date: today,
                visheshaSankalpa: _selectedKarya,
              );

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kGold.withAlpha(76)),
                ),
                child: SelectableText(
                  AppLocale.transliterate(sankalpaText),
                  style: TextStyle(
                    fontSize: 14, color: const Color(0xFFFFE0B2),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),

            // Copy & Share buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text = _getSankalpaText();
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocale.t('sankalpaCopied')), duration: Duration(seconds: 2)),
                      );
                    },
                    icon: Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                    label: Text(AppLocale.t('copy'), style: TextStyle(color: Colors.white, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold.withAlpha(180),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text = _getSankalpaText();
                      Share.share(text, subject: 'ಮಹಾ ಸಂಕಲ್ಪ');
                    },
                    icon: Icon(Icons.share_rounded, size: 16, color: Colors.white),
                    label: Text(AppLocale.t('share'), style: TextStyle(color: Colors.white, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold.withAlpha(180),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getSankalpaText() {
    final today = DateTime.now();
    try {
      final data = PanchangaCalculator.calculate(
        year: today.year, month: today.month, day: today.day,
        lat: LocationService.lat, lon: LocationService.lon,
        tzOffset: LocationService.tzOffset,
      );
      final amanta = MasaCalculator.calculateAmanta(
        jdSunrise: data.sunriseJd,
        lat: LocationService.lat, lon: LocationService.lon,
        tzOffset: LocationService.tzOffset,
      );
      final masaName = EventCalculator.masaKeyToKannada(amanta['masa'] as String);
      return SankalpaGenerator.generate(
        data: data, masaName: masaName, date: today,
        visheshaSankalpa: _selectedKarya,
      );
    } catch (_) {
      return '';
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
                Text(AppLocale.t('mahiti'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGold)),
                const Spacer(),
                // Year selector
                IconButton(
                  icon: Icon(Icons.chevron_left, color: kGold, size: 20),
                  onPressed: () => _changeYear(-1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                Column(
                  children: [
                    Text('$_year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold)),
                    Text(SankalpaGenerator.getSamvatsara(_year, 4), style: TextStyle(fontSize: 11, color: kGold.withAlpha(180))),
                  ],
                ),
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
            // ── Maha Sankalpa ──
            _buildSankalpaSection(),
            const SizedBox(height: 12),

            // ── Guru Asta (Jupiter Combustion) ──
            _buildAstaSection(
              icon: Icons.brightness_7_rounded,
              title: '${AppLocale.t('guruAsta')} (Jupiter Combustion)',
              color: const Color(0xFFFF9800),
              planetEmoji: '🪐',
              planetName: AppLocale.t('guru'),
              limitDeg: '9°',
              periods: _guruAsta,
              warnings: [
                AppLocale.t('guruAstaWarnTitle'),
                AppLocale.t('guruAstaWarn1'),
                AppLocale.t('guruAstaWarn2'),
                AppLocale.t('guruAstaWarn3'),
              ],
            ),

            // ── Shukra Asta (Venus Combustion) ──
            _buildAstaSection(
              icon: Icons.brightness_5_rounded,
              title: '${AppLocale.t('shukraAsta')} (Venus Combustion)',
              color: const Color(0xFFAB47BC),
              planetEmoji: '💎',
              planetName: AppLocale.t('shukra'),
              limitDeg: '6.6°',
              periods: _shukraAsta,
              warnings: [
                AppLocale.t('shukraAstaWarnTitle'),
                AppLocale.t('shukraAstaWarn1'),
                AppLocale.t('shukraAstaWarn2'),
                AppLocale.t('shukraAstaWarn3'),
              ],
            ),

            // ── Grahana (Eclipses — Dynamic) — removed for now ──
            // _buildGrahanaSection(),

            // ── Masa Details (Start Dates) ──
            _buildMasaDetailsSection(),
            const SizedBox(height: 12),

            // ── Adhika / Kshaya Masa (Dynamic) ──
            _buildMasaSection(),

            // ── Events / Festivals ──
            _buildEventsSection(),

            // ── Uttarayana / Dakshinayana ──
            _InfoSection(
              icon: Icons.swap_vert_rounded,
              title: '${AppLocale.t('ayanaTitle')} (Solstice)',
              color: const Color(0xFF42A5F5),
              items: [
                _InfoItem(
                  title: AppLocale.t('ayanaDetails'),
                  details: [
                    AppLocale.t('uttarayanaDesc'),
                    AppLocale.t('uttarayanaPeriod'),
                    '',
                    AppLocale.t('dakshinayanaDesc'),
                    AppLocale.t('dakshinayanaPeriod'),
                  ],
                ),
              ],
            ),

            // ── Shraddha Niyama ──
            _InfoSection(
              icon: Icons.self_improvement_rounded,
              title: AppLocale.t('shraddhaNiyama'),
              color: const Color(0xFFFFD54F),
              items: [
                _InfoItem(
                  title: AppLocale.t('shraddhaNiyamagalu'),
                  details: [
                    AppLocale.t('kutupaKalaTitle'),
                    AppLocale.t('kutupaDesc1'),
                    AppLocale.t('kutupaDesc2'),
                    '',
                    AppLocale.t('dvitiyaShraddha'),
                    AppLocale.t('dvitiyaDesc'),
                    '',
                    AppLocale.t('kshayePurva'),
                    AppLocale.t('kshayeDesc1'),
                    AppLocale.t('kshayeDesc2'),
                    '',
                    AppLocale.t('aparahnaKalaTitle'),
                    AppLocale.t('aparahnaDesc1'),
                    AppLocale.t('aparahnaDesc2'),
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
      details.add('✅ $_year ${AppLocale.t('astaNoPresent')}');
    } else {
      for (int i = 0; i < periods.length; i++) {
        final p = periods[i];
        final days = AstaCalculator.durationDays(p);
        details.add('$planetEmoji $planetName ${AppLocale.t('astaInfo')} ($limitDeg):');
        details.add('   📅 ${AstaCalculator.formatDate(p.start)} — ${AstaCalculator.formatDate(p.end)}');
        details.add('   📍 ${AppLocale.trAll(p.rashi)} ${AppLocale.t('rashi')}');
        details.add('   ⏱️ $days ${AppLocale.t('dinagalu')}');
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
                  child: Text(AppLocale.t('nowAsta'), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
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
                  Text('$planetName ${AppLocale.t('astaYear')} $_year', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kText)),
                  const SizedBox(height: 6),
                  ...details.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      AppLocale.trAll(line),
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
          title: Text('${AppLocale.t('grahana')} (Eclipses) $_year', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
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
                child: Text('✅ $_year ${AppLocale.t('grahanaNoPresent')}', style: TextStyle(fontSize: 11, color: kMuted)),
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
          // Local viewing window
          if (g.indiaVisibleMin > 0) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withAlpha(12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF1565C0).withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📍 ${LocationService.cityNameKn} ಗೋಚರ ಸಮಯ:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1565C0))),
                  const SizedBox(height: 2),
                  Text('   ${g.indiaVisibleText}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kText)),
                ],
              ),
            ),
          ] else if (g.indiaVisibleText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('📍 ${LocationService.cityNameKn}: ${g.indiaVisibleText}', style: TextStyle(fontSize: 9, color: kMuted)),
          ],
        ],
      ),
    );
  }

  /// Build Masa Details section — start dates for Pournimanta, Amanta, Souramana
  Widget _buildMasaDetailsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCard.withAlpha(178),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withAlpha(60)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
          leading: Icon(Icons.date_range_rounded, color: kGold, size: 20),
          title: Text(
            '${AppLocale.t('masaVivara')} $_year',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kGold),
          ),
          iconColor: kGold,
          collapsedIconColor: kGold.withAlpha(150),
          children: [
            const SizedBox(height: 8),

            // ── Pournimanta (Purnima to Purnima) ──
            _masaSubTable(
              title: 'ಪೌರ್ಣಿಮಾಂತ ಮಾಸ',
              subtitle: 'ಪೂರ್ಣಿಮೆಯಿಂದ ಪೂರ್ಣಿಮೆ',
              icon: '🌕',
              color: const Color(0xFFFFB300),
              entries: _buildPournimantaEntries(),
            ),
            const SizedBox(height: 10),

            // ── Amanta (Amavasya to Amavasya) ──
            _masaSubTable(
              title: 'ಅಮಾಂತ ಮಾಸ',
              subtitle: 'ಅಮಾವಾಸ್ಯೆಯಿಂದ ಅಮಾವಾಸ್ಯೆ',
              icon: '🌑',
              color: const Color(0xFF7E57C2),
              entries: _buildAmantaEntries(),
            ),
            const SizedBox(height: 10),

            // ── Souramana (Sankranti to Sankranti) ──
            _masaSubTable(
              title: 'ಸೌರಮಾನ ಮಾಸ',
              subtitle: 'ಸಂಕ್ರಾಂತಿಯಿಂದ ಸಂಕ್ರಾಂತಿ',
              icon: '☀️',
              color: const Color(0xFFFF7043),
              entries: _buildSouramanaEntries(),
            ),
          ],
        ),
      ),
    );
  }

  List<_MasaEntry> _buildPournimantaEntries() {
    if (_purnimas.length < 2) return [];
    final entries = <_MasaEntry>[];
    // Pournimanta: month starts day after Purnima
    // Month name = the month that starts after this Purnima
    const masaNames = [
      'ಚೈತ್ರ', 'ವೈಶಾಖ', 'ಜ್ಯೇಷ್ಠ', 'ಆಷಾಢ', 'ಶ್ರಾವಣ', 'ಭಾದ್ರಪದ',
      'ಆಶ್ವಯುಜ', 'ಕಾರ್ತೀಕ', 'ಮಾರ್ಗಶಿರ', 'ಪುಷ್ಯ', 'ಮಾಘ', 'ಫಾಲ್ಗುಣ',
    ];
    for (int i = 0; i < _purnimas.length - 1; i++) {
      final startDate = _purnimas[i].add(const Duration(days: 1));
      final endDate = _purnimas[i + 1];
      // Determine masa name from the Amanta masa that contains this period
      String masaName = '';
      for (final mp in _masaPeriods) {
        if (startDate.isAfter(mp.amavasya1.subtract(const Duration(days: 1))) &&
            startDate.isBefore(mp.amavasya2.add(const Duration(days: 15)))) {
          masaName = mp.masaName;
          break;
        }
      }
      if (masaName.isEmpty && i < masaNames.length) masaName = masaNames[i % 12];
      entries.add(_MasaEntry(name: masaName, start: startDate, end: endDate));
    }
    return entries;
  }

  List<_MasaEntry> _buildAmantaEntries() {
    return _masaPeriods.map((p) {
      final startDate = p.amavasya1.add(const Duration(days: 1));
      final prefix = p.masaType == 'adhika' ? 'ಅಧಿಕ ' : p.masaType == 'kshaya' ? 'ಕ್ಷಯ ' : '';
      return _MasaEntry(name: '$prefix${p.masaName}', start: startDate, end: p.amavasya2);
    }).toList();
  }

  List<_MasaEntry> _buildSouramanaEntries() {
    if (_sankrantis.length < 2) return [];
    final entries = <_MasaEntry>[];
    for (int i = 0; i < _sankrantis.length - 1; i++) {
      final s = _sankrantis[i];
      final startDate = s['date'] as DateTime;
      final endDate = (_sankrantis[i + 1]['date'] as DateTime).subtract(const Duration(days: 1));
      entries.add(_MasaEntry(
        name: '${s['masaName']} (${s['name']})',
        start: startDate,
        end: endDate,
      ));
    }
    return entries;
  }

  Widget _masaSubTable({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required List<_MasaEntry> entries,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('$icon ', style: const TextStyle(fontSize: 14)),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ]),
          Text('   $subtitle', style: TextStyle(fontSize: 9, color: kMuted, fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          // Header
          Row(children: [
            SizedBox(width: 90, child: Text('ಮಾಸ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color))),
            Expanded(child: Text('ಆರಂಭ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color))),
            SizedBox(width: 80, child: Text('ಅಂತ್ಯ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.right)),
          ]),
          Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 4), color: color.withAlpha(30)),
          if (entries.isEmpty)
            Text('ಲೆಕ್ಕಾಚಾರ ಮಾಡಲಾಗುತ್ತಿದೆ...', style: TextStyle(fontSize: 10, color: kMuted))
          else
            ...entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                SizedBox(width: 90, child: Text(AppLocale.trAll(e.name), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kText))),
                Expanded(child: Text(_fmtMasaDate(e.start), style: TextStyle(fontSize: 10, color: kMuted))),
                SizedBox(width: 80, child: Text(_fmtMasaDate(e.end), style: TextStyle(fontSize: 10, color: kMuted), textAlign: TextAlign.right)),
              ]),
            )),
        ],
      ),
    );
  }

  String _fmtMasaDate(DateTime dt) {
    const months = ['', 'ಜನ', 'ಫೆಬ್ರ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿ', 'ಮೇ', 'ಜೂನ್', 'ಜುಲೈ', 'ಆಗ', 'ಸೆಪ್ಟೆ', 'ಅಕ್ಟೋ', 'ನವೆ', 'ಡಿಸೆ'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
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

  // ── Monthly event category detection ──
  String? _getMonthlyCategory(String name) {
    if (name.contains('ಏಕಾದಶಿ')) return 'ಏಕಾದಶಿ';
    if (name.contains('ಪ್ರದೋಷ')) return 'ಪ್ರದೋಷ';
    if (name.contains('ಸಂಕಷ್ಟಹರ') || name.contains('ವಿನಾಯಕ ಚತುರ್ಥಿ')) return 'ಸಂಕಷ್ಟಹರ ಚತುರ್ಥಿ';
    return null;
  }

  String _fmtDate(DateTime dt) {
    final m = ['', AppLocale.t('monJan'), AppLocale.t('monFeb'), AppLocale.t('monMar'), AppLocale.t('monApr'), AppLocale.t('monMay'), AppLocale.t('monJun'), AppLocale.t('monJul'), AppLocale.t('monAug'), AppLocale.t('monSep'), AppLocale.t('monOct'), AppLocale.t('monNov'), AppLocale.t('monDec')];
    final wd = ['', AppLocale.t('wdMon'), AppLocale.t('wdTue'), AppLocale.t('wdWed'), AppLocale.t('wdThu'), AppLocale.t('wdFri'), AppLocale.t('wdSat'), AppLocale.t('wdSun')];
    return '${m[dt.month]} ${dt.day} (${wd[dt.weekday]})';
  }

  /// Build the Events/Festivals section
  Widget _buildEventsSection() {
    if (_eventsLoading) {
      return AppCard(
        child: Column(children: [
          SectionHeader(icon: Icons.celebration_rounded, title: 'ಹಬ್ಬ / ವಿಶೇಷ ದಿನಗಳು'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _eventsProgress / 12, color: kGold, backgroundColor: kBorder),
          const SizedBox(height: 8),
          Text('Computing events... $_eventsProgress/12 months',
            style: TextStyle(fontSize: 12, color: kMuted)),
          if (_yearEvents.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('${_yearEvents.length} events found so far',
              style: TextStyle(fontSize: 11, color: kGold)),
          ],
        ]),
      );
    }
    if (_yearEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    // Categorize events
    final monthlyGroups = <String, List<MapEntry<String, DateTime>>>{};
    final specialEvents = <MapEntry<String, DateTime>>[];

    for (final entry in _yearEvents.entries) {
      final name = entry.key;
      final dates = entry.value;
      final category = _getMonthlyCategory(name);
      if (category != null) {
        monthlyGroups.putIfAbsent(category, () => []);
        for (final dt in dates) {
          monthlyGroups[category]!.add(MapEntry(name, dt));
        }
      } else {
        for (final dt in dates) {
          specialEvents.add(MapEntry(name, dt));
        }
      }
    }

    // Sort by date
    for (final group in monthlyGroups.values) {
      group.sort((a, b) => a.value.compareTo(b.value));
    }
    specialEvents.sort((a, b) => a.value.compareTo(b.value));

    const color = Color(0xFFE91E63);

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
          leading: Icon(Icons.celebration_rounded, color: color, size: 20),
          title: Row(
            children: [
              Expanded(child: Text('${AppLocale.t('habbaVishesha')}  $_year', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${specialEvents.length + monthlyGroups.values.fold<int>(0, (s, l) => s + l.length)}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          iconColor: color,
          collapsedIconColor: color.withAlpha(150),
          children: [
            // ── Special (yearly) events ──
            if (specialEvents.isNotEmpty)
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
                    Text('🎉 ವಿಶೇಷ ಹಬ್ಬಗಳು', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 8),
                    ...specialEvents.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              _fmtDate(e.value),
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kGold),
                            ),
                          ),
                          Expanded(
                            child: Text(e.key, style: TextStyle(fontSize: 10, color: kText)),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

            // ── Monthly recurring event dropdowns ──
            ...monthlyGroups.entries.map((group) {
              final categoryName = group.key;
              final items = group.value;
              final categoryIcons = {
                'ಏಕಾದಶಿ': '🙏',
                'ಪ್ರದೋಷ': '🌙',
                'ಸಂಕಷ್ಟಹರ ಚತುರ್ಥಿ': '🐘',
              };

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: kBg.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorder.withAlpha(40)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    childrenPadding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
                    title: Row(
                      children: [
                        Text('${categoryIcons[categoryName] ?? '🔁'} $categoryName', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kText)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${items.length}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
                        ),
                      ],
                    ),
                    children: items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              _fmtDate(item.value),
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kGold),
                            ),
                          ),
                          Expanded(
                            child: Text(item.key, style: TextStyle(fontSize: 10, color: kMuted)),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _shortDate(DateTime dt) {
    final m = ['', AppLocale.t('monJan'), AppLocale.t('monFeb'), AppLocale.t('monMar'), AppLocale.t('monApr'), AppLocale.t('monMay'), AppLocale.t('monJun'), AppLocale.t('monJul'), AppLocale.t('monAug'), AppLocale.t('monSep'), AppLocale.t('monOct'), AppLocale.t('monNov'), AppLocale.t('monDec')];
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

class _MasaEntry {
  final String name;
  final DateTime start;
  final DateTime end;
  const _MasaEntry({required this.name, required this.start, required this.end});
}
