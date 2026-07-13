/// Muhurta Calculator — 15 Day + 15 Night muhurtas + special muhurtas.
import '../models/panchanga_data.dart';
import 'ephemeris.dart';

class MuhurtaCalculator {
  // ─── 15 Day Muhurta names and natures ───
  static const List<Map<String, String>> _dayMuhurtas = [
    {'name': 'dm0', 'nature': 'ashubha'},  // Rudra
    {'name': 'dm1', 'nature': 'ashubha'},  // Ahi
    {'name': 'dm2', 'nature': 'shubha'},   // Mitra
    {'name': 'dm3', 'nature': 'ashubha'},  // Pitru
    {'name': 'dm4', 'nature': 'shubha'},   // Vasu
    {'name': 'dm5', 'nature': 'shubha'},   // Varaha
    {'name': 'dm6', 'nature': 'shubha'},   // Vishwedeva
    {'name': 'dm7', 'nature': 'madhyama'}, // Vidhi
    {'name': 'dm8', 'nature': 'shubha'},   // Satmukhi
    {'name': 'dm9', 'nature': 'ashubha'},  // Puruhuta
    {'name': 'dm10', 'nature': 'ashubha'}, // Vahini
    {'name': 'dm11', 'nature': 'madhyama'},// Naktanakara
    {'name': 'dm12', 'nature': 'shubha'},  // Varuna
    {'name': 'dm13', 'nature': 'shubha'},  // Aryama
    {'name': 'dm14', 'nature': 'ashubha'}, // Bhaga
  ];

  // ─── 15 Night Muhurta names and natures ───
  static const List<Map<String, String>> _nightMuhurtas = [
    {'name': 'nm0', 'nature': 'shubha'},   // Shiva
    {'name': 'nm1', 'nature': 'ashubha'},  // Guhya
    {'name': 'nm2', 'nature': 'shubha'},   // Brahma
    {'name': 'nm3', 'nature': 'shubha'},   // Indra
    {'name': 'nm4', 'nature': 'shubha'},   // Jiva
    {'name': 'nm5', 'nature': 'madhyama'}, // Dipti
    {'name': 'nm6', 'nature': 'ashubha'},  // Vishwa
    {'name': 'nm7', 'nature': 'ashubha'},  // Kutsam
    {'name': 'nm8', 'nature': 'madhyama'}, // Isham
    {'name': 'nm9', 'nature': 'shubha'},   // Isha
    {'name': 'nm10', 'nature': 'shubha'},  // Mitra
    {'name': 'nm11', 'nature': 'ashubha'}, // Aditya
    {'name': 'nm12', 'nature': 'ashubha'}, // Kali
    {'name': 'nm13', 'nature': 'shubha'},  // Siddhi
    {'name': 'nm14', 'nature': 'shubha'},  // Nirdosha
  ];

  /// Calculate 15 day muhurtas
  static List<MuhurtaTiming> calculateDayMuhurtas({
    required double sunriseJd,
    required double sunsetJd,
    double tzOffset = 5.5,
  }) {
    final duration = (sunsetJd - sunriseJd) / 15.0;
    return List.generate(15, (i) {
      final start = sunriseJd + i * duration;
      final end = start + duration;
      return MuhurtaTiming(
        name: _dayMuhurtas[i]['name']!,
        startTime: Ephemeris.formatTimeFromJd(start, tzOffset: tzOffset),
        endTime: Ephemeris.formatTimeFromJd(end, tzOffset: tzOffset),
        nature: _dayMuhurtas[i]['nature']!,
      );
    });
  }

  /// Calculate 15 night muhurtas (sunset to next sunrise)
  static List<MuhurtaTiming> calculateNightMuhurtas({
    required double sunsetJd,
    required double nextSunriseJd,
    double tzOffset = 5.5,
  }) {
    final duration = (nextSunriseJd - sunsetJd) / 15.0;
    return List.generate(15, (i) {
      final start = sunsetJd + i * duration;
      final end = start + duration;
      return MuhurtaTiming(
        name: _nightMuhurtas[i]['name']!,
        startTime: Ephemeris.formatTimeFromJd(start, tzOffset: tzOffset),
        endTime: Ephemeris.formatTimeFromJd(end, tzOffset: tzOffset),
        nature: _nightMuhurtas[i]['nature']!,
      );
    });
  }

