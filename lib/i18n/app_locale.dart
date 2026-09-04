/// App Locale — Multi-language system for Bharatiyam Panchanga.
/// Supports: Kannada, Hindi, Tamil, Telugu, Malayalam, English, Sanskrit.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'strings/kn.dart';
import 'strings/hi.dart';
import 'strings/en.dart';
import 'strings/ta.dart';
import 'strings/te.dart';
import 'strings/ml.dart';
import 'strings/sa.dart';

class AppLocale {
  static final ValueNotifier<String> langNotifier = ValueNotifier('kn');
  static String get current => langNotifier.value;
  static bool get isKannada => current == 'kn';

  static const Map<String, String> languageNames = {
    'kn': 'ಕನ್ನಡ',
    'hi': 'हिन्दी',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'ml': 'മലയാളം',
    'en': 'English',
    'sa': 'संस्कृतम्',
  };

  static final Map<String, Map<String, String>> _allStrings = {
    'kn': knStrings,
    'hi': hiStrings,
    'ta': taStrings,
    'te': teStrings,
    'ml': mlStrings,
    'en': enStrings,
    'sa': saStrings,
  };

  /// Set language and persist
  static void setLang(String lang) {
    if (!_allStrings.containsKey(lang)) return;
    langNotifier.value = lang;
    SharedPreferences.getInstance().then((p) => p.setString('app_lang', lang));
  }

  /// Load saved language preference
  static Future<void> loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    langNotifier.value = prefs.getString('app_lang') ?? 'kn';
  }

  /// Translate by key — falls back to Kannada then key
  static String t(String key) {
    final langMap = _allStrings[current];
    if (langMap != null && langMap.containsKey(key)) return langMap[key]!;
    final knMap = _allStrings['kn'];
    if (knMap != null && knMap.containsKey(key)) return knMap[key]!;
    return key;
  }

  /// Get Kannada value for a key
  static String tKn(String key) {
    final kn = _allStrings['kn'];
    if (kn != null && kn.containsKey(key)) return kn[key]!;
    return key;
  }

  // Reverse lookup cache
  static Map<String, String>? _reverseCache;
  static String? _reverseCacheLang;

  /// Translate Kannada text to current language by reverse lookup
  static String trAll(String knText) {
    if (current == 'kn') return knText;

    // Build reverse cache if needed
    if (_reverseCache == null || _reverseCacheLang != current) {
      _reverseCache = {};
      _reverseCacheLang = current;
      final kn = _allStrings['kn']!;
      final target = _allStrings[current]!;
      for (final key in kn.keys) {
        if (target.containsKey(key)) {
          _reverseCache![kn[key]!] = target[key]!;
        }
      }
    }

    // Try exact match
    return _reverseCache![knText] ?? knText;
  }

  /// Transliterate Kannada-script text to the current language's script.
  /// Uses Unicode block offset mapping (all Indic scripts share same layout).
  static String transliterate(String knText) {
    if (current == 'kn') return knText;
    if (current == 'en') return knText; // English has no Indic script

    // Kannada block: U+0C80..U+0CFF
    const int knBase = 0x0C80;
    // Target script bases
    const Map<String, int> scriptBase = {
      'hi': 0x0900, // Devanagari
      'sa': 0x0900, // Sanskrit uses Devanagari
      'te': 0x0C00, // Telugu
      'ta': 0x0B80, // Tamil
      'ml': 0x0D00, // Malayalam
    };

    final targetBase = scriptBase[current];
    if (targetBase == null) return knText;

    final offset = targetBase - knBase;
    final buf = StringBuffer();
    for (int i = 0; i < knText.length; i++) {
      final c = knText.codeUnitAt(i);
      if (c >= knBase && c <= 0x0CFF) {
        buf.writeCharCode(c + offset);
      } else {
        buf.writeCharCode(c);
      }
    }
    return buf.toString();
  }
}
