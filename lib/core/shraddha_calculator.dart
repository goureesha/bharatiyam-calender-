/// Shraddha Calculator — Varshika Shraddha Nirnaya and Mahalaya Shraddha.
///
/// Covers:
/// - Varshika Shraddha: Annual ancestor rites based on masa+paksha+tithi
///   - Chandra Mana (Amanta): uses amanta masa
///   - Chandra Mana (Pournimanta): uses pournimanta masa
///   - Soura Mana: uses soura masa
/// - Mahalaya Shraddha: Pitru Paksha (Krishna Paksha of Bhadrapada)
///   - Per-tithi significance during Pitru Paksha
///   - Special days: Bharani, Avidhava Navami, Ghata Chaturdashi, Sarva Pitru Amavasya

class ShraddhaInfo {
  // Varshika Shraddha (annual)
  final String varshikaChandraAmanta;    // e.g. "ಆಷಾಢ ಶುಕ್ಲ ಪ್ರತಿಪದಾ ಶ್ರಾದ್ಧ"
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
  });
}

class ShraddhaCalculator {

  /// Tithi names (within paksha, 0-13 + Purnima/Amavasya)
  static const _tithiNames = [
    'ಪ್ರತಿಪದಾ', 'ದ್ವಿತೀಯಾ', 'ತೃತೀಯಾ', 'ಚತುರ್ಥೀ', 'ಪಂಚಮೀ',
    'ಷಷ್ಠೀ', 'ಸಪ್ತಮೀ', 'ಅಷ್ಟಮೀ', 'ನವಮೀ', 'ದಶಮೀ',
    'ಏಕಾದಶಿ', 'ದ್ವಾದಶಿ', 'ತ್ರಯೋದಶಿ', 'ಚತುರ್ದಶಿ',
  ];

  /// Chandra Masa names (Amanta/Pournimanta share same names)
  static const _chandraMasaNames = [
    'ಚೈತ್ರ', 'ವೈಶಾಖ', 'ಜ್ಯೇಷ್ಠ', 'ಆಷಾಢ',
    'ಶ್ರಾವಣ', 'ಭಾದ್ರಪದ', 'ಆಶ್ವಿನ', 'ಕಾರ್ತಿಕ',
    'ಮಾರ್ಗಶಿರ', 'ಪುಷ್ಯ', 'ಮಾಘ', 'ಫಾಲ್ಗುಣ',
  ];

  /// Soura Masa names
  static const _souraMasaNames = [
    'ಮೇಷ', 'ವೃಷಭ', 'ಮಿಥುನ', 'ಕರ್ಕ',
    'ಸಿಂಹ', 'ಕನ್ಯಾ', 'ತುಲಾ', 'ವೃಶ್ಚಿಕ',
    'ಧನು', 'ಮಕರ', 'ಕುಂಭ', 'ಮೀನ',
  ];

  /// Pitru Paksha significance per tithi (Kannada)
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

  /// Krishna Paksha tithi names for Pitru Paksha display
  static const _krishnaTithiKn = [
    'ಕೃಷ್ಣ ಪ್ರತಿಪದಾ', 'ಕೃಷ್ಣ ದ್ವಿತೀಯಾ', 'ಕೃಷ್ಣ ತೃತೀಯಾ',
    'ಕೃಷ್ಣ ಚತುರ್ಥೀ', 'ಕೃಷ್ಣ ಪಂಚಮೀ', 'ಕೃಷ್ಣ ಷಷ್ಠೀ',
    'ಕೃಷ್ಣ ಸಪ್ತಮೀ', 'ಕೃಷ್ಣ ಅಷ್ಟಮೀ', 'ಕೃಷ್ಣ ನವಮೀ',
    'ಕೃಷ್ಣ ದಶಮೀ', 'ಕೃಷ್ಣ ಏಕಾದಶಿ', 'ಕೃಷ್ಣ ದ್ವಾದಶಿ',
    'ಕೃಷ್ಣ ತ್ರಯೋದಶಿ', 'ಕೃಷ್ಣ ಚತುರ್ದಶಿ', 'ಅಮಾವಾಸ್ಯೆ',
  ];

  /// Resolve a masa key (e.g. "cm3" or "ಆಷಾಢ") to a display name
  static String _resolveChandraMasa(String masaKey) {
    // Try cmN keys
    if (masaKey.startsWith('cm') && masaKey.length <= 4) {
      final idx = int.tryParse(masaKey.substring(2));
      if (idx != null && idx >= 0 && idx < 12) return _chandraMasaNames[idx];
    }
    // Already Kannada name
    for (final name in _chandraMasaNames) {
      if (masaKey.contains(name)) return name;
    }
    return masaKey;
  }

  /// Resolve soura masa key (e.g. "sm2" or "ಮಿಥುನ") to a display name
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

  static ShraddhaInfo calculate({
    required int tithiIndex,
    required int nakshatraIndex,
    required String amantaMasa,
    required String pournimantaMasa,
    required String souraMasa,
  }) {
    final isKrishna = tithiIndex >= 15;
    final isAmavasya = tithiIndex == 29;
    final isPurnima = tithiIndex == 14;
    final isPitruPakshaMasa = _isPitruPakshaMasa(amantaMasa);
    final isPitruPaksha = isPitruPakshaMasa && isKrishna;

    // ── Varshika Shraddha (for every day) ──
    // Build: "MasaName PakshaName TithiName ಶ್ರಾದ್ಧ"
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

    if (isAmavasya) {
      varshikaChandraAmanta = '$amantaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaChandraPournimanta = '$pournimantaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaSoura = '$souraName $tithiName ಶ್ರಾದ್ಧ';
    } else if (isPurnima) {
      varshikaChandraAmanta = '$amantaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaChandraPournimanta = '$pournimantaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaSoura = '$souraName $tithiName ಶ್ರಾದ್ಧ';
    } else {
      varshikaChandraAmanta = '$amantaName $pakshaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaChandraPournimanta = '$pournimantaName $pakshaName $tithiName ಶ್ರಾದ್ಧ';
      varshikaSoura = '$souraName $pakshaName $tithiName ಶ್ರಾದ್ಧ';
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
      );
    }

    return ShraddhaInfo(
      varshikaChandraAmanta: varshikaChandraAmanta,
      varshikaChandraPournimanta: varshikaChandraPournimanta,
      varshikaSoura: varshikaSoura,
      isSarvaPitru: isAmavasya,
    );
  }
}
