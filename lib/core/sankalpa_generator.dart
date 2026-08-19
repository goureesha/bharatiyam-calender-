/// Sankalpa Generator — Generates Maha Sankalpa text from panchanga data.
/// Sanskrit text in Kannada script. Includes Vishesha Sankalpa templates.
import '../models/panchanga_data.dart';
import '../services/location_service.dart';
import 'masa_calculator.dart';

class SankalpaGenerator {
  // ── 60 Samvatsara Names (Kannada script) ──
  static const samvatsaraNames = [
    'ಪ್ರಭವ', 'ವಿಭವ', 'ಶುಕ್ಲ', 'ಪ್ರಮೋದ', 'ಪ್ರಜಾಪತಿ',
    'ಅಂಗಿರಸ', 'ಶ್ರೀಮುಖ', 'ಭಾವ', 'ಯುವ', 'ಧಾತೃ',
    'ಈಶ್ವರ', 'ಬಹುಧಾನ್ಯ', 'ಪ್ರಮಾಥಿ', 'ವಿಕ್ರಮ', 'ವೃಷ',
    'ಚಿತ್ರಭಾನು', 'ಸ್ವಭಾನು', 'ತಾರಣ', 'ಪಾರ್ಥಿವ', 'ವ್ಯಯ',
    'ಸರ್ವಜಿತ್', 'ಸರ್ವಧಾರಿ', 'ವಿರೋಧಿ', 'ವಿಕೃತಿ', 'ಖರ',
    'ನಂದನ', 'ವಿಜಯ', 'ಜಯ', 'ಮನ್ಮಥ', 'ದುರ್ಮುಖಿ',
    'ಹೇವಿಳಂಬಿ', 'ವಿಳಂಬಿ', 'ವಿಕಾರಿ', 'ಶಾರ್ವರಿ', 'ಪ್ಲವ',
    'ಶುಭಕೃತ್', 'ಶೋಭಕೃತ್', 'ಕ್ರೋಧಿ', 'ವಿಶ್ವಾವಸು', 'ಪರಾಭವ',
    'ಪ್ಲವಂಗ', 'ಕೀಲಕ', 'ಸೌಮ್ಯ', 'ಸಾಧಾರಣ', 'ವಿರೋಧಿಕೃತ್',
    'ಪರಿಧಾವಿ', 'ಪ್ರಮಾದೀಚ', 'ಆನಂದ', 'ರಾಕ್ಷಸ', 'ಅನಲ',
    'ಪಿಂಗಳ', 'ಕಾಳಯುಕ್ತಿ', 'ಸಿದ್ಧಾರ್ಥಿ', 'ರೌದ್ರ', 'ದುರ್ಮತಿ',
    'ದುಂದುಭಿ', 'ರುಧಿರೋದ್ಗಾರಿ', 'ರಕ್ತಾಕ್ಷಿ', 'ಕ್ರೋಧನ', 'ಅಕ್ಷಯ',
  ];

  // ── Vara Names (Sanskrit in Kannada) ──
  // Dart DateTime.weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
  static const varaNames = {
    1: 'ಇಂದು ವಾಸರ ಯುಕ್ತಾಯಾಂ',    // Monday (Soma/Indu)
    2: 'ಭೌಮ ವಾಸರ ಯುಕ್ತಾಯಾಂ',    // Tuesday (Mangala/Bhauma)
    3: 'ಸೌಮ್ಯ ವಾಸರ ಯುಕ್ತಾಯಾಂ',   // Wednesday (Budha/Saumya)
    4: 'ಗುರು ವಾಸರ ಯುಕ್ತಾಯಾಂ',    // Thursday (Guru/Brihaspati)
    5: 'ಭೃಗು ವಾಸರ ಯುಕ್ತಾಯಾಂ',    // Friday (Shukra/Bhrigu)
    6: 'ಸ್ಥಿರ ವಾಸರ ಯುಕ್ತಾಯಾಂ',    // Saturday (Shani/Sthira)
    7: 'ಭಾನು ವಾಸರ ಯುಕ್ತಾಯಾಂ',    // Sunday (Ravi/Bhanu)
  };

