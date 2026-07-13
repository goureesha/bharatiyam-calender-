/// Kala Calculator — Rahu Kala, Yamaganda Kala, Gulika Kala.
/// Divides daytime into 8 equal muhurtas, assigns inauspicious periods per weekday.
import '../models/panchanga_data.dart';
import 'ephemeris.dart';

class KalaCalculator {
  // Muhurta number (1-indexed) for each weekday (Sun=0 .. Sat=6)
  static const List<int> _rahuKala = [8, 2, 7, 5, 6, 4, 3];
  static const List<int> _yamaganda = [5, 4, 3, 6, 5, 1, 2];
  static const List<int> _gulikaKala = [7, 6, 5, 4, 3, 2, 1];

  /// Calculate all three Kala timings
  static List<KalaTiming> calculate({
    required double sunriseJd,
    required double sunsetJd,
    required int varaIndex, // 0=Sun, 1=Mon, ..., 6=Sat
    double tzOffset = 5.5,
  }) {
    final dayDuration = sunsetJd - sunriseJd; // in JD
    final muhurtaDuration = dayDuration / 8.0;

    KalaTiming _calcKala(String name, List<int> table) {
      final muhurtaNum = table[varaIndex];
      final startJd = sunriseJd + (muhurtaNum - 1) * muhurtaDuration;
      final endJd = startJd + muhurtaDuration;
      return KalaTiming(
        name: name,
        startTime: Ephemeris.formatTimeFromJd(startJd, tzOffset: tzOffset),
        endTime: Ephemeris.formatTimeFromJd(endJd, tzOffset: tzOffset),
      );
    }

    return [
      _calcKala('rahuKala', _rahuKala),
      _calcKala('yamaKala', _yamaganda),
      _calcKala('gulikaKala', _gulikaKala),
    ];
  }
}
