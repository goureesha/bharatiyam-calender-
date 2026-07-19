/// Grahana (Eclipse) Calculator — Precise eclipse computation using Swiss Ephemeris.
///
/// Implements the full algorithm (Sayana coordinates, Mean Node for Rahu):
/// 1. Find exact syzygy (New Moon / Full Moon) moments using tropical longitudes
/// 2. Check nodal proximity — syzygy must be within ~18° of Mean Rahu/Ketu
/// 3. Check lunar latitude at syzygy for eclipse possibility
/// 4. Calculate angular diameters (Bimba) for eclipse type
/// 5. Compute contact phases: Sparsha → Sammilana → Madhya → Unmilana → Moksha
/// 6. Determine local visibility for Indian coordinates

import 'dart:math';
import 'package:sweph/sweph.dart';
import 'ephemeris.dart';

/// Eclipse type
enum GrahanaType {
  surya,   // Solar eclipse
  chandra, // Lunar eclipse
}

/// Eclipse subtype
enum GrahanaSubtype {
  purna,     // Total
  kankana,   // Annular (solar only)
  bhagasha,  // Partial
  penumbral, // Penumbral (lunar only)
}

/// Eclipse phase timing
class GrahanaPhase {
  final String name;       // Kannada name
  final String nameEn;     // English name
  final double jd;         // Julian Day
  final String time;       // Formatted IST time
  final String date;       // Formatted date

  GrahanaPhase({
    required this.name,
    required this.nameEn,
    required this.jd,
    required this.time,
    required this.date,
  });
}

/// Complete eclipse information
class GrahanaInfo {
  final GrahanaType type;
  final GrahanaSubtype subtype;
  final DateTime dateTime;         // Date of eclipse
  final double syzygyJd;           // Exact syzygy JD
  final double moonLatitude;       // Moon's latitude at syzygy (degrees)
  final double magnitude;          // Eclipse magnitude
  final List<GrahanaPhase> phases; // Contact phases
  final bool visibleInIndia;       // Is it visible from India?
  final String visibilityNote;     // Visibility details
  final String typeKannada;        // Type in Kannada
  final String summary;            // One-line summary

  GrahanaInfo({
    required this.type,
    required this.subtype,
    required this.dateTime,
    required this.syzygyJd,
    required this.moonLatitude,
    required this.magnitude,
    required this.phases,
    required this.visibleInIndia,
    required this.visibilityNote,
    required this.typeKannada,
    required this.summary,
  });
}

class GrahanaCalculator {
  // Eclipse latitude limits (degrees)
  static const double _solarLatLimit = 1.5667;   // ~1°34'
  static const double _lunarLatLimit = 1.05;      // ~1°03'
  static const double _nodeProximityLimit = 18.0;  // degrees from Mean Node

  // Mean radii for angular diameter calculations
  static const double _earthRadiusKm = 6371.0;
  static const double _sunRadiusKm = 696000.0;
  static const double _moonRadiusKm = 1737.4;

  /// Calculate all eclipses for a given year
  static List<GrahanaInfo> calculateForYear(int year, {double tzOffset = 5.5}) {
    final results = <GrahanaInfo>[];

    // Find all New Moons (potential solar eclipses) and Full Moons (potential lunar eclipses)
    final newMoons = _findSyzygies(year, isFull: false);
    final fullMoons = _findSyzygies(year, isFull: true);

    // Check each New Moon for solar eclipse
    for (final nmJd in newMoons) {
      final info = _checkSolarEclipse(nmJd, tzOffset);
      if (info != null) results.add(info);
    }

    // Check each Full Moon for lunar eclipse
    for (final fmJd in fullMoons) {
      final info = _checkLunarEclipse(fmJd, tzOffset);
      if (info != null) results.add(info);
    }

    // Sort by date
    results.sort((a, b) => a.syzygyJd.compareTo(b.syzygyJd));
    return results;
  }

