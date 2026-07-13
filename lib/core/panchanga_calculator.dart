/// Main Panchanga Calculator — computes the 5 limbs and all details.
/// Adapted from reference app's calculator.dart.
import 'dart:math';
import 'ephemeris.dart';
import '../models/panchanga_data.dart';

class PanchangaCalculator {
  static const double _nakshatraSpan = 13.333333333; // 360/27
  static const double _tithiSpan = 12.0;             // 360/30
  static const double _yogaSpan = 13.333333333;      // 360/27
  static const double _karanaSpan = 6.0;             // 360/60

  /// Calculate complete Panchanga for a given date and location
  static PanchangaData calculate({
    required int year,
    required int month,
    required int day,
    required double lat,
    required double lon,
    required double tzOffset,
    String ayanamsaMode = 'lahiri',
    bool trueNode = true,
  }) {
    // 1. Sunrise & Sunset
    final srss = Ephemeris.findSunriseSetForDate(year, month, day, lat, lon, tzOffset: tzOffset);
    final sunriseJd = srss[0];
    final sunsetJd = srss[1];

    // 2. Planet positions at sunrise
    final planets = Ephemeris.calcAll(sunriseJd, ayanamsaMode, trueNode);
    final sunDeg = planets['Sun']![0];
    final moonDeg = planets['Moon']![0];

    // 3. Vara (Vedic weekday at sunrise)
    final dt = Ephemeris.jdToDateTime(sunriseJd, tzOffset: tzOffset);
    // Vedic weekday: Sunday=0, Monday=1, ..., Saturday=6
    final varaIndex = dt.weekday % 7; // Dart: Mon=1..Sun=7 → Sun=0,Mon=1..Sat=6

    // 4. Tithi
    final tithiDeg = Ephemeris.normDeg(moonDeg - sunDeg);
    final tithiIndex = (tithiDeg / _tithiSpan).floor().clamp(0, 29);

    // 5. Nakshatra
    final nakshatraIndex = (moonDeg / _nakshatraSpan).floor() % 27;
    final nakPercent = (moonDeg % _nakshatraSpan) / _nakshatraSpan;
    final chandraPadaNum = (nakPercent * 4).floor().clamp(0, 3) + 1;

    // 6. Yoga
    final yogaDeg = Ephemeris.normDeg(moonDeg + sunDeg);
    final yogaIndex = (yogaDeg / _yogaSpan).floor() % 27;

    // 7. Karana
    final karanaRawIdx = (tithiDeg / _karanaSpan).floor();
    final karanaIndex = _mapKaranaIndex(karanaRawIdx);

    // 8. Surya Nakshatra
    final suryaNakIdx = (sunDeg / _nakshatraSpan).floor() % 27;
    final suryaPadaNum = ((sunDeg % _nakshatraSpan) / (_nakshatraSpan / 4)).floor().clamp(0, 3) + 1;

    // 9. Chandra Rashi
    final chandraRashiIdx = (moonDeg / 30).floor() % 12;

    // 10. End times & ghatis via binary search
    final tithiEnd = _findTithiLimit(sunriseJd, tithiIndex, lat, lon, ayanamsaMode, trueNode);
    final nakEnd = _findNakLimit(sunriseJd, nakshatraIndex, lat, lon, ayanamsaMode, trueNode);
    final yogaEnd = _findYogaLimit(sunriseJd, yogaIndex, lat, lon, ayanamsaMode, trueNode);
    final karanaEnd = _findKaranaLimit(sunriseJd, karanaRawIdx, lat, lon, ayanamsaMode, trueNode);

    // 11. Compute ghati details
    final tithiGhati = _computeGhati(sunriseJd, tithiEnd['startJd']!, tithiEnd['endJd']!);
    final nakGhati = _computeGhati(sunriseJd, nakEnd['startJd']!, nakEnd['endJd']!);
    final yogaGhati = _computeGhati(sunriseJd, yogEnd['startJd']!, yogEnd['endJd']!);
    final karanaGhati = _computeGhati(sunriseJd, karanaEnd['startJd']!, karanaEnd['endJd']!);

    // 12. Udayadi Ghati
    final now = Ephemeris.julday(year, month, day, 12.0 - tzOffset);
    final udayadiGhatis = (now - sunriseJd) * 60; // JD diff * 60 = ghatis

    // 13. Next day flags
    final nextDayJd = sunriseJd + 1.0;
    final tithiNextDay = tithiEnd['endJd']! > nextDayJd;
    final nakNextDay = nakEnd['endJd']! > nextDayJd;
    final yogaNextDay = yogaEnd['endJd']! > nextDayJd;
    final karanaNextDay = karanaEnd['endJd']! > nextDayJd;

    // 14. Divamana / Ratrimana
    final dayHours = (sunsetJd - sunriseJd) * 24;
    final nightHours = 24 - dayHours;

    // 15. Agni Vasa
    final agniVal = (tithiIndex + varaIndex + 3) % 4;
    String agniVasa;
    if (agniVal == 0 || agniVal == 3) {
      agniVasa = 'bhumi'; // Shubha
    } else if (agniVal == 1) {
      agniVasa = 'akasha'; // Ashubha
    } else {
      agniVasa = 'patala'; // Ashubha
    }

    // 16. Soura Masa (solar month)
    final souraMasaIdx = (sunDeg / 30).floor() % 12;
    // Find last Sankranti for Gata Dina
    final tropFlags = 0x00000100; // SEFLG_SWIEPH only (tropical)
    double searchJd = sunriseJd;
    int gataDina = 0;
    for (int i = 0; i < 35; i++) {
      final checkJd = searchJd - i / 24.0 * 24;
      // Simple: count days since sun was at start of current rashi
      final checkPlanets = Ephemeris.calcAll(sunriseJd - i, ayanamsaMode, trueNode);
      final checkSun = checkPlanets['Sun']![0];
      final checkRashi = (checkSun / 30).floor() % 12;
      if (checkRashi != souraMasaIdx) {
        gataDina = i;
        break;
      }
    }

    return PanchangaData(
      tithi: 't$tithiIndex',
      vara: 'v$varaIndex',
      nakshatra: 'n$nakshatraIndex',
      yoga: 'y$yogaIndex',
      karana: _karanaKey(karanaRawIdx),
      tithiIndex: tithiIndex,
      nakshatraIndex: nakshatraIndex,
      yogaIndex: yogaIndex,
      karanaIndex: karanaIndex,
      varaIndex: varaIndex,
      tithiEndTime: Ephemeris.formatTimeFromJd(tithiEnd['endJd']!, tzOffset: tzOffset),
      nakEndTime: Ephemeris.formatTimeFromJd(nakEnd['endJd']!, tzOffset: tzOffset),
      yogaEndTime: Ephemeris.formatTimeFromJd(yogaEnd['endJd']!, tzOffset: tzOffset),
      karanaEndTime: Ephemeris.formatTimeFromJd(karanaEnd['endJd']!, tzOffset: tzOffset),
      tithiEndsNextDay: tithiNextDay,
      nakEndsNextDay: nakNextDay,
      yogaEndsNextDay: yogaNextDay,
      karanaEndsNextDay: karanaNextDay,
      tithiGata: Ephemeris.formatGhati(tithiGhati['gata']!),
      tithiShesha: Ephemeris.formatGhati(tithiGhati['shesha']!),
      tithiParama: Ephemeris.formatGhati(tithiGhati['parama']!),
      nakGata: Ephemeris.formatGhati(nakGhati['gata']!),
      nakShesha: Ephemeris.formatGhati(nakGhati['shesha']!),
      nakParama: Ephemeris.formatGhati(nakGhati['parama']!),
      yogaGata: Ephemeris.formatGhati(yogaGhati['gata']!),
      yogaShesha: Ephemeris.formatGhati(yogaGhati['shesha']!),
      yogaParama: Ephemeris.formatGhati(yogaGhati['parama']!),
      karanaGata: Ephemeris.formatGhati(karanaGhati['gata']!),
      karanaShesha: Ephemeris.formatGhati(karanaGhati['shesha']!),
      karanaParama: Ephemeris.formatGhati(karanaGhati['parama']!),
      udayadiGhati: Ephemeris.formatGhati(udayadiGhatis),
      sunrise: Ephemeris.formatTimeFromJd(sunriseJd, tzOffset: tzOffset),
      sunset: Ephemeris.formatTimeFromJd(sunsetJd, tzOffset: tzOffset),
      chandraRashi: 'r$chandraRashiIdx',
      chandraPada: '$chandraPadaNum',
      suryaNakshatra: 'n$suryaNakIdx',
      suryaPada: '$suryaPadaNum',
      nakPercent: nakPercent,
      amantaMasa: '', // Filled by MasaCalculator
      pournimantaMasa: '', // Filled by MasaCalculator
      souraMasa: 'sm$souraMasaIdx',
      souraMasaGataDina: '$gataDina',
      samvatsara: '', // Filled by SamvatsaraCalculator
      rutu: '', // Filled by SamvatsaraCalculator
      ayana: sunDeg >= 90 && sunDeg < 270 ? 'dakshinayana' : 'uttarayana',
      divamana: Ephemeris.formatDuration(dayHours),
      ratrimana: Ephemeris.formatDuration(nightHours),
      vishaPraghati: '', // Filled by GhatiCalculator
      amrutaPraghati: '', // Filled by GhatiCalculator
      agniVasa: agniVasa,
      sunriseJd: sunriseJd,
      sunsetJd: sunsetJd,
    );
  }

