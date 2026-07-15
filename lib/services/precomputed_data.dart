/// Loads pre-computed 3-year panchanga data from bundled JSON asset.
import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/events.dart';
import '../models/panchanga_data.dart';

class PrecomputedData {
  static final PrecomputedData _instance = PrecomputedData._();
  factory PrecomputedData() => _instance;
  PrecomputedData._();

  Map<String, dynamic>? _data;
  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/panchanga_3yr.json');
      _data = jsonDecode(jsonStr) as Map<String, dynamic>;
      _loaded = true;
    } catch (e) {
      // Asset not found — will compute on-demand
    }
  }

  PanchangaData? getDay(int year, int month, int day) {
    if (_data == null) return null;
    final key = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    final days = _data!['days'] as Map<String, dynamic>?;
    if (days == null || !days.containsKey(key)) return null;
    return PanchangaData.fromJson(days[key] as Map<String, dynamic>);
  }

  List<AstroEvent> getEvents(int year, int month, int day) {
    if (_data == null) return [];
    final key = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    final days = _data!['days'] as Map<String, dynamic>?;
    if (days == null || !days.containsKey(key)) return [];
    final dayData = days[key] as Map<String, dynamic>;
    final events = dayData['ev'] as List<dynamic>?;
    if (events == null || events.isEmpty) return [];
    return events.map((e) {
      final m = e as Map<String, dynamic>;
      return AstroEvent(
        name: m['n'] ?? '', description: m['d'] ?? '',
        shloka: m['s'] ?? '', meaning: m['m'] ?? '', source: m['r'] ?? '',
      );
    }).toList();
  }

  Map<int, PanchangaData> getMonthData(int year, int month) {
    final result = <int, PanchangaData>{};
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int d = 1; d <= daysInMonth; d++) {
      final p = getDay(year, month, d);
      if (p != null) result[d] = p;
    }
    return result;
  }

  Map<int, List<AstroEvent>> getMonthEvents(int year, int month) {
    final result = <int, List<AstroEvent>>{};
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int d = 1; d <= daysInMonth; d++) {
      final ev = getEvents(year, month, d);
      if (ev.isNotEmpty) result[d] = ev;
    }
    return result;
  }
}
