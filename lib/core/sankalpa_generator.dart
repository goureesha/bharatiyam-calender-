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
  static const varaNames = {
    1: 'ಭಾನು ವಾಸರೇ',    // Monday -> index 1 in DateTime
    2: 'ಸೋಮ ವಾಸರೇ',
    3: 'ಮಂಗಳ ವಾಸರೇ',
    4: 'ಬುಧ ವಾಸರೇ',
    5: 'ಗುರು ವಾಸರೇ',
    6: 'ಶುಕ್ರ ವಾಸರೇ',
    7: 'ಶನಿ ವಾಸರೇ',
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

  // ── Masa Names (Sanskrit in Kannada) ──
  static const masaNamesSanskrit = {
    'ಚೈತ್ರ': 'ಚೈತ್ರ', 'ವೈಶಾಖ': 'ವೈಶಾಖ', 'ಜ್ಯೇಷ್ಠ': 'ಜ್ಯೇಷ್ಠ',
    'ಆಷಾಢ': 'ಆಷಾಢ', 'ಶ್ರಾವಣ': 'ಶ್ರಾವಣ', 'ಭಾದ್ರಪದ': 'ಭಾದ್ರಪದ',
    'ಆಶ್ವಿಜ': 'ಆಶ್ವಯುಜ', 'ಕಾರ್ತಿಕ': 'ಕಾರ್ತೀಕ', 'ಮಾರ್ಗಶಿರ': 'ಮಾರ್ಗಶೀರ್ಷ',
    'ಪುಷ್ಯ': 'ಪೌಷ', 'ಮಾಘ': 'ಮಾಘ', 'ಫಾಲ್ಗುಣ': 'ಫಾಲ್ಗುಣ',
  };

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
    'ನಿತ್ಯ ಪೂಜಾ': 'ಇಷ್ಟ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ',
    'ಶ್ರೀ ಗಣಪತಿ ಪೂಜಾ': 'ಶ್ರೀ ಮಹಾ ಗಣಪತಿ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ',
    'ಶ್ರೀ ಸತ್ಯನಾರಾಯಣ ಪೂಜಾ': 'ಶ್ರೀ ಸತ್ಯನಾರಾಯಣ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ',
    'ಶ್ರೀ ಶಿವ ಪೂಜಾ': 'ಶ್ರೀ ಮಹಾದೇವ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ',
    'ಶ್ರೀ ವಿಷ್ಣು ಪೂಜಾ': 'ಶ್ರೀ ಮಹಾವಿಷ್ಣು ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ',
    'ಶ್ರೀ ಲಕ್ಷ್ಮೀ ಪೂಜಾ': 'ಶ್ರೀ ಮಹಾಲಕ್ಷ್ಮೀ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ',
    'ಶ್ರೀ ದುರ್ಗಾ ಪೂಜಾ': 'ಶ್ರೀ ದುರ್ಗಾ ದೇವೀ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ',
    'ಶ್ರೀ ಸರಸ್ವತೀ ಪೂಜಾ': 'ಶ್ರೀ ಸರಸ್ವತೀ ದೇವೀ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ',
    'ಶ್ರೀ ಸುಬ್ರಹ್ಮಣ್ಯ ಪೂಜಾ': 'ಶ್ರೀ ಸುಬ್ರಹ್ಮಣ್ಯ ಸ್ವಾಮಿ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ',
    'ಹೋಮ': 'ಅಗ್ನಿ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಹೋಮಂ ಕರಿಷ್ಯೇ',
    'ಗಣಪತಿ ಹೋಮ': 'ಶ್ರೀ ಮಹಾ ಗಣಪತಿ ಪ್ರೀತ್ಯರ್ಥಂ ಹೋಮಂ ಕರಿಷ್ಯೇ',
    'ನವಗ್ರಹ ಹೋಮ': 'ನವಗ್ರಹ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಶಾಂತಿ ಹೋಮಂ ಕರಿಷ್ಯೇ',
    'ಶ್ರಾದ್ಧ ಕರ್ಮ': 'ಪಿತೃ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಶ್ರಾದ್ಧ ಕರ್ಮ ಕರಿಷ್ಯೇ',
    'ಪ್ರಾಯಶ್ಚಿತ್ತ': 'ಸಕಲ ದುರಿತ ಕ್ಷಯ ದ್ವಾರಾ ಪ್ರಾಯಶ್ಚಿತ್ತ ಕರ್ಮ ಕರಿಷ್ಯೇ',
    'ಇಷ್ಟ ಕರ್ಮ': 'ಧರ್ಮ ಅರ್ಥ ಕಾಮ ಮೋಕ್ಷ ಫಲ ಸಿದ್ಧ್ಯರ್ಥಂ ಇಷ್ಟ ಕರ್ಮ ಕರಿಷ್ಯೇ',
    'ಗ್ರಹ ಶಾಂತಿ': 'ನವಗ್ರಹ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಶಾಂತಿ ಕರ್ಮ ಕರಿಷ್ಯೇ',
    'ಉಪನಯನ': 'ವೇದಾಧ್ಯಯನ ಯೋಗ್ಯತಾ ಸಿದ್ಧ್ಯರ್ಥಂ ಉಪನಯನಂ ಕರಿಷ್ಯೇ',
    'ವಿವಾಹ': 'ಧರ್ಮ ಪತ್ನೀ ಪ್ರಾಪ್ತ್ಯರ್ಥಂ ವಿವಾಹಂ ಕರಿಷ್ಯೇ',
    'ಗೃಹ ಪ್ರವೇಶ': 'ಗೃಹ ಪ್ರವೇಶ ಶಾಂತಿ ಕರ್ಮ ಕರಿಷ್ಯೇ',
    'ಅನ್ನಪ್ರಾಶನ': 'ಶಿಶು ಅನ್ನಪ್ರಾಶನ ಸಂಸ್ಕಾರಂ ಕರಿಷ್ಯೇ',
  };

  /// Get Samvatsara name for a given year
  /// Reference: 2024-2025 = Krodhi (38th), cycle starts from Prabhava
  static String getSamvatsara(int year, int month) {
    // Hindu year starts at Ugadi (March/April)
    // If before April, use previous year's samvatsara
    final adjustedYear = month < 4 ? year - 1 : year;
    // 1987-88 was Prabhava (1st), so offset = (year - 1987) % 60
    final idx = ((adjustedYear - 1987) % 60 + 60) % 60;
    return samvatsaraNames[idx];
  }

  /// Get Ayana based on solar longitude
  /// Uttarayana: ~Jan 14 (Makara Sankranti) to ~Jul 16 (Karka Sankranti)
  /// Dakshinayana: ~Jul 16 to ~Jan 14
  static String getAyana(double sunLongitude) {
    // Sun in Makara(270°) to Mithuna(90°+180°) = Uttarayana
    // Actually: Makara Sankranti = Sun enters Makara (270° tropical → sidereal ~)
    // Simpler: sun tropical longitude 270-90 = Uttarayana, 90-270 = Dakshinayana
    // But we have sidereal. Approximate by month.
    return 'ಉತ್ತರಾಯಣೇ'; // Will be determined by month in generate()
  }

  /// Get Ayana from month
  static String getAyanaFromMonth(int month) {
    // Uttarayana: mid-Jan to mid-Jul (roughly months 1-6 or adjusted)
    // Makara Sankranti ~Jan 14, Karka Sankranti ~Jul 16
    if (month >= 1 && month <= 6) return 'ಉತ್ತರಾಯಣೇ';
    return 'ದಕ್ಷಿಣಾಯನೇ';
  }

  /// Get Ritu from Amanta masa name
  static String getRitu(String masaName) {
    return masaToRitu[masaName] ?? 'ವರ್ಷಾ';
  }

  /// Get Paksha from tithi index (0-14 = Shukla, 15-29 = Krishna)
  static String getPaksha(int tithiIndex) {
    return tithiIndex < 15 ? 'ಶುಕ್ಲ ಪಕ್ಷೇ' : 'ಕೃಷ್ಣ ಪಕ್ಷೇ';
  }

  /// Get Tithi name from index
  static String getTithiName(int tithiIndex) {
    if (tithiIndex < 0 || tithiIndex >= 30) return '';
    return '${tithiNames[tithiIndex]} ತಿಥೌ';
  }

  /// Get Nakshatra name from index
  static String getNakshatraName(int nakshatraIndex) {
    if (nakshatraIndex < 0 || nakshatraIndex >= 27) return '';
    return '${nakshatraNames[nakshatraIndex]} ನಕ್ಷತ್ರ ಯುಕ್ತಾಯಾಂ';
  }

  /// Get Yoga name from index
  static String getYogaName(int yogaIndex) {
    if (yogaIndex < 0 || yogaIndex >= 27) return '';
    return '${yogaNames[yogaIndex]} ಯೋಗೇ';
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
    String gotra = '___',
    String name = '___',
    String kshetra = '___',
  }) {
    final samvatsara = getSamvatsara(date.year, date.month);
    final ayana = getAyanaFromMonth(date.month);
    final ritu = getRitu(masaName);
    final paksha = getPaksha(data.tithiIndex);
    final tithi = getTithiName(data.tithiIndex);
    final vara = getVara(date.weekday);
    final nakshatra = getNakshatraName(data.nakshatraIndex);
    final yoga = getYogaName(data.yogaIndex);
    final masaSanskrit = masaNamesSanskrit[masaName] ?? masaName;

    final buf = StringBuffer();

    // ── Invocation ──
    buf.writeln('ॐ ವಿಷ್ಣುಃ ವಿಷ್ಣುಃ ವಿಷ್ಣುಃ');
    buf.writeln('ಶ್ರೀ ಗೋವಿಂದ ಗೋವಿಂದ ಗೋವಿಂದ');
    buf.writeln();

    // ── Cosmic Time ──
    buf.writeln('ಅಸ್ಯ ಶ್ರೀ ಭಗವತಃ ಮಹಾಪುರುಷಸ್ಯ');
    buf.writeln('ವಿಷ್ಣೋಃ ಆಜ್ಞಯಾ ಪ್ರವರ್ತಮಾನಸ್ಯ');
    buf.writeln('ಆದ್ಯ ಬ್ರಹ್ಮಣಃ ದ್ವಿತೀಯ ಪರಾರ್ಧೇ');
    buf.writeln('ಶ್ವೇತ ವರಾಹ ಕಲ್ಪೇ');
    buf.writeln('ವೈವಸ್ವತ ಮನ್ವಂತರೇ');
    buf.writeln('ಅಷ್ಟಾವಿಂಶತಿತಮೇ ಕಲಿಯುಗೇ');
    buf.writeln('ಕಲಿ ಪ್ರಥಮೇ ಪಾದೇ');
    buf.writeln();

    // ── Location ──
    buf.writeln('ಜಂಬೂದ್ವೀಪೇ ಭಾರತವರ್ಷೇ ಭಾರತಖಂಡೇ');
    buf.writeln('ಮೇರೋಃ ದಕ್ಷಿಣ ಪಾರ್ಶ್ವೇ');
    buf.writeln('$kshetra ಕ್ಷೇತ್ರೇ');
    buf.writeln();

    // ── Current Time Details ──
    buf.writeln('$samvatsara ನಾಮ ಸಂವತ್ಸರೇ');
    buf.writeln('$ayana');
    buf.writeln('$ritu ಋತೌ');
    buf.writeln('$masaSanskrit ಮಾಸೇ');
    buf.writeln('$paksha');
    buf.writeln('$tithi');
    buf.writeln('$vara');
    buf.writeln('$nakshatra');
    buf.writeln('$yoga');
    buf.writeln('ಶುಭ ತಿಥೌ');
    buf.writeln();

    // ── Gotra & Identity ──
    buf.writeln('ಏವಂ ಗುಣ ವಿಶೇಷಣ ವಿಶಿಷ್ಟಾಯಾಂ');
    buf.writeln('ಅಸ್ಯಾಂ ಶುಭ ತಿಥೌ');
    buf.writeln('$gotra ಗೋತ್ರಸ್ಯ');
    buf.writeln('$name ಶರ್ಮಣಃ');
    buf.writeln();

    // ── Purpose ──
    buf.writeln('ಮಮ ಉಪಾತ್ತ ಸಮಸ್ತ ದುರಿತಕ್ಷಯ ದ್ವಾರಾ');
    buf.writeln('ಶ್ರೀ ಪರಮೇಶ್ವರ ಪ್ರೀತ್ಯರ್ಥಂ');
    buf.writeln('ಮಮ ಸಕುಟುಂಬಸ್ಯ ಸಪರಿವಾರಸ್ಯ');
    buf.writeln('ಕ್ಷೇಮ ಸ್ಥೈರ್ಯ ಆಯುಃ ಆರೋಗ್ಯ');
    buf.writeln('ಐಶ್ವರ್ಯ ಅಭಿವೃದ್ಧ್ಯರ್ಥಂ');
    buf.writeln();

    // ── Vishesha Sankalpa (specific karya) ──
    if (visheshaSankalpa != null && visheshaSankalpa.isNotEmpty) {
      final karya = visheshaSankalpas[visheshaSankalpa] ?? visheshaSankalpa;
      buf.writeln(karya);
    } else {
      buf.writeln('ಇಷ್ಟ ದೇವತಾ ಪ್ರೀತ್ಯರ್ಥಂ ಪೂಜಾಂ ಕರಿಷ್ಯೇ');
    }

    return buf.toString().trim();
  }

  /// Get list of all Vishesha Sankalpa karya names
  static List<String> get karyaNames => visheshaSankalpas.keys.toList();
}
