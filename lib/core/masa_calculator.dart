/// Masa Calculator — 4 calendar systems: Amanta, Pournimanta, Chandra Mana, Soura Mana.
/// Includes Adhika Masa detection.
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
    // Find the previous and next Amavasya (New Moon)
    final prevAmavasya = _findNewMoon(jdSunrise, -1, ayanamsaMode, trueNode);
    final nextAmavasya = _findNewMoon(jdSunrise, 1, ayanamsaMode, trueNode);

    // Check Sun's rashi at the Amavasya boundaries to determine month name
    final sunAtPrev = Ephemeris.calcAll(prevAmavasya, ayanamsaMode, trueNode);
    final sunRashi = (sunAtPrev['Sun']![0] / 30).floor() % 12;
    final masaIdx = _masaFromSunRashi(sunRashi);

    // Check for Adhika Masa: no Sankranti between prevAmavasya and nextAmavasya
    final isAdhika = !_hasSankranti(prevAmavasya, nextAmavasya, ayanamsaMode, trueNode);

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
    // Find previous and next Purnima (Full Moon)
    final prevPurnima = _findFullMoon(jdSunrise, -1, ayanamsaMode, trueNode);
    final nextPurnima = _findFullMoon(jdSunrise, 1, ayanamsaMode, trueNode);

    // Determine tithi to check paksha
    final planets = Ephemeris.calcAll(jdSunrise, ayanamsaMode, trueNode);
    final tithiDeg = Ephemeris.normDeg(planets['Moon']![0] - planets['Sun']![0]);
    final tithiIdx = (tithiDeg / 12).floor().clamp(0, 29);
    final isKrishnaPaksha = tithiIdx >= 15;

    // In Pournimanta: Krishna Paksha belongs to the NEXT month compared to Amanta
    // Find the Amavasya within this Pournimanta month
    double refAmavasyaJd;
    if (isKrishnaPaksha) {
      // Krishna Paksha: find next Amavasya
      refAmavasyaJd = _findNewMoon(jdSunrise, 1, ayanamsaMode, trueNode);
    } else {
      // Shukla Paksha: find previous Amavasya
      refAmavasyaJd = _findNewMoon(jdSunrise, -1, ayanamsaMode, trueNode);
    }

    final sunAtRef = Ephemeris.calcAll(refAmavasyaJd, ayanamsaMode, trueNode);
    final sunRashi = (sunAtRef['Sun']![0] / 30).floor() % 12;

    // In Pournimanta, the month name is ONE ahead for Krishna Paksha
    int masaIdx;
    if (isKrishnaPaksha) {
      masaIdx = _masaFromSunRashi(sunRashi);
    } else {
      masaIdx = _masaFromSunRashi(sunRashi);
    }

    // Check for Adhika Masa
    final isAdhika = !_hasSankranti(prevPurnima, nextPurnima, ayanamsaMode, trueNode);

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

  // ─── HELPER: Find New Moon (Amavasya) ───
  // direction: -1 = search backward, +1 = search forward
  static double _findNewMoon(double jdStart, int direction, String mode, bool tn) {
    // Scan in 1-day steps to find approximate conjunction
    double jd = jdStart;
    double prevDiff = _moonSunDiff(jd, mode, tn);

    for (int i = 0; i < 35; i++) {
      jd += direction * 1.0;
      final diff = _moonSunDiff(jd, mode, tn);

      // New Moon: Moon-Sun crosses 0° (or 360°)
      if (direction > 0 && prevDiff > 180 && diff < 180) {
        // Crossed from ~360 to ~0
        return _refineNewMoon(jd - 1.0, jd, mode, tn);
      }
      if (direction < 0 && prevDiff < 180 && diff > 180) {
        return _refineNewMoon(jd, jd + 1.0, mode, tn);
      }
      prevDiff = diff;
    }
    return jdStart; // fallback
  }

  static double _refineNewMoon(double lo, double hi, String mode, bool tn) {
    for (int i = 0; i < 25; i++) {
      final mid = (lo + hi) / 2;
      final diff = _moonSunDiff(mid, mode, tn);
      if (diff > 180) {
        lo = mid; // Before conjunction
      } else {
        hi = mid; // After conjunction
      }
    }
    return (lo + hi) / 2;
  }

  // ─── HELPER: Find Full Moon (Purnima) ───
  static double _findFullMoon(double jdStart, int direction, String mode, bool tn) {
    double jd = jdStart;
    double prevDiff = _moonSunDiff(jd, mode, tn);

    for (int i = 0; i < 35; i++) {
      jd += direction * 1.0;
      final diff = _moonSunDiff(jd, mode, tn);

      // Full Moon: Moon-Sun crosses 180°
      if (direction > 0 && prevDiff < 180 && diff >= 180) {
        return _refineFullMoon(jd - 1.0, jd, mode, tn);
      }
      if (direction < 0 && prevDiff >= 180 && diff < 180) {
        return _refineFullMoon(jd, jd + 1.0, mode, tn);
      }
      prevDiff = diff;
    }
    return jdStart;
  }

  static double _refineFullMoon(double lo, double hi, String mode, bool tn) {
    for (int i = 0; i < 25; i++) {
      final mid = (lo + hi) / 2;
      final diff = _moonSunDiff(mid, mode, tn);
      if (diff < 180) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  /// Moon - Sun elongation (0-360)
  static double _moonSunDiff(double jd, String mode, bool tn) {
    final p = Ephemeris.calcAll(jd, mode, tn);
    return Ephemeris.normDeg(p['Moon']![0] - p['Sun']![0]);
  }

  /// Check if Sun's Sankranti (rashi change) occurs between two JDs
  /// Reference approach: simply compare Sun's rashi at both boundary points
  static bool _hasSankranti(double jd1, double jd2, String mode, bool tn) {
    final p1 = Ephemeris.calcAll(jd1, mode, tn);
    final r1 = (p1['Sun']![0] / 30).floor() % 12;
    final p2 = Ephemeris.calcAll(jd2, mode, tn);
    final r2 = (p2['Sun']![0] / 30).floor() % 12;
    return r1 != r2;
  }
}