  // ─── BINARY SEARCH: Tithi end ───
  static Map<String, double> _findTithiLimit(
    double jdSunrise, int tithiIdx, double lat, double lon, String mode, bool tn
  ) {
    final targetDeg = ((tithiIdx + 1) % 30) * _tithiSpan;
    double lo = jdSunrise - 0.5, hi = jdSunrise + 1.5;

    // Find start of current tithi (search backward)
    double startJd = jdSunrise;
    for (int i = 0; i < 20; i++) {
      final checkJd = jdSunrise - i * 0.05;
      final p = Ephemeris.calcAll(checkJd, mode, tn);
      final td = Ephemeris.normDeg(p['Moon']![0] - p['Sun']![0]);
      final ti = (td / _tithiSpan).floor().clamp(0, 29);
      if (ti != tithiIdx) { startJd = checkJd + 0.05; break; }
    }

    // Find end of current tithi
    for (int i = 0; i < 20; i++) {
      final mid = (lo + hi) / 2;
      final p = Ephemeris.calcAll(mid, mode, tn);
      final td = Ephemeris.normDeg(p['Moon']![0] - p['Sun']![0]);
      final diff = _signedDiff(td, targetDeg);
      if (diff < 0) lo = mid; else hi = mid;
    }
    return {'startJd': startJd, 'endJd': (lo + hi) / 2};
  }

