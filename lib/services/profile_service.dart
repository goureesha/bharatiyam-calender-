/// Profile Service — Manages user profile data (name, address, mobile).
/// Stores locally via SharedPreferences and syncs to server.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class ProfileService {
  static String _name = '';
  static String _address = '';
  static String _mobile = '';
  static bool _profileComplete = false;

  static String get name => _name;
  static String get address => _address;
  static String get mobile => _mobile;
  static bool get isProfileComplete => _profileComplete;

  /// Purohit details string for share card
  static String get purohitDetails {
    if (!_profileComplete) return '';
    final parts = <String>[];
    if (_name.isNotEmpty) parts.add(_name);
    if (_address.isNotEmpty) parts.add(_address);
    if (_mobile.isNotEmpty) parts.add('📞 $_mobile');
    return parts.join('\n');
  }

  /// Load profile from local storage
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('profile_name') ?? '';
    _address = prefs.getString('profile_address') ?? '';
    _mobile = prefs.getString('profile_mobile') ?? '';
    _profileComplete = _name.isNotEmpty && _mobile.isNotEmpty;
  }

  /// Save profile to local storage
  static Future<void> save({
    required String name,
    required String address,
    required String mobile,
  }) async {
    _name = name.trim();
    _address = address.trim();
    _mobile = mobile.trim();
    _profileComplete = _name.isNotEmpty && _mobile.isNotEmpty;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _name);
    await prefs.setString('profile_address', _address);
    await prefs.setString('profile_mobile', _mobile);

    // Sync to server (fire-and-forget)
    _syncToServer();
  }

  /// Sync profile to server
  static Future<void> _syncToServer() async {
    try {
      // TODO: Replace with your actual server endpoint
      // Example: POST to Firebase, Supabase, or custom API
      final payload = {
        'name': _name,
        'address': _address,
        'mobile': _mobile,
        'timestamp': DateTime.now().toIso8601String(),
      };
      debugPrint('Profile sync payload: ${json.encode(payload)}');
      // Uncomment when server is ready:
      // final response = await http.post(
      //   Uri.parse('https://your-server.com/api/profiles'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode(payload),
      // );
    } catch (e) {
      debugPrint('Profile sync error: $e');
    }
  }
}
