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
  final bool isTithiPresentAtAparahna; // Does tithi extend into aparahna?
  final String tithiStatusAtAparahna;  // Status text
  final String aparahnaStartGhati;  // Ghati-vighati from sunrise
  final String tithiEndTimeForRule; // Tithi end time used for rule check

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

  /// Calculate Aparahna timing.
  /// Day is divided into 5 equal parts (Panchabhaga):
  /// 1. Pratah  2. Sangava  3. Madhyahna  4. Aparahna  5. Sayahna
  /// Aparahna = 4th part = sunrise + (3/5)*dayDuration to sunrise + (4/5)*dayDuration
  static Map<String, double> _calcAparahna(double sunriseJd, double sunsetJd) {
    final dayDuration = sunsetJd - sunriseJd;
    final partDuration = dayDuration / 5.0;
    return {
      'startJd': sunriseJd + 3 * partDuration,
      'endJd': sunriseJd + 4 * partDuration,
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

    // ── Aparahna Rule ──
    // Rule: ತಿಥಿ ಅಪರಾಹ್ನ ಆರಂಭದಿಂದ ಕನಿಷ್ಠ ೨ ಘಟಿ ಇರಬೇಕು
    // 2 ghati = 48 minutes = 48/1440 days
    final aparahna = _calcAparahna(sunriseJd, sunsetJd);
    final aparahnaStartJd = aparahna['startJd']!;
    final aparahnaEndJd = aparahna['endJd']!;
    final twoGhatiJd = 2.0 / 60.0; // 2 ghati in days (2/60 of a day = 48 min)
    final ruleCheckJd = aparahnaStartJd + twoGhatiJd;

    final aparahnaStartTime = Ephemeris.formatTimeFromJd(aparahnaStartJd, tzOffset: tzOffset);
    final aparahnaEndTime = Ephemeris.formatTimeFromJd(aparahnaEndJd, tzOffset: tzOffset);
    final tithiEndTimeForRule = Ephemeris.formatTimeFromJd(tithiEndJd, tzOffset: tzOffset);

    // Aparahna start in ghati from sunrise
    final aparahnaStartGhati = (aparahnaStartJd - sunriseJd) * 60.0;
    final aparahnaGhatiStr = Ephemeris.formatGhati(aparahnaStartGhati);

    // Check if tithi extends past aparahna + 2 ghati
    final isTithiPresent = tithiEndJd >= ruleCheckJd;

    String tithiStatus;
    if (tithiEndJd >= aparahnaEndJd) {
      tithiStatus = '✅ ತಿಥಿ ಅಪರಾಹ್ನ ಕಾಲದಾಚೆಗೂ ಇದೆ — ಶ್ರಾದ್ಧ ಯೋಗ್ಯ';
    } else if (isTithiPresent) {
      tithiStatus = '✅ ತಿಥಿ ಅಪರಾಹ್ನ ಆರಂಭದಿಂದ ೨ ಘಟಿ ಮೇಲೆ ಇದೆ — ಶ್ರಾದ್ಧ ಯೋಗ್ಯ';
    } else if (tithiEndJd >= aparahnaStartJd) {
      tithiStatus = '⚠️ ತಿಥಿ ಅಪರಾಹ್ನದಲ್ಲಿ ೨ ಘಟಿ ಇಲ್ಲ — ಹಿಂದಿನ ದಿನ ಶ್ರಾದ್ಧ ಮಾಡಬೇಕು';
    } else {
      tithiStatus = '⚠️ ತಿಥಿ ಅಪರಾಹ್ನಕ್ಕೆ ಮೊದಲೇ ಮುಗಿಯುತ್ತದೆ — ಹಿಂದಿನ ದಿನ ಶ್ರಾದ್ಧ';
    }

    final ruleText = 'ನಿಯಮ: ತಿಥಿ ಅಪರಾಹ್ನ ಆರಂಭದಿಂದ ಕನಿಷ್ಠ ೨ ಘಟಿ (೪೮ ನಿಮಿಷ) ಇರಬೇಕು';

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
    );
  }
}
