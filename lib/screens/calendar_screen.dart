/// Calendar Screen — Monthly grid view with panchanga summary per day.
import 'package:flutter/material.dart';
import '../core/panchanga_calculator.dart';
import '../core/masa_calculator.dart';
import '../core/events.dart';
import '../models/panchanga_data.dart';
import '../i18n/app_locale.dart';
import '../services/panchanga_cache.dart';
import '../services/location_service.dart';
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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;
    _loadMonth();
  }

  void _loadMonth() {
    final cache = PanchangaCache();
    if (cache.isInitialized) {
      // Use cached data — instant!
      setState(() {
        _monthData = cache.getMonthData(_currentMonth.year, _currentMonth.month);
        _monthEvents = cache.getMonthEvents(_currentMonth.year, _currentMonth.month);
        _loading = false;
      });
    } else {
      // Cache not ready, compute directly
      _computeMonthDirect();
    }
  }

  Future<void> _computeMonthDirect() async {
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
      // Yield every 5 days
      if (d % 5 == 0) await Future.delayed(Duration.zero);
    }

    setState(() {
      _monthData = data;
      _monthEvents = events;
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta, 1);
      _selectedDay = null;
    });
    _loadMonth();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when cache becomes ready
    if (_loading && PanchangaCache().isInitialized) {
      _loadMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: appGradientColors,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildMonthBar(),
            _buildWeekdayHeader(),
            Expanded(
              child: _loading
                ? Center(child: CircularProgressIndicator(color: kGold))
                : _buildCalendarGrid(),
            ),
            if (_selectedDay != null && _monthData.containsKey(_selectedDay))
              _buildDayDetail(_monthData[_selectedDay]!),
          ],
        ),
      ),
    );
  }

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

  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7; // 0=Sun
    final today = DateTime.now();
    final isCurrentMonth = today.year == _currentMonth.year && today.month == _currentMonth.month;

    final cells = <Widget>[];

    // Empty cells before first day
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (int d = 1; d <= daysInMonth; d++) {
      final data = _monthData[d];
      final isToday = isCurrentMonth && d == today.day;
      final isSelected = d == _selectedDay;

      // Determine tithi paksha for color
      Color dayColor = kText;
      if (data != null) {
        final ti = data.tithiIndex;
        if (ti == 14) dayColor = const Color(0xFFFFD700); // Purnima - gold
        if (ti == 29) dayColor = const Color(0xFF9E9E9E); // Amavasya - grey
      }

      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDay = d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                ? kGold.withAlpha(30)
                : isToday
                  ? kTeal.withAlpha(20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                  ? kGold
                  : isToday
                    ? kTeal.withAlpha(127)
                    : kBorder.withAlpha(51),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Day number
                Text(
                  '$d',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? kGold : isToday ? kTeal : dayColor,
                  ),
                ),
                // Tithi short
                if (data != null)
                  Text(
                    _tithiShort(data.tithiIndex),
                    style: TextStyle(
                      fontSize: 7,
                      color: isSelected ? kGold.withAlpha(178) : kMuted,
                    ),
                  ),
                // Event dot
                if (_monthEvents.containsKey(d))
                  Container(
                    width: 5, height: 5,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF9800),
                      shape: BoxShape.circle,
                    ),
                  )
                else if (data != null)
                  Text(
                    _nakShort(data.nakshatraIndex),
                    style: TextStyle(
                      fontSize: 6,
                      color: isSelected ? kGold.withAlpha(127) : kMuted.withAlpha(127),
                    ),
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
      children: cells,
    );
  }

  Widget _buildDayDetail(PanchangaData d) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 380),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCard.withAlpha(204),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withAlpha(51)),
      ),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date & Vara
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_selectedDay/${_currentMonth.month}/${_currentMonth.year}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold),
              ),
              Text(AppLocale.t(d.vara), style: TextStyle(fontSize: 12, color: kGold)),
            ],
          ),
          const SizedBox(height: 6),
          // Panchanga summary
          Row(
            children: [
              Expanded(child: _miniInfo(AppLocale.t('tithi'), AppLocale.t(d.tithi))),
              Expanded(child: _miniInfo(AppLocale.t('nakshatra'), AppLocale.t(d.nakshatra))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: _miniInfo(AppLocale.t('yoga'), AppLocale.t(d.yoga))),
              Expanded(child: _miniInfo(AppLocale.t('karana'), AppLocale.t(d.karana))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: _miniInfo(AppLocale.t('sunrise'), d.sunrise)),
              Expanded(child: _miniInfo(AppLocale.t('sunset'), d.sunset)),
              Expanded(child: _miniInfo(AppLocale.t('chandraRashi'), AppLocale.t(d.chandraRashi))),
            ],
          ),
          // Events
          if (_selectedDay != null && _monthEvents.containsKey(_selectedDay))
            ..._monthEvents[_selectedDay]!.map((e) => Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF9800).withAlpha(76)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🪔 ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(e.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(e.description, style: TextStyle(fontSize: 9, color: kMuted)),
                  if (e.shloka.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kBg.withAlpha(127),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        e.shloka.replaceAll('\\\\n', '\n'),
                        style: TextStyle(fontSize: 9, color: kGold, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  if (e.meaning.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(e.meaning, style: TextStyle(fontSize: 9, color: kTeal)),
                  ],
                  const SizedBox(height: 2),
                  Text('— ${e.source}', style: TextStyle(fontSize: 8, color: kMuted.withAlpha(127))),
                ],
              ),
            )),
        ],
      )),
      ),
    );
  }

  Widget _miniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 8, color: kMuted)),
        Text(value, style: TextStyle(fontSize: 11, color: kText, fontWeight: FontWeight.w500)),
      ],
    );
  }

  /// Short tithi display: "ಶು01" = Shukla Pratipada
  String _tithiShort(int idx) {
    if (idx < 15) return 'ಶು${(idx + 1).toString().padLeft(2, '0')}';
    if (idx == 29) return 'ಅಮಾ';
    return 'ಕೃ${(idx - 14).toString().padLeft(2, '0')}';
  }

  /// Short nakshatra: first 3 chars of Kannada name
  String _nakShort(int idx) {
    final key = 'n$idx';
    final name = AppLocale.t(key);
    return name.length > 3 ? name.substring(0, 3) : name;
  }
}
