/// Profile Image Service — Save/load user's profile photo for share card.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageService {
  static const _key = 'profile_image_path';
  static String? _cachedPath;

  /// Get saved image path (or null)
  static String? get imagePath => _cachedPath;

  /// Check if image exists
  static bool get hasImage => _cachedPath != null && File(_cachedPath!).existsSync();

  /// Load from SharedPreferences on app start
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_key);
    if (path != null && File(path).existsSync()) {
      _cachedPath = path;
    }
  }

  /// Pick image from gallery and save to app directory
  static Future<bool> pickAndSave() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
      if (picked == null) return false;

      // Delete old image if exists
      if (_cachedPath != null) {
        try { await File(_cachedPath!).delete(); } catch (_) {}
      }

      // Save with unique timestamp filename to bust Flutter's image cache
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final savePath = '${dir.path}/profile_image_$ts.jpg';
      await File(picked.path).copy(savePath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, savePath);
      _cachedPath = savePath;

      // Clear Flutter's image cache so the new image shows immediately
      imageCache.clear();
      imageCache.clearLiveImages();

      return true;
    } catch (e) {
      debugPrint('Image pick error: $e');
      return false;
    }
  }

  /// Remove saved image
  static Future<void> remove() async {
    if (_cachedPath != null) {
      try { await File(_cachedPath!).delete(); } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _cachedPath = null;
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  /// Get image widget (round)
  static Widget roundImage({double size = 50}) {
    if (!hasImage) return SizedBox(width: size, height: size);
    return ClipOval(
      child: Image.file(
        File(_cachedPath!),
        width: size, height: size, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
      ),
    );
  }
}
