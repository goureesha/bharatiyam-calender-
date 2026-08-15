/// Shraddha Calculator â€” Varshika Shraddha Nirnaya and Mahalaya Shraddha.
///
/// Covers:
/// - Varshika Shraddha: Annual ancestor rites based on masa+paksha+tithi
///   - Chandra Mana (Amanta/Pournimanta) and Soura Mana
/// - Mahalaya Shraddha: Pitru Paksha (Krishna Paksha of Bhadrapada)
/// - Aparahna Shraddha Rule: Tithi must be present â‰¥2 ghati after Aparahna start

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
  final String sunriseTithiName;    // Sunrise tithi name (e.g. 'à²•à³ƒà²·à³à²£ à²·à²·à³à² à²¿')
  final String aparahnaShraddha;    // Which shraddha can be done
  final String aparahnaTimeStart;   // Aparahna (4th of 5 parts) start
  final String aparahnaTimeEnd;     // Aparahna (4th of 5 parts) end

  // Next tithi's shraddha (when sunrise tithi ends during the day)
  final String nextTithiShraddha;   // Next tithi's shraddha name
  final String nextTithiStatus;     // Next tithi's kutupa status
  final String nextTithiEndTime;    // Next tithi's end time

  // Kshaya / Multi-day scenario tracking
  final bool isKshayaTithi;
  final bool isFirstDay;
  final bool isSecondDay;
  final String kshayaTithiExplanation;
  final String multiDayExplanation;

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
    this.isKshayaTithi = false,
    this.isFirstDay = false,
    this.isSecondDay = false,
    this.kshayaTithiExplanation = '',
    this.multiDayExplanation = '',
  });
}

class ShraddhaCalculator {

  static const _tithiNames = [
    'à²ªà³à²°à²¤à²¿à²ªà²¦à²¾', 'à²¦à³à²µà²¿à²¤à³€à²¯à²¾', 'à²¤à³ƒà²¤à³€à²¯à²¾', 'à²šà²¤à³à²°à³à²¥à³€', 'à²ªà²‚à²šà²®à³€',
    'à²·à²·à³à² à³€', 'à²¸à²ªà³à²¤à²®à³€', 'à²…à²·à³à²Ÿà²®à³€', 'à²¨à²µà²®à³€', 'à²¦à²¶à²®à³€',
    'à²à²•à²¾à²¦à²¶à²¿', 'à²¦à³à²µà²¾à²¦à²¶à²¿', 'à²¤à³à²°à²¯à³‹à²¦à²¶à²¿', 'à²šà²¤à³à²°à³à²¦à²¶à²¿',
  ];

  static const _chandraMasaNames = [
    'à²šà³ˆà²¤à³à²°', 'à²µà³ˆà²¶à²¾à²–', 'à²œà³à²¯à³‡à²·à³à² ', 'à²†à²·à²¾à²¢',
    'à²¶à³à²°à²¾à²µà²£', 'à²­à²¾à²¦à³à²°à²ªà²¦', 'à²†à²¶à³à²µà²¿à²¨', 'à²•à²¾à²°à³à²¤à²¿à²•',
    'à²®à²¾à²°à³à²—à²¶à²¿à²°', 'à²ªà³à²·à³à²¯', 'à²®à²¾à²˜', 'à²«à²¾à²²à³à²—à³à²£',
  ];

  static const _souraMasaNames = [
    'à²®à³‡à²·', 'à²µà³ƒà²·à²­', 'à²®à²¿à²¥à³à²¨', 'à²•à²°à³à²•',
    'à²¸à²¿à²‚à²¹', 'à²•à²¨à³à²¯à²¾', 'à²¤à³à²²à²¾', 'à²µà³ƒà²¶à³à²šà²¿à²•',
    'à²§à²¨à³', 'à²®à²•à²°', 'à²•à³à²‚à²­', 'à²®à³€à²¨',
  ];