  // ── Tithi Names (Sanskrit in Kannada) ──
  static const tithiNames = [
    'ಪ್ರತಿಪದಾ', 'ದ್ವಿತೀಯಾ', 'ತೃತೀಯಾ', 'ಚತುರ್ಥೀ', 'ಪಂಚಮೀ',
    'ಷಷ್ಠೀ', 'ಸಪ್ತಮೀ', 'ಅಷ್ಟಮೀ', 'ನವಮೀ', 'ದಶಮೀ',
    'ಏಕಾದಶೀ', 'ದ್ವಾದಶೀ', 'ತ್ರಯೋದಶೀ', 'ಚತುರ್ದಶೀ', 'ಪೂರ್ಣಿಮಾ',
    'ಪ್ರತಿಪದಾ', 'ದ್ವಿತೀಯಾ', 'ತೃತೀಯಾ', 'ಚತುರ್ಥೀ', 'ಪಂಚಮೀ',
    'ಷಷ್ಠೀ', 'ಸಪ್ತಮೀ', 'ಅಷ್ಟಮೀ', 'ನವಮೀ', 'ದಶಮೀ',
    'ಏಕಾದಶೀ', 'ದ್ವಾದಶೀ', 'ತ್ರಯೋದಶೀ', 'ಚತುರ್ದಶೀ', 'ಅಮಾವಾಸ್ಯಾ',
  ];

  // ── Nakshatra Names (Sanskrit in Kannada) ──
  static const nakshatraNames = [
    'ಅಶ್ವಿನೀ', 'ಭರಣೀ', 'ಕೃತ್ತಿಕಾ', 'ರೋಹಿಣೀ', 'ಮೃಗಶಿರಾ',
    'ಆರ್ದ್ರಾ', 'ಪುನರ್ವಸು', 'ಪುಷ್ಯ', 'ಆಶ್ಲೇಷಾ', 'ಮಘಾ',
    'ಪೂರ್ವ ಫಲ್ಗುಣೀ', 'ಉತ್ತರ ಫಲ್ಗುಣೀ', 'ಹಸ್ತ', 'ಚಿತ್ರಾ', 'ಸ್ವಾತೀ',
    'ವಿಶಾಖಾ', 'ಅನುರಾಧಾ', 'ಜ್ಯೇಷ್ಠಾ', 'ಮೂಲ', 'ಪೂರ್ವಾಷಾಢಾ',
    'ಉತ್ತರಾಷಾಢಾ', 'ಶ್ರವಣ', 'ಧನಿಷ್ಠಾ', 'ಶತಭಿಷಾ', 'ಪೂರ್ವಾಭಾದ್ರಪದಾ',
    'ಉತ್ತರಾಭಾದ್ರಪದಾ', 'ರೇವತೀ',
  ];

  // ── Yoga Names (Sanskrit in Kannada) ──
  static const yogaNames = [
    'ವಿಷ್ಕಂಭ', 'ಪ್ರೀತಿ', 'ಆಯುಷ್ಮಾನ್', 'ಸೌಭಾಗ್ಯ', 'ಶೋಭನ',
    'ಅತಿಗಂಡ', 'ಸುಕರ್ಮ', 'ಧೃತಿ', 'ಶೂಲ', 'ಗಂಡ',
    'ವೃದ್ಧಿ', 'ಧ್ರುವ', 'ವ್ಯಾಘಾತ', 'ಹರ್ಷಣ', 'ವಜ್ರ',
    'ಸಿದ್ಧಿ', 'ವ್ಯತೀಪಾತ', 'ವರೀಯಾನ್', 'ಪರಿಘ', 'ಶಿವ',
    'ಸಿದ್ಧ', 'ಸಾಧ್ಯ', 'ಶುಭ', 'ಶುಕ್ಲ', 'ಬ್ರಹ್ಮ',
    'ಐಂದ್ರ', 'ವೈಧೃತಿ',
  ];

  // ── Karana Names (Sanskrit in Kannada) ──
  static const karanaNames = [
    'ಬವ', 'ಬಾಲವ', 'ಕೌಲವ', 'ತೈತಿಲ', 'ಗರ',
    'ವಣಿಜ', 'ವಿಷ್ಟಿ', 'ಶಕುನಿ', 'ಚತುಷ್ಪಾತ್', 'ನಾಗ', 'ಕಿಂಸ್ತುಘ್ನ',
  ];

  // ── Ritu from Masa ──
  static const masaToRitu = {
    'ಚೈತ್ರ': 'ವಸಂತ', 'ವೈಶಾಖ': 'ವಸಂತ',
    'ಜ್ಯೇಷ್ಠ': 'ಗ್ರೀಷ್ಮ', 'ಆಷಾಢ': 'ಗ್ರೀಷ್ಮ',
    'ಶ್ರಾವಣ': 'ವರ್ಷಾ', 'ಭಾದ್ರಪದ': 'ವರ್ಷಾ',
    'ಆಶ್ವಿಜ': 'ಶರದ್', 'ಕಾರ್ತಿಕ': 'ಶರದ್',
    'ಮಾರ್ಗಶಿರ': 'ಹೇಮಂತ', 'ಪುಷ್ಯ': 'ಹೇಮಂತ',
    'ಮಾಘ': 'ಶಿಶಿರ', 'ಫಾಲ್ಗುಣ': 'ಶಿಶಿರ',
  };

