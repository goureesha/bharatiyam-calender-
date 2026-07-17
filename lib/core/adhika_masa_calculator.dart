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
    // 1. Find all Amavasyas (New Moons) from ~March of prev year to ~April of next year
    //    to cover all masas that overlap with the given year
    final amavasyas = _findAllAmavasyas(year, tzOffset);
    if (amavasyas.length < 2) return [];

    final periods = <MasaPeriodInfo>[];

    for (int i = 0; i < amavasyas.length - 1; i++) {
      final am1Jd = amavasyas[i];
      final am2Jd = amavasyas[i + 1];

      // 2. Find Sankrantis between these two Amavasyas
      final sankrantis = _findSankrantis(am1Jd, am2Jd, tzOffset);

      // 3. Determine masa name from Sun's rashi after the first Amavasya
      //    The masa is named after the Sankranti that occurs in it
      //    If no Sankranti → Adhika of the next month
      final masaName = _determineMasaName(am1Jd, am2Jd, sankrantis);
      
      String masaType;
      if (sankrantis.isEmpty) {
        masaType = 'adhika';
      } else if (sankrantis.length >= 2) {
        masaType = 'kshaya';
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
          sankrantiCount: sankrantis.length,
          sankrantiDetails: sankrantis.map((s) => s['name'] as String).toList(),
        ));
      }
    }

    return periods;
  }

  /// Find all Amavasyas (elongation Moon-Sun ≈ 0°) from Mar prev year to Apr next year
  static List<double> _findAllAmavasyas(int year, double tzOffset) {
    final results = <double>[];
    // Start from January of the year, extend to February of next year
    final scanStart = Sweph.swe_julday(year - 1, 12, 1, 0, CalendarType.SE_GREG_CAL);
    final scanEnd = Sweph.swe_julday(year + 1, 3, 1, 0, CalendarType.SE_GREG_CAL);

    double jd = scanStart;
    while (jd < scanEnd) {
      final elong1 = _moonSunElong(jd);
      final elong2 = _moonSunElong(jd + 1.0);

      // Detect wrap-around (e.g., 355° → 5°) which indicates New Moon
      if (elong1 > 300 && elong2 < 60) {
        // Refine with binary search
        double lo = jd, hi = jd + 1.0;
        for (int i = 0; i < 25; i++) {
          final mid = (lo + hi) / 2;
          final e = _moonSunElong(mid);
          // If elongation is large (>180), we're before the transition
          if (e > 180) lo = mid; else hi = mid;
        }
        results.add((lo + hi) / 2);
        jd += 25; // Skip ahead ~25 days to next lunation
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
      // Adhika: name = the next masa's name (based on Sun's rashi at end)
      final rashi = _sunRashi(am2Jd);
      // Masa = rashi where Sun enters: Mesha→Vaishakha, Vrishabha→Jyeshtha...
      return _masaNames[(rashi + 1) % 12];
    }
    // Use the first Sankranti's rashi to determine masa
    final rashi = sankrantis[0]['rashi'] as int;
    return _masaNames[(rashi + 1) % 12];
  }

  /// Get Moon-Sun elongation (0-360°) sidereal
  static double _moonSunElong(double jd) {
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI);
    final flags = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SIDEREAL;
    final sun = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, flags);
    final moon = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, flags);
    return ((moon.longitude - sun.longitude) + 360) % 360;
  }

  /// Get Sun's rashi index (0-11)
  static int _sunRashi(double jd) {
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI);
    final flags = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SIDEREAL;
    final sun = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, flags);
    return (sun.longitude / 30).floor() % 12;
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