  static const _pitruPakshaSignificanceKn = [
    'à²ªà³à²°à²¤à²¿à²ªà²¦à²¾ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²®à³ƒà²¤à²°à²¾à²¦ à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§',
    'à²¦à³à²µà²¿à²¤à³€à²¯à²¾ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²®à³ƒà²¤à²°à²¾à²¦ à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§',
    'à²¤à³ƒà²¤à³€à²¯à²¾ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²®à³ƒà²¤à²°à²¾à²¦ à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§',
    'à²šà²¤à³à²°à³à²¥à³€ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²®à³ƒà²¤à²°à²¾à²¦ à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§; à²¸à³à²¹à²¾à²—à²¿à²¨/à²µà²¿à²§à²µà³† à²¸à³à²¤à³à²°à³€à²¯à²°à²¿à²—à³‚',
    'à²ªà²‚à²šà²®à³€ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²®à³ƒà²¤à²°à²¾à²¦ à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§; à²…à²µà²¿à²µà²¾à²¹à²¿à²¤à²°à²¿à²—à³†',
    'à²·à²·à³à² à³€ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²®à³ƒà²¤à²°à²¾à²¦ à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§',
    'à²¸à²ªà³à²¤à²®à³€ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²®à³ƒà²¤à²°à²¾à²¦ à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§',
    'à²…à²·à³à²Ÿà²®à³€ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²®à³ƒà²¤à²°à²¾à²¦ à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§',
    'à²…à²µà²¿à²§à²µà²¾ à²¨à²µà²®à³€ â€” à²¸à³Œà²­à²¾à²—à³à²¯à²µà²¤à²¿ à²¸à³à²¤à³à²°à³€à²¯à²° à²¶à³à²°à²¾à²¦à³à²§',
    'à²¦à²¶à²®à³€ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²®à³ƒà²¤à²°à²¾à²¦ à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§',
    'à²à²•à²¾à²¦à²¶à²¿ â€” à²¸à²¨à³à²¯à²¾à²¸à²¿à²—à²³à³/à²¯à²¤à²¿à²—à²³ à²¶à³à²°à²¾à²¦à³à²§',
    'à²¦à³à²µà²¾à²¦à²¶à²¿ â€” à²¸à²¨à³à²¯à²¾à²¸à²¿à²—à²³ à²¶à³à²°à²¾à²¦à³à²§; à²µà³ˆà²·à³à²£à²µ à²¶à³à²°à²¾à²¦à³à²§',
    'à²®à²˜à²¾ à²¶à³à²°à²¾à²¦à³à²§ â€” à²¤à²¿à²¥à²¿ à²¤à²¿à²³à²¿à²¯à²¦à²µà²° à²¶à³à²°à²¾à²¦à³à²§à²•à³à²•à³† à²¸à³‚à²•à³à²¤',
    'à²˜à²¾à²¤ à²šà²¤à³à²°à³à²¦à²¶à²¿ â€” à²¶à²¸à³à²¤à³à²°/à²…à²ªà²˜à²¾à²¤/à²…à²•à²¾à²² à²®à²°à²£à²¦ à²¶à³à²°à²¾à²¦à³à²§',
    'à²¸à²°à³à²µ à²ªà²¿à²¤à³ƒ à²…à²®à²¾à²µà²¾à²¸à³à²¯à³† (à²®à²¹à²¾à²²à²¯) â€” à²Žà²²à³à²² à²ªà²¿à²¤à³ƒà²—à²³ à²¶à³à²°à²¾à²¦à³à²§',
  ];

