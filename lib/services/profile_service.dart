/// Profile Service — Manages user profile data (name, address, mobile).
/// Stores locally via SharedPreferences and syncs to Cloud Firestore.
/// Tracks lastSeen and shareCount.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  static String _name = '';
  static String _address = '';
  static String _mobile = '';
  static bool _profileComplete = false;
  static String _docId = '';
  static bool _firebaseReady = false;
  static String _firebaseStatus = 'Not initialized';

  static String get name => _name;
  static String get address => _address;
  static String get mobile => _mobile;
  static bool get isProfileComplete => _profileComplete;
  static bool get isFirebaseReady => _firebaseReady;
  static String get firebaseStatus => _firebaseStatus;

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

  /// Load profile from local storage
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('profile_name') ?? '';
    _address = prefs.getString('profile_address') ?? '';
    _mobile = prefs.getString('profile_mobile') ?? '';
    _docId = prefs.getString('profile_doc_id') ?? '';
    _profileComplete = _name.isNotEmpty && _mobile.isNotEmpty;
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
    _profileComplete = _name.isNotEmpty && _mobile.isNotEmpty;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _name);
    await prefs.setString('profile_address', _address);
    await prefs.setString('profile_mobile', _mobile);

    // Sync to Firestore
    await _syncToFirestore();
  }

  /// Update lastSeen timestamp (call on app open)
  static Future<void> updateLastSeen() async {
    if (_docId.isEmpty || !_firebaseReady) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_docId)
          .update({'lastSeen': FieldValue.serverTimestamp()});
      debugPrint('lastSeen updated');
    } catch (e) {
      debugPrint('lastSeen update error: $e');
    }
  }

  /// Increment share count (call after each panchanga share)
  static Future<void> incrementShareCount() async {
    if (_docId.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_docId)
          .update({'shareCount': FieldValue.increment(1)});
      debugPrint('shareCount incremented');
    } catch (e) {
      debugPrint('shareCount error: $e');
    }
  }

  /// Sync profile to Cloud Firestore
  static Future<void> _syncToFirestore() async {
    try {
      final collection = FirebaseFirestore.instance.collection('users');
      final data = {
        'name': _name,
        'address': _address,
        'mobile': _mobile,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_docId.isNotEmpty) {
        await collection.doc(_docId).update(data);
      } else {
        final existing = await collection
            .where('mobile', isEqualTo: _mobile)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          _docId = existing.docs.first.id;
          await collection.doc(_docId).update(data);
        } else {
          data['createdAt'] = FieldValue.serverTimestamp();
          data['lastSeen'] = FieldValue.serverTimestamp();
          data['shareCount'] = 0;
          final doc = await collection.add(data);
          _docId = doc.id;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_doc_id', _docId);
      }

      debugPrint('Profile synced to Firestore: $_docId');
    } catch (e) {
      debugPrint('Firestore sync error: $e');
    }
  }
}