  /// Find all New Moon or Full Moon moments in a year
  static List<double> _findSyzygies(int year, {required bool isFull}) {
    final results = <double>[];
    final startJd = Sweph.swe_julday(year, 1, 1, 0, CalendarType.SE_GREG_CAL);
    final endJd = Sweph.swe_julday(year, 12, 31, 23.99, CalendarType.SE_GREG_CAL);

    double jd = startJd;
    while (jd < endJd) {
      final elong1 = _moonSunElong(jd);
      final elong2 = _moonSunElong(jd + 1.0);

      bool crossing;
      if (isFull) {
        // Full Moon: elongation crosses 180°
        crossing = (elong1 < 180 && elong2 >= 180) ||
                   (elong1 > 170 && elong2 < 10 && false); // avoid wrap false positive
        if (!crossing && elong1 > 160 && elong1 < 200 && elong2 > 160 && elong2 < 200) {
          // Already near 180, check more carefully
          if ((elong1 - 180).abs() > (elong2 - 180).abs() && (elong2 - 180).abs() < 5) {
            final elong3 = _moonSunElong(jd + 2.0);
            crossing = (elong2 - 180).abs() < (elong3 - 180).abs();
          }
        }
      } else {
        // New Moon: elongation crosses 0°/360°
        crossing = elong1 > 300 && elong2 < 60;
      }

      if (crossing) {
        // Refine with binary search
        double lo = jd, hi = jd + 1.0;
        for (int i = 0; i < 30; i++) {
          final mid = (lo + hi) / 2;
          final e = _moonSunElong(mid);
          if (isFull) {
            if (e < 180) lo = mid; else hi = mid;
          } else {
            if (e > 180) lo = mid; else hi = mid;
          }
        }
        results.add((lo + hi) / 2);
        jd += 25; // Skip ahead
      } else {
        jd += 1.0;
      }
    }
    return results;
  }

  /// Check if a New Moon produces a solar eclipse
  static GrahanaInfo? _checkSolarEclipse(double syzygyJd, double tzOffset) {
    // Step 1: Check proximity to Mean Node (Rahu/Ketu)
    if (!_isNearNode(syzygyJd)) return null;

    // Step 2: Get Moon's latitude at syzygy
    final moonLat = _getMoonLatitude(syzygyJd);
    if (moonLat.abs() > _solarLatLimit) return null; // No eclipse

    // Calculate angular diameters
    final moonDist = _getMoonDistance(syzygyJd);
    final sunDist = _getSunDistance(syzygyJd);

    final moonAngDiam = 2 * atan(_moonRadiusKm / moonDist) * 180 / pi * 3600; // arcseconds
    final sunAngDiam = 2 * atan(_sunRadiusKm / sunDist) * 180 / pi * 3600;

    // Eclipse magnitude: ratio of apparent diameters
    // Simplified: magnitude based on latitude
    final gamma = moonLat.abs(); // simplified
    final magnitude = 1.0 - (gamma / _solarLatLimit);

    // Determine subtype
    GrahanaSubtype subtype;
    String typeKn;
    if (moonAngDiam >= sunAngDiam && gamma < 0.5) {
      subtype = GrahanaSubtype.purna;
      typeKn = 'ಪೂರ್ಣ ಸೂರ್ಯ ಗ್ರಹಣ';
    } else if (moonAngDiam < sunAngDiam && gamma < 0.5) {
      subtype = GrahanaSubtype.kankana;
      typeKn = 'ಕಂಕಣ ಸೂರ್ಯ ಗ್ರಹಣ';
    } else {
      subtype = GrahanaSubtype.bhagasha;
      typeKn = 'ಭಾಗಶಃ ಸೂರ್ಯ ಗ್ರಹಣ';
    }

    // Calculate phases
    final phases = _calculateSolarPhases(syzygyJd, moonLat, moonAngDiam, sunAngDiam, tzOffset);

    // Check India visibility (approximate: lat 8-37°N, lon 68-97°E)
    final visibility = _checkIndiaVisibility(syzygyJd, tzOffset, isSolar: true);

    final dt = _jdToLocal(syzygyJd, tzOffset);
    return GrahanaInfo(
      type: GrahanaType.surya,
      subtype: subtype,
      dateTime: dt,
      syzygyJd: syzygyJd,
      moonLatitude: moonLat,
      magnitude: magnitude.clamp(0.0, 1.0),
      phases: phases,
      visibleInIndia: visibility['visible'] as bool,
      visibilityNote: visibility['note'] as String,
      typeKannada: typeKn,
      summary: '$typeKn — ${_formatDateKn(dt)}',
    );
  }

