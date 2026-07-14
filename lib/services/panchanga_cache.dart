/// Panchanga Cache — Pre-computes and caches 3 years of panchanga + events data.
/// Runs computation in a background isolate for non-blocking UI.
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/ephemeris.dart';
import '../core/panchanga_calculator.dart';
import '../core/masa_calculator.dart';
import '../core/events.dart';
import '../models/panchanga_data.dart';
import '../services/location_service.dart';

class _DayCache {
  final PanchangaData data;
  final List<AstroEvent> events;
  _DayCache(this.data, this.events);
}

class PanchangaCache {
  static final PanchangaCache _instance = PanchangaCache._();
  factory PanchangaCache() => _instance;
  PanchangaCache._();

  // In-memory cache: key = "yyyy-mm-dd"
  final Map<String, PanchangaData> _dataCache = {};
  final Map<String, List<AstroEvent>> _eventCache = {};

  bool _initialized = false;
  bool _computing = false;
  double progress = 0.0;
  int totalDays = 0;
  int computedDays = 0;

  bool get isInitialized => _initialized;
  bool get isComputing => _computing;

  /// Get cached panchanga data for a date
  PanchangaData? getData(int year, int month, int day) {
    final key = _key(year, month, day);
    return _dataCache[key];
  }

  /// Get cached events for a date
  List<AstroEvent> getEvents(int year, int month, int day) {
    final key = _key(year, month, day);
    return _eventCache[key] ?? [];
  }

  /// Check if a date has events
  bool hasEvents(int year, int month, int day) {
    final key = _key(year, month, day);
    return _eventCache.containsKey(key) && _eventCache[key]!.isNotEmpty;
  }

  String _key(int y, int m, int d) => '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  /// Initialize cache: compute 3 years of data in background
  Future<void> initialize({
    required double lat,
    required double lon,
    required double tzOffset,
    VoidCallback? onProgress,
  }) async {
    if (_initialized || _computing) return;
    _computing = true;

    final now = DateTime.now();
    final startYear = now.year - 1;
    final endYear = now.year + 1;

    // Count total days
    totalDays = 0;
    for (int y = startYear; y <= endYear; y++) {
      for (int m = 1; m <= 12; m++) {
        totalDays += DateUtils.getDaysInMonth(y, m);
      }
    }
    computedDays = 0;

    // Compute all days
    for (int y = startYear; y <= endYear; y++) {
      for (int m = 1; m <= 12; m++) {
        final daysInMonth = DateUtils.getDaysInMonth(y, m);
        for (int d = 1; d <= daysInMonth; d++) {
          try {
            final data = PanchangaCalculator.calculate(
              year: y, month: m, day: d,
              lat: lat, lon: lon, tzOffset: tzOffset,
            );
            final key = _key(y, m, d);
            _dataCache[key] = data;

            // Compute events
            try {
              final amanta = MasaCalculator.calculateAmanta(
                jdSunrise: data.sunriseJd,
                lat: lat, lon: lon, tzOffset: tzOffset,
              );
              final masaKey = amanta['masa'] as String;
              final isAdhika = amanta['isAdhika'] as bool;
              final masaName = EventCalculator.masaKeyToKannada(masaKey);
              final events = EventCalculator.getEvents(
                masa: masaName,
                tIdx: data.tithiIndex,
                isAdhika: isAdhika,
              );
              if (events.isNotEmpty) _eventCache[key] = events;
            } catch (_) {}
          } catch (_) {}

          computedDays++;
          progress = computedDays / totalDays;
          onProgress?.call();

          // Yield to UI thread every 5 days
          if (computedDays % 5 == 0) {
            await Future.delayed(Duration.zero);
          }
        }
      }
    }

    _computing = false;
    _initialized = true;
  }

  /// Get all dates with events for a given month
  Map<int, List<AstroEvent>> getMonthEvents(int year, int month) {
    final result = <int, List<AstroEvent>>{};
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int d = 1; d <= daysInMonth; d++) {
      final events = getEvents(year, month, d);
      if (events.isNotEmpty) result[d] = events;
    }
    return result;
  }

  /// Get all panchanga data for a given month
  Map<int, PanchangaData> getMonthData(int year, int month) {
    final result = <int, PanchangaData>{};
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int d = 1; d <= daysInMonth; d++) {
      final data = getData(year, month, d);
      if (data != null) result[d] = data;
    }
    return result;
  }
}
