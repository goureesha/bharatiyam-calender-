/// Shraddha Calculator — Ancestor ritual dates and daily Shraddha Nirnaya.
///
/// Covers:
/// - Pitru Paksha (Mahalaya) identification and per-tithi significance
/// - Daily Shraddha Nirnaya for every day (both Shukla and Krishna Paksha)
/// - Special Shraddha days (Bharani, Avidhava Navami, Vyatipata, Vaidhriti, etc.)
/// - Monthly tithi matching

class ShraddhaInfo {
  final bool isPitruPaksha;
  final String pitruPakshaDay;     // e.g. "ಕೃಷ್ಣ ಏಕಾದಶಿ" during Pitru Paksha
  final String significance;       // Kannada significance text
  final bool isSarvaPitru;         // Mahalaya Amavasya — for all ancestors
  final bool isBharaniShraddha;    // Bharani nakshatra + Pitru Paksha
  final bool isAvidhavaNavami;     // K9 — married women
  final bool isGhataChaturdashi;   // K14 — accidental death
  final bool isMonthlyShraddha;    // Monthly tithi match day
  final String monthlyNote;        // Note about monthly shraddha
  // Daily Shraddha Nirnaya
  final String dailyNirnaya;       // Today's shraddha suitability note
  final bool isShraddhaYogya;      // Is today suitable for shraddha?
  final List<String> shraddhaGuna; // Positive factors
  final List<String> shraddhaDosha;// Negative factors
  const ShraddhaInfo({
    this.isPitruPaksha = false,
    this.pitruPakshaDay = '',
    this.significance = '',
    this.isSarvaPitru = false,
    this.isBharaniShraddha = false,
    this.isAvidhavaNavami = false,
    this.isGhataChaturdashi = false,
    this.isMonthlyShraddha = false,
    this.monthlyNote = '',
    this.dailyNirnaya = '',
    this.isShraddhaYogya = false,
    this.shraddhaGuna = const [],
    this.shraddhaDosha = const [],
  });
}

class ShraddhaCalculator {

