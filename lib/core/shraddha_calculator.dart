/// Shraddha Calculator — Varshika Shraddha Nirnaya and Mahalaya Shraddha.
///
/// Covers:
/// - Varshika Shraddha: Annual ancestor rites based on masa+paksha+tithi
///   - Chandra Mana (Amanta/Pournimanta) and Soura Mana
/// - Mahalaya Shraddha: Pitru Paksha (Krishna Paksha of Bhadrapada)
/// - Aparahna Shraddha Rule: Tithi must be present ≥2 ghati after Aparahna start

import 'ephemeris.dart';
import 'package:sweph/sweph.dart';

class ShraddhaInfo {
  // Varshika Shraddha (annual)
  final String varshikaChandraAmanta;
  final String varshikaChandraPournimanta;
  final String varshikaSoura;

  // Mahalaya / Pitru Paksha
  final bool isPitruPaksha;
  final String pitruPakshaDay;
  final String significance;
  final bool isSarvaPitru;
  final bool isBharaniShraddha;
  final bool isAvidhavaNavami;
  final bool isGhataChaturdashi;

  // Kutupa Kala & Aparahna timing
  final String aparahnaStart;       // Kutupa start clock time
  final String aparahnaEnd;         // Kutupa end clock time
  final String ruleText;            // Rule description
  final bool isTithiPresentAtAparahna; // Does sunrise tithi extend into kutupa?
  final String tithiStatusAtAparahna;  // Status text
  final String aparahnaStartGhati;  // Kutupa ghati from sunrise
  final String tithiEndTimeForRule; // Tithi end time
  final String sunriseTithiName;    // Sunrise tithi name (e.g. 'ಕೃಷ್ಣ ಷಷ್ಠಿ')
  final String aparahnaShraddha;    // Which shraddha can be done
  final String aparahnaTimeStart;   // Aparahna (4th of 5 parts) start
  final String aparahnaTimeEnd;     // Aparahna (4th of 5 parts) end

  // Next tithi's shraddha (when sunrise tithi ends during the day)
  final String nextTithiShraddha;   // Next tithi's shraddha name
  final String nextTithiStatus;     // Next tithi's kutupa status
  final String nextTithiEndTime;    // Next tithi's end time

  const ShraddhaInfo({
    this.varshikaChandraAmanta = '',
    this.varshikaChandraPournimanta = '',
    this.varshikaSoura = '',
    this.isPitruPaksha = false,
    this.pitruPakshaDay = '',
    this.significance = '',
    this.isSarvaPitru = false,
    this.isBharaniShraddha = false,
    this.isAvidhavaNavami = false,
    this.isGhataChaturdashi = false,
    this.aparahnaStart = '',
    this.aparahnaEnd = '',
    this.ruleText = '',
    this.isTithiPresentAtAparahna = false,
    this.tithiStatusAtAparahna = '',
    this.aparahnaStartGhati = '',
    this.tithiEndTimeForRule = '',
    this.sunriseTithiName = '',
    this.aparahnaShraddha = '',
    this.aparahnaTimeStart = '',
    this.aparahnaTimeEnd = '',
    this.nextTithiShraddha = '',
    this.nextTithiStatus = '',
    this.nextTithiEndTime = '',
  });
}

class ShraddhaCalculator {

  static const _tithiNames = [
    'ಪ್ರತಿಪದಾ', 'ದ್ವಿತೀಯಾ', 'ತೃತೀಯಾ', 'ಚತುರ್ಥೀ', 'ಪಂಚಮೀ',
    'ಷಷ್ಠೀ', 'ಸಪ್ತಮೀ', 'ಅಷ್ಟಮೀ', 'ನವಮೀ', 'ದಶಮೀ',
    'ಏಕಾದಶಿ', 'ದ್ವಾದಶಿ', 'ತ್ರಯೋದಶಿ', 'ಚತುರ್ದಶಿ',
  ];

