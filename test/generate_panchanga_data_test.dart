// Pre-compute 3 years of panchanga data for bundling in app.
// Run: flutter test test/generate_panchanga_data_test.dart
@TestOn('vm')
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bharatiyam_panchanga/core/ephemeris.dart';
import 'package:bharatiyam_panchanga/core/panchanga_calculator.dart';
import 'package:bharatiyam_panchanga/core/masa_calculator.dart';
import 'package:bharatiyam_panchanga/core/samvatsara.dart';
import 'package:bharatiyam_panchanga/core/events.dart';

void main() {
  test('Generate 3-year panchanga JSON', () async {
    await Ephemeris.initSweph();

    const lat = 12.9716;
    const lon = 77.5946;
    const tz = 5.5;

    final now = DateTime.now();
    final startYear = now.year - 1;
    final endYear = now.year + 1;

    final allData = <String, dynamic>{
      'g': DateTime.now().toIso8601String(),
      'lat': lat, 'lon': lon, 'tz': tz,
      'days': <String, dynamic>{},
    };

    for (int y = startYear; y <= endYear; y++) {
      for (int m = 1; m <= 12; m++) {
        final daysInMonth = DateTime(y, m + 1, 0).day;
        for (int d = 1; d <= daysInMonth; d++) {
          try {
            var p = PanchangaCalculator.calculate(
              year: y, month: m, day: d,
              lat: lat, lon: lon, tzOffset: tz,
            );

            try {
              final amanta = MasaCalculator.calculateAmanta(
                jdSunrise: p.sunriseJd, lat: lat, lon: lon, tzOffset: tz,
              );
              final pour = MasaCalculator.calculatePournimanta(
                jdSunrise: p.sunriseJd, lat: lat, lon: lon, tzOffset: tz,
              );
              final soura = MasaCalculator.calculateSoura(
                jdSunrise: p.sunriseJd, lat: lat, lon: lon, tzOffset: tz,
              );
              final amantaKey = amanta['masa'] as String;
              final sam = SamvatsaraCalculator.calculate(y, m, chandraMasaKey: amantaKey);
              // Compute rutu from Sun's sidereal longitude
              final sunPlanets = Ephemeris.calcAll(p.sunriseJd, 'lahiri', true);
              final sunDeg = sunPlanets['Sun']![0];
              final rutu = SamvatsaraCalculator.calculateRutu(sunDeg);
              p = p.copyWith(
                amantaMasa: '${amanta["isAdhika"] == true ? "Adhika " : ""}${amanta["masa"]}',
                pournimantaMasa: '${pour["isAdhika"] == true ? "Adhika " : ""}${pour["masa"]}',
                samvatsara: sam['samvatsara'] ?? '',
                rutu: rutu,
              );
            } catch (_) {}

            final dayJson = p.toJson();

            // Add events
            try {
              final amanta = MasaCalculator.calculateAmanta(
                jdSunrise: p.sunriseJd, lat: lat, lon: lon, tzOffset: tz,
              );
              final masaName = EventCalculator.masaKeyToKannada(amanta['masa'] as String);
              final ev = EventCalculator.getEvents(
                masa: masaName, tIdx: p.tithiIndex,
                isAdhika: amanta['isAdhika'] as bool,
              );
              if (ev.isNotEmpty) {
                dayJson['ev'] = ev.map((e) => {
                  'n': e.name, 'd': e.description,
                  's': e.shloka, 'm': e.meaning, 'r': e.source,
                }).toList();
              }
            } catch (_) {}

            final key = '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
            (allData['days'] as Map<String, dynamic>)[key] = dayJson;
          } catch (e) {
            // Skip days that fail
          }
        }
      }
    }

    final dir = Directory('assets');
    if (!dir.existsSync()) dir.createSync();
    final file = File('assets/panchanga_3yr.json');
    file.writeAsStringSync(jsonEncode(allData));
    final kb = (file.lengthSync() / 1024).toStringAsFixed(1);
    final days = (allData['days'] as Map).length;
    // ignore: avoid_print
    print('Written $kb KB, $days days to ${file.path}');
  }, timeout: const Timeout(Duration(minutes: 15)));
}
