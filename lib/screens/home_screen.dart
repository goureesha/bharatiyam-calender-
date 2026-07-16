/// Home Screen — Main entry with date selector, quick panchanga summary, and navigation.
import 'package:flutter/material.dart';
import '../core/ephemeris.dart';
import '../core/panchanga_calculator.dart';
import '../core/kala_calculator.dart';
import '../core/ghati_calculator.dart';
import '../core/masa_calculator.dart';
import '../core/samvatsara.dart';
import '../core/shraddha_calculator.dart';
import '../models/panchanga_data.dart';
import '../i18n/app_locale.dart';
import '../services/location_service.dart';
import '../services/precomputed_data.dart';
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
    await PrecomputedData().load();
    await Ephemeris.initSweph();
    _initDone = true;
    _compute();
  }

  void _compute() {
    if (!_initDone) return;
    setState(() => _loading = true);

    try {
      var data = PanchangaCalculator.calculate(
        year: _selectedDate.year,
        month: _selectedDate.month,
        day: _selectedDate.day,
        lat: LocationService.lat,
        lon: LocationService.lon,
        tzOffset: LocationService.tzOffset,
      );

      // Fill Amanta & Pournimanta Masa (needed before Samvatsara for Ugadi detection)
      final amanta = MasaCalculator.calculateAmanta(
        jdSunrise: data.sunriseJd, lat: LocationService.lat, lon: LocationService.lon,
        tzOffset: LocationService.tzOffset,
      );
      final pournimanta = MasaCalculator.calculatePournimanta(
        jdSunrise: data.sunriseJd, lat: LocationService.lat, lon: LocationService.lon,
        tzOffset: LocationService.tzOffset,
      );

      String amantaKey = amanta['masa'] as String;
      String amantaName = amantaKey;
      if (amanta['isAdhika'] == true) amantaName = 'adhika_$amantaName';
      String pourniName = pournimanta['masa'] as String;
      if (pournimanta['isAdhika'] == true) pourniName = 'adhika_$pourniName';

      // Fill Samvatsara & Rutu (using amanta masa for Ugadi detection)
      final samData = SamvatsaraCalculator.calculate(
        _selectedDate.year, _selectedDate.month,
        chandraMasaKey: amantaKey,
      );
      final sunPlanets = Ephemeris.calcAll(data.sunriseJd, 'lahiri', true);
      final sunDeg = sunPlanets['Sun']![0];
      final rutu = SamvatsaraCalculator.calculateRutu(sunDeg);

      // Fill Ghati (Visha/Amruta)
      final vishaData = GhatiCalculator.calculateVishaGhati(
        nakshatraIndex: data.nakshatraIndex,
        sunriseJd: data.sunriseJd,
        nakStartJd: data.sunriseJd - 0.5,
        nakEndJd: data.sunriseJd + 0.5,
        tzOffset: LocationService.tzOffset,
      );
      final amrutaData = GhatiCalculator.calculateAmrutaGhati(
        nakshatraIndex: data.nakshatraIndex,
        sunriseJd: data.sunriseJd,
        nakStartJd: data.sunriseJd - 0.5,
        nakEndJd: data.sunriseJd + 0.5,
        tzOffset: LocationService.tzOffset,
      );

      data = data.copyWith(
        samvatsara: samData['samvatsara'] as String,
        rutu: rutu,
        amantaMasa: amantaName,
        pournimantaMasa: pourniName,
        vishaPraghati: '${vishaData['start'] ?? ''} - ${vishaData['end'] ?? ''}',
        amrutaPraghati: '${amrutaData['start'] ?? ''} - ${amrutaData['end'] ?? ''}',
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
          colorScheme: ColorScheme.dark(
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: appGradientColors,
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
        decoration: BoxDecoration(
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
            ? Center(child: CircularProgressIndicator(color: kGold))
            : _data == null
              ? Center(child: Text('Unable to compute', style: TextStyle(color: kMuted)))
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
          Icon(Icons.auto_awesome, color: kGold, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocale.t('appName'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGold,
                    fontFamily: 'NotoSansKannada')),
                Text('📍 ${AppLocale.isKannada ? LocationService.cityNameKn : LocationService.cityName}',
                  style: TextStyle(fontSize: 11, color: kMuted)),
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
                style: TextStyle(fontSize: 11, color: kGold, fontWeight: FontWeight.bold)),
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
            icon: Icon(Icons.chevron_left_rounded, color: kGold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText),
                  ),
                  if (_data != null)
                    Text(AppLocale.t(_data!.vara),
                      style: TextStyle(fontSize: 12, color: kGold)),
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
                child: Text(AppLocale.t('today'), style: TextStyle(fontSize: 10, color: kTeal, fontWeight: FontWeight.bold)),
              ),
            ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: kGold),
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
          // ── Sunrise/Sunset + Moon rise/set banner ──
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _sunTimeWidget('🌅', AppLocale.t('sunrise'), d.sunrise),
                    Container(width: 1, height: 36, color: kBorder),
                    _sunTimeWidget('🌇', AppLocale.t('sunset'), d.sunset),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: kBorder.withAlpha(76)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _sunTimeWidget('🌙', 'ಚಂದ್ರೋದಯ', d.chandraUdaya),
                    Container(width: 1, height: 36, color: kBorder),
                    _sunTimeWidget('🌑', 'ಚಂದ್ರಾಸ್ತ', d.chandraAsta),
                  ],
                ),
              ],
            ),
          ),

          // ── Samvatsara / Shaka / Calendar ──
          AppCard(
            child: Column(
              children: [
                const SectionHeader(icon: Icons.calendar_today_rounded, title: 'ಸಂವತ್ಸರ / ಪಂಚಾಂಗ ವಿವರ'),
                const SizedBox(height: 8),
                InfoRow(label: 'ಶಕ ವರ್ಷ (Shaka)', value: '${d.shakaVarsha}'),
                InfoRow(label: AppLocale.t('samvatsara'), value: AppLocale.t(d.samvatsara)),
                InfoRow(label: 'ಪಕ್ಷ (Paksha)', value: d.paksha == 'shukla' ? 'ಶುಕ್ಲ ಪಕ್ಷ' : 'ಕೃಷ್ಣ ಪಕ್ಷ'),
                InfoRow(label: 'ಚಂದ್ರ ಮಾಸ (Amanta)', value: AppLocale.t(d.amantaMasa)),
                InfoRow(label: 'ಚಂದ್ರ ಮಾಸ (Pournimanta)', value: AppLocale.t(d.pournimantaMasa)),
                InfoRow(label: AppLocale.t('souraMasa'), value: AppLocale.t(d.souraMasa)),
                InfoRow(label: 'ಸೌರ ಮಾಸ ಗತ ದಿನ', value: '${d.souraMasaGataDina} ದಿನ'),
                InfoRow(label: AppLocale.t('rutu'), value: AppLocale.t(d.rutu)),
                InfoRow(label: AppLocale.t('ayana'), value: AppLocale.t(d.ayana)),
              ],
            ),
          ),

          // ── 5 Limbs (Panchangam) with Ghati-Vighati ──
          AppCard(
            child: Column(
              children: [
                SectionHeader(icon: Icons.auto_awesome, title: AppLocale.t('panchanga')),
                const SizedBox(height: 8),
                _limbWithGhati(
                  label: AppLocale.t('tithi'),
                  value: AppLocale.t(d.tithi),
                  currentName: d.currentTithi.isNotEmpty && d.currentTithi != d.tithi ? AppLocale.t(d.currentTithi) : null,
                  endTime: d.tithiEndTime, endGhati: d.tithiEndGhati,
                  endsNextDay: d.tithiEndsNextDay,
                  gata: d.tithiGata, shesha: d.tithiShesha, parama: d.tithiParama,
                  gataNow: d.tithiGataNow, sheshaNow: d.tithiSheshaNow,
                  currentEndTime: d.currentTithiEndTime, currentParama: d.currentTithiParama,
                ),
                _limbWithGhati(
                  label: AppLocale.t('nakshatra'),
                  value: '${AppLocale.t(d.nakshatra)} (${AppLocale.t("pada")} ${d.chandraPada})',
                  currentName: d.currentNakshatra.isNotEmpty && d.currentNakshatra != d.nakshatra ? AppLocale.t(d.currentNakshatra) : null,
                  endTime: d.nakEndTime, endGhati: d.nakEndGhati,
                  endsNextDay: d.nakEndsNextDay,
                  gata: d.nakGata, shesha: d.nakShesha, parama: d.nakParama,
                  gataNow: d.nakGataNow, sheshaNow: d.nakSheshaNow,
                  currentEndTime: d.currentNakEndTime, currentParama: d.currentNakParama,
                ),
                _limbWithGhati(
                  label: AppLocale.t('yoga'),
                  value: AppLocale.t(d.yoga),
                  currentName: d.currentYoga.isNotEmpty && d.currentYoga != d.yoga ? AppLocale.t(d.currentYoga) : null,
                  endTime: d.yogaEndTime, endGhati: d.yogaEndGhati,
                  endsNextDay: d.yogaEndsNextDay,
                  gata: d.yogaGata, shesha: d.yogaShesha, parama: d.yogaParama,
                  gataNow: d.yogaGataNow, sheshaNow: d.yogaSheshaNow,
                  currentEndTime: d.currentYogaEndTime, currentParama: d.currentYogaParama,
                ),
                _limbWithGhati(
                  label: AppLocale.t('karana'),
                  value: AppLocale.t(d.karana),
                  currentName: d.currentKarana.isNotEmpty && d.currentKarana != d.karana ? AppLocale.t(d.currentKarana) : null,
                  endTime: d.karanaEndTime, endGhati: d.karanaEndGhati,
                  endsNextDay: d.karanaEndsNextDay,
                  gata: d.karanaGata, shesha: d.karanaShesha, parama: d.karanaParama,
                  gataNow: d.karanaGataNow, sheshaNow: d.karanaSheshaNow,
                  currentEndTime: d.currentKaranaEndTime, currentParama: d.currentKaranaParama,
                ),
                const SizedBox(height: 6),
                // Udayadi Ghati
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: kGold.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ಉದಯಾದಿ ಘಟಿ: ', style: TextStyle(fontSize: 11, color: kMuted)),
                      Text(d.udayadiGhati, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold)),
                    ],
                  ),
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

          // ── Shraddha Details ──
          _buildShraddhaCard(d),

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
        Text(label, style: TextStyle(fontSize: 10, color: kMuted)),
        Text(time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGold)),
      ],
    );
  }

  Widget _limbWithGhati({
    required String label,
    required String value,
    String? currentName,
    required String endTime,
    String endGhati = '',
    required bool endsNextDay,
    required String gata,
    required String shesha,
    required String parama,
    required String gataNow,
    required String sheshaNow,
    String currentEndTime = '',
    String currentParama = '',
  }) {
    final hasTransitioned = currentName != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kBg.withAlpha(127),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sunrise Anga ──
          // Row 1: label + name + end time
          Row(
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: kMuted, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kText))),
              Text(endTime, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kGold)),
              if (endsNextDay)
                Text(' (ಮರುದಿನ)', style: TextStyle(fontSize: 9, color: kAshubha)),
              if (endGhati.isNotEmpty) ...[
                Text(' (', style: TextStyle(fontSize: 9, color: kMuted)),
                Text(endGhati, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kMuted)),
                Text(' ಘ)', style: TextStyle(fontSize: 9, color: kMuted)),
              ],
            ],
          ),
          // Row 2: (at sunrise) + ghati
          const SizedBox(height: 3),
          Row(
            children: [
              Text(hasTransitioned ? '(ಉದಯ ಕಾಲ)  ' : '☀  ', style: TextStyle(fontSize: 9, color: kMuted, fontStyle: FontStyle.italic)),
              _ghatiTag('ಗತ', gata, kGold),
              const SizedBox(width: 4),
              _ghatiTag('ಶೇಷ', shesha, kTeal),
              const SizedBox(width: 4),
              _ghatiTag('ಪರಮ', parama, kMuted),
            ],
          ),

          // ── Current Anga (when transitioned) ──
          if (hasTransitioned) ...[
            const SizedBox(height: 6),
            Container(height: 1, color: kTeal.withAlpha(30)),
            const SizedBox(height: 6),
            // Row 1: label + current name + end time
            Row(
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: kTeal, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(child: Text(currentName!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kTeal))),
                if (currentEndTime.isNotEmpty)
                  Text(currentEndTime, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTeal)),
              ],
            ),
            // Row 2: (current) + ghati
            const SizedBox(height: 3),
            Row(
              children: [
                Text('(ಈಗ)  ', style: TextStyle(fontSize: 9, color: kTeal, fontStyle: FontStyle.italic)),
                _ghatiTag('ಗತ', gataNow, const Color(0xFFFF9800)),
                const SizedBox(width: 4),
                _ghatiTag('ಶೇಷ', sheshaNow, const Color(0xFF4CAF50)),
                if (currentParama.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  _ghatiTag('ಪರಮ', currentParama, kMuted),
                ],
              ],
            ),
          ] else ...[
            // No transition — just show current ghati
            const SizedBox(height: 3),
            Row(
              children: [
                Text('⏱  ', style: TextStyle(fontSize: 9, color: kMuted)),
                _ghatiTag('ಗತ', gataNow, const Color(0xFFFF9800)),
                const SizedBox(width: 4),
                _ghatiTag('ಶೇಷ', sheshaNow, const Color(0xFF4CAF50)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _ghatiTag(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ', style: TextStyle(fontSize: 8, color: color)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildShraddhaCard(PanchangaData d) {
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


          // Shraddha Rule & Timing
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
                    Text('${info.sunriseTithiName} ತಿಥಿ ಅಂತ್ಯ: ', style: TextStyle(fontSize: 9, color: kMuted)),
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

  Widget _shraddhaTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildSettings() {
    return SettingsScreen(onLocationChanged: () {
      _compute();
    });
  }
}
