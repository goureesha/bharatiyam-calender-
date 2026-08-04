// Masa Calculator — 4 calendar systems: Amanta, Pournimanta, Chandra Mana, Soura Mana.
// Includes Adhika Masa detection.
// Uses TROPICAL positions for New Moon finding (geometric event),
// then SIDEREAL Sun for rashi determination — matching reference app approach.
import 'package:sweph/sweph.dart';
import 'ephemeris.dart';

class MasaCalculator {
  // 12 Chandra Masa names (keys for i18n)
  static const List<String> masaKeys = [
    'cm0', 'cm1', 'cm2', 'cm3', 'cm4', 'cm5',
    'cm6', 'cm7', 'cm8', 'cm9', 'cm10', 'cm11',
  ];

  // Chandra Masa mapping from Sun's rashi at Amavasya:
  // Mesha(0)→Vaishakha(cm1), Vrishabha(1)→Jyeshtha(cm2), ... Meena(11)→Chaitra(cm0)
  // Reference: knChandraMasa[rashiIdx] where array is [Vaishakha, Jyeshtha, Ashadha, ...]
  // Our cm0=Chaitra, cm1=Vaishakha, so we add 1
  static int _masaFromSunRashi(int sunRashi) => (sunRashi + 1) % 12;

  /// Get Sun's sidereal rashi at a given JD using tropical + manual ayanamsa
  /// (matches reference app's approach for maximum accuracy)
  static int _sunSiderealRashi(double jd, String ayanamsaMode) {
    final ayn = Ephemeris.getAyanamsa(jd, ayanamsaMode);
    final sunCalc = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);
    final sunSid = ((sunCalc.longitude - ayn) % 360 + 360) % 360;
    return (sunSid / 30).floor() % 12;
  }

  /// Calculate Amanta (Amavasyanta) month name
  /// Month runs from Amavasya to Amavasya
  static Map<String, dynamic> calculateAmanta({
    required double jdSunrise,
    required double lat,
    required double lon,
    String ayanamsaMode = 'lahiri',
    bool trueNode = true,
    double tzOffset = 5.5,
  }) {
    // Find the previous and next Amavasya using TROPICAL positions
    final prevAmavasya = _findNewMoon(jdSunrise, -1);
    final nextAmavasya = _findNewMoon(jdSunrise, 1);

    // Get Sun's sidereal rashi at EXACT Amavasya times
    // (tropical Sun - ayanamsa, matching reference app)
    final prevRashi = _sunSiderealRashi(prevAmavasya, ayanamsaMode);
    final nextRashi = _sunSiderealRashi(nextAmavasya, ayanamsaMode);
    final masaIdx = _masaFromSunRashi(prevRashi);

    // Adhika: Sun stays in same rashi → no Sankranti occurred
    final isAdhika = (prevRashi == nextRashi);

    return {
      'masa': masaKeys[masaIdx],
      'masaIndex': masaIdx,
      'isAdhika': isAdhika,
      'prevAmavasyaJd': prevAmavasya,
      'nextAmavasyaJd': nextAmavasya,
    };
  }

  /// Calculate Pournimanta month name
  /// Month runs from Purnima to Purnima
  static Map<String, dynamic> calculatePournimanta({
    required double jdSunrise,
    required double lat,
    required double lon,
    String ayanamsaMode = 'lahiri',
    bool trueNode = true,
    double tzOffset = 5.5,
  }) {
    // Find previous and next Purnima
    final prevPurnima = _findFullMoon(jdSunrise, -1);
    final nextPurnima = _findFullMoon(jdSunrise, 1);

    // Determine tithi to check paksha (using sidereal for tithi)
    final planets = Ephemeris.calcAll(jdSunrise, ayanamsaMode, trueNode);
    final tithiDeg = Ephemeris.normDeg(planets['Moon']![0] - planets['Sun']![0]);
    final tithiIdx = (tithiDeg / 12).floor().clamp(0, 29);
    final isKrishnaPaksha = tithiIdx >= 15;

    // Find the Amavasya within this Pournimanta month for naming
    double refAmavasyaJd;
    if (isKrishnaPaksha) {
      refAmavasyaJd = _findNewMoon(jdSunrise, 1);
    } else {
      refAmavasyaJd = _findNewMoon(jdSunrise, -1);
    }

    // Get Sun's sidereal rashi at exact Amavasya
    final sunRashi = _sunSiderealRashi(refAmavasyaJd, ayanamsaMode);
    final masaIdx = _masaFromSunRashi(sunRashi);

    // Adhika: compare Sun's rashi at both Purnima boundaries
    final prevRashi = _sunSiderealRashi(prevPurnima, ayanamsaMode);
    final nextRashi = _sunSiderealRashi(nextPurnima, ayanamsaMode);
    final isAdhika = (prevRashi == nextRashi);

    return {
      'masa': masaKeys[masaIdx],
      'masaIndex': masaIdx,
      'isAdhika': isAdhika,
      'isKrishnaPaksha': isKrishnaPaksha,
    };
  }

  /// Calculate Soura Masa (solar month = Sankranti to Sankranti)
  static Map<String, dynamic> calculateSouraMasa({
    required double jdSunrise,
    String ayanamsaMode = 'lahiri',
    bool trueNode = true,
  }) {
    final planets = Ephemeris.calcAll(jdSunrise, ayanamsaMode, trueNode);
    final sunDeg = planets['Sun']![0];
    final rashiIdx = (sunDeg / 30).floor() % 12;

    // Find last Sankranti (when Sun entered this rashi)
    double searchJd = jdSunrise;
    int gataDina = 0;
    for (int i = 1; i <= 35; i++) {
      final p = Ephemeris.calcAll(searchJd - i, ayanamsaMode, trueNode);
      final r = (p['Sun']![0] / 30).floor() % 12;
      if (r != rashiIdx) {
        gataDina = i;
        break;
      }
    }

    return {
      'masa': 'sm$rashiIdx',
      'masaIndex': rashiIdx,
      'gataDina': gataDina,
    };
  }

  // ═══════════════════════════════════════════════════════════════
  //  NEW MOON FINDING — TROPICAL (matches reference app)
  //  Uses tropical Moon-Sun for geometric conjunction accuracy.
  //  Binary search with -180..+180 mapping for smooth convergence.
  // ═══════════════════════════════════════════════════════════════

  /// Find exact New Moon (Amavasya) near jdStart.
  /// direction: -1 = search backward, +1 = search forward
  static double _findNewMoon(double jdStart, int direction) {
    // Scan in 1-day steps to find approximate conjunction
    double jd = jdStart;
    double prevDiff = _tropicalElongation(jd);

    for (int i = 0; i < 35; i++) {
      jd += direction * 1.0;
      final diff = _tropicalElongation(jd);

      // New Moon: elongation crosses 0° (wraps from ~360 to ~0)
      if (direction > 0 && prevDiff > 180 && diff < 180) {
        return _refineNewMoonTropical(jd - 1.0, jd);
      }
      if (direction < 0 && prevDiff < 180 && diff > 180) {
        return _refineNewMoonTropical(jd, jd + 1.0);
      }
      prevDiff = diff;
    }
    return jdStart; // fallback
  }

  /// Refine New Moon using binary search with -180..+180 convergence
  /// (matches reference app's findNewMoon approach)
  static double _refineNewMoonTropical(double lo, double hi) {
    for (int i = 0; i < 30; i++) {
      final mid = (lo + hi) / 2;
      final moonCalc = Sweph.swe_calc_ut(mid, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
      final sunCalc = Sweph.swe_calc_ut(mid, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);
      final tDeg = ((moonCalc.longitude - sunCalc.longitude) % 360 + 360) % 360;
      // Map to -180..+180 for convergence at 0°
      final diff = ((tDeg + 180) % 360) - 180;
      if (diff < 0) lo = mid; else hi = mid;
    }
    return (lo + hi) / 2;
  }

  // ═══════════════════════════════════════════════════════════════
  //  FULL MOON FINDING — TROPICAL
  // ═══════════════════════════════════════════════════════════════

  /// Find Full Moon (Purnima) near jdStart
  static double _findFullMoon(double jdStart, int direction) {
    double jd = jdStart;
    double prevDiff = _tropicalElongation(jd);

    for (int i = 0; i < 35; i++) {
      jd += direction * 1.0;
      final diff = _tropicalElongation(jd);

      // Full Moon: elongation crosses 180°
      if (direction > 0 && prevDiff < 180 && diff >= 180) {
        return _refineFullMoonTropical(jd - 1.0, jd);
      }
      if (direction < 0 && prevDiff >= 180 && diff < 180) {
        return _refineFullMoonTropical(jd, jd + 1.0);
      }
      prevDiff = diff;
    }
    return jdStart;
  }

  /// Refine Full Moon using binary search
  static double _refineFullMoonTropical(double lo, double hi) {
    for (int i = 0; i < 30; i++) {
      final mid = (lo + hi) / 2;
      final elong = _tropicalElongation(mid);
      if (elong < 180) lo = mid; else hi = mid;
    }
    return (lo + hi) / 2;
  }

  /// Tropical Moon-Sun elongation (0-360°) — NO ayanamsa
  /// Used for finding conjunctions/oppositions (geometric events)
  static double _tropicalElongation(double jd) {
    final moonCalc = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
    final sunCalc = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);
    return ((moonCalc.longitude - sunCalc.longitude) % 360 + 360) % 360;
  }
}