  // ─── BINARY SEARCH: Nakshatra end ───
  static Map<String, double> _findNakLimit(
    double jdSunrise, int nakIdx, double lat, double lon, String mode, bool tn
  ) {
    final targetDeg = ((nakIdx + 1) % 27) * _nakshatraSpan;
    double lo = jdSunrise - 0.5, hi = jdSunrise + 1.2;

    double startJd = jdSunrise;
    for (int i = 0; i < 20; i++) {
      final checkJd = jdSunrise - i * 0.04;
      final p = Ephemeris.calcAll(checkJd, mode, tn);
      final ni = (p['Moon']![0] / _nakshatraSpan).floor() % 27;
      if (ni != nakIdx) { startJd = checkJd + 0.04; break; }
    }

    for (int i = 0; i < 20; i++) {
      final mid = (lo + hi) / 2;
      final p = Ephemeris.calcAll(mid, mode, tn);
      final moonDeg = p['Moon']![0];
      final diff = _signedDiff(moonDeg, targetDeg);
      if (diff < 0) lo = mid; else hi = mid;
    }
    return {'startJd': startJd, 'endJd': (lo + hi) / 2};
  }

  // ─── BINARY SEARCH: Yoga end ───
  static Map<String, double> _findYogaLimit(
    double jdSunrise, int yogaIdx, double lat, double lon, String mode, bool tn
  ) {
    final targetDeg = ((yogaIdx + 1) % 27) * _yogaSpan;
    double lo = jdSunrise - 0.5, hi = jdSunrise + 1.5;

    double startJd = jdSunrise;
    for (int i = 0; i < 20; i++) {
      final checkJd = jdSunrise - i * 0.04;
      final p = Ephemeris.calcAll(checkJd, mode, tn);
      final yd = Ephemeris.normDeg(p['Moon']![0] + p['Sun']![0]);
      final yi = (yd / _yogaSpan).floor() % 27;
      if (yi != yogaIdx) { startJd = checkJd + 0.04; break; }
    }

    for (int i = 0; i < 20; i++) {
      final mid = (lo + hi) / 2;
      final p = Ephemeris.calcAll(mid, mode, tn);
      final yd = Ephemeris.normDeg(p['Moon']![0] + p['Sun']![0]);
      final diff = _signedDiff(yd, targetDeg);
      if (diff < 0) lo = mid; else hi = mid;
    }
    return {'startJd': startJd, 'endJd': (lo + hi) / 2};
  }

