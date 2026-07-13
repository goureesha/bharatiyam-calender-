/// Swiss Ephemeris wrapper for astronomical calculations.
/// Uses sweph package (Dart FFI wrapper for Swiss Ephemeris).
/// Lahiri Ayanamsha, mid-limb sunrise calculation.
import 'dart:math';
import 'package:sweph/sweph.dart';

class Ephemeris {
  static bool _initialized = false;

  /// Initialize Swiss Ephemeris with retry logic
  static Future<void> initSweph() async {
    if (_initialized) return;
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        await Sweph.init(epheAssets: [
          'packages/sweph/assets/ephe/sepl_18.se1',
          'packages/sweph/assets/ephe/semo_18.se1',
          'packages/sweph/assets/ephe/seas_18.se1',
        ]);
        _initialized = true;
        return;
      } catch (e) {
        if (attempt == 2) rethrow;
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  /// Get Sun altitude at a given JD, lat, lon using RA/Dec manual calculation
  static double getAltitudeManual(double jd, double lat, double lon) {
    final res = Sweph.swe_calc_ut(
      jd, HeavenlyBody.SE_SUN,
      SwephFlag.SEFLG_EQUATORIAL | SwephFlag.SEFLG_SWIEPH,
    );
    final ra = res.longitude;  // Right Ascension in degrees
    final dec = res.latitude;  // Declination in degrees
    final gmst = Sweph.swe_sidtime(jd); // Greenwich Mean Sidereal Time (hours)
    final lst = gmst + (lon / 15.0);    // Local Sidereal Time
    double haDeg = ((lst * 15.0) - ra + 360) % 360; // Hour Angle
    if (haDeg > 180) haDeg -= 360;
    final haRad = haDeg * pi / 180;
    final latRad = lat * pi / 180;
    final decRad = dec * pi / 180;
    final sinAlt = sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(haRad);
    return asin(sinAlt.clamp(-1.0, 1.0)) * 180 / pi;
  }

  /// Find sunrise and sunset JDs for a given date using binary search on solar altitude.
  /// tzOffset provided: -0.5667° horizon (mid-limb with refraction)
  /// tzOffset null: 0.0° horizon (true geocentric — for Mandi calc)
  static List<double> findSunriseSetForDate(
    int y, int m, int d, double lat, double lon, {double? tzOffset}
  ) {
    final horizonAlt = (tzOffset != null) ? -0.5667 : 0.0;
    double jdStart;
    if (tzOffset != null) {
      jdStart = Sweph.swe_julday(y, m, d, 0, CalendarType.SE_GREG_CAL) - (tzOffset / 24.0) - (2.0 / 24.0);
    } else {
      jdStart = Sweph.swe_julday(y, m, d, 0, CalendarType.SE_GREG_CAL) - 0.3;
    }

    double riseTime = jdStart + 0.25; // fallback ~6 AM
    double setTime = jdStart + 0.75;  // fallback ~6 PM
    bool foundRise = false, foundSet = false;
    const step = 1.0 / 24.0; // 1-hour steps

    for (int i = 0; i < 30; i++) {
      final t1 = jdStart + i * step;
      final t2 = t1 + step;
      final a1 = getAltitudeManual(t1, lat, lon);
      final a2 = getAltitudeManual(t2, lat, lon);

      // Rising: below → above horizon
      if (!foundRise && a1 < horizonAlt && a2 >= horizonAlt) {
        double lo = t1, hi = t2;
        for (int j = 0; j < 20; j++) {
          final mid = (lo + hi) / 2;
          if (getAltitudeManual(mid, lat, lon) < horizonAlt) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        riseTime = (lo + hi) / 2;
        foundRise = true;
      }
      // Setting: above → below horizon
      if (!foundSet && a1 > horizonAlt && a2 <= horizonAlt) {
        double lo = t1, hi = t2;
        for (int j = 0; j < 20; j++) {
          final mid = (lo + hi) / 2;
          if (getAltitudeManual(mid, lat, lon) > horizonAlt) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        setTime = (lo + hi) / 2;
        foundSet = true;
      }
      if (foundRise && foundSet) break;
    }
    return [riseTime, setTime];
  }

  /// Calculate all planet positions (sidereal + speed)
  static Map<String, List<double>> calcAll(double jd, String ayanamsaMode, bool trueNode) {
    _setAyanamsaMode(ayanamsaMode);
    final flags = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SIDEREAL | SwephFlag.SEFLG_SPEED;
    final result = <String, List<double>>{};

    final bodies = {
      'Sun': HeavenlyBody.SE_SUN,
      'Moon': HeavenlyBody.SE_MOON,
      'Mercury': HeavenlyBody.SE_MERCURY,
      'Venus': HeavenlyBody.SE_VENUS,
      'Mars': HeavenlyBody.SE_MARS,
      'Jupiter': HeavenlyBody.SE_JUPITER,
      'Saturn': HeavenlyBody.SE_SATURN,
    };

    for (final entry in bodies.entries) {
      final res = Sweph.swe_calc_ut(jd, entry.value, flags);
      result[entry.key] = [res.longitude, res.longitudeSpeed];
    }

    // Rahu (node)
    final rahuBody = trueNode ? HeavenlyBody.SE_TRUE_NODE : HeavenlyBody.SE_MEAN_NODE;
    final rahuRes = Sweph.swe_calc_ut(jd, rahuBody, flags);
    result['Rahu'] = [rahuRes.longitude, rahuRes.longitudeSpeed];
    result['Ketu'] = [(rahuRes.longitude + 180) % 360, rahuRes.longitudeSpeed];

    return result;
  }

  /// Get ayanamsa value for a given JD
  static double getAyanamsa(double jd, String mode) {
    _setAyanamsaMode(mode);
    return Sweph.swe_get_ayanamsa(jd);
  }

  /// Get tropical houses (for Lagna/Bhava calculation)
  static Map<String, double> getHouses(double jd, double lat, double lon, String ayanamsaMode) {
    final houses = Sweph.swe_houses(jd, lat, lon, Hsys.P);
    final ayn = getAyanamsa(jd, ayanamsaMode);
    return {
      'asc': normDeg(houses.cusps[1] - ayn),
      'mc': normDeg(houses.cusps[10] - ayn),
    };
  }

  /// Get Julian Day for a date
  static double julday(int y, int m, int d, double h) {
    return Sweph.swe_julday(y, m, d, h, CalendarType.SE_GREG_CAL);
  }

  /// Convert Julian Day back to date
  static DateTime jdToDateTime(double jd, {double tzOffset = 5.5}) {
    final utcMs = ((jd - 2440587.5) * 86400000).round();
    final utcDt = DateTime.fromMillisecondsSinceEpoch(utcMs, isUtc: true);
    return utcDt.add(Duration(milliseconds: (tzOffset * 3600000).round()));
  }

  /// Format time from Julian Day
  static String formatTimeFromJd(double jd, {double tzOffset = 5.5}) {
    final dt = jdToDateTime(jd, tzOffset: tzOffset);
    final h = dt.hour;
    final m = dt.minute;
    final amPm = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $amPm';
  }

  /// Format ghati-vighati from decimal ghatis
  static String formatGhati(double ghatis) {
    if (ghatis < 0) ghatis = -ghatis;
    final g = ghatis.floor();
    final v = ((ghatis - g) * 60).round();
    return '$g-${v.toString().padLeft(2, '0')}';
  }

  /// Format duration in hours and minutes
  static String formatDuration(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h}h ${m}m';
  }

  /// Normalize degree to 0–360
  static double normDeg(double d) => ((d % 360) + 360) % 360;

  /// Set ayanamsa mode
  static void _setAyanamsaMode(String mode) {
    switch (mode) {
      case 'raman':
        Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_RAMAN);
        break;
      case 'kp':
        Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_KRISHNAMURTI);
        break;
      default:
        Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI);
    }
  }
}
