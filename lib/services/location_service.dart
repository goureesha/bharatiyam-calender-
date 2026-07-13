/// Location service — GPS auto-detect and city selector.
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/places.dart';

class LocationService {
  static double lat = 12.9716; // Default: Bangalore
  static double lon = 77.5946;
  static double tzOffset = 5.5;
  static String cityName = 'Bangalore';
  static String cityNameKn = 'ಬೆಂಗಳೂರು';

  /// Load saved location or default
  static Future<void> loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    lat = prefs.getDouble('loc_lat') ?? 12.9716;
    lon = prefs.getDouble('loc_lon') ?? 77.5946;
    tzOffset = prefs.getDouble('loc_tz') ?? 5.5;
    cityName = prefs.getString('loc_name') ?? 'Bangalore';
    cityNameKn = prefs.getString('loc_name_kn') ?? 'ಬೆಂಗಳೂರು';
  }

  /// Save current location
  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('loc_lat', lat);
    await prefs.setDouble('loc_lon', lon);
    await prefs.setDouble('loc_tz', tzOffset);
    await prefs.setString('loc_name', cityName);
    await prefs.setString('loc_name_kn', cityNameKn);
  }

  /// Set location from a city
  static Future<void> setCity(CityData city) async {
    lat = city.lat;
    lon = city.lon;
    tzOffset = city.tzOffset;
    cityName = city.name;
    cityNameKn = city.nameKn;
    await _save();
  }

  /// Auto-detect location via GPS
  static Future<bool> detectGps() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }
      if (permission == LocationPermission.deniedForever) return false;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      lat = position.latitude;
      lon = position.longitude;

      // Find nearest city
      final nearest = _findNearestCity(lat, lon);
      if (nearest != null) {
        cityName = nearest.name;
        cityNameKn = nearest.nameKn;
        tzOffset = nearest.tzOffset;
      } else {
        cityName = '${lat.toStringAsFixed(2)}°N, ${lon.toStringAsFixed(2)}°E';
        cityNameKn = cityName;
      }
      await _save();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Find nearest city within 100km
  static CityData? _findNearestCity(double lat, double lon) {
    CityData? nearest;
    double minDist = double.infinity;
    for (final city in indianCities) {
      final dlat = city.lat - lat;
      final dlon = city.lon - lon;
      final dist = dlat * dlat + dlon * dlon;
      if (dist < minDist) {
        minDist = dist;
        nearest = city;
      }
    }
    // Only match if within ~100km (~1 degree)
    return (minDist < 1.0) ? nearest : null;
  }

  /// Search cities by name
  static List<CityData> searchCities(String query) {
    if (query.isEmpty) return indianCities;
    final q = query.toLowerCase();
    return indianCities.where((c) =>
      c.name.toLowerCase().contains(q) ||
      c.nameKn.contains(query) ||
      c.state.toLowerCase().contains(q)
    ).toList();
  }
}
