/// Grahana (Eclipse) Calculator — Ketaki Drig Ganita method using Swiss Ephemeris
/// Besselian eclipse functions for precise computation.
///
/// Uses swe_sol_eclipse_when_loc / swe_lun_eclipse_when_loc for exact local
/// contact times, and swe_sol_eclipse_how / swe_lun_eclipse_how for attributes.
///
/// Swiss Ephemeris times array indices (solar local):
///   [0] = maximum eclipse
///   [1] = first contact (C1/Sparsha)
///   [2] = second contact (C2/Sammilana) — total/annular begin
///   [3] = third contact (C3/Unmilana) — total/annular end
///   [4] = fourth contact (C4/Moksha)
///
/// Swiss Ephemeris times array indices (lunar local):
///   [0] = maximum eclipse
///   [2] = partial phase begin (Sparsha)
///   [3] = partial phase end (Moksha)
///   [4] = penumbral phase begin
///   [5] = penumbral phase end
///   [6] = total phase begin (Grasa/Sammilana)
///   [7] = total phase end (Unmilana)
///
/// Attributes array indices:
///   [0] = eclipse magnitude (fraction of solar/lunar diameter covered)
///   [1] = saros series number (solar only)
///   [2] = fraction of area covered (solar) / umbral magnitude (lunar)

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
  final String time;       // Formatted time string
  final String date;       // Formatted date string

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
  final double syzygyJd;           // JD of maximum eclipse
  final double moonLatitude;       // Moon's latitude at max eclipse
  final double magnitude;          // Eclipse magnitude
  final List<GrahanaPhase> phases; // Contact phases
  final bool visibleInIndia;       // Is it visible from this location?
  final String visibilityNote;     // Visibility details
  final String typeKannada;        // Type in Kannada
  final String summary;            // One-line summary
  final int totalDurationMin;      // Total duration in minutes
  final String durationText;       // Formatted duration text

  // Local visibility window
  final String indiaVisibleFrom;   // Start time visible locally
  final String indiaVisibleTo;     // End time visible locally
  final int indiaVisibleMin;       // Minutes visible locally
  final String indiaVisibleText;   // Formatted local visibility duration

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
    required this.totalDurationMin,
    required this.durationText,
    this.indiaVisibleFrom = '',
    this.indiaVisibleTo = '',
    this.indiaVisibleMin = 0,
    this.indiaVisibleText = '',
  });
}

class GrahanaCalculator {
  /// Calculate all eclipses for the Hindu year (Ugadi to Ugadi) at user's location
  /// Uses Ketaki Drig Ganita — Swiss Ephemeris Besselian eclipse functions
  static List<GrahanaInfo> calculateForYear(int year, {
    double lat = 12.9716,
    double lon = 77.5946,
    double tzOffset = 5.5,
  }) {
    final results = <GrahanaInfo>[];
    final geoPos = GeoPosition(lon, lat);

    // Use Ugadi-to-Ugadi range (Hindu year: Chaitra Shukla Pratipada)
    final startJd = _findUgadiJd(year);
    final endJd = _findUgadiJd(year + 1);

    // ── Solar Eclipses ──
    _findSolarEclipses(startJd, endJd, geoPos, lat, lon, tzOffset, results);

    // ── Lunar Eclipses ──
    _findLunarEclipses(startJd, endJd, geoPos, lat, lon, tzOffset, results);

    // Sort by date
    results.sort((a, b) => a.syzygyJd.compareTo(b.syzygyJd));
    return results;
  }

  /// Find Julian Day of Ugadi (Chaitra Shukla Pratipada) for a given year
  /// Ugadi = first New Moon after Sun enters sidereal Meena Rashi (330°)
  static double _findUgadiJd(int year) {
    // Sun enters Meena around mid-March. Search from March 1.
    final searchStart = Sweph.swe_julday(year, 3, 1, 0, CalendarType.SE_GREG_CAL);

    // Set Lahiri ayanamsha for sidereal longitude
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI);
    final flags = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SIDEREAL;

