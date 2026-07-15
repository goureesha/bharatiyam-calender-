/// Shraddha Calculator — Varshika Shraddha Nirnaya and Mahalaya Shraddha.
///
/// Covers:
/// - Varshika Shraddha: Annual ancestor rites based on masa+paksha+tithi
///   - Chandra Mana (Amanta/Pournimanta) and Soura Mana
/// - Mahalaya Shraddha: Pitru Paksha (Krishna Paksha of Bhadrapada)
/// - Aparahna Shraddha Rule: Tithi must be present ≥2 ghati after Aparahna start

import 'ephemeris.dart';

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

  // Aparahna Shraddha Rule
  final String aparahnaStart;       // Clock time
  final String aparahnaEnd;         // Clock time
  final String ruleText;            // Rule description
  final bool isTithiPresentAtAparahna; // Does sunrise tithi extend into aparahna?
  final String tithiStatusAtAparahna;  // Status text
  final String aparahnaStartGhati;  // Ghati-vighati from sunrise
  final String tithiEndTimeForRule; // Tithi end time used for rule check
  final String aparahnaShraddha;    // Which shraddha can be done at aparahna

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
    this.aparahnaShraddha = '',
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

    String varshikaChandraAmanta;
    String varshikaChandraPournimanta;
    String varshikaSoura;

    if (isAmavasya || isPurnima) {
      varshikaChandraAmanta = '$amantaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaChandraPournimanta = '$pournimantaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaSoura = '$souraName $tithiName ಶ್ರಾದ್ಧ';
    } else {
      varshikaChandraAmanta = '$amantaName $pakshaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaChandraPournimanta = '$pournimantaName $pakshaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaSoura = '$souraName $pakshaName $tithiName ಶ್ರಾದ್ಧ';
    }

    // ── Kutupa Kala Rule ──
    // Kutupa = 8th of 15 day muhurtas
    final kutupa = _calcKutupa(sunriseJd, sunsetJd);
    final kutupaStartJd = kutupa['startJd']!;
    final kutupaEndJd = kutupa['endJd']!;

    final kutupaStartTime = Ephemeris.formatTimeFromJd(kutupaStartJd, tzOffset: tzOffset);
    final kutupaEndTime = Ephemeris.formatTimeFromJd(kutupaEndJd, tzOffset: tzOffset);
    final tithiEndTimeForRule = Ephemeris.formatTimeFromJd(tithiEndJd, tzOffset: tzOffset);

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

    String aparahnaShraddha;
    if (kpIsAmavasya || kpIsPurnima) {
      aparahnaShraddha = '$amantaName $kpTithiName ಶ್ರಾದ್ಧ ಮಾಡಬಹುದು';
    } else {
      aparahnaShraddha = '$amantaName $kpPakshaName $kpTithiName ಶ್ರಾದ್ಧ ಮಾಡಬಹುದು';
    }

    // ── Kshaya Tithi detection ──
    // If tithi started after yesterday's Kutupa AND ends before today's Kutupa
    // → it misses Kutupa on both days → Kshaya Tithi
    final isKshayaTithi = !isTithiPresent &&
        tithiStartJd > yesterdayKutupaEndJd &&
        tithiEndJd < kutupaStartJd;

    String tithiStatus;
    if (isKshayaTithi) {
      // Kshaye Purva: shraddha on the first day (when tithi begins)
      tithiStatus = '⚠️ $pakshaName $tithiName — ಕ್ಷಯ ತಿಥಿ (ಕುತುಪ ಕಾಲ ಇಲ್ಲ)\n📜 ಕ್ಷಯೇ ಪೂರ್ವ — ತಿಥಿ ಆರಂಭ ದಿನ (ಹಿಂದಿನ ದಿನ) ಶ್ರಾದ್ಧ ಮಾಡಬೇಕು';
    } else if (isSecondDay) {
      tithiStatus = '⚠️ $pakshaName $tithiName — ಎರಡು ದಿನ ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ\n📌 ಹಿಂದಿನ ದಿನ (ಪ್ರಥಮ ದಿನ) ಶ್ರಾದ್ಧ ಯೋಗ್ಯ';
    } else if (isFirstDay) {
      tithiStatus = '✅ $pakshaName $tithiName — ಎರಡು ದಿನ ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ\n📌 ಇಂದು (ಪ್ರಥಮ ದಿನ) ಶ್ರಾದ್ಧ ಮಾಡಬೇಕು';
    } else if (tithiEndJd >= kutupaEndJd) {
      tithiStatus = '✅ $pakshaName $tithiName — ಕುತುಪ ಕಾಲದಾಚೆಗೂ ಇದೆ';
    } else if (isTithiPresent) {
      tithiStatus = '✅ $pakshaName $tithiName — ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇದೆ';
    } else {
      tithiStatus = '⚠️ $pakshaName $tithiName — ಕುತುಪ ಕಾಲಕ್ಕೆ ಮೊದಲೇ ಮುಗಿಯುತ್ತದೆ';
    }

    if (!isTithiPresent && kutupaTithiIdx != tithiIndex) {
      tithiStatus += '\n📌 ಕುತುಪ ಕಾಲದಲ್ಲಿ $kpPakshaName $kpTithiName ಇದೆ';
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
        aparahnaStart: aparahnaStartTime,
        aparahnaEnd: aparahnaEndTime,
        ruleText: ruleText,
        isTithiPresentAtAparahna: isTithiPresent,
        tithiStatusAtAparahna: tithiStatus,
        aparahnaStartGhati: aparahnaGhatiStr,
        tithiEndTimeForRule: tithiEndTimeForRule,
        aparahnaShraddha: aparahnaShraddha,
      );
    }

    return ShraddhaInfo(
      varshikaChandraAmanta: varshikaChandraAmanta,
      varshikaChandraPournimanta: varshikaChandraPournimanta,
      varshikaSoura: varshikaSoura,
      isSarvaPitru: isAmavasya,
      aparahnaStart: aparahnaStartTime,
      aparahnaEnd: aparahnaEndTime,
      ruleText: ruleText,
      isTithiPresentAtAparahna: isTithiPresent,
      tithiStatusAtAparahna: tithiStatus,
      aparahnaStartGhati: aparahnaGhatiStr,
      tithiEndTimeForRule: tithiEndTimeForRule,
      aparahnaShraddha: aparahnaShraddha,
    );
  }
}