  /// Check if a Full Moon produces a lunar eclipse
  static GrahanaInfo? _checkLunarEclipse(double syzygyJd, double tzOffset) {
    // Step 1: Check proximity to Mean Node (Rahu/Ketu)
    if (!_isNearNode(syzygyJd)) return null;

    // Step 2: Check Moon's latitude
    final moonLat = _getMoonLatitude(syzygyJd);
    if (moonLat.abs() > _lunarLatLimit * 1.5) return null; // Allow penumbral check

    // Calculate Earth's shadow cone at Moon's distance
    final moonDist = _getMoonDistance(syzygyJd);
    final sunDist = _getSunDistance(syzygyJd);

    final moonAngDiam = 2 * atan(_moonRadiusKm / moonDist) * 180 / pi * 3600;
    // Earth's umbra angular radius at Moon distance
    final umbralRadius = atan((_earthRadiusKm - _moonRadiusKm * 0.273) / moonDist) * 180 / pi * 3600;
    final penumbralRadius = umbralRadius * 1.6; // approximate

    final gamma = moonLat.abs() * 3600; // convert to arcseconds for comparison

    // Determine subtype
    GrahanaSubtype subtype;
    String typeKn;
    if (gamma > penumbralRadius + moonAngDiam / 2) {
      return null; // No eclipse at all
    } else if (gamma > umbralRadius + moonAngDiam / 2) {
      // Penumbral only
      if (gamma > penumbralRadius - moonAngDiam / 2) return null; // Skip marginal penumbral
      subtype = GrahanaSubtype.penumbral;
      typeKn = 'ಉಪಛಾಯಾ ಚಂದ್ರ ಗ್ರಹಣ';
    } else if (gamma + moonAngDiam / 2 <= umbralRadius) {
      subtype = GrahanaSubtype.purna;
      typeKn = 'ಪೂರ್ಣ ಚಂದ್ರ ಗ್ರಹಣ';
    } else {
      subtype = GrahanaSubtype.bhagasha;
      typeKn = 'ಭಾಗಶಃ ಚಂದ್ರ ಗ್ರಹಣ';
    }

    final magnitude = (umbralRadius - gamma + moonAngDiam / 2) / moonAngDiam;

    // Calculate phases
    final phases = _calculateLunarPhases(syzygyJd, moonLat, moonAngDiam, umbralRadius, tzOffset);

    // Lunar eclipses visible from anywhere the Moon is above horizon
    final visibility = _checkIndiaVisibility(syzygyJd, tzOffset, isSolar: false);

    final dt = _jdToLocal(syzygyJd, tzOffset);
    return GrahanaInfo(
      type: GrahanaType.chandra,
      subtype: subtype,
      dateTime: dt,
      syzygyJd: syzygyJd,
      moonLatitude: moonLat,
      magnitude: magnitude.clamp(0.0, 2.0),
      phases: phases,
      visibleInIndia: visibility['visible'] as bool,
      visibilityNote: visibility['note'] as String,
      typeKannada: typeKn,
      summary: '$typeKn — ${_formatDateKn(dt)}',
    );
  }