  static const _chandraMasaNames = [
    'ಚೈತ್ರ', 'ವೈಶಾಖ', 'ಜ್ಯೇಷ್ಠ', 'ಆಷಾಢ',
    'ಶ್ರಾವಣ', 'ಭಾದ್ರಪದ', 'ಆಶ್ವಿನ', 'ಕಾರ್ತಿಕ',
    'ಮಾರ್ಗಶಿರ', 'ಪುಷ್ಯ', 'ಮಾಘ', 'ಫಾಲ್ಗುಣ',
  ];

  static const _souraMasaNames = [
    'ಮೇಷ', 'ವೃಷಭ', 'ಮಿಥುನ', 'ಕರ್ಕ',
    'ಸಿಂಹ', 'ಕನ್ಯಾ', 'ತುಲಾ', 'ವೃಶ್ಚಿಕ',
    'ಧನು', 'ಮಕರ', 'ಕುಂಭ', 'ಮೀನ',
  ];

  static const _pitruPakshaSignificanceKn = [
    'ಪ್ರತಿಪದಾ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',
    'ದ್ವಿತೀಯಾ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',
    'ತೃತೀಯಾ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',
    'ಚತುರ್ಥೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ; ಸುಹಾಗಿನ/ವಿಧವೆ ಸ್ತ್ರೀಯರಿಗೂ',
    'ಪಂಚಮೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ; ಅವಿವಾಹಿತರಿಗೆ',
    'ಷಷ್ಠೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',
    'ಸಪ್ತಮೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',
    'ಅಷ್ಟಮೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',
    'ಅವಿಧವಾ ನವಮೀ — ಸೌಭಾಗ್ಯವತಿ ಸ್ತ್ರೀಯರ ಶ್ರಾದ್ಧ',
    'ದಶಮೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',
    'ಏಕಾದಶಿ — ಸನ್ಯಾಸಿಗಳು/ಯತಿಗಳ ಶ್ರಾದ್ಧ',
    'ದ್ವಾದಶಿ — ಸನ್ಯಾಸಿಗಳ ಶ್ರಾದ್ಧ; ವೈಷ್ಣವ ಶ್ರಾದ್ಧ',
    'ಮಘಾ ಶ್ರಾದ್ಧ — ತಿಥಿ ತಿಳಿಯದವರ ಶ್ರಾದ್ಧಕ್ಕೆ ಸೂಕ್ತ',
    'ಘಾತ ಚತುರ್ದಶಿ — ಶಸ್ತ್ರ/ಅಪಘಾತ/ಅಕಾಲ ಮರಣದ ಶ್ರಾದ್ಧ',
    'ಸರ್ವ ಪಿತೃ ಅಮಾವಾಸ್ಯೆ (ಮಹಾಲಯ) — ಎಲ್ಲ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',
  ];

  static const _krishnaTithiKn = [
    'ಕೃಷ್ಣ ಪ್ರತಿಪದಾ', 'ಕೃಷ್ಣ ದ್ವಿತೀಯಾ', 'ಕೃಷ್ಣ ತೃತೀಯಾ',
    'ಕೃಷ್ಣ ಚತುರ್ಥೀ', 'ಕೃಷ್ಣ ಪಂಚಮೀ', 'ಕೃಷ್ಣ ಷಷ್ಠೀ',
    'ಕೃಷ್ಣ ಸಪ್ತಮೀ', 'ಕೃಷ್ಣ ಅಷ್ಟಮೀ', 'ಕೃಷ್ಣ ನವಮೀ',
    'ಕೃಷ್ಣ ದಶಮೀ', 'ಕೃಷ್ಣ ಏಕಾದಶಿ', 'ಕೃಷ್ಣ ದ್ವಾದಶಿ',
    'ಕೃಷ್ಣ ತ್ರಯೋದಶಿ', 'ಕೃಷ್ಣ ಚತುರ್ದಶಿ', 'ಅಮಾವಾಸ್ಯೆ',
  ];

  static String _resolveChandraMasa(String masaKey) {
    if (masaKey.startsWith('cm') && masaKey.length <= 4) {
      final idx = int.tryParse(masaKey.substring(2));
      if (idx != null && idx >= 0 && idx < 12) return _chandraMasaNames[idx];
    }
    for (final name in _chandraMasaNames) {
      if (masaKey.contains(name)) return name;
    }
    return masaKey;
  }

