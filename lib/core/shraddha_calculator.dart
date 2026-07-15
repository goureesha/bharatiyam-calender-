/// Shraddha Calculator — Ancestor ritual dates based on tithi, nakshatra, and masa.
///
/// Covers:
/// - Pitru Paksha (Mahalaya) identification and per-tithi significance
/// - Monthly Shraddha tithi matching
/// - Special Shraddha days (Bharani, Avidhava Navami, etc.)
/// - Shraddha eligibility rules

class ShraddhaInfo {
  final bool isPitruPaksha;
  final String pitruPakshaDay;     // e.g. "ಕೃಷ್ಣ ಏಕಾದಶಿ" during Pitru Paksha
  final String significance;       // Kannada significance text
  final String significanceEn;     // English significance
  final bool isSarvaPitru;         // Mahalaya Amavasya — for all ancestors
  final bool isBharaniShraddha;    // Bharani nakshatra + Pitru Paksha
  final bool isAvidhavaNavami;     // K9 — married women
  final bool isGhataChaturdashi;   // K14 — accidental death
  final bool isMonthlyShraddha;    // Monthly tithi match day
  final String monthlyNote;        // Note about monthly shraddha
  const ShraddhaInfo({
    this.isPitruPaksha = false,
    this.pitruPakshaDay = '',
    this.significance = '',
    this.significanceEn = '',
    this.isSarvaPitru = false,
    this.isBharaniShraddha = false,
    this.isAvidhavaNavami = false,
    this.isGhataChaturdashi = false,
    this.isMonthlyShraddha = false,
    this.monthlyNote = '',
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

  /// English tithi names for Krishna Paksha
  static const _krishnaTithiEn = [
    'Krishna Pratipada',    // K1
    'Krishna Dvitiya',      // K2
    'Krishna Tritiya',      // K3
    'Krishna Chaturthi',    // K4
    'Krishna Panchami',     // K5
    'Krishna Shashthi',     // K6
    'Krishna Saptami',      // K7
    'Krishna Ashtami',      // K8
    'Krishna Navami',       // K9
    'Krishna Dashami',      // K10
    'Krishna Ekadashi',     // K11
    'Krishna Dvadashi',     // K12
    'Krishna Trayodashi',   // K13
    'Krishna Chaturdashi',  // K14
    'Amavasya',             // Amavasya
  ];

  /// Pitru Paksha significance per tithi (Kannada)
  static const _pitruPakshaSignificanceKn = [
    'ಪ್ರತಿಪದಾ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',                           // K1
    'ದ್ವಿತೀಯಾ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',                           // K2
    'ತೃತೀಯಾ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',                             // K3
    'ಚತುರ್ಥೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ; ಸುಹಾಗಿನ/ವಿಧವೆ ಸ್ತ್ರೀಯರಿಗೂ', // K4
    'ಪಂಚಮೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ; ಅವಿವಾಹಿತರಿಗೆ',               // K5
    'ಷಷ್ಠೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',                               // K6
    'ಸಪ್ತಮೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',                              // K7
    'ಅಷ್ಟಮೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',                              // K8
    'ಅವಿಧವಾ ನವಮೀ — ಸೌಭಾಗ್ಯವತಿ ಸ್ತ್ರೀಯರ (ಗಂಡನ ಮುಂಚೆ ಮೃತ) ಶ್ರಾದ್ಧ',         // K9
    'ದಶಮೀ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',                                // K10
    'ಏಕಾದಶಿ — ಸನ್ಯಾಸಿಗಳು/ಯತಿಗಳ ಶ್ರಾದ್ಧ',                                    // K11
    'ದ್ವಾದಶಿ — ಸನ್ಯಾಸಿಗಳು/ಯತಿಗಳ ಶ್ರಾದ್ಧ; ವೈಷ್ಣವ ಶ್ರಾದ್ಧ',                  // K12
    'ಮಘಾ ಶ್ರಾದ್ಧ — ತಿಥಿ ತಿಳಿಯದವರ ಶ್ರಾದ್ಧಕ್ಕೆ ಸೂಕ್ತ',                       // K13
    'ಘಾತ ಚತುರ್ದಶಿ — ಶಸ್ತ್ರ/ಅಪಘಾತ/ಅಕಾಲ ಮರಣದ ಶ್ರಾದ್ಧ',                       // K14
    'ಸರ್ವ ಪಿತೃ ಅಮಾವಾಸ್ಯೆ (ಮಹಾಲಯ) — ಎಲ್ಲ ಪಿತೃಗಳ ಶ್ರಾದ್ಧ',                   // Amavasya
  ];

  /// Pitru Paksha significance per tithi (English)
  static const _pitruPakshaSignificanceEn = [
    'Shraddha for ancestors who died on Pratipada tithi',                                // K1
    'Shraddha for ancestors who died on Dvitiya tithi',                                  // K2
    'Shraddha for ancestors who died on Tritiya tithi',                                  // K3
    'Shraddha for ancestors who died on Chaturthi; also for married/widowed women',       // K4
    'Shraddha for ancestors who died on Panchami; also for unmarried persons',            // K5
    'Shraddha for ancestors who died on Shashthi tithi',                                  // K6
    'Shraddha for ancestors who died on Saptami tithi',                                   // K7
    'Shraddha for ancestors who died on Ashtami tithi',                                   // K8
    'Avidhava Navami — Shraddha for married women who died before their husbands',        // K9
    'Shraddha for ancestors who died on Dashami tithi',                                    // K10
    'Ekadashi — Shraddha for Sannyasis and ascetics',                                     // K11
    'Dvadashi — Shraddha for Sannyasis; Vaishnava Shraddha',                              // K12
    'Magha Shraddha — Suitable when death tithi is unknown',                               // K13
    'Ghata Chaturdashi — Shraddha for those who died by weapons/accidents/untimely death', // K14
    'Sarva Pitru Amavasya (Mahalaya) — Universal Shraddha for ALL ancestors',              // Amavasya
  ];

  static bool _isPitruPakshaMasa(String amantaMasa) {
    final lower = amantaMasa.toLowerCase();
    return lower.contains('bhadrapada') ||
           lower.contains('ಭಾದ್ರಪದ') ||
           lower.contains('ashwin') ||
           lower.contains('ಆಶ್ವಿನ');
  }

  static ShraddhaInfo calculate({
    required int tithiIndex,
    required int nakshatraIndex,
    required String amantaMasa,
    required String paksha,
  }) {
    final isKrishna = tithiIndex >= 15 || tithiIndex == 29;
    final isPitruPakshaMasa = _isPitruPakshaMasa(amantaMasa);

    int krishnaIdx = -1;
    if (isKrishna) {
      krishnaIdx = tithiIndex >= 15 ? tithiIndex - 15 : 14;
    }

    final isPitruPaksha = isPitruPakshaMasa && isKrishna;

    if (!isPitruPaksha && !isKrishna) {
      return const ShraddhaInfo(
        monthlyNote: 'ಶ್ರಾದ್ಧ ಕೃಷ್ಣ ಪಕ್ಷದಲ್ಲಿ ಮಾತ್ರ (Shraddha only in Krishna Paksha)',
      );
    }

    final monthlyNote = isKrishna
      ? '${_krishnaTithiKn[krishnaIdx]} — ಈ ತಿಥಿಯಲ್ಲಿ ಮೃತರಾದ ಪಿತೃಗಳ ಮಾಸಿಕ ಶ್ರಾದ್ಧ ದಿನ'
      : '';

    if (!isPitruPaksha) {
      return ShraddhaInfo(
        isMonthlyShraddha: isKrishna,
        monthlyNote: monthlyNote,
        isSarvaPitru: tithiIndex == 29,
      );
    }

    return ShraddhaInfo(
      isPitruPaksha: true,
      pitruPakshaDay: _krishnaTithiKn[krishnaIdx],
      significance: _pitruPakshaSignificanceKn[krishnaIdx],
      significanceEn: _pitruPakshaSignificanceEn[krishnaIdx],
      isSarvaPitru: krishnaIdx == 14,
      isBharaniShraddha: (krishnaIdx == 1 || krishnaIdx == 2) && nakshatraIndex == 1,
      isAvidhavaNavami: krishnaIdx == 8,
      isGhataChaturdashi: krishnaIdx == 13,
      isMonthlyShraddha: true,
      monthlyNote: monthlyNote,
    );
  }
}