  /// Calculate solar eclipse contact phases
  static List<GrahanaPhase> _calculateSolarPhases(
    double syzygyJd, double moonLat, double moonAng, double sunAng, double tzOffset,
  ) {
    final phases = <GrahanaPhase>[];

    // Duration estimate based on latitude (rough: eclipse lasts ~2-4 hours for partials)
    final latFactor = 1.0 - (moonLat.abs() / _solarLatLimit);
    final halfDuration = latFactor * 1.5 / 24.0; // ~1.5 hours half-duration in JD

    final sparshaJd = syzygyJd - halfDuration;
    final mokshaJd = syzygyJd + halfDuration;

    phases.add(_makePhase('ಸ್ಪರ್ಶ', 'First Contact', sparshaJd, tzOffset));

    if (moonLat.abs() < 0.5) {
      final innerHalf = halfDuration * 0.3;
      phases.add(_makePhase('ಸಮ್ಮಿಲನ', 'Total Immersion', syzygyJd - innerHalf, tzOffset));
      phases.add(_makePhase('ಮಧ್ಯ', 'Maximum Eclipse', syzygyJd, tzOffset));
      phases.add(_makePhase('ಉನ್ಮಿಲನ', 'Egress Begin', syzygyJd + innerHalf, tzOffset));
    } else {
      phases.add(_makePhase('ಮಧ್ಯ', 'Maximum Eclipse', syzygyJd, tzOffset));
    }

    phases.add(_makePhase('ಮೋಕ್ಷ', 'Final Release', mokshaJd, tzOffset));
    return phases;
  }

  /// Calculate lunar eclipse contact phases
  static List<GrahanaPhase> _calculateLunarPhases(
    double syzygyJd, double moonLat, double moonAng, double umbralRadius, double tzOffset,
  ) {
    final phases = <GrahanaPhase>[];

    // Lunar eclipses last longer (~3-4 hours)
    final latFactor = 1.0 - (moonLat.abs() / (_lunarLatLimit * 1.5));
    final halfDuration = latFactor * 2.0 / 24.0; // ~2 hours half-duration in JD

    final sparshaJd = syzygyJd - halfDuration;
    final mokshaJd = syzygyJd + halfDuration;

    phases.add(_makePhase('ಸ್ಪರ್ಶ', 'First Contact', sparshaJd, tzOffset));

    final gamma = moonLat.abs() * 3600;
    if (gamma + moonAng / 2 <= umbralRadius) {
      // Total: add immersion/emersion
      final innerHalf = halfDuration * 0.4;
      phases.add(_makePhase('ಗ್ರಾಸ', 'Total Immersion', syzygyJd - innerHalf, tzOffset));
      phases.add(_makePhase('ಮಧ್ಯ', 'Maximum Eclipse', syzygyJd, tzOffset));
      phases.add(_makePhase('ಉನ್ಮಿಲನ', 'Egress Begin', syzygyJd + innerHalf, tzOffset));
    } else {
      phases.add(_makePhase('ಮಧ್ಯ', 'Maximum Eclipse', syzygyJd, tzOffset));
    }

    phases.add(_makePhase('ಮೋಕ್ಷ', 'Final Release', mokshaJd, tzOffset));
    return phases;
  }

  /// Create a phase object
  static GrahanaPhase _makePhase(String name, String nameEn, double jd, double tzOffset) {
    final dt = _jdToLocal(jd, tzOffset);
    return GrahanaPhase(
      name: name,
      nameEn: nameEn,
      jd: jd,
      time: _formatTime(dt),
      date: _formatDateKn(dt),
    );
  }