  static String _resolveSouraMasa(String masaKey) {
    if (masaKey.startsWith('sm') && masaKey.length <= 4) {
      final idx = int.tryParse(masaKey.substring(2));
      if (idx != null && idx >= 0 && idx < 12) return _souraMasaNames[idx];
    }
    for (final name in _souraMasaNames) {
      if (masaKey.contains(name)) return name;
    }
    return masaKey;
  }

  static bool _isPitruPakshaMasa(String amantaMasa) {
    final lower = amantaMasa.toLowerCase();
    return lower.contains('bhadrapada') ||
           lower.contains('ಭಾದ್ರಪದ') ||
           lower.contains('cm5') ||
           lower.contains('ashwin') ||
           lower.contains('ಆಶ್ವಿನ');
  }

  /// Calculate Kutupa Kala timing.
  /// Day is divided into 15 muhurtas (sunrise to sunset).
  /// Kutupa (Kutapa) = 8th muhurta = sunrise + (7/15)*dayDuration to sunrise + (8/15)*dayDuration
  static Map<String, double> _calcKutupa(double sunriseJd, double sunsetJd) {
    final dayDuration = sunsetJd - sunriseJd;
    final muhurtaDuration = dayDuration / 15.0;
    return {
      'startJd': sunriseJd + 7 * muhurtaDuration,
      'endJd': sunriseJd + 8 * muhurtaDuration,
    };
  }

  /// Calculate Aparahna timing.
  /// Day is divided into 5 equal parts (Panchabhaga):
  /// 1. Pratah  2. Sangava  3. Madhyahna  4. Aparahna  5. Sayahna
  static Map<String, double> _calcAparahna(double sunriseJd, double sunsetJd) {
    final dayDuration = sunsetJd - sunriseJd;
    final partDuration = dayDuration / 5.0;
    return {
      'startJd': sunriseJd + 3 * partDuration,
      'endJd': sunriseJd + 4 * partDuration,
    };
  }