    // Find when Sun enters Meena (330°) - search day by day
    double meenaSankrantiJd = searchStart;
    for (double jd = searchStart; jd < searchStart + 60; jd += 0.5) {
      final sun = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, flags);
      if (sun.longitude >= 330 && sun.longitude < 360) {
        meenaSankrantiJd = jd;
        break;
      }
    }

    // Find the next New Moon after Meena Sankranti
    // Use tropical for syzygy detection
    final tropFlags = SwephFlag.SEFLG_SWIEPH;
    for (double jd = meenaSankrantiJd; jd < meenaSankrantiJd + 45; jd += 1.0) {
      final sun1 = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, tropFlags);
      final moon1 = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, tropFlags);
      final sun2 = Sweph.swe_calc_ut(jd + 1, HeavenlyBody.SE_SUN, tropFlags);
      final moon2 = Sweph.swe_calc_ut(jd + 1, HeavenlyBody.SE_MOON, tropFlags);
      final elong1 = ((moon1.longitude - sun1.longitude) + 360) % 360;
      final elong2 = ((moon2.longitude - sun2.longitude) + 360) % 360;

      // New Moon: elongation crosses 0° (wraps from ~350° to ~10°)
      if (elong1 > 300 && elong2 < 60) {
        // Binary search for exact New Moon
        double lo = jd, hi = jd + 1;
        for (int i = 0; i < 25; i++) {
          final mid = (lo + hi) / 2;
          final s = Sweph.swe_calc_ut(mid, HeavenlyBody.SE_SUN, tropFlags);
          final m = Sweph.swe_calc_ut(mid, HeavenlyBody.SE_MOON, tropFlags);
          final e = ((m.longitude - s.longitude) + 360) % 360;
          if (e > 180) lo = mid; else hi = mid;
        }
        // Ugadi = day after Amavasya
        return (lo + hi) / 2 + 0.5;
      }
    }

    // Fallback: April 1
    return Sweph.swe_julday(year, 4, 1, 0, CalendarType.SE_GREG_CAL);
  }

  /// Find all solar eclipses in the year using swe_sol_eclipse_when_glob + local check
  static void _findSolarEclipses(double startJd, double endJd,
      GeoPosition geoPos, double lat, double lon, double tzOffset,
      List<GrahanaInfo> results) {

    double searchJd = startJd;
    int safety = 0;

    while (searchJd < endJd && safety < 10) {
      safety++;
      try {
        // Find next solar eclipse globally
        final globInfo = Sweph.swe_sol_eclipse_when_glob(
          searchJd,
          SwephFlag.SEFLG_SWIEPH,
          EclipseFlag(0), // any type
          false,
        );

        final maxJd = globInfo.times![0];
        if (maxJd >= endJd) break;

        // Get local circumstances at user's location
        final localInfo = Sweph.swe_sol_eclipse_how(
          maxJd,
          SwephFlag.SEFLG_SWIEPH,
          geoPos,
        );

        final magnitude = localInfo.attributes![0];
        final eclFlags = localInfo.eclipseType!;

        if (magnitude > 0.0) {
          // Eclipse IS visible at this location — get local contact times
          final locTimesInfo = Sweph.swe_sol_eclipse_when_loc(
            maxJd - 1,
            SwephFlag.SEFLG_SWIEPH,
            geoPos,
            false,
          );

          final times = locTimesInfo.times!;
          // Verify it's within our year
          if (times[0] >= startJd && times[0] < endJd) {
            final info = _buildSolarEclipseInfo(
              times, magnitude, eclFlags, globInfo.eclipseType!,
              lat, lon, tzOffset,
            );
            results.add(info);
          }
        } else {
          // Not visible locally but still exists globally — report it
          final globalType = globInfo.eclipseType!;
          if (maxJd >= startJd) {
            final info = _buildGlobalSolarEclipseInfo(
              maxJd, globalType, lat, lon, tzOffset,
            );
            results.add(info);
          }
        }

        // Advance past this eclipse
        searchJd = maxJd + 20;
      } catch (e) {
        searchJd += 30;
      }
    }
  }

  /// Find all lunar eclipses in the year using swe_lun_eclipse_when + local check
  static void _findLunarEclipses(double startJd, double endJd,
      GeoPosition geoPos, double lat, double lon, double tzOffset,
      List<GrahanaInfo> results) {

    double searchJd = startJd;
    int safety = 0;
    final foundJds = <double>[]; // Track found eclipses to prevent duplicates

    while (searchJd < endJd && safety < 10) {
      safety++;
      try {
        // Find next lunar eclipse globally
        final globInfo = Sweph.swe_lun_eclipse_when(
          searchJd,
          SwephFlag.SEFLG_SWIEPH,
          EclipseFlag(0), // any type
          false,
        );

        final maxJd = globInfo.times![0];
        if (maxJd >= endJd) break;

        // Dedup: skip if we already found an eclipse within 2 days
        if (foundJds.any((jd) => (jd - maxJd).abs() < 2)) {
          searchJd = maxJd + 20;
          continue;
        }
        foundJds.add(maxJd);

        final globalType = globInfo.eclipseType!;

        // Skip penumbral eclipses (not considered real grahana in panchanga)
        if (_hasFlag(globalType, EclipseFlag.SE_ECL_PENUMBRAL) &&
            !_hasFlag(globalType, EclipseFlag.SE_ECL_PARTIAL) &&
            !_hasFlag(globalType, EclipseFlag.SE_ECL_TOTAL)) {
          searchJd = maxJd + 20;
          continue;
        }

        // Get local circumstances
        final localInfo = Sweph.swe_lun_eclipse_how(
          maxJd,
          SwephFlag.SEFLG_SWIEPH,
          geoPos,
        );

        final magnitude = localInfo.attributes![0];

        // Get local timings
        try {
          final locTimesInfo = Sweph.swe_lun_eclipse_when_loc(
            maxJd - 1,
            SwephFlag.SEFLG_SWIEPH,
            geoPos,
            false,
          );

          final times = locTimesInfo.times!;
          if (times[0] >= startJd && times[0] < endJd) {
            final info = _buildLunarEclipseInfo(
              times, magnitude, globalType, lat, lon, tzOffset,
            );
            results.add(info);
          }
        } catch (_) {
          // Not visible from this location — report global data
          if (maxJd >= startJd) {
            final info = _buildGlobalLunarEclipseInfo(
              maxJd, globalType, lat, lon, tzOffset,
            );
            results.add(info);
          }
        }

        searchJd = maxJd + 20;
      } catch (e) {
        searchJd += 30;
      }
    }
  }

  /// Build GrahanaInfo from local solar eclipse data
  static GrahanaInfo _buildSolarEclipseInfo(
    List<double> times, double magnitude, EclipseFlag localType,
    EclipseFlag globalType, double lat, double lon, double tzOffset,
  ) {
    final maxJd = times[0];
    final c1 = times[1]; // First contact — Sparsha
    final c2 = times[2]; // Second contact — Sammilana (0 if not total/annular)
    final c3 = times[3]; // Third contact — Unmilana (0 if not total/annular)
    final c4 = times[4]; // Fourth contact — Moksha

    // Determine type
    GrahanaSubtype subtype;
    String typeKn;
    if (_hasFlag(globalType, EclipseFlag.SE_ECL_TOTAL)) {
      subtype = GrahanaSubtype.purna;
      typeKn = 'ಪೂರ್ಣ ಸೂರ್ಯ ಗ್ರಹಣ';
    } else if (_hasFlag(globalType, EclipseFlag.SE_ECL_ANNULAR)) {
      subtype = GrahanaSubtype.kankana;
      typeKn = 'ಕಂಕಣ ಸೂರ್ಯ ಗ್ರಹಣ';
    } else if (_hasFlag(globalType, EclipseFlag.SE_ECL_ANNULAR_TOTAL)) {
      subtype = GrahanaSubtype.kankana;
      typeKn = 'ಮಿಶ್ರ ಸೂರ್ಯ ಗ್ರಹಣ';
    } else {
      subtype = GrahanaSubtype.bhagasha;
      typeKn = 'ಭಾಗಶಃ ಸೂರ್ಯ ಗ್ರಹಣ';
    }

    // Build phases
    final phases = <GrahanaPhase>[];
    if (c1 > 0) phases.add(_makePhase('ಸ್ಪರ್ಶ', 'First Contact', c1, tzOffset));
    if (c2 > 0) phases.add(_makePhase('ಸಮ್ಮಿಲನ', 'Second Contact', c2, tzOffset));
    phases.add(_makePhase('ಮಧ್ಯ', 'Maximum Eclipse', maxJd, tzOffset));
    if (c3 > 0) phases.add(_makePhase('ಉನ್ಮಿಲನ', 'Third Contact', c3, tzOffset));
    if (c4 > 0) phases.add(_makePhase('ಮೋಕ್ಷ', 'Fourth Contact', c4, tzOffset));

    // Duration
    final dur = _calcDuration(phases);

    // Visible window = C1 to C4 (already local)
    final visMin = c4 > 0 && c1 > 0 ? ((c4 - c1) * 24 * 60).round() : 0;
    String visText = '';
    if (visMin > 0) {
      final fromStr = _formatTime(_jdToLocal(c1, tzOffset));
      final toStr = _formatTime(_jdToLocal(c4, tzOffset));
      final h = visMin ~/ 60;
      final m = visMin % 60;
      visText = h > 0 ? '$fromStr — $toStr ($h ಗಂಟೆ $m ನಿಮಿಷ)' : '$fromStr — $toStr ($m ನಿಮಿಷ)';
    }

    final moonLat = _getMoonLatitude(maxJd);
    final dt = _jdToLocal(maxJd, tzOffset);

    return GrahanaInfo(
      type: GrahanaType.surya,
      subtype: subtype,
      dateTime: dt,
      syzygyJd: maxJd,
      moonLatitude: moonLat,
      magnitude: magnitude,
      phases: phases,
      visibleInIndia: true,
      visibilityNote: 'ಗೋಚರ: ಹೌದು',
      typeKannada: typeKn,
      summary: '$typeKn — ${_formatDateKn(dt)}',
      totalDurationMin: dur['min'] as int,
      durationText: dur['text'] as String,
      indiaVisibleFrom: visMin > 0 ? _formatTime(_jdToLocal(c1, tzOffset)) : '',
      indiaVisibleTo: visMin > 0 ? _formatTime(_jdToLocal(c4, tzOffset)) : '',
      indiaVisibleMin: visMin,
      indiaVisibleText: visText,
    );
  }

  /// Build GrahanaInfo for a solar eclipse not visible locally
  static GrahanaInfo _buildGlobalSolarEclipseInfo(
    double maxJd, EclipseFlag globalType, double lat, double lon, double tzOffset,
  ) {
    GrahanaSubtype subtype;
    String typeKn;
    if (_hasFlag(globalType, EclipseFlag.SE_ECL_TOTAL)) {
      subtype = GrahanaSubtype.purna;
      typeKn = 'ಪೂರ್ಣ ಸೂರ್ಯ ಗ್ರಹಣ';
    } else if (_hasFlag(globalType, EclipseFlag.SE_ECL_ANNULAR)) {
      subtype = GrahanaSubtype.kankana;
      typeKn = 'ಕಂಕಣ ಸೂರ್ಯ ಗ್ರಹಣ';
    } else if (_hasFlag(globalType, EclipseFlag.SE_ECL_ANNULAR_TOTAL)) {
      subtype = GrahanaSubtype.kankana;
      typeKn = 'ಮಿಶ್ರ ಸೂರ್ಯ ಗ್ರಹಣ';
    } else {
      subtype = GrahanaSubtype.bhagasha;
      typeKn = 'ಭಾಗಶಃ ಸೂರ್ಯ ಗ್ರಹಣ';
    }

    final moonLat = _getMoonLatitude(maxJd);
    final dt = _jdToLocal(maxJd, tzOffset);
    final phases = [_makePhase('ಮಧ್ಯ', 'Maximum Eclipse', maxJd, tzOffset)];

    return GrahanaInfo(
      type: GrahanaType.surya,
      subtype: subtype,
      dateTime: dt,
      syzygyJd: maxJd,
      moonLatitude: moonLat,
      magnitude: 0,
      phases: phases,
      visibleInIndia: false,
      visibilityNote: 'ಗೋಚರ: ಇಲ್ಲ',
      typeKannada: typeKn,
      summary: '$typeKn — ${_formatDateKn(dt)}',
      totalDurationMin: 0,
      durationText: '—',
      indiaVisibleText: 'ಈ ಸ್ಥಳದಲ್ಲಿ ಗೋಚರ ಇಲ್ಲ',
    );
  }

  /// Build GrahanaInfo from local lunar eclipse data
  static GrahanaInfo _buildLunarEclipseInfo(
    List<double> times, double magnitude, EclipseFlag globalType,
    double lat, double lon, double tzOffset,
  ) {
    final maxJd = times[0];
    // Lunar eclipse times:
    // [2] = partial begin (Sparsha), [3] = partial end (Moksha)
    // [4] = penumbral begin, [5] = penumbral end
    // [6] = total begin (Grasa), [7] = total end (Unmilana)
    final partialBegin = times[2];
    final partialEnd = times[3];
    final penBegin = times[4];
    final penEnd = times[5];
    final totalBegin = times.length > 6 ? times[6] : 0.0;
    final totalEnd = times.length > 7 ? times[7] : 0.0;

    // Determine type
    GrahanaSubtype subtype;
    String typeKn;
    if (_hasFlag(globalType, EclipseFlag.SE_ECL_TOTAL)) {
      subtype = GrahanaSubtype.purna;
      typeKn = 'ಪೂರ್ಣ ಚಂದ್ರ ಗ್ರಹಣ';
    } else if (_hasFlag(globalType, EclipseFlag.SE_ECL_PARTIAL)) {
      subtype = GrahanaSubtype.bhagasha;
      typeKn = 'ಭಾಗಶಃ ಚಂದ್ರ ಗ್ರಹಣ';
    } else if (_hasFlag(globalType, EclipseFlag.SE_ECL_PENUMBRAL)) {
      subtype = GrahanaSubtype.penumbral;
      typeKn = 'ಉಪಛಾಯಾ ಚಂದ್ರ ಗ್ರಹಣ';
    } else {
      subtype = GrahanaSubtype.bhagasha;
      typeKn = 'ಚಂದ್ರ ಗ್ರಹಣ';
    }

    // Build phases
    final phases = <GrahanaPhase>[];
    if (penBegin > 0) phases.add(_makePhase('ಉಪಛಾಯಾ ಆರಂಭ', 'Penumbral Begin', penBegin, tzOffset));
    if (partialBegin > 0) phases.add(_makePhase('ಸ್ಪರ್ಶ', 'Partial Begin', partialBegin, tzOffset));
    if (totalBegin > 0) phases.add(_makePhase('ಗ್ರಾಸ', 'Total Begin', totalBegin, tzOffset));
    phases.add(_makePhase('ಮಧ್ಯ', 'Maximum Eclipse', maxJd, tzOffset));
    if (totalEnd > 0) phases.add(_makePhase('ಉನ್ಮಿಲನ', 'Total End', totalEnd, tzOffset));
    if (partialEnd > 0) phases.add(_makePhase('ಮೋಕ್ಷ', 'Partial End', partialEnd, tzOffset));
    if (penEnd > 0) phases.add(_makePhase('ಉಪಛಾಯಾ ಮೋಕ್ಷ', 'Penumbral End', penEnd, tzOffset));

    final dur = _calcDuration(phases);

    // Visible window: use partial begin/end if available, else penumbral
    final visStartJd = partialBegin > 0 ? partialBegin : (penBegin > 0 ? penBegin : maxJd);
    final visEndJd = partialEnd > 0 ? partialEnd : (penEnd > 0 ? penEnd : maxJd);
    final visMin = ((visEndJd - visStartJd) * 24 * 60).round();
    String visText = '';
    if (visMin > 0) {
      final fromStr = _formatTime(_jdToLocal(visStartJd, tzOffset));
      final toStr = _formatTime(_jdToLocal(visEndJd, tzOffset));
      final h = visMin ~/ 60;
      final m = visMin % 60;
      visText = h > 0 ? '$fromStr — $toStr ($h ಗಂಟೆ $m ನಿಮಿಷ)' : '$fromStr — $toStr ($m ನಿಮಿಷ)';
    }

    final moonLat = _getMoonLatitude(maxJd);
    final dt = _jdToLocal(maxJd, tzOffset);

    // Check if Moon is above horizon at any phase
    final moonAlt = _getMoonAltitude(maxJd, lat, lon);
    final isVisible = moonAlt > 0;

    return GrahanaInfo(
      type: GrahanaType.chandra,
      subtype: subtype,
      dateTime: dt,
      syzygyJd: maxJd,
      moonLatitude: moonLat,
      magnitude: magnitude,
      phases: phases,
      visibleInIndia: isVisible,
      visibilityNote: isVisible ? 'ಗೋಚರ: ಹೌದು' : 'ಗೋಚರ: ಇಲ್ಲ',
      typeKannada: typeKn,
      summary: '$typeKn — ${_formatDateKn(dt)}',
      totalDurationMin: dur['min'] as int,
      durationText: dur['text'] as String,
      indiaVisibleFrom: visMin > 0 ? _formatTime(_jdToLocal(visStartJd, tzOffset)) : '',
      indiaVisibleTo: visMin > 0 ? _formatTime(_jdToLocal(visEndJd, tzOffset)) : '',
      indiaVisibleMin: visMin,
      indiaVisibleText: isVisible ? visText : 'ಈ ಸ್ಥಳದಲ್ಲಿ ಗೋಚರ ಇಲ್ಲ',
    );
  }

  /// Build GrahanaInfo for a lunar eclipse not visible locally
  static GrahanaInfo _buildGlobalLunarEclipseInfo(
    double maxJd, EclipseFlag globalType, double lat, double lon, double tzOffset,
  ) {
    GrahanaSubtype subtype;
    String typeKn;
    if (_hasFlag(globalType, EclipseFlag.SE_ECL_TOTAL)) {
      subtype = GrahanaSubtype.purna;
      typeKn = 'ಪೂರ್ಣ ಚಂದ್ರ ಗ್ರಹಣ';
    } else if (_hasFlag(globalType, EclipseFlag.SE_ECL_PARTIAL)) {
      subtype = GrahanaSubtype.bhagasha;
      typeKn = 'ಭಾಗಶಃ ಚಂದ್ರ ಗ್ರಹಣ';
    } else if (_hasFlag(globalType, EclipseFlag.SE_ECL_PENUMBRAL)) {
      subtype = GrahanaSubtype.penumbral;
      typeKn = 'ಉಪಛಾಯಾ ಚಂದ್ರ ಗ್ರಹಣ';
    } else {
      subtype = GrahanaSubtype.bhagasha;
      typeKn = 'ಚಂದ್ರ ಗ್ರಹಣ';
    }

    final moonLat = _getMoonLatitude(maxJd);
    final dt = _jdToLocal(maxJd, tzOffset);
    final phases = [_makePhase('ಮಧ್ಯ', 'Maximum Eclipse', maxJd, tzOffset)];

    return GrahanaInfo(
      type: GrahanaType.chandra,
      subtype: subtype,
      dateTime: dt,
      syzygyJd: maxJd,
      moonLatitude: moonLat,
      magnitude: 0,
      phases: phases,
      visibleInIndia: false,
      visibilityNote: 'ಗೋಚರ: ಇಲ್ಲ',
      typeKannada: typeKn,
      summary: '$typeKn — ${_formatDateKn(dt)}',
      totalDurationMin: 0,
      durationText: '—',
      indiaVisibleText: 'ಈ ಸ್ಥಳದಲ್ಲಿ ಗೋಚರ ಇಲ್ಲ',
    );
  }

  // ── Helper functions ──

  /// Check if an EclipseFlag has a specific flag set
  static bool _hasFlag(EclipseFlag flags, EclipseFlag check) {
    return (flags.value & check.value) != 0;
  }

  /// Calculate duration from first to last phase
  static Map<String, dynamic> _calcDuration(List<GrahanaPhase> phases) {
    if (phases.length < 2) return {'min': 0, 'text': '—'};
    final durationMin = ((phases.last.jd - phases.first.jd) * 24 * 60).round();
    final hours = durationMin ~/ 60;
    final mins = durationMin % 60;
    String text;
    if (hours > 0) {
      text = '$hours ಗಂಟೆ $mins ನಿಮಿಷ';
    } else {
      text = '$mins ನಿಮಿಷ';
    }
    return {'min': durationMin, 'text': text};
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

  /// Moon's celestial latitude at JD (sayana/tropical)
  static double _getMoonLatitude(double jd) {
    final flags = SwephFlag.SEFLG_SWIEPH;
    final moon = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, flags);
    return moon.latitude;
  }

  /// Get Moon's altitude from a location
  static double _getMoonAltitude(double jd, double lat, double lon) {
    final flags = SwephFlag.SEFLG_EQUATORIAL | SwephFlag.SEFLG_SWIEPH;
    final moon = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, flags);
    final ra = moon.longitude;
    final dec = moon.latitude;
    final gmst = Sweph.swe_sidtime(jd);
    final lst = gmst + (lon / 15.0);
    double haDeg = ((lst * 15.0) - ra + 360) % 360;
    if (haDeg > 180) haDeg -= 360;
    final haRad = haDeg * pi / 180;
    final latRad = lat * pi / 180;
    final decRad = dec * pi / 180;
    final sinAlt = sin(latRad) * sin(decRad) + cos(latRad) * cos(decRad) * cos(haRad);
    return asin(sinAlt) * 180 / pi;
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
