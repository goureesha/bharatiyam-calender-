/// Samvatsara, Rutu, and Ayana calculations.
/// 60-year Shalivahana Shaka cycle, 6 Vedic seasons.

class SamvatsaraCalculator {
  // 60 Samvatsara names (keys for i18n lookup)
  static const List<String> samvatsaraKeys = [
    'sam0',  'sam1',  'sam2',  'sam3',  'sam4',
    'sam5',  'sam6',  'sam7',  'sam8',  'sam9',
    'sam10', 'sam11', 'sam12', 'sam13', 'sam14',
    'sam15', 'sam16', 'sam17', 'sam18', 'sam19',
    'sam20', 'sam21', 'sam22', 'sam23', 'sam24',
    'sam25', 'sam26', 'sam27', 'sam28', 'sam29',
    'sam30', 'sam31', 'sam32', 'sam33', 'sam34',
    'sam35', 'sam36', 'sam37', 'sam38', 'sam39',
    'sam40', 'sam41', 'sam42', 'sam43', 'sam44',
    'sam45', 'sam46', 'sam47', 'sam48', 'sam49',
    'sam50', 'sam51', 'sam52', 'sam53', 'sam54',
    'sam55', 'sam56', 'sam57', 'sam58', 'sam59',
  ];

  /// Calculate Samvatsara for a given Gregorian year and month
  /// Shaka year = Gregorian - 78, changes at Ugadi (~March/April)
  static Map<String, dynamic> calculate(int year, int month) {
    // Shaka year changes at Chaitra Shukla Pratipada (Ugadi)
    // Approximate: if before April, use previous year
    int shakaYear = year - 78;
    if (month < 4) shakaYear -= 1;

    // Samvatsara index in the 60-year cycle
    // South Indian tradition: Prabhava(0) started at a specific Shaka year
    // Offset +11 aligns with the traditional mapping
    final samIdx = ((shakaYear + 11) % 60 + 60) % 60;

    return {
      'samvatsara': samvatsaraKeys[samIdx],
      'shakaYear': shakaYear,
    };
  }

  /// Calculate Rutu (season) from Sun's sidereal longitude
  /// Each Rutu spans 2 rashis (60°)
  static String calculateRutu(double sunDeg) {
    final rashiPair = ((sunDeg / 60).floor()) % 6;
    // Mesha-Vrishabha(0-1) → Vasanta, Mithuna-Karka(2-3) → Grishma, etc.
    return 'rutu$rashiPair';
  }

  /// Calculate Ayana from Sun's sidereal longitude
  static String calculateAyana(double sunDeg) {
    // Uttarayana: Sun at 270° (Makara) to 90° (Karka)
    // Dakshinayana: Sun at 90° (Karka) to 270° (Makara)
    if (sunDeg >= 270 || sunDeg < 90) {
      return 'uttarayana';
    } else {
      return 'dakshinayana';
    }
  }
}