  // ── Vishesha Sankalpa Templates ──
  static const visheshaSankalpas = {
    'ನಿತ್ಯ ಪೂಜಾ': 'ಶ್ರೀ ಪರಮೇಶ್ವರ ಪ್ರೀತ್ಯರ್ಥಂ ಇಷ್ಟ ದೇವತಾ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ಗಣಪತಿ ಪೂಜಾ': 'ಶ್ರೀ ಮಹಾ ಗಣಪತಿ ಪ್ರಸಾದ ಸಿದ್ಧ್ಯರ್ಥಂ ಶ್ರೀ ಮಹಾ ಗಣಪತಿ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ಸತ್ಯನಾರಾಯಣ ಪೂಜಾ': 'ಶ್ರೀ ಸತ್ಯನಾರಾಯಣ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರೀ ಸತ್ಯನಾರಾಯಣ ವ್ರತ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ಶಿವ ಪೂಜಾ': 'ಶ್ರೀ ಸಾಂಬ ಸದಾಶಿವ ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರೀ ಮಹಾದೇವ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ವಿಷ್ಣು ಪೂಜಾ': 'ಶ್ರೀ ಮಹಾವಿಷ್ಣು ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರೀ ಮಹಾವಿಷ್ಣು ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ಲಕ್ಷ್ಮೀ ಪೂಜಾ': 'ಶ್ರೀ ಮಹಾಲಕ್ಷ್ಮೀ ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರೀ ಮಹಾಲಕ್ಷ್ಮೀ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ದುರ್ಗಾ ಪೂಜಾ': 'ಶ್ರೀ ದುರ್ಗಾ ಪರಮೇಶ್ವರೀ ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರೀ ದುರ್ಗಾ ದೇವೀ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ಸರಸ್ವತೀ ಪೂಜಾ': 'ಶ್ರೀ ಸರಸ್ವತೀ ದೇವೀ ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರೀ ಸರಸ್ವತೀ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ಸುಬ್ರಹ್ಮಣ್ಯ ಪೂಜಾ': 'ಶ್ರೀ ಸುಬ್ರಹ್ಮಣ್ಯ ಸ್ವಾಮಿ ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರೀ ಸುಬ್ರಹ್ಮಣ್ಯ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ಹನುಮಂತ ಪೂಜಾ': 'ಶ್ರೀ ಆಂಜನೇಯ ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರೀ ಹನುಮಂತ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರೀ ನಾಗ ಪೂಜಾ': 'ಶ್ರೀ ನಾಗ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರೀ ನಾಗ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥',
    'ಹೋಮ / ಹವನ': 'ಅಗ್ನಿ ಮುಖೇನ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಹೋಮಂ ಕರಿಷ್ಯೇ ॥',
    'ಗಣಪತಿ ಹೋಮ': 'ಶ್ರೀ ಮಹಾ ಗಣಪತಿ ಪ್ರೀತ್ಯರ್ಥಂ ಗಣಪತಿ ಹೋಮಂ ಕರಿಷ್ಯೇ ॥',
    'ನವಗ್ರಹ ಹೋಮ': 'ನವಗ್ರಹ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ನವಗ್ರಹ ಶಾಂತಿ ಹೋಮಂ ಕರಿಷ್ಯೇ ॥',
    'ರುದ್ರಾಭಿಷೇಕ': 'ಶ್ರೀ ರುದ್ರ ದೇವ ಪ್ರೀತ್ಯರ್ಥಂ ರುದ್ರಾಭಿಷೇಕಂ ಕರಿಷ್ಯೇ ॥',
    'ಶ್ರಾದ್ಧ ಕರ್ಮ': 'ಅಸ್ಮತ್ ಪಿತೃ / ಮಾತೃ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ವಾರ್ಷಿಕ ಶ್ರಾದ್ಧ ಕರ್ಮ ಕರಿಷ್ಯೇ ॥',
    'ಮಹಾಲಯ ಶ್ರಾದ್ಧ': 'ಸಮಸ್ತ ಪಿತೃ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಮಹಾಲಯ ಶ್ರಾದ್ಧ ಕರ್ಮ ಕರಿಷ್ಯೇ ॥',
    'ಪ್ರಾಯಶ್ಚಿತ್ತ': 'ಸಕಲ ಪಾಪ ಪರಿಹಾರಾರ್ಥಂ ಸಕಲ ದುರಿತ ಕ್ಷಯ ದ್ವಾರಾ ಪ್ರಾಯಶ್ಚಿತ್ತ ಕರ್ಮ ಕರಿಷ್ಯೇ ॥',
    'ಇಷ್ಟ ಕಾಮ್ಯ ಕರ್ಮ': 'ಧರ್ಮ ಅರ್ಥ ಕಾಮ ಮೋಕ್ಷ ಚತುರ್ವಿಧ ಫಲ ಪುರುಷಾರ್ಥ ಸಿದ್ಧ್ಯರ್ಥಂ ಇಷ್ಟ ಕರ್ಮ ಕರಿಷ್ಯೇ ॥',
    'ಗ್ರಹ ಶಾಂತಿ': 'ಸಕಲ ಗ್ರಹ ದೋಷ ಪರಿಹಾರಾರ್ಥಂ ನವಗ್ರಹ ಶಾಂತಿ ಕರ್ಮ ಕರಿಷ್ಯೇ ॥',
    'ಉಪನಯನ': 'ಗಾಯತ್ರೀ ಮಂತ್ರೋಪದೇಶ ಪೂರ್ವಕ ವೇದಾಧ್ಯಯನ ಯೋಗ್ಯತಾ ಸಿದ್ಧ್ಯರ್ಥಂ ಉಪನಯನ ಸಂಸ್ಕಾರಂ ಕರಿಷ್ಯೇ ॥',
    'ವಿವಾಹ': 'ಧರ್ಮೇಣ ಸಹಧರ್ಮಿಣೀ ಪ್ರಾಪ್ತ್ಯರ್ಥಂ ವಿವಾಹ ಕರ್ಮ ಕರಿಷ್ಯೇ ॥',
    'ಗೃಹ ಪ್ರವೇಶ': 'ನೂತನ ಗೃಹ ಪ್ರವೇಶ ಶಾಂತಿ ಪೂರ್ವಕ ವಾಸ್ತು ಹೋಮಂ ಕರಿಷ್ಯೇ ॥',
    'ಅನ್ನಪ್ರಾಶನ': 'ಶಿಶೋಃ ಅನ್ನಪ್ರಾಶನ ಸಂಸ್ಕಾರಂ ಕರಿಷ್ಯೇ ॥',
    'ನಾಮಕರಣ': 'ಶಿಶೋಃ ನಾಮಕರಣ ಸಂಸ್ಕಾರಂ ಕರಿಷ್ಯೇ ॥',
    'ಸೀಮಂತೋನ್ನಯನ': 'ಗರ್ಭಿಣೀ ಸೀಮಂತೋನ್ನಯನ ಸಂಸ್ಕಾರಂ ಕರಿಷ್ಯೇ ॥',
    'ಸಂಕಲ್ಪ ತರ್ಪಣ': 'ಸಮಸ್ತ ಪಿತೃ ದೇವತಾ ತೃಪ್ತ್ಯರ್ಥಂ ತಿಲ ತರ್ಪಣಂ ಕರಿಷ್ಯೇ ॥',
  };