  /// Check if eclipse is visible from India (approximate)
  static Map<String, dynamic> _checkIndiaVisibility(double syzygyJd, double tzOffset, {required bool isSolar}) {
    // India center: ~22°N, 78°E
    const indiaLat = 22.0;
    const indiaLon = 78.0;

    if (isSolar) {
      // Solar eclipse: Sun must be above horizon at eclipse time
      final sunAlt = Ephemeris.getAltitudeManual(syzygyJd, indiaLat, indiaLon);
      if (sunAlt > 0) {
        return {'visible': true, 'note': 'ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಹೌದು'};
      } else if (sunAlt > -10) {
        return {'visible': false, 'note': 'ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಭಾಗಶಃ (ಉದಯ/ಅಸ್ತ ಸಮಯ)'};
      } else {
        return {'visible': false, 'note': 'ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಇಲ್ಲ'};
      }
    } else {
      // Lunar eclipse: Moon must be above horizon
      // Check Moon's altitude at key eclipse times
      final flags = SwephFlag.SEFLG_EQUATORIAL | SwephFlag.SEFLG_SWIEPH;
      final moonRes = Sweph.swe_calc_ut(syzygyJd, HeavenlyBody.SE_MOON, flags);
      final moonRa = moonRes.longitude;
      final moonDec = moonRes.latitude;
      final gmst = Sweph.swe_sidtime(syzygyJd);
      final lst = gmst + (indiaLon / 15.0);
      double haDeg = ((lst * 15.0) - moonRa + 360) % 360;
      if (haDeg > 180) haDeg -= 360;
      final haRad = haDeg * pi / 180;
      final latRad = indiaLat * pi / 180;
      final decRad = moonDec * pi / 180;
      final sinAlt = sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(haRad);
      final moonAlt = asin(sinAlt) * 180 / pi;

      if (moonAlt > 10) {
        return {'visible': true, 'note': 'ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಹೌದು (ಪೂರ್ಣ)'};
      } else if (moonAlt > 0) {
        return {'visible': true, 'note': 'ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಹೌದು (ಭಾಗಶಃ)'};
      } else if (moonAlt > -10) {
        return {'visible': false, 'note': 'ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಭಾಗಶಃ (ಉದಯ/ಅಸ್ತ ಸಮಯ)'};
      } else {
        return {'visible': false, 'note': 'ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಇಲ್ಲ'};
      }
    }
  }

  // ── Helper functions ──

  /// Moon-Sun elongation (tropical, 0-360°)
  static double _moonSunElong(double jd) {
    final flags = SwephFlag.SEFLG_SWIEPH;
    final sun = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, flags);
    final moon = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, flags);
    return ((moon.longitude - sun.longitude) + 360) % 360;
  }

  /// Moon's celestial latitude at JD (sayana/tropical)
  static double _getMoonLatitude(double jd) {
    final flags = SwephFlag.SEFLG_SWIEPH;
    final moon = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, flags);
    return moon.latitude;
  }

  /// Check if syzygy is near Mean Node (Rahu/Ketu) within limit
  /// Uses Mean Node (SE_MEAN_NODE) as per traditional calculation
  static bool _isNearNode(double jd) {
    final flags = SwephFlag.SEFLG_SWIEPH; // tropical
    final sun = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, flags);
    final node = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MEAN_NODE, flags);
    final rahuLon = node.longitude;
    final ketuLon = (rahuLon + 180) % 360;
    final sunLon = sun.longitude;

    // Check distance from both Rahu and Ketu
    double distRahu = (sunLon - rahuLon).abs();
    if (distRahu > 180) distRahu = 360 - distRahu;
    double distKetu = (sunLon - ketuLon).abs();
    if (distKetu > 180) distKetu = 360 - distKetu;

    return distRahu <= _nodeProximityLimit || distKetu <= _nodeProximityLimit;
  }

  /// Moon's distance in km
  static double _getMoonDistance(double jd) {
    final flags = SwephFlag.SEFLG_SWIEPH;
    final moon = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, flags);
    return moon.distance * 149597870.7; // AU to km
  }

  /// Sun's distance in km
  static double _getSunDistance(double jd) {
    final flags = SwephFlag.SEFLG_SWIEPH;
    final sun = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, flags);
    return sun.distance * 149597870.7; // AU to km
  }

  /// Convert JD to local DateTime
  static DateTime _jdToLocal(double jd, double tzOffset) {
    final ms = ((jd - 2440587.5) * 86400000).round();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)
        .add(Duration(milliseconds: (tzOffset * 3600000).round()));
  }

  /// Format time
  static String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    final amPm = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $amPm IST';
  }

  /// Format date in Kannada
  static String _formatDateKn(DateTime dt) {
    const months = [
      '', 'ಜನವರಿ', 'ಫೆಬ್ರವರಿ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿಲ್', 'ಮೇ', 'ಜೂನ್',
      'ಜುಲೈ', 'ಆಗಸ್ಟ್', 'ಸೆಪ್ಟೆಂಬರ್', 'ಅಕ್ಟೋಬರ್', 'ನವೆಂಬರ್', 'ಡಿಸೆಂಬರ್',
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}
