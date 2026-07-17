/// Asta (Combustion) Calculator — Computes when planets are too close to the Sun.
/// Guru Asta: Jupiter within 9° of Sun (sidereal)
/// Shukra Asta: Venus within 6.6° of Sun (sidereal)
import 'package:sweph/sweph.dart';
import 'ephemeris.dart';

class AstaPeriod {
  final DateTime start;
  final DateTime end;
  final String rashi; // Rashi where combustion occurs

  AstaPeriod({required this.start, required this.end, required this.rashi});
}

class AstaCalculator {
  static const double _guruLimit = 9.0;    // degrees
  static const double _shukraLimit = 6.6;  // degrees

  static const _rashiNames = [
    'ಮೇಷ', 'ವೃಷಭ', 'ಮಿಥುನ', 'ಕರ್ಕಾಟಕ', 'ಸಿಂಹ', 'ಕನ್ಯಾ',
    'ತುಲಾ', 'ವೃಶ್ಚಿಕ', 'ಧನು', 'ಮಕರ', 'ಕುಂಭ', 'ಮೀನ',
  ];

  /// Calculate all Guru Asta periods for a given year
  static List<AstaPeriod> calculateGuruAsta(int year, {double tzOffset = 5.5}) {
    return _findAstaPeriods(year, HeavenlyBody.SE_JUPITER, _guruLimit, tzOffset);
  }

  /// Calculate all Shukra Asta periods for a given year
  static List<AstaPeriod> calculateShukraAsta(int year, {double tzOffset = 5.5}) {
    return _findAstaPeriods(year, HeavenlyBody.SE_VENUS, _shukraLimit, tzOffset);
  }

  /// Scan through the year day-by-day to find combustion periods
  static List<AstaPeriod> _findAstaPeriods(
    int year, HeavenlyBody planet, double limitDeg, double tzOffset,
  ) {
    final periods = <AstaPeriod>[];
    
    // Start from Jan 1 and go through Dec 31
    final startJd = Sweph.swe_julday(year, 1, 1, 0, CalendarType.SE_GREG_CAL);
    final endJd = Sweph.swe_julday(year, 12, 31, 23.99, CalendarType.SE_GREG_CAL);
    
    bool inAsta = false;
    double astaStartJd = 0;
    String startRashi = '';
    
    // Scan with 0.5-day steps (12 hours) for speed, then refine
    for (double jd = startJd; jd <= endJd; jd += 0.5) {
      final sep = _angularSeparation(jd, planet);
      
      if (!inAsta && sep < limitDeg) {
        // Entered combustion — refine start
        astaStartJd = _refineTransition(jd - 0.5, jd, planet, limitDeg, entering: true);
        final planets = Ephemeris.calcAll(astaStartJd, 'lahiri', true);
        final sunDeg = planets['Sun']![0];
        startRashi = _rashiNames[(sunDeg / 30).floor() % 12];
        inAsta = true;
      } else if (inAsta && sep >= limitDeg) {
        // Exited combustion — refine end
        final astaEndJd = _refineTransition(jd - 0.5, jd, planet, limitDeg, entering: false);
        final planets = Ephemeris.calcAll(astaEndJd, 'lahiri', true);
        final sunDeg = planets['Sun']![0];
        final endRashi = _rashiNames[(sunDeg / 30).floor() % 12];
        
        periods.add(AstaPeriod(
          start: _jdToLocal(astaStartJd, tzOffset),
          end: _jdToLocal(astaEndJd, tzOffset),
          rashi: startRashi == endRashi ? startRashi : '$startRashi / $endRashi',
        ));
        inAsta = false;
      }
    }
    
    // If still in asta at year end
    if (inAsta) {
      periods.add(AstaPeriod(
        start: _jdToLocal(astaStartJd, tzOffset),
        end: DateTime(year, 12, 31),
        rashi: '$startRashi (ಮುಂದುವರಿಯುತ್ತದೆ)',
      ));
    }
    
    return periods;
  }

  /// Get angular separation between planet and Sun (sidereal)
  static double _angularSeparation(double jd, HeavenlyBody planet) {
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI);
    final flags = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SIDEREAL;
    
    final sunRes = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, flags);
    final planetRes = Sweph.swe_calc_ut(jd, planet, flags);
    
    double diff = (planetRes.longitude - sunRes.longitude).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  /// Binary search to find exact transition point
  static double _refineTransition(
    double lo, double hi, HeavenlyBody planet, double limit, {required bool entering}
  ) {
    for (int i = 0; i < 20; i++) {
      final mid = (lo + hi) / 2;
      final sep = _angularSeparation(mid, planet);
      if (entering) {
        // Looking for where sep crosses below limit
        if (sep >= limit) lo = mid; else hi = mid;
      } else {
        // Looking for where sep crosses above limit
        if (sep < limit) lo = mid; else hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  /// Convert JD to local DateTime
  static DateTime _jdToLocal(double jd, double tzOffset) {
    final ms = ((jd - 2440587.5) * 86400000).round();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)
        .add(Duration(milliseconds: (tzOffset * 3600000).round()));
  }

  /// Format date in Kannada style
  static String formatDate(DateTime dt) {
    const months = [
      '', 'ಜನವರಿ', 'ಫೆಬ್ರವರಿ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿಲ್', 'ಮೇ', 'ಜೂನ್',
      'ಜುಲೈ', 'ಆಗಸ್ಟ್', 'ಸೆಪ್ಟೆಂಬರ್', 'ಅಕ್ಟೋಬರ್', 'ನವೆಂಬರ್', 'ಡಿಸೆಂಬರ್',
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }

  /// Calculate duration in days
  static int durationDays(AstaPeriod p) {
    return p.end.difference(p.start).inDays;
  }
}