  /// Get Samvatsara name for a given year
  static String getSamvatsara(int year, int month) {
    final adjustedYear = month < 4 ? year - 1 : year;
    final idx = ((adjustedYear - 1987) % 60 + 60) % 60;
    return samvatsaraNames[idx];
  }

  /// Get Shalivahana Shaka year (Gregorian - 78)
  static int getShakaYear(int year, int month) {
    return month < 3 ? year - 79 : year - 78;
  }

  /// Get Ayana from month
  static String getAyanaFromMonth(int month) {
    // Uttarayana: ~Jan 14 to ~Jul 16
    if (month >= 2 && month <= 7) return 'ಉತ್ತರಾಯಣೇ';
    return 'ದಕ್ಷಿಣಾಯನೇ';
  }

  /// Get Ritu from Amanta masa name
  static String getRitu(String masaName) {
    return masaToRitu[masaName] ?? 'ವರ್ಷಾ';
  }

  /// Get Paksha from tithi index
  static String getPaksha(int tithiIndex) {
    return tithiIndex < 15 ? 'ಶುಕ್ಲ ಪಕ್ಷೇ' : 'ಕೃಷ್ಣ ಪಕ್ಷೇ';
  }

  /// Get Tithi name from index
  static String getTithiName(int tithiIndex) {
    if (tithiIndex < 0 || tithiIndex >= 30) return '';
    return tithiNames[tithiIndex];
  }

