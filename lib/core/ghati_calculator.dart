/// Ghati Calculator — Visha Ghati & Amruta Ghati timings.
/// Fixed ghati offsets within each Nakshatra, 4 ghati (96 min) duration.
import 'ephemeris.dart';

class GhatiCalculator {
  // Visha Ghati start offset (in ghatis from nakshatra start)
  static const List<double> vishaGhatis = [
    50, 24, 30, 40, 14, 11, 30, 20, 32,
    30, 20, 18, 22, 20, 14, 14, 10, 14,
    20, 24, 20, 10, 10, 18, 16, 24, 30,
  ];

  // Amruta Ghati start offset (in ghatis from nakshatra start)
  static const List<double> amrutaGhatis = [
    42, 48, 54, 52, 38, 35, 54, 44, 56,
    54, 44, 43, 45, 44, 38, 38, 34, 38,
    44, 48, 44, 34, 34, 43, 40, 48, 54,
  ];

  /// Calculate Visha Ghati timing for current nakshatra
  /// Returns start and end times in formatted strings
  static Map<String, String> calculateVishaGhati({
    required double sunriseJd,
    required int nakshatraIndex,
    required double nakStartJd,
    required double nakEndJd,
    double tzOffset = 5.5,
  }) {
    return _calculateGhati(
      sunriseJd: sunriseJd,
      nakshatraIndex: nakshatraIndex,
      nakStartJd: nakStartJd,
      nakEndJd: nakEndJd,
      ghatiTable: vishaGhatis,
      tzOffset: tzOffset,
    );
  }

  /// Calculate Amruta Ghati timing for current nakshatra
  static Map<String, String> calculateAmrutaGhati({
    required double sunriseJd,
    required int nakshatraIndex,
    required double nakStartJd,
    required double nakEndJd,
    double tzOffset = 5.5,
  }) {
    return _calculateGhati(
      sunriseJd: sunriseJd,
      nakshatraIndex: nakshatraIndex,
      nakStartJd: nakStartJd,
      nakEndJd: nakEndJd,
      ghatiTable: amrutaGhatis,
      tzOffset: tzOffset,
    );
  }

  static Map<String, String> _calculateGhati({
    required double sunriseJd,
    required int nakshatraIndex,
    required double nakStartJd,
    required double nakEndJd,
    required List<double> ghatiTable,
    double tzOffset = 5.5,
  }) {
    if (nakshatraIndex < 0 || nakshatraIndex >= 27) {
      return {'start': '--', 'end': '--'};
    }

    final nakDuration = nakEndJd - nakStartJd; // in JD
    final totalNakGhatis = nakDuration * 60; // convert to ghatis

    // Scale the offset to the actual nakshatra duration
    final ghatiOffset = ghatiTable[nakshatraIndex];
    // Standard nakshatra = 60 ghatis, scale proportionally
    final scaledOffset = (ghatiOffset / 60.0) * nakDuration;
    final scaledDuration = (4.0 / 60.0) * nakDuration; // 4 ghati duration, scaled

    final startJd = nakStartJd + scaledOffset;
    final endJd = startJd + scaledDuration;

    return {
      'start': Ephemeris.formatTimeFromJd(startJd, tzOffset: tzOffset),
      'end': Ephemeris.formatTimeFromJd(endJd, tzOffset: tzOffset),
      'ghatiRange': '${Ephemeris.formatGhati(ghatiOffset)} - ${Ephemeris.formatGhati(ghatiOffset + 4)}',
    };
  }
}
