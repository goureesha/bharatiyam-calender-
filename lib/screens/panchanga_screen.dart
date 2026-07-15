/// Panchanga Detail Screen — Full details with Muhurta, Hora, Lagna, Chougadiya tabs.
import 'package:flutter/material.dart';
import '../core/muhurta_calculator.dart';
import '../core/hora_calculator.dart';
import '../core/chougadiya_calculator.dart';
import '../core/lagna_calculator.dart';
import '../core/ghati_calculator.dart';
import '../core/ephemeris.dart';
import '../models/panchanga_data.dart';
import '../i18n/app_locale.dart';
import '../services/location_service.dart';
import '../services/export_service.dart';
import '../widgets/common.dart';

class PanchangaScreen extends StatefulWidget {
  final PanchangaData data;
  final DateTime date;

  const PanchangaScreen({super.key, required this.data, required this.date});

  @override
  State<PanchangaScreen> createState() => _PanchangaScreenState();
}

class _PanchangaScreenState extends State<PanchangaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final GlobalKey _repaintKey = GlobalKey();

  // Computed data
  List<MuhurtaTiming> _dayMuhurtas = [];
  List<MuhurtaTiming> _nightMuhurtas = [];
  MuhurtaTiming? _abhijit;
  List<MuhurtaTiming> _durmuhurtas = [];
  MuhurtaTiming? _varjyam;
  bool _isAmritaSiddhi = false;
  List<HoraTiming> _dayHoras = [];
  List<HoraTiming> _nightHoras = [];
  List<ChougadiyaTiming> _dayChougadiya = [];
  List<ChougadiyaTiming> _nightChougadiya = [];
  List<LagnaTransit> _dayLagnas = [];
  List<LagnaTransit> _nightLagnas = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _computeAll();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _computeAll() {
    final d = widget.data;
    final tz = LocationService.tzOffset;

    // Next day sunrise for night calculations
    final nextDate = widget.date.add(const Duration(days: 1));
    final nextSrSs = Ephemeris.findSunriseSetForDate(
      nextDate.year, nextDate.month, nextDate.day,
      LocationService.lat, LocationService.lon,
      tzOffset: tz,
    );
    final nextSunriseJd = nextSrSs[0];

    // Muhurtas
    _dayMuhurtas = MuhurtaCalculator.calculateDayMuhurtas(
      sunriseJd: d.sunriseJd, sunsetJd: d.sunsetJd, tzOffset: tz,
    );
    _nightMuhurtas = MuhurtaCalculator.calculateNightMuhurtas(
      sunsetJd: d.sunsetJd, nextSunriseJd: nextSunriseJd, tzOffset: tz,
    );
    _abhijit = MuhurtaCalculator.calculateAbhijit(
      sunriseJd: d.sunriseJd, sunsetJd: d.sunsetJd, tzOffset: tz,
    );
    _durmuhurtas = MuhurtaCalculator.calculateDurmuhurta(
      sunriseJd: d.sunriseJd, sunsetJd: d.sunsetJd,
      varaIndex: d.varaIndex, tzOffset: tz,
    );
    _varjyam = MuhurtaCalculator.calculateVarjyam(
      sunriseJd: d.sunriseJd, nakshatraIndex: d.nakshatraIndex, tzOffset: tz,
    );
    _isAmritaSiddhi = MuhurtaCalculator.isAmritaSiddhi(d.varaIndex, d.nakshatraIndex);

    // Horas
    _dayHoras = HoraCalculator.calculateDayHoras(
      sunriseJd: d.sunriseJd, sunsetJd: d.sunsetJd,
      varaIndex: d.varaIndex, tzOffset: tz,
    );
    _nightHoras = HoraCalculator.calculateNightHoras(
      sunsetJd: d.sunsetJd, nextSunriseJd: nextSunriseJd,
      varaIndex: d.varaIndex, tzOffset: tz,
    );

    // Chougadiya
    _dayChougadiya = ChougadiyaCalculator.calculateDay(
      sunriseJd: d.sunriseJd, sunsetJd: d.sunsetJd,
      varaIndex: d.varaIndex, tzOffset: tz,
    );
    _nightChougadiya = ChougadiyaCalculator.calculateNight(
      sunsetJd: d.sunsetJd, nextSunriseJd: nextSunriseJd,
      varaIndex: d.varaIndex, tzOffset: tz,
    );

    // Lagnas
    _dayLagnas = LagnaCalculator.calculateDayLagnas(
      sunriseJd: d.sunriseJd, sunsetJd: d.sunsetJd,
      lat: LocationService.lat, lon: LocationService.lon, tzOffset: tz,
    );
    _nightLagnas = LagnaCalculator.calculateNightLagnas(
      sunsetJd: d.sunsetJd, nextSunriseJd: nextSunriseJd,
      lat: LocationService.lat, lon: LocationService.lon, tzOffset: tz,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: appGradientColors,
          ),
        ),
        child: SafeArea(
          child: RepaintBoundary(
            key: _repaintKey,
            child: Column(
              children: [
                _buildAppBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildMuhurtaTab(),
                      _buildHoraTab(),
                      _buildLagnaTab(),
                      _buildChougadiyaTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: kGold, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(AppLocale.t('panchanga'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGold)),
                Text('${widget.date.day}/${widget.date.month}/${widget.date.year} — ${AppLocale.t(widget.data.vara)}',
                  style: TextStyle(fontSize: 11, color: kMuted)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.share_rounded, color: kGold, size: 20),
            color: kCard,
            onSelected: (v) {
              if (v == 'pdf') ExportService.exportPdf(widget.data, widget.date);
              if (v == 'image') ExportService.exportImage(_repaintKey);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'pdf', child: Text(AppLocale.t('export_pdf'), style: TextStyle(color: kText))),
              PopupMenuItem(value: 'image', child: Text(AppLocale.t('export_image'), style: TextStyle(color: kText))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kCard.withAlpha(127),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabCtrl,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'NotoSansKannada'),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'NotoSansKannada'),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: kGold.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kGold.withAlpha(76)),
        ),
        tabs: [
          Tab(text: AppLocale.t('muhurta')),
          Tab(text: AppLocale.t('hora')),
          Tab(text: AppLocale.t('lagna')),
          Tab(text: AppLocale.t('chougadiya')),
        ],
      ),
    );
  }

  // ─── MUHURTA TAB ───
  Widget _buildMuhurtaTab() {
    return ResponsiveCenter(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        children: [
          // Special muhurtas
          if (_abhijit != null || _varjyam != null || _isAmritaSiddhi)
            AppCard(
              child: Column(
                children: [
                  SectionHeader(icon: Icons.star_rounded, title: AppLocale.t('specialMuhurta')),
                  const SizedBox(height: 8),
                  if (_abhijit != null)
                    KalaTimeBar(name: AppLocale.t('abhijit'), startTime: _abhijit!.startTime, endTime: _abhijit!.endTime, color: kShubha),
                  for (final dm in _durmuhurtas)
                    KalaTimeBar(name: AppLocale.t('durmuhurta'), startTime: dm.startTime, endTime: dm.endTime, color: kAshubha),
                  if (_varjyam != null)
                    KalaTimeBar(name: AppLocale.t('varjya'), startTime: _varjyam!.startTime, endTime: _varjyam!.endTime, color: kAshubha),
                  if (_isAmritaSiddhi)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: kShubha, size: 16),
                          const SizedBox(width: 8),
                          Text(AppLocale.t('amritaSiddhi'), style: TextStyle(fontSize: 12, color: kShubha, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // Day muhurtas
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.wb_sunny_rounded, title: AppLocale.t('dayMuhurta')),
                const SizedBox(height: 4),
                for (int i = 0; i < _dayMuhurtas.length; i++)
                  MuhurtaListItem(
                    index: i,
                    name: AppLocale.t(_dayMuhurtas[i].name),
                    startTime: _dayMuhurtas[i].startTime,
                    endTime: _dayMuhurtas[i].endTime,
                    nature: _dayMuhurtas[i].nature,
                  ),
              ],
            ),
          ),

          // Night muhurtas
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.nights_stay_rounded, title: AppLocale.t('nightMuhurta')),
                const SizedBox(height: 4),
                for (int i = 0; i < _nightMuhurtas.length; i++)
                  MuhurtaListItem(
                    index: i,
                    name: AppLocale.t(_nightMuhurtas[i].name),
                    startTime: _nightMuhurtas[i].startTime,
                    endTime: _nightMuhurtas[i].endTime,
                    nature: _nightMuhurtas[i].nature,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HORA TAB ───
  Widget _buildHoraTab() {
    return ResponsiveCenter(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        children: [
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.wb_sunny_rounded, title: '${AppLocale.t("hora")} — ${AppLocale.t("dayMuhurta")}'),
                const SizedBox(height: 4),
                for (int i = 0; i < _dayHoras.length; i++)
                  _horaItem(i, _dayHoras[i]),
              ],
            ),
          ),
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.nights_stay_rounded, title: '${AppLocale.t("hora")} — ${AppLocale.t("nightMuhurta")}'),
                const SizedBox(height: 4),
                for (int i = 0; i < _nightHoras.length; i++)
                  _horaItem(i, _nightHoras[i]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _horaItem(int idx, HoraTiming h) {
    final planetColors = {
      'Sun': const Color(0xFFFF6D00), 'Moon': const Color(0xFFE0E0E0),
      'Mars': const Color(0xFFFF1744), 'Mercury': const Color(0xFF00E676),
      'Jupiter': const Color(0xFFFFD600), 'Venus': const Color(0xFFE040FB),
      'Saturn': const Color(0xFF448AFF),
    };
    final color = planetColors[h.planet] ?? kText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('${idx + 1}', style: TextStyle(fontSize: 11, color: kMuted))),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(AppLocale.t(h.planet), style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500))),
          Text('${h.startTime} - ${h.endTime}', style: TextStyle(fontSize: 10, color: kMuted)),
        ],
      ),
    );
  }

  // ─── LAGNA TAB ───
  Widget _buildLagnaTab() {
    return ResponsiveCenter(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        children: [
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.wb_sunny_rounded, title: AppLocale.t('dayLagna')),
                const SizedBox(height: 4),
                for (final l in _dayLagnas)
                  LagnaListItem(rashi: AppLocale.t(l.rashi), startTime: l.startTime, endTime: l.endTime),
              ],
            ),
          ),
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.nights_stay_rounded, title: AppLocale.t('nightLagna')),
                const SizedBox(height: 4),
                for (final l in _nightLagnas)
                  LagnaListItem(rashi: AppLocale.t(l.rashi), startTime: l.startTime, endTime: l.endTime),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CHOUGADIYA TAB ───
  Widget _buildChougadiyaTab() {
    return ResponsiveCenter(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        children: [
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.wb_sunny_rounded, title: '${AppLocale.t("chougadiya")} — Day'),
                const SizedBox(height: 4),
                for (int i = 0; i < _dayChougadiya.length; i++)
                  _chougadiyaItem(i, _dayChougadiya[i]),
              ],
            ),
          ),
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.nights_stay_rounded, title: '${AppLocale.t("chougadiya")} — Night'),
                const SizedBox(height: 4),
                for (int i = 0; i < _nightChougadiya.length; i++)
                  _chougadiyaItem(i, _nightChougadiya[i]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chougadiyaItem(int idx, ChougadiyaTiming c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('${idx + 1}', style: TextStyle(fontSize: 11, color: kMuted))),
          Expanded(child: Text(AppLocale.t(c.name), style: TextStyle(fontSize: 12, color: kText))),
          NaturePill(nature: c.nature),
          const SizedBox(width: 8),
          Text('${c.startTime} - ${c.endTime}', style: TextStyle(fontSize: 10, color: kMuted)),
        ],
      ),
    );
  }
}