  /// Get Nakshatra name from index
  static String getNakshatraName(int nakshatraIndex) {
    if (nakshatraIndex < 0 || nakshatraIndex >= 27) return '';
    return nakshatraNames[nakshatraIndex];
  }

  /// Get Yoga name from index
  static String getYogaName(int yogaIndex) {
    if (yogaIndex < 0 || yogaIndex >= 27) return '';
    return yogaNames[yogaIndex];
  }

  /// Get Vara name from DateTime weekday
  static String getVara(int weekday) {
    return varaNames[weekday] ?? '';
  }

  /// Generate full Maha Sankalpa text
  static String generate({
    required PanchangaData data,
    required String masaName,
    required DateTime date,
    String? visheshaSankalpa,
    String gotra = '........',
    String name = '........',
  }) {
    final samvatsara = getSamvatsara(date.year, date.month);
    final shakaYear = getShakaYear(date.year, date.month);
    final ayana = getAyanaFromMonth(date.month);
    final ritu = getRitu(masaName);
    final paksha = getPaksha(data.tithiIndex);
    final tithi = getTithiName(data.tithiIndex);
    final vara = getVara(date.weekday);
    final nakshatra = getNakshatraName(data.nakshatraIndex);
    final yoga = getYogaName(data.yogaIndex);

    final buf = StringBuffer();

    // ── Invocation ──
    buf.writeln('॥ ಶ್ರೀ ಗಣೇಶಾಯ ನಮಃ ॥');
    buf.writeln();
    buf.writeln('ॐ ವಿಷ್ಣುಃ ವಿಷ್ಣುಃ ವಿಷ್ಣುಃ ।');
    buf.writeln('ಶ್ರೀಮದ್ಭಗವತೋ ಮಹಾಪುರುಷಸ್ಯ');
    buf.writeln('ವಿಷ್ಣೋಃ ಆಜ್ಞಯಾ ಪ್ರವರ್ತಮಾನಸ್ಯ ।');
    buf.writeln();

    // ── Cosmic Time (Brahma's age → Kalpa → Manvantara → Yuga) ──
    buf.writeln('ಆದ್ಯ ಬ್ರಹ್ಮಣಃ ದ್ವಿತೀಯ ಪರಾರ್ಧೇ ।');
    buf.writeln('ಶ್ವೇತ ವರಾಹ ಕಲ್ಪೇ ।');
    buf.writeln('ವೈವಸ್ವತ ಮನ್ವಂತರೇ ।');
    buf.writeln('ಅಷ್ಟಾವಿಂಶತಿತಮೇ ಕಲಿಯುಗೇ ।');
    buf.writeln('ಕಲಿ ಪ್ರಥಮೇ ಪಾದೇ ।');
    buf.writeln();

    // ── Era ──
    buf.writeln('ಬೌದ್ಧಾವತಾರೇ ।');
    buf.writeln('ಶಾಲಿವಾಹನ ಶಕೇ $shakaYear ಪ್ರವರ್ತಮಾನೇ ।');
    buf.writeln();

    // ── Sacred Geography ──
    buf.writeln('ಜಂಬೂದ್ವೀಪೇ ।');
    buf.writeln('ಭಾರತವರ್ಷೇ ।');
    buf.writeln('ಭಾರತಖಂಡೇ ।');
    buf.writeln('ಮೇರೋಃ ದಕ್ಷಿಣ ಭಾಗೇ ।');
    buf.writeln('ಗೋದಾವರ್ಯಾಃ ದಕ್ಷಿಣೇ ತೀರೇ ।');
    buf.writeln();

    // ── Current Time Details ──
    buf.writeln('ಪ್ರಭವಾದಿ ಷಷ್ಟಿ ಸಂವತ್ಸರಾಣಾಂ ಮಧ್ಯೇ');
    buf.writeln('$samvatsara ನಾಮ ಸಂವತ್ಸರೇ ।');
    buf.writeln('$ayana ।');
    buf.writeln('$ritu ಋತೌ ।');
    buf.writeln('$masaName ಮಾಸೇ ।');
    buf.writeln('$paksha ।');
    buf.writeln('$tithi ತಿಥೌ ।');
    buf.writeln('$vara ।');
    buf.writeln('$nakshatra ನಕ್ಷತ್ರೇ ।');
    buf.writeln('$yoga ನಾಮ ಯೋಗೇ ।');
    buf.writeln();
    buf.writeln('ಶುಭ ನಕ್ಷತ್ರ ಶುಭ ಯೋಗ');
    buf.writeln('ಶುಭ ಕರಣ ।');
    buf.writeln('ಏವಂ ಗುಣ ವಿಶೇಷಣ ವಿಶಿಷ್ಟಾಯಾಂ ।');
    buf.writeln('ಅಸ್ಯಾಂ ಶುಭ ತಿಥೌ ।');
    buf.writeln();

    // ── Identity ──
    buf.writeln('$gotra ಗೋತ್ರೋತ್ಪನ್ನಸ್ಯ ।');
    buf.writeln('$name ನಾಮಧೇಯಸ್ಯ ।');
    buf.writeln();

    // ── Purpose ──
    buf.writeln('ಮಮ ಉಪಾತ್ತ ಸಮಸ್ತ ದುರಿತಕ್ಷಯ ದ್ವಾರಾ ।');
    buf.writeln('ಶ್ರೀ ಪರಮೇಶ್ವರ ಪ್ರೀತ್ಯರ್ಥಂ ।');
    buf.writeln('ಮಮ ಸಕುಟುಂಬಸ್ಯ ಸಪರಿವಾರಸ್ಯ ।');
    buf.writeln('ಸಕಲ ಪಾಪ ಕ್ಷಯ ಪೂರ್ವಕಂ ।');
    buf.writeln();

    // ── Dosha-Badha Nivritti ──
    buf.writeln('ಗ್ರಹ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ನವಗ್ರಹ ದೋಷ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಕಾಲಸರ್ಪ ದೋಷ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಪಿತೃ ದೋಷ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ವಾಸ್ತು ದೋಷ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಸರ್ಪ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಭೂತ ಪ್ರೇತ ಪಿಶಾಚ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಯಕ್ಷ ರಾಕ್ಷಸ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಡಾಕಿನೀ ಶಾಕಿನೀ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಅಭಿಚಾರ ದೋಷ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ದೃಷ್ಟ ಅದೃಷ್ಟ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ರಾಜ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಚೋರ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಅಗ್ನಿ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಜಲ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ವಾಯು ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ರೋಗ ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಶತ್ರು ಬಾಧಾ ನಿವೃತ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಸಮಸ್ತ ಆಧಿ ವ್ಯಾಧಿ ಉಪಾಧಿ ಶಮನಾರ್ಥಂ ।');
    buf.writeln();

    // ── Mangala Kamana ──
    buf.writeln('ಸರ್ವಾರಿಷ್ಟ ಶಾಂತಿ ನಿಮಿತ್ತಂ ।');
    buf.writeln('ಕ್ಷೇಮ ಸ್ಥೈರ್ಯ ವಿಜಯ ।');
    buf.writeln('ಆಯುಃ ಆರೋಗ್ಯ ಐಶ್ವರ್ಯ ।');
    buf.writeln('ಅಭಿವೃದ್ಧ್ಯರ್ಥಂ ।');
    buf.writeln('ಧರ್ಮ ಅರ್ಥ ಕಾಮ ಮೋಕ್ಷ ಚತುರ್ವಿಧ ಫಲ ಪುರುಷಾರ್ಥ ಸಿದ್ಧ್ಯರ್ಥಂ ।');
    buf.writeln('ಇಷ್ಟ ಕಾಮ್ಯಾರ್ಥ ಸಿದ್ಧ್ಯರ್ಥಂ ।');
    buf.writeln('ಸಮಸ್ತ ಮಂಗಳ ಅವಾಪ್ತ್ಯರ್ಥಂ ।');
    buf.writeln('ಸಮಸ್ತ ಸನ್ಮಂಗಳ ಸಿದ್ಧ್ಯರ್ಥಂ ।');
    buf.writeln();

    // ── Vishesha Sankalpa (specific karya) ──
    if (visheshaSankalpa != null && visheshaSankalpa.isNotEmpty) {
      final karya = visheshaSankalpas[visheshaSankalpa] ?? visheshaSankalpa;
      buf.writeln(karya);
    } else {
      buf.writeln('ಇಷ್ಟ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ ॥');
    }

    return buf.toString().trim();
  }

  /// Get list of all Vishesha Sankalpa karya names
  static List<String> get karyaNames => visheshaSankalpas.keys.toList();
}
