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

  /// Chandra Masa names that belong to the "old" Shaka year
  /// (Margashira through Phalguna = months before Ugadi)
  static const List<String> _oldYearMasaKeys = [
    'cm7',  // Margashira
    'cm8',  // Pushya
    'cm9',  // Magha
    'cm10', // Phalguna
  ];

  /// Calculate Samvatsara for a given Gregorian year and month.
  /// [chandraMasaKey] is the Amanta masa key (e.g. 'cm7' for Margashira).
  /// If provided, uses lunar month for accurate Ugadi detection.
  static Map<String, dynamic> calculate(int year, int month, {String chandraMasaKey = ''}) {
    int shakaYear = year - 78;

    // Ugadi (Chaitra Shukla Pratipada) typically falls in March/April.
    // If the lunar month is before Chaitra AND we're in the first half of the Gregorian year,
    // this date belongs to the previous Shaka year.
    if (chandraMasaKey.isNotEmpty) {
      final beforeUgadi = month <= 5 && _oldYearMasaKeys.contains(chandraMasaKey);
      if (beforeUgadi) shakaYear -= 1;
    } else {
      // Fallback: simple approximation
      if (month < 4) shakaYear -= 1;
    }

    final samIdx = ((shakaYear + 11) % 60 + 60) % 60;

    return {
      'samvatsara': samvatsaraKeys[samIdx],
      'shakaYear': shakaYear,
    };
  }

  /// Calculate Rutu (season) from Sun's sidereal longitude.
  /// Traditional mapping (per Surya Siddhanta):
  ///   Mesha(0)=Vasanta, Vrishabha(1)=Grishma, Mithuna(2)=Grishma,
  ///   Karka(3)=Varsha, Simha(4)=Varsha, Kanya(5)=Sharad,
  ///   Tula(6)=Sharad, Vrischika(7)=Hemanta, Dhanu(8)=Hemanta,
  ///   Makara(9)=Shishira, Kumbha(10)=Shishira, Meena(11)=Vasanta
  static const List<String> _rutuMap = [
    'rutu0', // 0  Mesha     → Vasanta
    'rutu1', // 1  Vrishabha → Grishma
    'rutu1', // 2  Mithuna   → Grishma
    'rutu2', // 3  Karka     → Varsha
    'rutu2', // 4  Simha     → Varsha
    'rutu3', // 5  Kanya     → Sharad
    'rutu3', // 6  Tula      → Sharad
    'rutu4', // 7  Vrischika → Hemanta
    'rutu4', // 8  Dhanu     → Hemanta
    'rutu5', // 9  Makara    → Shishira
    'rutu5', // 10 Kumbha    → Shishira
    'rutu0', // 11 Meena     → Vasanta
  ];

  static String calculateRutu(double sunDeg) {
    final rashiIdx = (sunDeg / 30).floor() % 12;
    return _rutuMap[rashiIdx];
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