  /// Abhijit Muhurta: midday ± half muhurta
  static MuhurtaTiming calculateAbhijit({
    required double sunriseJd,
    required double sunsetJd,
    double tzOffset = 5.5,
  }) {
    final mid = (sunriseJd + sunsetJd) / 2;
    final muhurtaDur = (sunsetJd - sunriseJd) / 15.0;
    final halfDur = muhurtaDur / 2;
    return MuhurtaTiming(
      name: 'abhijit',
      startTime: Ephemeris.formatTimeFromJd(mid - halfDur, tzOffset: tzOffset),
      endTime: Ephemeris.formatTimeFromJd(mid + halfDur, tzOffset: tzOffset),
      nature: 'shubha',
    );
  }

  // ─── Durmuhurta offsets per weekday (in muhurta index from sunrise) ───
  // Each weekday has 1-2 durmuhurta periods
  static const Map<int, List<List<int>>> _durmuhurtaOffsets = {
    0: [[2, 3], [10, 11]],     // Sunday
    1: [[7, 8], [14, 15]],     // Monday
    2: [[3, 4], [11, 12]],     // Tuesday
    3: [[5, 6], [13, 14]],     // Wednesday
    4: [[6, 7], [14, 15]],     // Thursday
    5: [[4, 5], [12, 13]],     // Friday
    6: [[1, 2], [9, 10]],      // Saturday
  };

  /// Calculate Durmuhurta timings
  static List<MuhurtaTiming> calculateDurmuhurta({
    required double sunriseJd,
    required double sunsetJd,
    required int varaIndex,
    double tzOffset = 5.5,
  }) {
    final muhurtaDur = (sunsetJd - sunriseJd) / 15.0;
    final offsets = _durmuhurtaOffsets[varaIndex] ?? [];
    return offsets.map((pair) {
      final start = sunriseJd + pair[0] * muhurtaDur;
      final end = sunriseJd + pair[1] * muhurtaDur;
      return MuhurtaTiming(
        name: 'durmuhurta',
        startTime: Ephemeris.formatTimeFromJd(start, tzOffset: tzOffset),
        endTime: Ephemeris.formatTimeFromJd(end, tzOffset: tzOffset),
        nature: 'ashubha',
      );
    }).toList();
  }

  // ─── Varjyam ghati offsets per nakshatra ───
  static const List<double> _varjyamGhatis = [
    50, 24, 30, 40, 14, 11, 30, 20, 32,
    30, 20, 18, 22, 20, 14, 14, 10, 14,
    20, 24, 20, 10, 10, 18, 16, 24, 30,
  ];

  /// Calculate Varjyam (Tyajya) timing
  static MuhurtaTiming? calculateVarjyam({
    required double sunriseJd,
    required int nakshatraIndex,
    double tzOffset = 5.5,
  }) {
    if (nakshatraIndex < 0 || nakshatraIndex >= 27) return null;
    final ghatiOffset = _varjyamGhatis[nakshatraIndex];
    final startJd = sunriseJd + (ghatiOffset * 24.0 / 60.0) / 24.0; // ghati to JD
    final endJd = startJd + (4.0 * 24.0 / 60.0) / 24.0; // 4 ghati duration
    return MuhurtaTiming(
      name: 'varjya',
      startTime: Ephemeris.formatTimeFromJd(startJd, tzOffset: tzOffset),
      endTime: Ephemeris.formatTimeFromJd(endJd, tzOffset: tzOffset),
      nature: 'ashubha',
    );
  }

  // ─── Amrita Siddhi Yoga: vara + nakshatra combinations ───
  static const Map<int, List<int>> _amritaSiddhiCombos = {
    0: [12],     // Sunday + Hasta
    1: [21],     // Monday + Shravana
    2: [4],      // Tuesday + Mrigashira
    3: [16],     // Wednesday + Anuradha
    4: [6],      // Thursday + Punarvasu
    5: [0],      // Friday + Ashwini
    6: [7],      // Saturday + Pushya
  };

  /// Check if Amrita Siddhi Yoga is active
  static bool isAmritaSiddhi(int varaIndex, int nakshatraIndex) {
    final combos = _amritaSiddhiCombos[varaIndex];
    return combos?.contains(nakshatraIndex) ?? false;
  }
}