  static const _krishnaTithiKn = [
    'à²•à³ƒà²·à³à²£ à²ªà³à²°à²¤à²¿à²ªà²¦à²¾', 'à²•à³ƒà²·à³à²£ à²¦à³à²µà²¿à²¤à³€à²¯à²¾', 'à²•à³ƒà²·à³à²£ à²¤à³ƒà²¤à³€à²¯à²¾',
    'à²•à³ƒà²·à³à²£ à²šà²¤à³à²°à³à²¥à³€', 'à²•à³ƒà²·à³à²£ à²ªà²‚à²šà²®à³€', 'à²•à³ƒà²·à³à²£ à²·à²·à³à² à³€',
    'à²•à³ƒà²·à³à²£ à²¸à²ªà³à²¤à²®à³€', 'à²•à³ƒà²·à³à²£ à²…à²·à³à²Ÿà²®à³€', 'à²•à³ƒà²·à³à²£ à²¨à²µà²®à³€',
    'à²•à³ƒà²·à³à²£ à²¦à²¶à²®à³€', 'à²•à³ƒà²·à³à²£ à²à²•à²¾à²¦à²¶à²¿', 'à²•à³ƒà²·à³à²£ à²¦à³à²µà²¾à²¦à²¶à²¿',
    'à²•à³ƒà²·à³à²£ à²¤à³à²°à²¯à³‹à²¦à²¶à²¿', 'à²•à³ƒà²·à³à²£ à²šà²¤à³à²°à³à²¦à²¶à²¿', 'à²…à²®à²¾à²µà²¾à²¸à³à²¯à³†',
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
           lower.contains('à²­à²¾à²¦à³à²°à²ªà²¦') ||
           lower.contains('cm5') ||
           lower.contains('ashwin') ||
           lower.contains('à²†à²¶à³à²µà²¿à²¨');
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

    // â”€â”€ Varshika Shraddha â”€â”€
    final pakshaName = isKrishna ? 'à²•à³ƒà²·à³à²£' : 'à²¶à³à²•à³à²²';
    String tithiName;
    if (isAmavasya) {
      tithiName = 'à²…à²®à²¾à²µà²¾à²¸à³à²¯à³†';
    } else if (isPurnima) {
      tithiName = 'à²¹à³à²£à³à²£à²¿à²®à³†';
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

    // â”€â”€ Kutupa Kala Rule â”€â”€
    // Kutupa = 8th of 15 day muhurtas
    final kutupa = _calcKutupa(sunriseJd, sunsetJd);
    final kutupaStartJd = kutupa['startJd']!;
    final kutupaEndJd = kutupa['endJd']!;

    // â”€â”€ Aparahna (4th of 5 parts) â”€â”€
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
        ? ' (à²®à²°à³à²¦à²¿à²¨)' : '';
    final tithiEndTimeForRule = '$tithiEndTimeStr$tithiEndDayLabel';

    // Kutupa start in ghati from sunrise
    final kutupaStartGhati = (kutupaStartJd - sunriseJd) * 60.0;
    final kutupaGhatiStr = Ephemeris.formatGhati(kutupaStartGhati);

    // Check if tithi is present during Kutupa Kala
    final isTithiPresent = tithiEndJd >= kutupaStartJd;

    // â”€â”€ 2-day Kutupa detection â”€â”€
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
        // Tithi at today AND tomorrow â†’ today is first day
        isFirstDay = true;
      } else if (wasAtYesterdayKutupa) {
        // Tithi at yesterday AND today â†’ today is second day
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
    final kpPakshaName = kpIsKrishna ? 'à²•à³ƒà²·à³à²£' : 'à²¶à³à²•à³à²²';
    String kpTithiName;
    if (kpIsAmavasya) {
      kpTithiName = 'à²…à²®à²¾à²µà²¾à²¸à³à²¯à³†';
    } else if (kpIsPurnima) {
      kpTithiName = 'à²¹à³à²£à³à²£à²¿à²®à³†';
    } else {
      final kpTithiInPaksha = kpIsKrishna ? kutupaTithiIdx - 15 : kutupaTithiIdx;
      kpTithiName = (kpTithiInPaksha >= 0 && kpTithiInPaksha < 14) ? _tithiNames[kpTithiInPaksha] : '';
    }

    // Build varshika and aparahna shraddha using Kutupa-determined tithi
    // (tithi and paksha are same across all 3 calendar systems, only masa changes)
    String aparahnaShraddha;
    if (kpIsAmavasya || kpIsPurnima) {
      aparahnaShraddha = '$amantaName $kpTithiName à²¶à³à²°à²¾à²¦à³à²§ à²®à²¾à²¡à²¬à²¹à³à²¦à³';
      varshikaChandraAmanta = '$amantaName $kpTithiName à²¶à³à²°à²¾à²¦à³à²§';
      varshikaChandraPournimanta = '$pournimantaName $kpTithiName à²¶à³à²°à²¾à²¦à³à²§';
      varshikaSoura = '$souraName $kpTithiName à²¶à³à²°à²¾à²¦à³à²§';
    } else {
      aparahnaShraddha = '$amantaName $kpPakshaName $kpTithiName à²¶à³à²°à²¾à²¦à³à²§ à²®à²¾à²¡à²¬à²¹à³à²¦à³';
      varshikaChandraAmanta = '$amantaName $kpPakshaName $kpTithiName à²¶à³à²°à²¾à²¦à³à²§';
      varshikaChandraPournimanta = '$pournimantaName $kpPakshaName $kpTithiName à²¶à³à²°à²¾à²¦à³à²§';
      varshikaSoura = '$souraName $kpPakshaName $kpTithiName à²¶à³à²°à²¾à²¦à³à²§';
    }

    // â”€â”€ Kshaya Tithi detection (for sunrise tithi) â”€â”€
    final isKshayaTithi = !isTithiPresent &&
        tithiStartJd > yesterdayKutupaEndJd &&
        tithiEndJd < kutupaStartJd;

    // â”€â”€ Status: based on Kutupa tithi â”€â”€
    String tithiStatus;
    if (kutupaTithiIdx == tithiIndex) {
      // Sunrise tithi IS at Kutupa
      if (isFirstDay) {
        tithiStatus = 'âœ… $kpPakshaName $kpTithiName â€” à²•à³à²¤à³à²ª à²•à²¾à²²à²¦à²²à³à²²à²¿ à²‡à²¦à³† (à²ªà³à²°à²¥à²® à²¦à²¿à²¨)';
      } else if (isSecondDay) {
        tithiStatus = 'âš ï¸ $kpPakshaName $kpTithiName â€” à²•à³à²¤à³à²ª à²•à²¾à²²à²¦à²²à³à²²à²¿ à²‡à²¦à³† (à²¦à³à²µà²¿à²¤à³€à²¯ à²¦à²¿à²¨)\nðŸ“Œ à²¹à²¿à²‚à²¦à²¿à²¨ à²¦à²¿à²¨ (à²ªà³à²°à²¥à²® à²¦à²¿à²¨) à²¶à³à²°à²¾à²¦à³à²§ à²¯à³‹à²—à³à²¯';
      } else {
        tithiStatus = 'âœ… $kpPakshaName $kpTithiName â€” à²•à³à²¤à³à²ª à²•à²¾à²²à²¦à²²à³à²²à²¿ à²‡à²¦à³†';
      }
    } else {
      // Sunrise tithi ended before Kutupa, next tithi is at Kutupa
      tithiStatus = 'âœ… $kpPakshaName $kpTithiName â€” à²•à³à²¤à³à²ª à²•à²¾à²²à²¦à²²à³à²²à²¿ à²‡à²¦à³†';
    }

    // â”€â”€ Next Tithi Shraddha â”€â”€
    // Check if the next tithi is Kshaya (misses Kutupa on both today AND tomorrow).
    // We must check even if sunrise tithi ends after sunset â€” the next tithi could
    // still start at night and end before tomorrow's Kutupa (Kshaya).
    // If Kshaya â†’ by Kshaye Purva, its shraddha is TODAY (the first day).
    // If present at today's Kutupa â†’ shraddha is also today.
    // If present only at tomorrow's Kutupa â†’ shraddha is tomorrow, not shown here.
    String nextTithiShraddha = '';
    String nextTithiStatus = '';
    String nextTithiEndTime = '';

    final nextTithiIdx = (tithiIndex + 1) % 30;
    // Check next tithi if it starts within 24 hours (before tomorrow's sunrise)
    final bool checkNextTithi = tithiEndJd < (sunriseJd + 1.0);

    if (checkNextTithi) {
      // Next tithi starts at tithiEndJd
      final ntIsKrishna = nextTithiIdx >= 15;
      final ntIsAmavasya = nextTithiIdx == 29;
      final ntIsPurnima = nextTithiIdx == 14;
      final ntPakshaName = ntIsKrishna ? 'à²•à³ƒà²·à³à²£' : 'à²¶à³à²•à³à²²';
      String ntTithiName;
      if (ntIsAmavasya) {
        ntTithiName = 'à²…à²®à²¾à²µà²¾à²¸à³à²¯à³†';
      } else if (ntIsPurnima) {
        ntTithiName = 'à²¹à³à²£à³à²£à²¿à²®à³†';
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
        // Next tithi IS at today's Kutupa â†’ shraddha today
        showNextTithiToday = true;
      } else if (isNextTithiKshaya) {
        // Kshaye Purva: Kshaya tithi â†’ shraddha on first day (today)
        showNextTithiToday = true;
      }
      // If only at tomorrow's Kutupa â†’ tomorrow's shraddha, don't show here

      if (showNextTithiToday) {
      if (showNextTithiToday) {
        // Build next tithi shraddha name
        if (ntIsAmavasya || ntIsPurnima) {
          nextTithiShraddha = '$amantaName $ntTithiName ಶ್ರಾದ್ಧ';
        } else {
          nextTithiShraddha = '$amantaName $ntPakshaName $ntTithiName ಶ್ರಾದ್ಧ';
        }

        final ntStartTimeStr = Ephemeris.formatTimeFromJd(tithiEndJd, tzOffset: tzOffset);
        nextTithiEndTime = Ephemeris.formatTimeFromJd(nextTithiEndJd, tzOffset: tzOffset);

        // Check if next tithi end is on a different day
        final ntEndMs = ((nextTithiEndJd - 2440587.5) * 86400000).round();
        final ntEndDt = DateTime.fromMillisecondsSinceEpoch(ntEndMs, isUtc: true)
            .add(Duration(milliseconds: (tzOffset * 3600000).round()));
        final ntEndDayLabel = (ntEndDt.day != sunriseDt.day || ntEndDt.month != sunriseDt.month)
            ? ' (ಮರುದಿನ)' : '';

        if (isNextTithiKshaya) {
          nextTithiStatus = '⚠️ $ntPakshaName $ntTithiName — ಕ್ಷಯ ತಿಥಿ\nಪ್ರಾರಂಭ: $ntStartTimeStr | ಅಂತ್ಯ: $nextTithiEndTime$ntEndDayLabel\nಇಂದು ಮತ್ತು ನಾಳೆ ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇಲ್ಲ\n📜 ಕ್ಷಯೇ ಪೂರ್ವ — ಇಂದು ಶ್ರಾದ್ಧ ಮಾಡಬೇಕು';
        } else {
          nextTithiStatus = '✅ $ntPakshaName $ntTithiName — ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ\nಪ್ರಾರಂಭ: $ntStartTimeStr | ಅಂತ್ಯ: $nextTithiEndTime$ntEndDayLabel';
        }
      }
    }

    String ruleText;
    if (isKshayaTithi) {
      ruleText = 'à²¨à²¿à²¯à²®: à²¶à³à²°à²¾à²¦à³à²§ à²¤à²¿à²¥à²¿ à²•à³à²¤à³à²ª à²•à²¾à²²à²¦à²²à³à²²à²¿ à²‡à²°à²¬à³‡à²•à³\nà²•à³à²·à²¯à³‡ à²ªà³‚à²°à³à²µ: à²•à³à²·à²¯ à²¤à²¿à²¥à²¿à²¯à²²à³à²²à²¿ à²ªà³à²°à²¥à²® à²¦à²¿à²¨ à²¶à³à²°à²¾à²¦à³à²§ à²®à²¾à²¡à²¬à³‡à²•à³';
    } else {
      ruleText = 'à²¨à²¿à²¯à²®: à²¶à³à²°à²¾à²¦à³à²§ à²¤à²¿à²¥à²¿ à²•à³à²¤à³à²ª à²•à²¾à²²à²¦à²²à³à²²à²¿ à²‡à²°à²¬à³‡à²•à³';
    }

    // Build Kshaya / Multi-day explanations
    String kshayaTithiExplanation = '';
    if (isKshayaTithi) {
      kshayaTithiExplanation = '$pakshaName $tithiName à²¤à²¿à²¥à²¿ à²‡à²‚à²¦à³ à²®à²¤à³à²¤à³ à²¨à²¾à²³à³† à²•à³à²¤à³à²ª à²•à²¾à²²à²¦à²²à³à²²à²¿ à²‡à²²à³à²².\n'
          'à²‡à²¦à³ à²•à³à²·à²¯ à²¤à²¿à²¥à²¿. à²•à³à²·à²¯à³‡ à²ªà³‚à²°à³à²µ à²¨à²¿à²¯à²®à²¦à²‚à²¤à³† à²‡à²‚à²¦à³ à²¶à³à²°à²¾à²¦à³à²§ à²®à²¾à²¡à²¬à³‡à²•à³.\n'
          'à²ˆ à²¤à²¿à²¥à²¿à²¯ à²®à²¤à³à²¤à³ à²®à³à²‚à²¦à²¿à²¨ à²¤à²¿à²¥à²¿à²¯ à²Žà²°à²¡à³‚ à²¶à³à²°à²¾à²¦à³à²§ à²‡à²‚à²¦à³ à²¬à²°à³à²¤à³à²¤à²¦à³†.';
    }

    String multiDayExplanation = '';
    if (isFirstDay) {
      multiDayExplanation = '$pakshaName $tithiName à²¤à²¿à²¥à²¿ à²‡à²‚à²¦à³ à²®à²¤à³à²¤à³ à²¨à²¾à²³à³† à²Žà²°à²¡à³‚ à²¦à²¿à²¨ à²•à³à²¤à³à²ª à²•à²¾à²²à²¦à²²à³à²²à²¿ à²‡à²¦à³†.\n'
          'à²ªà³à²°à²¥à²® à²¦à²¿à²¨ (à²‡à²‚à²¦à³) à²¶à³à²°à²¾à²¦à³à²§ à²®à²¾à²¡à²¬à²¹à³à²¦à³. à²¨à²¾à²³à³†à²¯à³‚ à²®à²¾à²¡à²¬à²¹à³à²¦à³.';
    } else if (isSecondDay) {
      multiDayExplanation = '$pakshaName $tithiName à²¤à²¿à²¥à²¿ à²¨à²¿à²¨à³à²¨à³† à²®à²¤à³à²¤à³ à²‡à²‚à²¦à³ à²Žà²°à²¡à³‚ à²¦à²¿à²¨ à²•à³à²¤à³à²ª à²•à²¾à²²à²¦à²²à³à²²à²¿ à²‡à²¦à³†.\n'
          'à²ªà³à²°à²¥à²® à²¦à²¿à²¨ (à²¨à²¿à²¨à³à²¨à³†) à²¶à³à²°à²¾à²¦à³à²§ à²¯à³‹à²—à³à²¯. à²†à²¦à²°à³† à²‡à²‚à²¦à³‚ à²®à²¾à²¡à²¬à²¹à³à²¦à³.';
    }

    // â”€â”€ Pitru Paksha / Mahalaya â”€â”€
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
        isKshayaTithi: isKshayaTithi,
        isFirstDay: isFirstDay,
        isSecondDay: isSecondDay,
        kshayaTithiExplanation: kshayaTithiExplanation,
        multiDayExplanation: multiDayExplanation,
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
      isKshayaTithi: isKshayaTithi,
      isFirstDay: isFirstDay,
      isSecondDay: isSecondDay,
      kshayaTithiExplanation: kshayaTithiExplanation,
      multiDayExplanation: multiDayExplanation,
    );
  }
}
