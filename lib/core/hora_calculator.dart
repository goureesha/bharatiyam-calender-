/// Hora Calculator — 12 day + 12 night planetary hours.
import '../models/panchanga_data.dart';
import 'ephemeris.dart';

class HoraCalculator {
  // Planet order for Hora cycle
  static const List<String> _planetOrder = [
    'Sun', 'Venus', 'Mercury', 'Moon', 'Saturn', 'Jupiter', 'Mars'
  ];

  // Starting planet index per weekday (Sun=0..Sat=6)
  static const List<int> _dayStart = [0, 3, 6, 2, 5, 1, 4];

  /// Calculate 12 day horas (sunrise to sunset)
  static List<HoraTiming> calculateDayHoras({
    required double sunriseJd,
    required double sunsetJd,
    required int varaIndex,
    double tzOffset = 5.5,
  }) {
    final duration = (sunsetJd - sunriseJd) / 12.0;
    final startIdx = _dayStart[varaIndex];
    return List.generate(12, (i) {
      final start = sunriseJd + i * duration;
      final end = start + duration;
      final planetIdx = (startIdx + i) % 7;
      return HoraTiming(
        planet: _planetOrder[planetIdx],
        startTime: Ephemeris.formatTimeFromJd(start, tzOffset: tzOffset),
        endTime: Ephemeris.formatTimeFromJd(end, tzOffset: tzOffset),
      );
    });
  }

  /// Calculate 12 night horas (sunset to next sunrise)
  static List<HoraTiming> calculateNightHoras({
    required double sunsetJd,
    required double nextSunriseJd,
    required int varaIndex,
    double tzOffset = 5.5,
  }) {
    final duration = (nextSunriseJd - sunsetJd) / 12.0;
    // Night horas continue from where day horas ended
    final startIdx = (_dayStart[varaIndex] + 12) % 7;
    return List.generate(12, (i) {
      final start = sunsetJd + i * duration;
      final end = start + duration;
      final planetIdx = (startIdx + i) % 7;
      return HoraTiming(
        planet: _planetOrder[planetIdx],
        startTime: Ephemeris.formatTimeFromJd(start, tzOffset: tzOffset),
        endTime: Ephemeris.formatTimeFromJd(end, tzOffset: tzOffset),
      );
    });
  }
}
