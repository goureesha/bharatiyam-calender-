/// Lagna Calculator — Full 12-rashi ascendant transit timings.
/// Scans day/night for when each rashi rises on the eastern horizon.
import '../models/panchanga_data.dart';
import 'ephemeris.dart';

class LagnaCalculator {
  /// Calculate day lagna transits (sunrise to sunset)
  static List<LagnaTransit> calculateDayLagnas({
    required double sunriseJd,
    required double sunsetJd,
    required double lat,
    required double lon,
    String ayanamsaMode = 'lahiri',
    double tzOffset = 5.5,
  }) {
    return _scanLagnas(
      startJd: sunriseJd,
      endJd: sunsetJd,
      lat: lat,
      lon: lon,
      ayanamsaMode: ayanamsaMode,
      tzOffset: tzOffset,
    );
  }

  /// Calculate night lagna transits (sunset to next sunrise)
  static List<LagnaTransit> calculateNightLagnas({
    required double sunsetJd,
    required double nextSunriseJd,
    required double lat,
    required double lon,
    String ayanamsaMode = 'lahiri',
    double tzOffset = 5.5,
  }) {
    return _scanLagnas(
      startJd: sunsetJd,
      endJd: nextSunriseJd,
      lat: lat,
      lon: lon,
      ayanamsaMode: ayanamsaMode,
      tzOffset: tzOffset,
    );
  }

  /// Scan a time range for lagna (ascendant) rashi changes
  static List<LagnaTransit> _scanLagnas({
    required double startJd,
    required double endJd,
    required double lat,
    required double lon,
    required String ayanamsaMode,
    required double tzOffset,
  }) {
    final results = <LagnaTransit>[];
    final step = 5.0 / (24.0 * 60.0); // 5-minute steps in JD

    // Get initial rashi
    var prevHouses = Ephemeris.getHouses(startJd, lat, lon, ayanamsaMode);
    var prevRashi = (prevHouses['asc']! / 30).floor() % 12;
    var segmentStart = startJd;

    double jd = startJd + step;
    while (jd <= endJd) {
      final houses = Ephemeris.getHouses(jd, lat, lon, ayanamsaMode);
      final currentRashi = (houses['asc']! / 30).floor() % 12;

      if (currentRashi != prevRashi) {
        // Binary search for exact transit moment
        double lo = jd - step, hi = jd;
        for (int i = 0; i < 15; i++) {
          final mid = (lo + hi) / 2;
          final midHouses = Ephemeris.getHouses(mid, lat, lon, ayanamsaMode);
          final midRashi = (midHouses['asc']! / 30).floor() % 12;
          if (midRashi == prevRashi) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        final transitJd = (lo + hi) / 2;

        // Add completed segment
        results.add(LagnaTransit(
          rashi: 'r$prevRashi',
          rashiIndex: prevRashi,
          startTime: Ephemeris.formatTimeFromJd(segmentStart, tzOffset: tzOffset),
          endTime: Ephemeris.formatTimeFromJd(transitJd, tzOffset: tzOffset),
        ));

        prevRashi = currentRashi;
        segmentStart = transitJd;
      }

      jd += step;
    }

    // Add final segment
    results.add(LagnaTransit(
      rashi: 'r$prevRashi',
      rashiIndex: prevRashi,
      startTime: Ephemeris.formatTimeFromJd(segmentStart, tzOffset: tzOffset),
      endTime: Ephemeris.formatTimeFromJd(endJd, tzOffset: tzOffset),
    ));

    return results;
  }
}
