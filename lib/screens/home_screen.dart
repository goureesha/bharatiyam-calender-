/// Home Screen — Main entry with date selector, quick panchanga summary, and navigation.
import 'package:flutter/material.dart';
import '../core/ephemeris.dart';
import '../core/panchanga_calculator.dart';
import '../core/kala_calculator.dart';
import '../core/masa_calculator.dart';
import '../core/samvatsara.dart';
import '../models/panchanga_data.dart';
import '../i18n/app_locale.dart';
import '../services/location_service.dart';
import '../widgets/common.dart';
import 'panchanga_screen.dart';
import 'settings_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  PanchangaData? _data;
  List<KalaTiming>? _kalas;
  bool _loading = true;
  bool _initDone = false;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
    AppLocale.langNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    AppLocale.langNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() => setState(() {});

  Future<void> _init() async {
    await AppLocale.loadLang();
    await LocationService.loadSavedLocation();
    await Ephemeris.initSweph();
    _initDone = true;
    _compute();
  }

  void _compute() {
    if (!_initDone) return;
    setState(() => _loading = true);

    try {
      final data = PanchangaCalculator.calculate(
        year: _selectedDate.year,
        month: _selectedDate.month,
        day: _selectedDate.day,
        lat: LocationService.lat,
        lon: LocationService.lon,
        tzOffset: LocationService.tzOffset,
      );
      final kalas = KalaCalculator.calculate(
        sunriseJd: data.sunriseJd,
        sunsetJd: data.sunsetJd,
        varaIndex: data.varaIndex,
        tzOffset: LocationService.tzOffset,
      );

      setState(() {
        _data = data;
        _kalas = kalas;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Compute error: $e');
    }
  }

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
    _compute();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kGold,
            onPrimary: kBg,
            surface: kCard,
            onSurface: kText,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _compute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0533), kBg, Color(0xFF0A0118)],
          ),
        ),
        child: SafeArea(
          child: _navIndex == 0
            ? _buildHome()
            : _navIndex == 1
              ? const CalendarScreen()
              : _buildSettings(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kCardBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: AppLocale.t('home')),
            BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_rounded), label: 'Calendar'),
            BottomNavigationBarItem(icon: const Icon(Icons.settings_rounded), label: AppLocale.t('settings')),
          ],
        ),
      ),
    );
  }

  Widget _buildHome() {
    return Column(
      children: [
        _buildHeader(),
        _buildDateBar(),
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: kGold))
            : _data == null
              ? const Center(child: Text('Unable to compute', style: TextStyle(color: kMuted)))
              : _buildContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: kGold, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocale.t('appName'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGold,
                    fontFamily: 'NotoSansKannada')),
                Text('📍 ${AppLocale.isKannada ? LocationService.cityNameKn : LocationService.cityName}',
                  style: const TextStyle(fontSize: 11, color: kMuted)),
              ],
            ),
          ),
          // Language chip
          GestureDetector(
            onTap: () => setState(() => _navIndex = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kGold.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGold.withAlpha(76)),
              ),
              child: Text(AppLocale.languageNames[AppLocale.current] ?? 'ಕನ್ನಡ',
                style: const TextStyle(fontSize: 11, color: kGold, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBar() {
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: kCard.withAlpha(178),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: kGold),
            onPressed: () => _changeDate(-1),
            iconSize: 28,
          ),
          Expanded(
            child: GestureDetector(
              onTap: _pickDate,
              child: Column(
                children: [
                  Text(
                    '${_selectedDate.day} / ${_selectedDate.month} / ${_selectedDate.year}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText),
                  ),
                  if (_data != null)
                    Text(AppLocale.t(_data!.vara),
                      style: const TextStyle(fontSize: 12, color: kGold)),
                ],
              ),
            ),
          ),
          if (!isToday)
            GestureDetector(
              onTap: () { setState(() => _selectedDate = DateTime.now()); _compute(); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: kTeal.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(AppLocale.t('today'), style: const TextStyle(fontSize: 10, color: kTeal, fontWeight: FontWeight.bold)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: kGold),
            onPressed: () => _changeDate(1),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final d = _data!;
    return ResponsiveCenter(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ── Sunrise/Sunset banner ──
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _sunTimeWidget('🌅', AppLocale.t('sunrise'), d.sunrise),
                Container(width: 1, height: 36, color: kBorder),
                _sunTimeWidget('🌇', AppLocale.t('sunset'), d.sunset),
              ],
            ),
          ),

          // ── 5 Limbs (Panchangam) ──
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.auto_awesome, title: AppLocale.t('panchanga')),
                const SizedBox(height: 8),
                InfoRow(
                  label: AppLocale.t('tithi'),
                  value: AppLocale.t(d.tithi),
                  endTime: '${AppLocale.t("endLabel")}: ${d.tithiEndTime}',
                  endsNextDay: d.tithiEndsNextDay,
                ),
                InfoRow(
                  label: AppLocale.t('nakshatra'),
                  value: '${AppLocale.t(d.nakshatra)} (${AppLocale.t("pada")} ${d.chandraPada})',
                  endTime: '${AppLocale.t("endLabel")}: ${d.nakEndTime}',
                  endsNextDay: d.nakEndsNextDay,
                ),
                InfoRow(
                  label: AppLocale.t('yoga'),
                  value: AppLocale.t(d.yoga),
                  endTime: '${AppLocale.t("endLabel")}: ${d.yogaEndTime}',
                  endsNextDay: d.yogaEndsNextDay,
                ),
                InfoRow(
                  label: AppLocale.t('karana'),
                  value: AppLocale.t(d.karana),
                  endTime: '${AppLocale.t("endLabel")}: ${d.karanaEndTime}',
                  endsNextDay: d.karanaEndsNextDay,
                ),
              ],
            ),
          ),

          // ── Ashubha Kala ──
          if (_kalas != null)
            AppCard(
              child: Column(
                children: [
                  SectionHeader(icon: Icons.warning_amber_rounded, title: AppLocale.t('ashubhaKala')),
                  const SizedBox(height: 8),
                  for (final k in _kalas!)
                    KalaTimeBar(
                      name: AppLocale.t(k.name),
                      startTime: k.startTime,
                      endTime: k.endTime,
                      color: kAshubha,
                    ),
                ],
              ),
            ),

          // ── Ghati-Vighati ──
          AppCard(
            child: Column(
              children: [
                const SectionHeader(icon: Icons.timer_outlined, title: 'ಘಟಿ-ವಿಘಟಿ (Ghati-Vighati)'),
                const SizedBox(height: 8),
                // Udayadi Ghati
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: kGold.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ಉದಯಾದಿ ಘಟಿ: ', style: TextStyle(fontSize: 11, color: kMuted)),
                      Text(d.udayadiGhati, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold)),
                    ],
                  ),
                ),
                // Table header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      const Expanded(flex: 3, child: Text('', style: TextStyle(fontSize: 9))),
                      Expanded(flex: 2, child: Text('ಗತ (Gata)', style: TextStyle(fontSize: 9, color: kMuted, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('ಶೇಷ (Shesha)', style: TextStyle(fontSize: 9, color: kMuted, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('ಪರಮ (Parama)', style: TextStyle(fontSize: 9, color: kMuted, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                _ghatiRow(AppLocale.t('tithi'), d.tithiGata, d.tithiShesha, d.tithiParama),
                _ghatiRow(AppLocale.t('nakshatra'), d.nakGata, d.nakShesha, d.nakParama),
                _ghatiRow(AppLocale.t('yoga'), d.yogaGata, d.yogaShesha, d.yogaParama),
                _ghatiRow(AppLocale.t('karana'), d.karanaGata, d.karanaShesha, d.karanaParama),
                const SizedBox(height: 8),
                // Visha & Amruta Praghati
                Row(
                  children: [
                    Expanded(child: _ghatiChip('☠️ ${AppLocale.t("vishaPraghati")}', d.vishaPraghati, kAshubha)),
                    const SizedBox(width: 8),
                    Expanded(child: _ghatiChip('🍯 ${AppLocale.t("amrutaPraghati")}', d.amrutaPraghati, kShubha)),
                  ],
                ),
                const SizedBox(height: 6),
                // Agni Vasa
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔥 ${AppLocale.t("agniVasa")}: ', style: const TextStyle(fontSize: 11, color: kMuted)),
                    Text(d.agniVasa, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kText)),
                  ],
                ),
              ],
            ),
          ),

          // ── Moon & Sun details ──
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.brightness_2_rounded, title: '${AppLocale.t("chandra")} / ${AppLocale.t("surya")}'),
                const SizedBox(height: 8),
                InfoRow(label: AppLocale.t('chandraRashi'), value: AppLocale.t(d.chandraRashi)),
                InfoRow(label: AppLocale.t('suryaNak'), value: '${AppLocale.t(d.suryaNakshatra)} (${AppLocale.t("pada")} ${d.suryaPada})'),
                InfoRow(label: AppLocale.t('souraMasa'), value: AppLocale.t(d.souraMasa)),
                InfoRow(label: AppLocale.t('divamana'), value: d.divamana),
                InfoRow(label: AppLocale.t('ratrimana'), value: d.ratrimana),
                InfoRow(label: AppLocale.t('ayana'), value: AppLocale.t(d.ayana)),
              ],
            ),
          ),

          // ── View Full Details button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => PanchangaScreen(data: d, date: _selectedDate),
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: kBg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text('${AppLocale.t("panchanga")} — ${AppLocale.t("muhurta")} / ${AppLocale.t("hora")} / ${AppLocale.t("lagna")}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sunTimeWidget(String emoji, String label, String time) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: kMuted)),
        Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGold)),
      ],
    );
  }

  Widget _ghatiRow(String label, String gata, String shesha, String parama) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 11, color: kText))),
          Expanded(flex: 2, child: Text(gata, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kGold), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(shesha, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTeal), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(parama, style: const TextStyle(fontSize: 12, color: kMuted), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _ghatiChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: color)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return SettingsScreen(onLocationChanged: () {
      _compute();
    });
  }
}