  /// Kannada tithi names for Krishna Paksha (used in Pitru Paksha)
  static const _krishnaTithiKn = [
    'ಕೃಷ್ಣ ಪ್ರತಿಪದಾ',    // K1
    'ಕೃಷ್ಣ ದ್ವಿತೀಯಾ',    // K2
    'ಕೃಷ್ಣ ತೃತೀಯಾ',      // K3
    'ಕೃಷ್ಣ ಚತುರ್ಥೀ',     // K4
    'ಕೃಷ್ಣ ಪಂಚಮೀ',       // K5
    'ಕೃಷ್ಣ ಷಷ್ಠೀ',       // K6
    'ಕೃಷ್ಣ ಸಪ್ತಮೀ',      // K7
    'ಕೃಷ್ಣ ಅಷ್ಟಮೀ',      // K8
    'ಕೃಷ್ಣ ನವಮೀ',        // K9
    'ಕೃಷ್ಣ ದಶಮೀ',        // K10
    'ಕೃಷ್ಣ ಏಕಾದಶಿ',      // K11
    'ಕೃಷ್ಣ ದ್ವಾದಶಿ',     // K12
    'ಕೃಷ್ಣ ತ್ರಯೋದಶಿ',    // K13
    'ಕೃಷ್ಣ ಚತುರ್ದಶಿ',    // K14
    'ಅಮಾವಾಸ್ಯೆ',          // Amavasya
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

  /// Tithis that are Shraddha-yogya (suitable for shraddha) in BOTH pakshas
  /// Based on Dharmasindhu / Nirnayasindhu rules:
  /// Amavasya, Purnima, Ashtami, Chaturdashi, Dvadashi, Sankranti are generally good.
  /// Ekadashi, Chaturthi, Shashthi are generally avoided.
  static const _shraddhaYogyaTithis = {
    0, 1, 2, 3, 4, 5, 7, 9, 11, 14,   // Shukla: Prat-Shashti, Ashtami, Dashami, Dvadashi, Purnima
    15, 16, 17, 18, 19, 20, 22, 24, 26, 28, 29, // Krishna: most + Amavasya
  };

  /// Tithis that are NOT suitable for shraddha (varjya tithis)
  static const _shraddhaVarjyaTithis = {
    6,   // Shukla Saptami (some texts)
    10,  // Shukla Ekadashi
    25,  // Krishna Ekadashi
  };

  /// Nakshatras suitable for shraddha
  static const _shraddhaYogyaNakshatras = {
    0,  // Ashwini
    1,  // Bharani (especially good - Pitru Nakshatra)
    3,  // Rohini
    9,  // Magha (Pitru Nakshatra)
    10, // Purva Phalguni
    11, // Uttara Phalguni
    12, // Hasta
    16, // Anuradha
    18, // Mula
    20, // Uttarashada
    21, // Shravana
    24, // Purva Bhadra
    25, // Uttara Bhadra
    26, // Revati
  };

  /// Nakshatras to avoid for shraddha
  static const _shraddhaVarjyaNakshatras = {
    5,  // Ardra
    6,  // Punarvasu
    14, // Swati
    22, // Dhanishta
  };

  /// Yogas that are special for shraddha
  /// Vyatipata (y16) and Vaidhriti (y26) are extremely auspicious for shraddha
  static const _shraddhaSpecialYogas = {16, 26};

  /// Yogas to avoid for shraddha
  static const _shraddhaVarjyaYogas = {8, 9, 12}; // Shula, Ganda, Vyaghata

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
    required int yogaIndex,
    required int varaIndex,
    required String amantaMasa,
  }) {
    final isKrishna = tithiIndex >= 15;
    final isAmavasya = tithiIndex == 29;
    final isPurnima = tithiIndex == 14;
    final isPitruPakshaMasa = _isPitruPakshaMasa(amantaMasa);
    final isPitruPaksha = isPitruPakshaMasa && isKrishna;

    int krishnaIdx = -1;
    if (isKrishna) {
      krishnaIdx = tithiIndex >= 15 ? tithiIndex - 15 : 14;
    }

    // ── Daily Shraddha Nirnaya (applies to ALL days, both pakshas) ──
    final guna = <String>[];
    final dosha = <String>[];

    // Tithi-based
    if (isAmavasya) {
      guna.add('ಅಮಾವಾಸ್ಯೆ — ಎಲ್ಲ ಪಿತೃಗಳ ಶ್ರಾದ್ಧಕ್ಕೆ ಶ್ರೇಷ್ಠ');
    } else if (isPurnima) {
      guna.add('ಹುಣ್ಣಿಮೆ — ಶ್ರಾದ್ಧಕ್ಕೆ ಯೋಗ್ಯ ದಿನ');
    }
    if (_shraddhaVarjyaTithis.contains(tithiIndex)) {
      dosha.add('ಏಕಾದಶಿ ತಿಥಿ — ಶ್ರಾದ್ಧ ವರ್ಜ್ಯ');
    }

    // Nakshatra-based
    if (nakshatraIndex == 1) {
      guna.add('ಭರಣಿ ನಕ್ಷತ್ರ — ಪಿತೃ ನಕ್ಷತ್ರ, ಶ್ರಾದ್ಧಕ್ಕೆ ಅತ್ಯುತ್ತಮ');
    } else if (nakshatraIndex == 9) {
      guna.add('ಮಘಾ ನಕ್ಷತ್ರ — ಪಿತೃ ನಕ್ಷತ್ರ, ಶ್ರಾದ್ಧಕ್ಕೆ ಉತ್ತಮ');
    } else if (_shraddhaYogyaNakshatras.contains(nakshatraIndex)) {
      guna.add('ಶ್ರಾದ್ಧ ಯೋಗ್ಯ ನಕ್ಷತ್ರ');
    }
    if (_shraddhaVarjyaNakshatras.contains(nakshatraIndex)) {
      dosha.add('ಶ್ರಾದ್ಧ ವರ್ಜ್ಯ ನಕ್ಷತ್ರ');
    }

    // Yoga-based
    if (_shraddhaSpecialYogas.contains(yogaIndex)) {
      final yogaName = yogaIndex == 16 ? 'ವ್ಯತೀಪಾತ' : 'ವೈಧೃತಿ';
      guna.add('$yogaName ಯೋಗ — ಶ್ರಾದ್ಧಕ್ಕೆ ಅತಿ ಶ್ರೇಷ್ಠ');
    }
    if (_shraddhaVarjyaYogas.contains(yogaIndex)) {
      dosha.add('ಶ್ರಾದ್ಧ ವರ್ಜ್ಯ ಯೋಗ');
    }

    // Vara-based (Tuesday is inauspicious for shraddha in some texts)
    if (varaIndex == 2) {
      dosha.add('ಮಂಗಳವಾರ — ಕೆಲವು ಗ್ರಂಥಗಳಲ್ಲಿ ಶ್ರಾದ್ಧ ವರ್ಜ್ಯ');
    }

    // Overall suitability
    final isShraddhaYogya = dosha.isEmpty || guna.isNotEmpty;

    // Build daily nirnaya text
    String dailyNirnaya;
    if (guna.isNotEmpty && dosha.isEmpty) {
      dailyNirnaya = 'ಇಂದು ಶ್ರಾದ್ಧಕ್ಕೆ ಯೋಗ್ಯ ದಿನ';
    } else if (guna.isEmpty && dosha.isNotEmpty) {
      dailyNirnaya = 'ಇಂದು ಶ್ರಾದ್ಧಕ್ಕೆ ವರ್ಜ್ಯ ದಿನ';
    } else if (guna.isNotEmpty && dosha.isNotEmpty) {
      dailyNirnaya = 'ಇಂದು ಶ್ರಾದ್ಧ — ಗುಣ ಮತ್ತು ದೋಷ ಎರಡೂ ಇವೆ';
    } else {
      dailyNirnaya = 'ಇಂದು ಶ್ರಾದ್ಧಕ್ಕೆ ಸಾಮಾನ್ಯ ದಿನ';
    }

    // ── Monthly Shraddha (tithi match for any day) ──
    // If someone died on this tithi, today is their monthly shraddha
    final tithiInPaksha = isKrishna ? tithiIndex - 15 : tithiIndex;
    final pakshaName = isKrishna ? 'ಕೃಷ್ಣ' : 'ಶುಕ್ಲ';
    final tithiNames = [
      'ಪ್ರತಿಪದಾ', 'ದ್ವಿತೀಯಾ', 'ತೃತೀಯಾ', 'ಚತುರ್ಥೀ', 'ಪಂಚಮೀ',
      'ಷಷ್ಠೀ', 'ಸಪ್ತಮೀ', 'ಅಷ್ಟಮೀ', 'ನವಮೀ', 'ದಶಮೀ',
      'ಏಕಾದಶಿ', 'ದ್ವಾದಶಿ', 'ತ್ರಯೋದಶಿ', 'ಚತುರ್ದಶಿ',
    ];
    String monthlyNote;
    if (isAmavasya) {
      monthlyNote = 'ಅಮಾವಾಸ್ಯೆ — ಎಲ್ಲ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ ದಿನ';
    } else if (isPurnima) {
      monthlyNote = 'ಹುಣ್ಣಿಮೆ — ಹುಣ್ಣಿಮೆ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ';
    } else if (tithiInPaksha >= 0 && tithiInPaksha < 14) {
      monthlyNote = '$pakshaName ${tithiNames[tithiInPaksha]} — ಈ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ ದಿನ';
    } else {
      monthlyNote = '';
    }

    // ── Pitru Paksha (Krishna Paksha of Bhadrapada) ──
    if (isPitruPaksha) {
      return ShraddhaInfo(
        isPitruPaksha: true,
        pitruPakshaDay: _krishnaTithiKn[krishnaIdx],
        significance: _pitruPakshaSignificanceKn[krishnaIdx],
        isSarvaPitru: krishnaIdx == 14,
        isBharaniShraddha: (krishnaIdx == 1 || krishnaIdx == 2) && nakshatraIndex == 1,
        isAvidhavaNavami: krishnaIdx == 8,
        isGhataChaturdashi: krishnaIdx == 13,
        isMonthlyShraddha: true,
        monthlyNote: monthlyNote,
        dailyNirnaya: dailyNirnaya,
        isShraddhaYogya: true, // Pitru Paksha is always yogya
        shraddhaGuna: [...guna, 'ಪಿತೃ ಪಕ್ಷ — ಶ್ರಾದ್ಧಕ್ಕೆ ಅತ್ಯಂತ ಪವಿತ್ರ ಕಾಲ'],
        shraddhaDosha: dosha,
      );
    }

    return ShraddhaInfo(
      isMonthlyShraddha: true,
      monthlyNote: monthlyNote,
      isSarvaPitru: isAmavasya,
      dailyNirnaya: dailyNirnaya,
      isShraddhaYogya: isShraddhaYogya,
      shraddhaGuna: guna,
      shraddhaDosha: dosha,
    );
  }
}
