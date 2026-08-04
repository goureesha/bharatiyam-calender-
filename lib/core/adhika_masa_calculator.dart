/// Adhika/Kshaya Masa Calculator — Finds leap and lost months for a year.
/// Adhika Masa: No Sankranti between two consecutive Amavasyas
/// Kshaya Masa: Two Sankrantis between two consecutive Amavasyas
import 'package:sweph/sweph.dart';
import 'ephemeris.dart';

class MasaPeriodInfo {
  final String masaName;      // Kannada name
  final String masaType;      // 'nija', 'adhika', 'kshaya'
  final DateTime amavasya1;   // Start Amavasya
  final DateTime amavasya2;   // End Amavasya
  final int sankrantiCount;   // Number of Sankrantis in this period
  final List<String> sankrantiDetails; // Which Sankrantis occurred

  MasaPeriodInfo({
    required this.masaName,
    required this.masaType,
    required this.amavasya1,
    required this.amavasya2,
    required this.sankrantiCount,
    required this.sankrantiDetails,
  });
}

class AdhikaMasaCalculator {
  static const _masaNames = [
    'ಚೈತ್ರ', 'ವೈಶಾಖ', 'ಜ್ಯೇಷ್ಠ', 'ಆಷಾಢ', 'ಶ್ರಾವಣ', 'ಭಾದ್ರಪದ',
    'ಆಶ್ವಯುಜ', 'ಕಾರ್ತೀಕ', 'ಮಾರ್ಗಶಿರ', 'ಪುಷ್ಯ', 'ಮಾಘ', 'ಫಾಲ್ಗುಣ',
  ];

  static const _rashiNames = [
    'ಮೇಷ', 'ವೃಷಭ', 'ಮಿಥುನ', 'ಕರ್ಕಾಟಕ', 'ಸಿಂಹ', 'ಕನ್ಯಾ',
    'ತುಲಾ', 'ವೃಶ್ಚಿಕ', 'ಧನು', 'ಮಕರ', 'ಕುಂಭ', 'ಮೀನ',
  ];

  /// Calculate all masa periods for a year, identifying Adhika and Kshaya
  static List<MasaPeriodInfo> calculateForYear(int year, {double tzOffset = 5.5}) {
    // 1. Find all Amavasyas (New Moons)
    final amavasyas = _findAllAmavasyas(year, tzOffset);
    if (amavasyas.length < 2) return [];

    final periods = <MasaPeriodInfo>[];

    for (int i = 0; i < amavasyas.length - 1; i++) {
      final am1Jd = amavasyas[i];
      final am2Jd = amavasyas[i + 1];

      // 2. Primary Adhika detection: compare Sun's rashi at the two Amavasyas
      //    (Reference app approach — reliable, no boundary scan gaps)
      final rashi1 = _sunRashi(am1Jd);
      final rashi2 = _sunRashi(am2Jd);
      final bool hasSankranti = (rashi1 != rashi2);

      // 3. Scan for Sankranti details (for display: which Sankranti, when)
      final sankrantis = _findSankrantis(am1Jd, am2Jd, tzOffset);

      // 4. Determine masa name
      String masaName;
      if (!hasSankranti) {
        // Adhika: Sun stays in same rashi → name from next month
        masaName = _masaNames[(rashi1 + 1) % 12];
      } else if (sankrantis.isNotEmpty) {
        // Normal: use first Sankranti's new rashi for naming
        final newRashi = sankrantis[0]['rashi'] as int;
        masaName = _masaNames[newRashi];
      } else {
        // Fallback: hasSankranti but scan missed it (boundary edge case)
        masaName = _masaNames[rashi2];
      }

      // 5. Determine type: count rashi changes for Kshaya detection
      final rashiDiff = ((rashi2 - rashi1) % 12 + 12) % 12;
      String masaType;
      if (!hasSankranti) {
        masaType = 'adhika';
      } else if (rashiDiff >= 2) {
        masaType = 'kshaya'; // Sun crossed 2+ rashis → Kshaya
      } else {
        masaType = 'nija';
      }

      final am1Dt = _jdToLocal(am1Jd, tzOffset);
      final am2Dt = _jdToLocal(am2Jd, tzOffset);

      // Only include if it overlaps with the requested year
      if (am2Dt.year >= year && am1Dt.year <= year) {
        periods.add(MasaPeriodInfo(
          masaName: masaName,
          masaType: masaType,
          amavasya1: am1Dt,
          amavasya2: am2Dt,
          sankrantiCount: hasSankranti ? (rashiDiff > 0 ? rashiDiff : 1) : 0,
          sankrantiDetails: sankrantis.map((s) => s['name'] as String).toList(),
        ));
      }
    }

    return periods;
  }