  /// Find when the next tithi boundary is reached after a given JD.
  /// targetDeg = the degree boundary (e.g. 12, 24, 36... for tithi transitions)
  static double _findTithiEnd(double jdStart, double targetDeg) {
    // Binary search: find when Moon-Sun elongation crosses targetDeg
    double lo = jdStart;
    double hi = jdStart + 2.0; // search up to 2 days ahead
    for (int i = 0; i < 30; i++) {
      final mid = (lo + hi) / 2;
      final moonCalc = Sweph.swe_calc_ut(mid, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
      final sunCalc = Sweph.swe_calc_ut(mid, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);
      final ayn = Sweph.swe_get_ayanamsa(mid);
      final moonSid = ((moonCalc.longitude - ayn) % 360 + 360) % 360;
      final sunSid = ((sunCalc.longitude - ayn) % 360 + 360) % 360;
      final elongation = ((moonSid - sunSid) % 360 + 360) % 360;
      final diff = ((elongation - targetDeg) + 540) % 360 - 180;
      if (diff < 0) lo = mid; else hi = mid;
    }
    return (lo + hi) / 2;
  }
  static ShraddhaInfo calculate({
    required int tithiIndex,
    required int nakshatraIndex,
    required String amantaMasa,
    required String pournimantaMasa,
    required String souraMasa,
    required double sunriseJd,
    required double sunsetJd,
    required double tithiEndJd,
    required double tithiStartJd,
    double tzOffset = 5.5,
  }) {
    final isKrishna = tithiIndex >= 15;
    final isAmavasya = tithiIndex == 29;
    final isPurnima = tithiIndex == 14;
    final isPitruPakshaMasa = _isPitruPakshaMasa(amantaMasa);
    final isPitruPaksha = isPitruPakshaMasa && isKrishna;

    // ── Varshika Shraddha ──
    final pakshaName = isKrishna ? 'ಕೃಷ್ಣ' : 'ಶುಕ್ಲ';
    String tithiName;
    if (isAmavasya) {
      tithiName = 'ಅಮಾವಾಸ್ಯೆ';
    } else if (isPurnima) {
      tithiName = 'ಹುಣ್ಣಿಮೆ';
    } else {
      final tithiInPaksha = isKrishna ? tithiIndex - 15 : tithiIndex;
      tithiName = (tithiInPaksha >= 0 && tithiInPaksha < 14) ? _tithiNames[tithiInPaksha] : '';
    }

    final amantaName = _resolveChandraMasa(amantaMasa);
    final pournimantaName = _resolveChandraMasa(pournimantaMasa);
    final souraName = _resolveSouraMasa(souraMasa);

    // Varshika strings will be built after kutupa tithi is determined
    String varshikaChandraAmanta;
    String varshikaChandraPournimanta;
    String varshikaSoura;

    // ── Kutupa Kala Rule ──
    // Kutupa = 8th of 15 day muhurtas
    final kutupa = _calcKutupa(sunriseJd, sunsetJd);
    final kutupaStartJd = kutupa['startJd']!;
    final kutupaEndJd = kutupa['endJd']!;

    // ── Aparahna (4th of 5 parts) ──
    final aparahna = _calcAparahna(sunriseJd, sunsetJd);
    final aparahnaStartJd = aparahna['startJd']!;
    final aparahnaEndJd = aparahna['endJd']!;

    final kutupaStartTime = Ephemeris.formatTimeFromJd(kutupaStartJd, tzOffset: tzOffset);
    final kutupaEndTime = Ephemeris.formatTimeFromJd(kutupaEndJd, tzOffset: tzOffset);
    final aparahnaStartTimeStr = Ephemeris.formatTimeFromJd(aparahnaStartJd, tzOffset: tzOffset);
    final aparahnaEndTimeStr = Ephemeris.formatTimeFromJd(aparahnaEndJd, tzOffset: tzOffset);
    final tithiEndTimeStr = Ephemeris.formatTimeFromJd(tithiEndJd, tzOffset: tzOffset);
    // Check if tithi ends today or tomorrow (compare local dates)
    final sunriseMs = ((sunriseJd - 2440587.5) * 86400000).round();
    final sunriseDt = DateTime.fromMillisecondsSinceEpoch(sunriseMs, isUtc: true)
        .add(Duration(milliseconds: (tzOffset * 3600000).round()));
    final endMs = ((tithiEndJd - 2440587.5) * 86400000).round();
    final endDt = DateTime.fromMillisecondsSinceEpoch(endMs, isUtc: true)
        .add(Duration(milliseconds: (tzOffset * 3600000).round()));
    final tithiEndDayLabel = (endDt.day != sunriseDt.day || endDt.month != sunriseDt.month)
        ? ' (ಮರುದಿನ)' : '';
    final tithiEndTimeForRule = '$tithiEndTimeStr$tithiEndDayLabel';

    // Kutupa start in ghati from sunrise
    final kutupaStartGhati = (kutupaStartJd - sunriseJd) * 60.0;
    final kutupaGhatiStr = Ephemeris.formatGhati(kutupaStartGhati);

    // Check if tithi is present during Kutupa Kala
    final isTithiPresent = tithiEndJd >= kutupaStartJd;

    // ── 2-day Kutupa detection ──
    // Yesterday's Kutupa (approx 24h earlier)
    final yesterdayKutupaStartJd = kutupaStartJd - 1.0;
    final yesterdayKutupaEndJd = kutupaEndJd - 1.0;
    // Tomorrow's Kutupa (approx 24h later)
    final tomorrowKutupaStartJd = kutupaStartJd + 1.0;

    // Was this tithi at yesterday's Kutupa?
    final wasAtYesterdayKutupa = tithiStartJd < yesterdayKutupaEndJd && tithiEndJd > yesterdayKutupaStartJd;
    // Will this tithi be at tomorrow's Kutupa?
    final willBeAtTomorrowKutupa = tithiEndJd >= tomorrowKutupaStartJd;

    bool isFirstDay = false;
    bool isSecondDay = false;

    if (isTithiPresent) {
      if (willBeAtTomorrowKutupa) {
        // Tithi at today AND tomorrow → today is first day
        isFirstDay = true;
      } else if (wasAtYesterdayKutupa) {
        // Tithi at yesterday AND today → today is second day
        isSecondDay = true;
      }
    }

    // Determine which tithi is at Kutupa
    int kutupaTithiIdx;
    if (tithiEndJd >= kutupaStartJd) {
      kutupaTithiIdx = tithiIndex;
    } else {
      kutupaTithiIdx = (tithiIndex + 1) % 30;
    }

    // Build kutupa shraddha name
    final kpIsKrishna = kutupaTithiIdx >= 15;
    final kpIsAmavasya = kutupaTithiIdx == 29;
    final kpIsPurnima = kutupaTithiIdx == 14;
    final kpPakshaName = kpIsKrishna ? 'ಕೃಷ್ಣ' : 'ಶುಕ್ಲ';
    String kpTithiName;
    if (kpIsAmavasya) {
      kpTithiName = 'ಅಮಾವಾಸ್ಯೆ';
    } else if (kpIsPurnima) {
      kpTithiName = 'ಹುಣ್ಣಿಮೆ';
    } else {
      final kpTithiInPaksha = kpIsKrishna ? kutupaTithiIdx - 15 : kutupaTithiIdx;
      kpTithiName = (kpTithiInPaksha >= 0 && kpTithiInPaksha < 14) ? _tithiNames[kpTithiInPaksha] : '';
    }

    // Build varshika and aparahna shraddha using Kutupa-determined tithi
    // (tithi and paksha are same across all 3 calendar systems, only masa changes)
    String aparahnaShraddha;
    if (kpIsAmavasya || kpIsPurnima) {
      aparahnaShraddha = '$amantaName $kpTithiName ಶ್ರಾದ್ಧ ಮಾಡಬಹುದು';
      varshikaChandraAmanta = '$amantaName $kpTithiName ಶ್ರಾದ್ಧ';
      varshikaChandraPournimanta = '$pournimantaName $kpTithiName ಶ್ರಾದ್ಧ';
      varshikaSoura = '$souraName $kpTithiName ಶ್ರಾದ್ಧ';
    } else {
      aparahnaShraddha = '$amantaName $kpPakshaName $kpTithiName ಶ್ರಾದ್ಧ ಮಾಡಬಹುದು';
      varshikaChandraAmanta = '$amantaName $kpPakshaName $kpTithiName ಶ್ರಾದ್ಧ';
      varshikaChandraPournimanta = '$pournimantaName $kpPakshaName $kpTithiName ಶ್ರಾದ್ಧ';
      varshikaSoura = '$souraName $kpPakshaName $kpTithiName ಶ್ರಾದ್ಧ';
    }

    // ── Kshaya Tithi detection (for sunrise tithi) ──
    final isKshayaTithi = !isTithiPresent &&
        tithiStartJd > yesterdayKutupaEndJd &&
        tithiEndJd < kutupaStartJd;

    // ── Status: based on Kutupa tithi ──
    String tithiStatus;
    if (kutupaTithiIdx == tithiIndex) {
      // Sunrise tithi IS at Kutupa
      if (isFirstDay) {
        tithiStatus = '✅ $kpPakshaName $kpTithiName — ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ (ಪ್ರಥಮ ದಿನ)';
      } else if (isSecondDay) {
        tithiStatus = '⚠️ $kpPakshaName $kpTithiName — ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ (ದ್ವಿತೀಯ ದಿನ)\n📌 ಹಿಂದಿನ ದಿನ (ಪ್ರಥಮ ದಿನ) ಶ್ರಾದ್ಧ ಯೋಗ್ಯ';
      } else {
        tithiStatus = '✅ $kpPakshaName $kpTithiName — ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ';
      }
    } else {
      // Sunrise tithi ended before Kutupa, next tithi is at Kutupa
      tithiStatus = '✅ $kpPakshaName $kpTithiName — ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ';
    }

    // ── Next Tithi Shraddha ──
    // If sunrise tithi ends before sunset, the next tithi starts during this day.
    // Check if the next tithi is Kshaya (misses Kutupa on both today AND tomorrow).
    // If Kshaya → by Kshaye Purva, its shraddha is TODAY (the first day).
    // If present at today's Kutupa → shraddha is also today.
    // If present only at tomorrow's Kutupa → shraddha is tomorrow, not shown here.
    String nextTithiShraddha = '';
    String nextTithiStatus = '';
    String nextTithiEndTime = '';

    final nextTithiIdx = (tithiIndex + 1) % 30;
    final bool sunriseTithiEndsDuringDay = tithiEndJd < sunsetJd;

    if (sunriseTithiEndsDuringDay) {
      // Next tithi starts at tithiEndJd
      final ntIsKrishna = nextTithiIdx >= 15;
      final ntIsAmavasya = nextTithiIdx == 29;
      final ntIsPurnima = nextTithiIdx == 14;
      final ntPakshaName = ntIsKrishna ? 'ಕೃಷ್ಣ' : 'ಶುಕ್ಲ';
      String ntTithiName;
      if (ntIsAmavasya) {
        ntTithiName = 'ಅಮಾವಾಸ್ಯೆ';
      } else if (ntIsPurnima) {
        ntTithiName = 'ಹುಣ್ಣಿಮೆ';
      } else {
        final ntTithiInPaksha = ntIsKrishna ? nextTithiIdx - 15 : nextTithiIdx;
        ntTithiName = (ntTithiInPaksha >= 0 && ntTithiInPaksha < 14) ? _tithiNames[ntTithiInPaksha] : '';
      }

      // Find next tithi's END JD using binary search
      final nextTithiBoundaryDeg = ((nextTithiIdx + 1) % 30) * 12.0;
      double nextTithiEndJd;
      try {
        nextTithiEndJd = _findTithiEnd(tithiEndJd, nextTithiBoundaryDeg);
      } catch (_) {
        nextTithiEndJd = tithiEndJd + 1.0; // fallback ~1 day
      }

      // Check if next tithi is at TODAY's Kutupa
      final nextStartsBeforeKutupaEnd = tithiEndJd < kutupaEndJd;
      final nextAtTodayKutupa = nextStartsBeforeKutupaEnd && nextTithiEndJd > kutupaStartJd;

      // Compute TOMORROW's Kutupa Kala
      final tomorrowSunriseJd = sunriseJd + 1.0; // approximate
      final tomorrowSunsetJd = sunsetJd + 1.0;   // approximate
      final tomorrowKutupa = _calcKutupa(tomorrowSunriseJd, tomorrowSunsetJd);
      final tmrKutupaStartJd = tomorrowKutupa['startJd']!;
      final tmrKutupaEndJd = tomorrowKutupa['endJd']!;

      // Check if next tithi is at TOMORROW's Kutupa
      final nextAtTomorrowKutupa = nextTithiEndJd > tmrKutupaStartJd && tithiEndJd < tmrKutupaEndJd;

      // Is this next tithi Kshaya? (misses Kutupa on BOTH days)
      final isNextTithiKshaya = !nextAtTodayKutupa && !nextAtTomorrowKutupa;

      // Determine if we should show this next tithi's shraddha TODAY
      bool showNextTithiToday = false;
      if (nextAtTodayKutupa) {
        // Next tithi IS at today's Kutupa → shraddha today
        showNextTithiToday = true;
      } else if (isNextTithiKshaya) {
        // Kshaye Purva: Kshaya tithi → shraddha on first day (today)
        showNextTithiToday = true;
      }
      // If only at tomorrow's Kutupa → tomorrow's shraddha, don't show here

      if (showNextTithiToday) {
        // Build next tithi shraddha name
        if (ntIsAmavasya || ntIsPurnima) {
          nextTithiShraddha = '$amantaName $ntTithiName ಶ್ರಾದ್ಧ';
        } else {
          nextTithiShraddha = '$amantaName $ntPakshaName $ntTithiName ಶ್ರಾದ್ಧ';
        }

        nextTithiEndTime = Ephemeris.formatTimeFromJd(nextTithiEndJd, tzOffset: tzOffset);

        if (isNextTithiKshaya) {
          nextTithiStatus = '⚠️ $ntPakshaName $ntTithiName — ಕ್ಷಯ ತಿಥಿ\n📜 ಕ್ಷಯೇ ಪೂರ್ವ — ಇಂದು (ಪ್ರಥಮ ದಿನ) ಶ್ರಾದ್ಧ ಮಾಡಬೇಕು';
        } else {
          nextTithiStatus = '✅ $ntPakshaName $ntTithiName — ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ';
        }
      }
    }

    String ruleText;
    if (isKshayaTithi) {
      ruleText = 'ನಿಯಮ: ಶ್ರಾದ್ಧ ತಿಥಿ ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇರಬೇಕು\nಕ್ಷಯೇ ಪೂರ್ವ: ಕ್ಷಯ ತಿಥಿಯಲ್ಲಿ ಪ್ರಥಮ ದಿನ ಶ್ರಾದ್ಧ ಮಾಡಬೇಕು';
    } else {
      ruleText = 'ನಿಯಮ: ಶ್ರಾದ್ಧ ತಿಥಿ ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇರಬೇಕು';
    }

    // ── Pitru Paksha / Mahalaya ──
    int krishnaIdx = -1;
    if (isKrishna) {
      krishnaIdx = isAmavasya ? 14 : tithiIndex - 15;
    }

    if (isPitruPaksha) {
      return ShraddhaInfo(
        varshikaChandraAmanta: varshikaChandraAmanta,
        varshikaChandraPournimanta: varshikaChandraPournimanta,
        varshikaSoura: varshikaSoura,
        isPitruPaksha: true,
        pitruPakshaDay: _krishnaTithiKn[krishnaIdx],
        significance: _pitruPakshaSignificanceKn[krishnaIdx],
        isSarvaPitru: krishnaIdx == 14,
        isBharaniShraddha: (krishnaIdx == 1 || krishnaIdx == 2) && nakshatraIndex == 1,
        isAvidhavaNavami: krishnaIdx == 8,
        isGhataChaturdashi: krishnaIdx == 13,
        aparahnaStart: kutupaStartTime,
        aparahnaEnd: kutupaEndTime,
        ruleText: ruleText,
        isTithiPresentAtAparahna: isTithiPresent,
        tithiStatusAtAparahna: tithiStatus,
        aparahnaStartGhati: kutupaGhatiStr,
        tithiEndTimeForRule: tithiEndTimeForRule,
        sunriseTithiName: '$pakshaName $tithiName',
        aparahnaShraddha: aparahnaShraddha,
        aparahnaTimeStart: aparahnaStartTimeStr,
        aparahnaTimeEnd: aparahnaEndTimeStr,
        nextTithiShraddha: nextTithiShraddha,
        nextTithiStatus: nextTithiStatus,
        nextTithiEndTime: nextTithiEndTime,
      );
    }

    return ShraddhaInfo(
      varshikaChandraAmanta: varshikaChandraAmanta,
      varshikaChandraPournimanta: varshikaChandraPournimanta,
      varshikaSoura: varshikaSoura,
      isSarvaPitru: isAmavasya,
      aparahnaStart: kutupaStartTime,
      aparahnaEnd: kutupaEndTime,
      ruleText: ruleText,
      isTithiPresentAtAparahna: isTithiPresent,
      tithiStatusAtAparahna: tithiStatus,
      aparahnaStartGhati: kutupaGhatiStr,
      tithiEndTimeForRule: tithiEndTimeForRule,
      sunriseTithiName: '$pakshaName $tithiName',
      aparahnaShraddha: aparahnaShraddha,
      aparahnaTimeStart: aparahnaStartTimeStr,
      aparahnaTimeEnd: aparahnaEndTimeStr,
      nextTithiShraddha: nextTithiShraddha,
      nextTithiStatus: nextTithiStatus,
      nextTithiEndTime: nextTithiEndTime,
    );
  }
}
