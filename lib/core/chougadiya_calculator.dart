/// Chougadiya Calculator — 8 day + 8 night periods (Gauri Panchanga).
import '../models/panchanga_data.dart';
import 'ephemeris.dart';

class ChougadiyaCalculator {
  // 7 named periods
  static const List<String> _names = [
    'Udveg', 'Chal', 'Laabh', 'Amrut', 'Kaal', 'Shubh', 'Rog'
  ];
  static const List<String> _natures = [
    'ashubha', 'madhyama', 'shubha', 'shubha', 'ashubha', 'shubha', 'ashubha'
  ];

  // Starting index per weekday (Sun=0..Sat=6)
  static const List<int> _dayStart = [0, 3, 6, 2, 5, 1, 4];
  static const List<int> _nightStart = [5, 1, 4, 0, 3, 6, 2];

  /// Calculate 8 day chougadiya periods
  static List<ChougadiyaTiming> calculateDay({
    required double sunriseJd,
    required double sunsetJd,
    required int varaIndex,
    double tzOffset = 5.5,
  }) {
    final duration = (sunsetJd - sunriseJd) / 8.0;
    final startIdx = _dayStart[varaIndex];
    return List.generate(8, (i) {
      final start = sunriseJd + i * duration;
      final end = start + duration;
      final idx = (startIdx + i) % 7;
      return ChougadiyaTiming(
        name: _names[idx],
        startTime: Ephemeris.formatTimeFromJd(start, tzOffset: tzOffset),
        endTime: Ephemeris.formatTimeFromJd(end, tzOffset: tzOffset),
        nature: _natures[idx],
      );
    });
  }

  /// Calculate 8 night chougadiya periods
  static List<ChougadiyaTiming> calculateNight({
    required double sunsetJd,
    required double nextSunriseJd,
    required int varaIndex,
    double tzOffset = 5.5,
  }) {
    final duration = (nextSunriseJd - sunsetJd) / 8.0;
    final startIdx = _nightStart[varaIndex];
    return List.generate(8, (i) {
      final start = sunsetJd + i * duration;
      final end = start + duration;
      final idx = (startIdx + i) % 7;
      return ChougadiyaTiming(
        name: _names[idx],
        startTime: Ephemeris.formatTimeFromJd(start, tzOffset: tzOffset),
        endTime: Ephemeris.formatTimeFromJd(end, tzOffset: tzOffset),
        nature: _natures[idx],
      );
    });
  }
}
