/// Calendar Screen — Full-screen monthly grid + full panchanga detail on scroll.
import 'package:flutter/material.dart';
import '../core/panchanga_calculator.dart';
import '../core/masa_calculator.dart';
import '../core/samvatsara.dart';
import '../core/ghati_calculator.dart';
import '../core/kala_calculator.dart';
import '../core/ephemeris.dart';
import '../core/events.dart';
import '../core/shraddha_calculator.dart';
import '../models/panchanga_data.dart';
import '../i18n/app_locale.dart';
import '../services/location_service.dart';
import '../services/precomputed_data.dart';
import '../widgets/common.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  Map<int, PanchangaData> _monthData = {};
  Map<int, List<AstroEvent>> _monthEvents = {};
  bool _loading = false;
  int? _selectedDay;
  List<KalaTiming>? _selectedKalas;

  // In-memory cache
  static final Map<String, Map<int, PanchangaData>> _dataCache = {};
  static final Map<String, Map<int, List<AstroEvent>>> _eventsCache = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;
    _loadMonth();
  }

  String _monthKey(int y, int m) => '$y-$m';

  void _loadMonth() {
    final key = _monthKey(_currentMonth.year, _currentMonth.month);
    if (_dataCache.containsKey(key)) {
      setState(() {
        _monthData = _dataCache[key]!;
        _monthEvents = _eventsCache[key] ?? {};
        _loading = false;
      });
      _computeKalas();
      return;
    }
    final pre = PrecomputedData();
    if (pre.isLoaded) {
      final data = pre.getMonthData(_currentMonth.year, _currentMonth.month);
      if (data.isNotEmpty) {
        final events = pre.getMonthEvents(_currentMonth.year, _currentMonth.month);
        _dataCache[key] = data;
        _eventsCache[key] = events;
        setState(() {
          _monthData = data;
          _monthEvents = events;
          _loading = false;
        });
        _computeKalas();
        return;
      }
    }
    _computeMonth();
  }

  Future<void> _computeMonth() async {
    setState(() => _loading = true);
    final data = <int, PanchangaData>{};
    final events = <int, List<AstroEvent>>{};
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);

    for (int d = 1; d <= daysInMonth; d++) {
      try {
        final p = PanchangaCalculator.calculate(
          year: _currentMonth.year, month: _currentMonth.month, day: d,
          lat: LocationService.lat, lon: LocationService.lon,
          tzOffset: LocationService.tzOffset,
        );
        data[d] = p;
        try {
          final amanta = MasaCalculator.calculateAmanta(
            jdSunrise: p.sunriseJd, lat: LocationService.lat,
            lon: LocationService.lon, tzOffset: LocationService.tzOffset,
          );
          final masaName = EventCalculator.masaKeyToKannada(amanta['masa'] as String);
          final ev = EventCalculator.getEvents(
            masa: masaName, tIdx: p.tithiIndex,
            isAdhika: amanta['isAdhika'] as bool,
          );
          if (ev.isNotEmpty) events[d] = ev;
        } catch (_) {}
      } catch (_) {}
      if (d % 2 == 0) await Future.delayed(Duration.zero);
    }

    final key = _monthKey(_currentMonth.year, _currentMonth.month);
    _dataCache[key] = data;
    _eventsCache[key] = events;

    if (mounted) {
      setState(() {
        _monthData = data;
        _monthEvents = events;
        _loading = false;
      });
      _computeKalas();
    }
  }

  void _computeKalas() {
    if (_selectedDay == null || !_monthData.containsKey(_selectedDay)) {
      _selectedKalas = null;
      return;
    }
    final d = _monthData[_selectedDay]!;
    try {
      final kalas = KalaCalculator.calculate(
        sunriseJd: d.sunriseJd, sunsetJd: d.sunsetJd,
        varaIndex: d.varaIndex, tzOffset: LocationService.tzOffset,
      );
      setState(() => _selectedKalas = kalas);
    } catch (_) {
      _selectedKalas = null;
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta, 1);
      _selectedDay = null;
      _selectedKalas = null;
    });
    _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
      ? Center(child: CircularProgressIndicator(color: kGold))
      : SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _buildMonthBar(),
              _buildWeekdayHeader(),
              _buildCalendarGrid(),
              if (_selectedDay != null && _monthData.containsKey(_selectedDay)) ...[
                const SizedBox(height: 8),
                _buildFullDetail(_monthData[_selectedDay]!),
              ],
            ],
          ),
        );
  }

  // ─── MONTH BAR ─────────────────────────────────────────

  Widget _buildMonthBar() {
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: kCard.withAlpha(178),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: kGold),
            onPressed: () => _changeMonth(-1),
            iconSize: 28,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _currentMonth,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: kGold, onPrimary: kBg,
                        surface: kCard, onSurface: kText,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() {
                    _currentMonth = DateTime(picked.year, picked.month, 1);
                    _selectedDay = picked.day;
                  });
                  _loadMonth();
                }
              },
              child: Text(
                '${months[_currentMonth.month]} ${_currentMonth.year}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGold),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: kGold),
            onPressed: () => _changeMonth(1),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  // ─── WEEKDAY HEADER ────────────────────────────────────

  Widget _buildWeekdayHeader() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: days.map((d) => Expanded(
          child: Center(
            child: Text(d, style: TextStyle(fontSize: 10, color: kMuted, fontWeight: FontWeight.bold)),
          ),
        )).toList(),
      ),
    );
  }

  // ─── CALENDAR GRID ─────────────────────────────────────

  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    final today = DateTime.now();
    final isCurrentMonth = today.year == _currentMonth.year && today.month == _currentMonth.month;

    final cells = <Widget>[];
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final data = _monthData[d];
      final isToday = isCurrentMonth && d == today.day;
      final isSelected = d == _selectedDay;

      Color dayColor = kText;
      if (data != null) {
        if (data.tithiIndex == 14) dayColor = const Color(0xFFFFD700);
        if (data.tithiIndex == 29) dayColor = const Color(0xFF9E9E9E);
      }

      cells.add(
        GestureDetector(
          onTap: () {
            setState(() => _selectedDay = d);
            _computeKalas();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                ? kGold.withAlpha(30)
                : isToday ? kTeal.withAlpha(20) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? kGold : isToday ? kTeal.withAlpha(127) : kBorder.withAlpha(51),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$d',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? kGold : isToday ? kTeal : dayColor,
                  ),
                ),
                if (data != null)
                  Text(
                    _tithiShort(data.tithiIndex),
                    style: TextStyle(fontSize: 7, color: isSelected ? kGold.withAlpha(178) : kMuted),
                  ),
                if (_monthEvents.containsKey(d))
                  Container(
                    width: 5, height: 5,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(color: Color(0xFFFF9800), shape: BoxShape.circle),
                  )
                else if (data != null)
                  Text(
                    _nakShort(data.nakshatraIndex),
                    style: TextStyle(fontSize: 6, color: isSelected ? kGold.withAlpha(127) : kMuted.withAlpha(127)),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      childAspectRatio: 0.85,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  // ─── FULL PANCHANGA DETAIL ─────────────────────────────

  Widget _buildFullDetail(PanchangaData d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Date header
          AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_selectedDay/${_currentMonth.month}/${_currentMonth.year}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGold),
                    ),
                    Text(AppLocale.t(d.vara), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${AppLocale.t("udayadiGhati")}: ', style: TextStyle(fontSize: 11, color: kMuted)),
                    Text(d.udayadiGhati, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold)),
                  ],
                ),
              ],
            ),
          ),

          // ── 5 Angas ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(icon: Icons.auto_awesome_rounded, title: AppLocale.t('panchanga')),
                const SizedBox(height: 8),
                _angaRow(AppLocale.t('tithi'), AppLocale.t(d.tithi), d.tithiEndTime, d.tithiEndsNextDay, d.tithiGata, d.tithiShesha, d.tithiParama),
                const Divider(height: 12, thickness: 0.3),
                _angaRow(AppLocale.t('nakshatra'), AppLocale.t(d.nakshatra), d.nakEndTime, d.nakEndsNextDay, d.nakGata, d.nakShesha, d.nakParama),
                const Divider(height: 12, thickness: 0.3),
                _angaRow(AppLocale.t('yoga'), AppLocale.t(d.yoga), d.yogaEndTime, d.yogaEndsNextDay, d.yogaGata, d.yogaShesha, d.yogaParama),
                const Divider(height: 12, thickness: 0.3),
                _angaRow(AppLocale.t('karana'), AppLocale.t(d.karana), d.karanaEndTime, d.karanaEndsNextDay, d.karanaGata, d.karanaShesha, d.karanaParama),
              ],
            ),
          ),

          // ── Sun / Moon / Rashi ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(icon: Icons.wb_sunny_rounded, title: '${AppLocale.t("sunrise")} / ${AppLocale.t("sunset")}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _infoTile('☀️ ${AppLocale.t("sunrise")}', d.sunrise)),
                    Expanded(child: _infoTile('🌅 ${AppLocale.t("sunset")}', d.sunset)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _infoTile(AppLocale.t('divamana'), d.divamana)),
                    Expanded(child: _infoTile(AppLocale.t('ratrimana'), d.ratrimana)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _infoTile(AppLocale.t('chandraRashi'), AppLocale.t(d.chandraRashi))),
                    Expanded(child: _infoTile(AppLocale.t('chandraPada'), d.chandraPada)),
                    Expanded(child: _infoTile(AppLocale.t('suryaNakshatra'), AppLocale.t(d.suryaNakshatra))),
                  ],
                ),
              ],
            ),
          ),

          // ── Calendar Systems ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(icon: Icons.calendar_today_rounded, title: AppLocale.t('calendarSystems')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _infoTile(AppLocale.t('amanta'), AppLocale.t(d.amantaMasa))),
                    Expanded(child: _infoTile(AppLocale.t('pournimanta'), AppLocale.t(d.pournimantaMasa))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: _infoTile(AppLocale.t('souraMasa'), '${AppLocale.t(d.souraMasa)} (${AppLocale.t("gataDina")} ${d.souraMasaGataDina})')),
                    Expanded(child: _infoTile(AppLocale.t('samvatsara'), AppLocale.t(d.samvatsara))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: _infoTile(AppLocale.t('rutu'), AppLocale.t(d.rutu))),
                    Expanded(child: _infoTile(AppLocale.t('ayana'), AppLocale.t(d.ayana))),
                    Expanded(child: _infoTile(AppLocale.t('paksha'), d.tithiIndex < 15 ? AppLocale.t('shukla') : AppLocale.t('krishna'))),
                  ],
                ),
              ],
            ),
          ),

          // ── Ghati & Visha/Amruta ──
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(icon: Icons.access_time_rounded, title: AppLocale.t('ghatiDetails')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _infoTile('⚠️ ${AppLocale.t("vishaPraghati")}', d.vishaPraghati, isWarning: true)),
                    Expanded(child: _infoTile('✨ ${AppLocale.t("amrutaPraghati")}', d.amrutaPraghati)),
                  ],
                ),
                const SizedBox(height: 6),
                _infoTile(AppLocale.t('agniVasa'), d.agniVasa),
              ],
            ),
          ),

          // ── Kala Timings ──
          if (_selectedKalas != null)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(icon: Icons.warning_amber_rounded, title: AppLocale.t('kalaTimings')),
                  const SizedBox(height: 8),
                  ..._selectedKalas!.map((k) =>
                    KalaTimeBar(name: AppLocale.t(k.name), startTime: k.startTime, endTime: k.endTime),
                  ),
                ],
              ),
            ),

          // ── Events ──
          if (_selectedDay != null && _monthEvents.containsKey(_selectedDay))
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(icon: Icons.celebration_rounded, title: AppLocale.t('festivalsEvents')),
                  const SizedBox(height: 8),
                  ..._monthEvents[_selectedDay]!.map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFF9800).withAlpha(76)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('🪔 ', style: TextStyle(fontSize: 14)),
                          Expanded(child: Text(e.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF9800)))),
                        ]),
                        if (e.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(e.description, style: TextStyle(fontSize: 10, color: kMuted)),
                        ],
                        if (e.shloka.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: kBg.withAlpha(127), borderRadius: BorderRadius.circular(6)),
                            child: Text(e.shloka.replaceAll('\\\\n', '\n'), style: TextStyle(fontSize: 9, color: kGold, fontStyle: FontStyle.italic)),
                          ),
                        ],
                        if (e.meaning.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(e.meaning, style: TextStyle(fontSize: 10, color: kTeal)),
                        ],
                        const SizedBox(height: 2),
                        Text('— ${e.source}', style: TextStyle(fontSize: 8, color: kMuted.withAlpha(127))),
                      ],
                    ),
                  )),
                ],
              ),
            ),

          // ── Shraddha Details ──
          _buildShraddhaSection(d),
        ],
      ),
    );
  }

  Widget _buildShraddhaSection(PanchangaData d) {
    final info = ShraddhaCalculator.calculate(
      tithiIndex: d.tithiIndex,
      nakshatraIndex: d.nakshatraIndex,
      amantaMasa: d.amantaMasa,
      pournimantaMasa: d.pournimantaMasa,
      souraMasa: d.souraMasa,
      sunriseJd: d.sunriseJd,
      sunsetJd: d.sunsetJd,
      tithiEndJd: d.tithiEndJd,
      tithiStartJd: d.tithiStartJd,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.self_improvement_rounded,
            title: 'ಶ್ರಾದ್ಧ ನಿರ್ಣಯ',
          ),
          const SizedBox(height: 8),


          // ── Shraddha Rule & Timing ──
          const SizedBox(height: 10),
          Text('📋 ಶ್ರಾದ್ಧ ನಿಯಮ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kGold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF455A64).withAlpha(12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF455A64).withAlpha(30)),
            ),
            child: Text(info.ruleText, style: TextStyle(fontSize: 9, color: kMuted, fontStyle: FontStyle.italic, height: 1.4)),
          ),
          const SizedBox(height: 6),
          // Timing details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: info.isTithiPresentAtAparahna ? const Color(0xFF388E3C).withAlpha(12) : kAshubha.withAlpha(12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: info.isTithiPresentAtAparahna ? const Color(0xFF388E3C).withAlpha(40) : kAshubha.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('ಕುತುಪ ಕಾಲ: ', style: TextStyle(fontSize: 9, color: kMuted)),
                    Text('${info.aparahnaStart} — ${info.aparahnaEnd}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kText)),
                    Text('  (${info.aparahnaStartGhati} ಘಟಿ)', style: TextStyle(fontSize: 8, color: kMuted)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text('ಅಪರಾಹ್ನ: ', style: TextStyle(fontSize: 9, color: kMuted)),
                    Text('${info.aparahnaTimeStart} — ${info.aparahnaTimeEnd}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kText)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text('ತಿಥಿ ಅಂತ್ಯ: ', style: TextStyle(fontSize: 9, color: kMuted)),
                    Text(info.tithiEndTimeForRule, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kText)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(info.tithiStatusAtAparahna, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: info.isTithiPresentAtAparahna ? const Color(0xFF388E3C) : kAshubha)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: kGold.withAlpha(12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kGold.withAlpha(40)),
                  ),
                  child: Text('🙏 ${info.aparahnaShraddha}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kGold)),
                ),
                if (info.nextTithiShraddha.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: kGold.withAlpha(12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: kGold.withAlpha(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🙏 ${info.nextTithiShraddha} ಮಾಡಬಹುದು', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kGold)),
                        const SizedBox(height: 3),
                        Text(info.nextTithiStatus, style: TextStyle(fontSize: 9, color: kMuted)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shraddhaManaTile(String manaLabel, String shraddhaText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: kTeal.withAlpha(10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kTeal.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(manaLabel, style: TextStyle(fontSize: 8, color: kMuted, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(shraddhaText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kText)),
        ],
      ),
    );
  }

  Widget _shraddhaChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }

  // ─── HELPER WIDGETS ────────────────────────────────────

  Widget _angaRow(String label, String value, String endTime, bool endsNextDay, String gata, String shesha, String parama) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 9, color: kMuted)),
                  Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kText)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${AppLocale.t("endLabel")}', style: TextStyle(fontSize: 8, color: kMuted)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(endTime, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kGold)),
                      if (endsNextDay) Text(' +1', style: TextStyle(fontSize: 8, color: kAshubha)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _ghatiChip('G', gata),
            const SizedBox(width: 8),
            _ghatiChip('S', shesha),
            const SizedBox(width: 8),
            _ghatiChip('P', parama),
          ],
        ),
      ],
    );
  }

  Widget _ghatiChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: TextStyle(fontSize: 8, color: kMuted)),
        Text(value, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTeal)),
      ],
    );
  }

  Widget _infoTile(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 8, color: isWarning ? kAshubha : kMuted)),
          Text(value.isEmpty ? '—' : value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isWarning ? kAshubha : kText)),
        ],
      ),
    );
  }

  String _tithiShort(int idx) {
    if (idx < 15) return 'ಶು${(idx + 1).toString().padLeft(2, '0')}';
    if (idx == 29) return 'ಅಮಾ';
    return 'ಕೃ${(idx - 14).toString().padLeft(2, '0')}';
  }

  String _nakShort(int idx) {
    final key = 'n$idx';
    final name = AppLocale.t(key);
    return name.length > 3 ? name.substring(0, 3) : name;
  }
}