  /// Find all Amavasyas using TROPICAL Moon-Sun elongation (geometric event)
  /// Matches reference app's approach for maximum accuracy.
  static List<double> _findAllAmavasyas(int year, double tzOffset) {
    final results = <double>[];
    final scanStart = Sweph.swe_julday(year - 1, 12, 1, 0, CalendarType.SE_GREG_CAL);
    final scanEnd = Sweph.swe_julday(year + 1, 3, 1, 0, CalendarType.SE_GREG_CAL);

    double jd = scanStart;
    while (jd < scanEnd) {
      final elong1 = _tropicalElong(jd);
      final elong2 = _tropicalElong(jd + 1.0);

      // Detect wrap-around (e.g., 355° → 5°) which indicates New Moon
      if (elong1 > 300 && elong2 < 60) {
        // Refine with -180..+180 binary search (reference app approach)
        double lo = jd, hi = jd + 1.0;
        for (int i = 0; i < 30; i++) {
          final mid = (lo + hi) / 2;
          final moonCalc = Sweph.swe_calc_ut(mid, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
          final sunCalc = Sweph.swe_calc_ut(mid, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);
          final tDeg = ((moonCalc.longitude - sunCalc.longitude) % 360 + 360) % 360;
          final diff = ((tDeg + 180) % 360) - 180;
          if (diff < 0) lo = mid; else hi = mid;
        }
        results.add((lo + hi) / 2);
        jd += 25;
      } else {
        jd += 1.0;
      }
    }
    return results;
  }

  /// Find all Sankrantis (Sun crossing 30° rashi boundaries) between two JDs
  static List<Map<String, dynamic>> _findSankrantis(double jd1, double jd2, double tzOffset) {
    final results = <Map<String, dynamic>>[];

    final sunRashi1 = _sunRashi(jd1);

    double jd = jd1;
    int prevRashi = sunRashi1;

    while (jd < jd2) {
      final step = 0.5; // half-day steps
      final nextJd = jd + step;
      if (nextJd > jd2) break;

      final curRashi = _sunRashi(nextJd);
      if (curRashi != prevRashi) {
        // Sankranti occurred — refine
        double lo = jd, hi = nextJd;
        for (int i = 0; i < 20; i++) {
          final mid = (lo + hi) / 2;
          if (_sunRashi(mid) == prevRashi) lo = mid; else hi = mid;
        }
        final sankrantiJd = (lo + hi) / 2;
        final newRashi = _sunRashi(sankrantiJd + 0.01);
        results.add({
          'jd': sankrantiJd,
          'rashi': newRashi,
          'name': '${_rashiNames[newRashi]} ಸಂಕ್ರಾಂತಿ (${_formatDate(_jdToLocal(sankrantiJd, tzOffset))})',
        });
        prevRashi = newRashi;
      } else {
        prevRashi = curRashi;
      }
      jd = nextJd;
    }

    return results;
  }

  /// Determine masa name from the Sankranti that falls within the period
  static String _determineMasaName(double am1Jd, double am2Jd, List<Map<String, dynamic>> sankrantis) {
    if (sankrantis.isEmpty) {
      // Adhika: no Sankranti, Sun stays in same rashi.
      // Sample at mid-month for safety (avoids boundary issues).
      final midJd = (am1Jd + am2Jd) / 2;
      final rashi = _sunRashi(midJd);
      // Sun is in rashi X throughout → Adhika of month X
      // _masaNames maps: Mesha(0)→Chaitra, Vrishabha(1)→Vaishakha...
      // But Mesha Sankranti → Chaitra month → _masaNames[0]=Chaitra
      // For Adhika, the next Sankranti will be from rashi X to X+1
      // Month name = _masaNames for the NEXT Sankranti's target = (rashi+1)%12
      // BUT _masaNames[0]=Chaitra (Mesha Sankranti month), so:
      // Vrishabha(1) Sun → next Sankranti enters Mithuna(2) → Jyeshtha = _masaNames[2]
      return _masaNames[(rashi + 1) % 12];
    }
    // Normal/Kshaya: use the first Sankranti's NEW rashi.
    // sankrantis[0]['rashi'] = the rashi Sun ENTERS (e.g., Mithuna=2 for Mithuna Sankranti)
    // Mithuna(2) Sankranti → Jyeshtha month = _masaNames[2]
    // Mesha(0) Sankranti → Chaitra month = _masaNames[0]
    final newRashi = sankrantis[0]['rashi'] as int;
    return _masaNames[newRashi];
  }

  /// Tropical Moon-Sun elongation (0-360°) — NO ayanamsa
  /// Used for finding conjunctions (geometric events)
  static double _tropicalElong(double jd) {
    final moon = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
    final sun = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);
    return ((moon.longitude - sun.longitude) + 360) % 360;
  }

  /// Get Sun's sidereal rashi index (0-11)
  /// Uses tropical Sun + manual ayanamsa subtraction (reference app approach)
  static int _sunRashi(double jd) {
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI);
    final ayn = Sweph.swe_get_ayanamsa(jd);
    final sun = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);
    final sunSid = ((sun.longitude - ayn) % 360 + 360) % 360;
    return (sunSid / 30).floor() % 12;
  }

  /// Convert JD to local DateTime
  static DateTime _jdToLocal(double jd, double tzOffset) {
    final ms = ((jd - 2440587.5) * 86400000).round();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)
        .add(Duration(milliseconds: (tzOffset * 3600000).round()));
  }

  /// Format date
  static String _formatDate(DateTime dt) {
    const months = [
      '', 'ಜನವರಿ', 'ಫೆಬ್ರವರಿ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿಲ್', 'ಮೇ', 'ಜೂನ್',
      'ಜುಲೈ', 'ಆಗಸ್ಟ್', 'ಸೆಪ್ಟೆಂಬರ್', 'ಅಕ್ಟೋಬರ್', 'ನವೆಂಬರ್', 'ಡಿಸೆಂಬರ್',
    ];
    return '${months[dt.month]} ${dt.day}';
  }

  /// Format date with year
  static String formatDateFull(DateTime dt) {
    const months = [
      '', 'ಜನವರಿ', 'ಫೆಬ್ರವರಿ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿಲ್', 'ಮೇ', 'ಜೂನ್',
      'ಜುಲೈ', 'ಆಗಸ್ಟ್', 'ಸೆಪ್ಟೆಂಬರ್', 'ಅಕ್ಟೋಬರ್', 'ನವೆಂಬರ್', 'ಡಿಸೆಂಬರ್',
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}
