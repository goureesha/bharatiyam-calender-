/// Profile Service — Manages user profile data (name, address, mobile).
/// Stores locally via SharedPreferences and syncs to Cloud Firestore.
/// Tracks lastSeen, shareCount, and permanent deviceId.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ProfileService {
  static String _name = '';
  static String _address = '';
  static String _mobile = '';
  static bool _profileComplete = false;
  static String _docId = '';
  static String _deviceId = '';
  static bool _firebaseReady = false;
  static String _firebaseStatus = 'Not initialized';

  static String get name => _name;
  static String get address => _address;
  static String get mobile => _mobile;
  static bool get isProfileComplete => _profileComplete;
  static bool get isFirebaseReady => _firebaseReady;
  static String get firebaseStatus => _firebaseStatus;
  static String get deviceId => _deviceId;

  /// Check and set Firebase status
  static Future<void> checkFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('_ping')
          .doc('test')
          .set({'ts': FieldValue.serverTimestamp()})
          .timeout(const Duration(seconds: 5));
      _firebaseReady = true;
      _firebaseStatus = 'Connected ✓';
      debugPrint('Firestore connected');
    } catch (e) {
      _firebaseReady = false;
      _firebaseStatus = 'Error: $e';
      debugPrint('Firestore check failed: $e');
    }
  }

  /// Purohit details string for share card
  static String get purohitDetails {
    if (!_profileComplete) return '';
    final parts = <String>[];
    if (_name.isNotEmpty) parts.add(_name);
    if (_address.isNotEmpty) parts.add(_address);
    if (_mobile.isNotEmpty) parts.add('📞 $_mobile');
    return parts.join('\n');
  }

  /// Generate or retrieve permanent device ID (UUID v4).
  /// Created once on first launch, never changes.
  static Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('device_id');
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString('device_id', id);
      debugPrint('Generated new device ID: $id');
    }
    return id;
  }

  /// Load profile from local storage
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('profile_name') ?? '';
    _address = prefs.getString('profile_address') ?? '';
    _mobile = prefs.getString('profile_mobile') ?? '';
    _docId = prefs.getString('profile_doc_id') ?? '';
    _deviceId = await _getOrCreateDeviceId();
    _profileComplete = _name.isNotEmpty;
  }

  /// Save profile to local storage and sync to Firestore
  static Future<void> save({
    required String name,
    required String address,
    required String mobile,
  }) async {
    _name = name.trim();
    _address = address.trim();
    _mobile = mobile.trim();
    _profileComplete = _name.isNotEmpty;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _name);
    await prefs.setString('profile_address', _address);
    await prefs.setString('profile_mobile', _mobile);

    // Sync to Firestore
    await _syncToFirestore();
  }

  /// Update lastSeen timestamp (call on app open)
  static Future<void> updateLastSeen() async {
    if (_deviceId.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_deviceId)
          .set({
            'lastSeen': FieldValue.serverTimestamp(),
            'deviceId': _deviceId,
          }, SetOptions(merge: true));
      debugPrint('lastSeen updated for device $_deviceId');
    } catch (e) {
      debugPrint('lastSeen update error: $e');
    }
  }

  /// Increment share count (call after each panchanga share)
  static Future<void> incrementShareCount() async {
    if (_deviceId.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_deviceId)
          .update({'shareCount': FieldValue.increment(1)});
      debugPrint('shareCount incremented');
    } catch (e) {
      debugPrint('shareCount error: $e');
    }
  }

  /// Sync profile to Cloud Firestore using deviceId as document ID
  static Future<void> _syncToFirestore() async {
    if (_deviceId.isEmpty) {
      _deviceId = await _getOrCreateDeviceId();
    }
    try {
      final collection = FirebaseFirestore.instance.collection('users');
      final data = <String, dynamic>{
        'name': _name,
        'address': _address,
        'mobile': _mobile,
        'deviceId': _deviceId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Always use deviceId as the document ID — permanent per device
      final docRef = collection.doc(_deviceId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update(data);
      } else {
        // First time on this device
        data['createdAt'] = FieldValue.serverTimestamp();
        data['lastSeen'] = FieldValue.serverTimestamp();
        data['shareCount'] = 0;
        await docRef.set(data);
      }

      _docId = _deviceId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_doc_id', _docId);

      debugPrint('Profile synced to Firestore: $_deviceId');
    } catch (e) {
      debugPrint('Firestore sync error: $e');
    }
  }
}