  // ─── BINARY SEARCH: Karana end ───
  static Map<String, double> _findKaranaLimit(
    double jdSunrise, int karanaRawIdx, double lat, double lon, String mode, bool tn
  ) {
    final targetDeg = ((karanaRawIdx + 1) % 60) * _karanaSpan;
    double lo = jdSunrise - 0.3, hi = jdSunrise + 0.8;

    double startJd = jdSunrise;
    for (int i = 0; i < 15; i++) {
      final checkJd = jdSunrise - i * 0.03;
      final p = Ephemeris.calcAll(checkJd, mode, tn);
      final td = Ephemeris.normDeg(p['Moon']![0] - p['Sun']![0]);
      final ki = (td / _karanaSpan).floor();
      if (ki != karanaRawIdx) { startJd = checkJd + 0.03; break; }
    }

    for (int i = 0; i < 20; i++) {
      final mid = (lo + hi) / 2;
      final p = Ephemeris.calcAll(mid, mode, tn);
      final td = Ephemeris.normDeg(p['Moon']![0] - p['Sun']![0]);
      final diff = _signedDiff(td, targetDeg);
      if (diff < 0) lo = mid; else hi = mid;
    }
    return {'startJd': startJd, 'endJd': (lo + hi) / 2};
  }

  /// Compute Gata/Shesha/Parama ghatis from boundary JDs
  static Map<String, double> _computeGhati(double jdSunrise, double startJd, double endJd) {
    final parama = (endJd - startJd) * 60; // total ghatis
    final gata = (jdSunrise - startJd) * 60; // elapsed
    final shesha = (endJd - jdSunrise) * 60; // remaining
    return {'gata': gata.abs(), 'shesha': shesha.abs(), 'parama': parama.abs()};
  }

  /// Signed difference between two angles (for bisection convergence)
  static double _signedDiff(double current, double target) {
    double d = current - target;
    if (d > 180) d -= 360;
    if (d < -180) d += 360;
    return d;
  }

  /// Map raw karana index (0-59) to display index
  static int _mapKaranaIndex(int rawIdx) {
    if (rawIdx == 0) return 0; // Kimstughna (special)
    if (rawIdx >= 57) return rawIdx - 57 + 8; // Shakuni(8), Chatushpada(9), Naga(10)
    return ((rawIdx - 1) % 7) + 1; // Bava(1)..Bhadra(7)
  }

  /// Get karana key string for i18n lookup
  static String _karanaKey(int rawIdx) {
    if (rawIdx == 0) return 'ks0'; // Kimstughna
    if (rawIdx == 57) return 'ks1'; // Shakuni
    if (rawIdx == 58) return 'ks2'; // Chatushpada
    if (rawIdx == 59) return 'ks3'; // Naga
    return 'kr${(rawIdx - 1) % 7}'; // kr0..kr6
  }
}
