/// Event Calculator — Hindu festivals and observances based on Chandra Masa and Tithi.
/// Each event uses its correct timing rule (sunrise, sunset, moonrise, midnight, noon).

class AstroEvent {
  final String name;
  final String description;
  final String shloka;
  final String meaning;
  final String source;

  AstroEvent({
    required this.name,
    required this.description,
    this.shloka = '',
    this.meaning = '',
    this.source = '',
  });
}

class EventCalculator {
  /// Returns events for a given Chandra Masa and tithi index.
  /// tIdx: tithi at SUNRISE (0-29)
  /// sunsetTithiIdx: tithi at SUNSET
  /// moonriseTithiIdx: tithi at MOONRISE (for chandrodaya events)
  /// noonTithiIdx: tithi at NOON/MADHYAHNA
  /// midnightTithiIdx: tithi at MIDNIGHT/NISHITHA
  /// prevDayTithiIdx/nextDayTithiIdx: for vriddhi/kshaya detection
  static List<AstroEvent> getEvents({
    required String masa,
    required int tIdx,
    int? sunsetTithiIdx,
    int? nextDayTithiIdx,
    int? prevDayTithiIdx,
    int? moonriseTithiIdx,
    int? noonTithiIdx,
    int? midnightTithiIdx,
    bool isAdhika = false,
  }) {
    final List<AstroEvent> events = [];
    if (isAdhika) return events;

    // ═══ Purva Viddha: fire on first day, skip vriddhi second day ═══
    bool t(int target) {
      if (tIdx == target) {
        if (prevDayTithiIdx != null && prevDayTithiIdx == tIdx) return false;
        return true;
      }
      if (prevDayTithiIdx != null) {
        final expected = (prevDayTithiIdx! + 1) % 30;
        if (expected != tIdx && expected == target) return true;
      }
      return false;
    }

    // ═══ Para Viddha: fire on second day, skip vriddhi first day ═══
    bool tPara(int target) {
      if (tIdx == target) {
        if (nextDayTithiIdx != null && nextDayTithiIdx == tIdx) return false;
        return true;
      }
      if (prevDayTithiIdx != null) {
        final expected = (prevDayTithiIdx! + 1) % 30;
        if (expected != tIdx && expected == target) return true;
      }
      return false;
    }

    // ═══════════════════════════════════════════════════════
    //  MASA-SPECIFIC EVENTS
    // ═══════════════════════════════════════════════════════

    // 1. ಚೈತ್ರ ಮಾಸ
    if (masa == 'ಚೈತ್ರ') {
      if (t(0)) events.add(AstroEvent(name: 'ಯುಗಾದಿ ಹಬ್ಬ (ಚಾಂದ್ರಮಾನ)', description: 'ಹೊಸ ವರ್ಷದ ಆರಂಭ. ಬೇವು-ಬೆಲ್ಲ ಸೇವನೆ ವಿಶೇಷ. ಪಂಚಾಂಗ ಶ್ರವಣ.'));
      if (t(2)) events.add(AstroEvent(name: 'ಗೌರೀ ತೃತೀಯಾ (ಸೌಭಾಗ್ಯ ಗೌರೀ ವ್ರತ) / ಮತ್ಸ್ಯ ಜಯಂತಿ', description: 'ಪಾರ್ವತೀ ದೇವಿ ಮತ್ತು ಮತ್ಸ್ಯಾವತಾರ ಆರಾಧನೆ.'));
      if (t(5)) events.add(AstroEvent(name: 'ಸ್ಕಂದ ಷಷ್ಠಿ', description: 'ಕಾರ್ತಿಕೇಯ ಸ್ವಾಮಿಯ ಆರಾಧನೆ.'));
      // Rama Navami: Navami at MADHYAHNA (noon)
      if (noonTithiIdx == 8) events.add(AstroEvent(name: 'ಶ್ರೀರಾಮ ನವಮಿ', description: 'ಶ್ರೀರಾಮಚಂದ್ರನ ಜನ್ಮದಿನ. ಮಧ್ಯಾಹ್ನ ಕಾಲದಲ್ಲಿ ನವಮಿ ಇರಬೇಕು.'));
      if (tPara(10)) events.add(AstroEvent(name: 'ಕಾಮದಾ ಏಕಾದಶಿ', description: 'ಸರ್ವ ಕಾಮನೆಗಳನ್ನು ಪೂರೈಸುವ ಏಕಾದಶಿ.'));
      if (t(14)) events.add(AstroEvent(name: 'ಹನುಮಜ್ಜಯಂತಿ / ಚಿತ್ರಾ ಪೌರ್ಣಿಮೆ', description: 'ಹನುಮಂತನ ಅವತಾರ ದಿನ. ಚಿತ್ರಗುಪ್ತ ಪೂಜೆ.'));
      if (t(27)) events.add(AstroEvent(name: 'ಅನಂಗ ತ್ರಯೋದಶೀ', description: 'ಕಾಮದೇವನ ಆರಾಧನೆ.'));
    }

    // 2. ವೈಶಾಖ ಮಾಸ
    if (masa == 'ವೈಶಾಖ') {
      if (t(2)) events.add(AstroEvent(name: 'ಅಕ್ಷಯ ತೃತೀಯಾ / ಪರಶುರಾಮ ಜಯಂತಿ', description: 'ಅತ್ಯಂತ ಶುಭದಿನ. ದಾನ, ಜಪಗಳು ಅಕ್ಷಯ ಫಲ ನೀಡುತ್ತವೆ.'));
      if (t(4)) events.add(AstroEvent(name: 'ಶಂಕರಾಚಾರ್ಯ ಜಯಂತಿ', description: 'ಆದಿ ಶಂಕರಾಚಾರ್ಯರ ಅವತಾರ ದಿನ.'));
      if (t(6)) events.add(AstroEvent(name: 'ಗಂಗೋತ್ಪತ್ತಿ / ಜಹ್ನು ಸಪ್ತಮಿ', description: 'ಗಂಗಾದೇವಿಯ ಅವತರಣ ದಿನ.'));
      if (tPara(10)) events.add(AstroEvent(name: 'ಮೋಹಿನೀ ಏಕಾದಶಿ', description: 'ಮೋಹಿನೀ ಅವತಾರದ ಸ್ಮರಣೆ.'));
      // Narasimha Jayanti: Chaturdashi at SANDHYA (sunset)
      if (sunsetTithiIdx == 13) events.add(AstroEvent(name: 'ಶ್ರೀ ನರಸಿಂಹ ಜಯಂತಿ', description: 'ನರಸಿಂಹನ ಅವತಾರ ದಿನ. ಸಂಧ್ಯಾ ಕಾಲದಲ್ಲಿ ಪ್ರಾದುರ್ಭಾವ.'));
      if (t(14)) events.add(AstroEvent(name: 'ಬುದ್ಧ ಪೌರ್ಣಿಮೆ / ಕೂರ್ಮ ಜಯಂತಿ', description: 'ಬುದ್ಧ ಮತ್ತು ಕೂರ್ಮಾವತಾರದ ಜನ್ಮದಿನ.'));
      if (t(29)) events.add(AstroEvent(name: 'ಶನೈಶ್ಚರ ಜಯಂತಿ', description: 'ಶನಿ ದೇವನ ಜನ್ಮ ದಿನ. ತೈಲಾಭಿಷೇಕ.'));
    }

    // 3. ಜ್ಯೇಷ್ಠ ಮಾಸ
    if (masa == 'ಜ್ಯೇಷ್ಠ') {
      if (t(9)) events.add(AstroEvent(name: 'ಗಂಗಾ ದಶಹರಾ', description: 'ಗಂಗಾ ನದಿಯ ಭೂಮಿಗೆ ಅವತರಣ ದಿನ.'));
      if (tPara(10)) events.add(AstroEvent(name: 'ನಿರ್ಜಲಾ ಏಕಾದಶಿ', description: '೨೪ ಏಕಾದಶಿಗಳ ಫಲ ನೀಡುವ ಕಠಿಣ ವ್ರತ.'));
      if (t(14)) events.add(AstroEvent(name: 'ವಟ ಸಾವಿತ್ರಿ ವ್ರತ / ಜ್ಯೇಷ್ಠ ಪೌರ್ಣಿಮೆ', description: 'ಪತಿಯ ದೀರ್ಘಾಯುಷ್ಯಕ್ಕಾಗಿ ವ್ರತ.'));
      if (t(29)) events.add(AstroEvent(name: 'ಜ್ಯೇಷ್ಠ ಅಮಾವಾಸ್ಯೆ / ಶನಿ ಅಮಾವಾಸ್ಯೆ', description: 'ಪಿತೃ ತರ್ಪಣ. ಶನಿ ಪ್ರೀತಿಗಾಗಿ ತೈಲಾಭಿಷೇಕ.'));
    }

    // 4. ಆಷಾಢ ಮಾಸ
    if (masa == 'ಆಷಾಢ') {
      if (t(1)) events.add(AstroEvent(name: 'ರಥ ಯಾತ್ರಾ', description: 'ಜಗನ್ನಾಥ ಸ್ವಾಮಿಯ ರಥೋತ್ಸವ.'));
      if (tPara(10)) events.add(AstroEvent(name: 'ಶಯನೀ ಏಕಾದಶಿ (ಪ್ರಥಮ ಏಕಾದಶಿ)', description: 'ಚಾತುರ್ಮಾಸ್ಯ ವ್ರತದ ಆರಂಭ.'));
      if (t(14)) events.add(AstroEvent(name: 'ಗುರು ಪೌರ್ಣಿಮೆ (ವ್ಯಾಸ ಪೌರ್ಣಿಮೆ)', description: 'ಗುರುಪೂಜೆಗೆ ಶ್ರೇಷ್ಠ ದಿನ.'));
      if (t(29)) events.add(AstroEvent(name: 'ದೀಪ ಅಮಾವಾಸ್ಯೆ', description: 'ಪಿತೃಗಳ ಆರಾಧನೆ. ದೀಪ ಬೆಳಗಿಸಿ ಪಿತೃತರ್ಪಣ.'));
    }

    // 5. ಶ್ರಾವಣ ಮಾಸ
    if (masa == 'ಶ್ರಾವಣ') {
      if (t(2)) events.add(AstroEvent(name: 'ಮಂಗಳ ಗೌರಿ ವ್ರತ ಆರಂಭ', description: 'ಶ್ರಾವಣ ಮಾಸದ ಪ್ರಾರಂಭದಲ್ಲಿ ಗೌರಿ ವ್ರತ.'));
      if (t(4)) events.add(AstroEvent(name: 'ನಾಗ ಪಂಚಮಿ', description: 'ನಾಗ ದೇವತೆಗಳ ಆರಾಧನೆ. ಹಾಲು ಅರ್ಪಣೆ.'));
      if (t(14)) events.add(AstroEvent(name: 'ಉಪಾಕರ್ಮ / ರಕ್ಷಾ ಬಂಧನ', description: 'ನೂತನ ಯಜ್ಞೋಪವೀತ ಧಾರಣೆ. ಸಹೋದರ ಪ್ರೇಮ.'));
      if (t(17)) events.add(AstroEvent(name: 'ಕಜ್ಜಾಯ ತದಿಗೆ', description: 'ಕಜ್ಜಾಯ ತಯಾರಿಸಿ ದೇವತೆಗಳಿಗೆ ಅರ್ಪಿಸುವ ಆಚರಣೆ.'));
      // Krishna Janmashtami: Ashtami at MIDNIGHT (Nishitha kala)
      if (midnightTithiIdx == 22) events.add(AstroEvent(name: 'ಶ್ರೀ ಕೃಷ್ಣ ಜನ್ಮಾಷ್ಟಮಿ', description: 'ಭಗವಾನ್ ಶ್ರೀಕೃಷ್ಣನ ಅವತಾರ ದಿನ. ಅರ್ಧರಾತ್ರಿ ಪುಣ್ಯಕಾಲ.'));
      if (tPara(25)) events.add(AstroEvent(name: 'ಅಜಾ ಏಕಾದಶಿ', description: 'ಶ್ರಾವಣ ಕೃಷ್ಣ ಏಕಾದಶಿ. ಪಾಪ ವಿಮೋಚನ.'));
    }

    // 6. ಭಾದ್ರಪದ ಮಾಸ
    if (masa == 'ಭಾದ್ರಪದ') {
      if (t(2)) events.add(AstroEvent(name: 'ಸ್ವರ್ಣಗೌರಿ ವ್ರತ / ಹರ್ತಾಲಿಕಾ ತೃತೀಯಾ', description: 'ಸೌಭಾಗ್ಯಕ್ಕಾಗಿ ಪಾರ್ವತಿ ವ್ರತ. ಹರ್ತಾಲಿಕಾ ಪೂಜೆ.'));
      // Ganesha Chaturthi: Madhyahna Vyapti — Chaturthi must be at NOON (Dharma Sindhu)
      if (noonTithiIdx == 3 && prevDayTithiIdx != 3) events.add(AstroEvent(name: 'ಗಣೇಶ ಚತುರ್ಥಿ', description: 'ಮಹಾಗಣಪತಿಯ ಅವತಾರ ದಿನ. ಮಣ್ಣಿನ ಗಣೇಶ ಸ್ಥಾಪನೆ. ಮಧ್ಯಾಹ್ನ ವ್ಯಾಪ್ತಿ.'));
      if (t(4)) events.add(AstroEvent(name: 'ಋಷಿ ಪಂಚಮಿ', description: 'ಸಪ್ತ ಋಷಿಗಳ ಆರಾಧನೆ.'));
      if (t(6)) events.add(AstroEvent(name: 'ಲಲಿತಾ ಸಪ್ತಮಿ', description: 'ಲಲಿತಾ ದೇವಿ ಆರಾಧನೆ.'));
      if (tPara(10)) events.add(AstroEvent(name: 'ಪರಿವರ್ತಿನೀ ಏಕಾದಶಿ', description: 'ವಿಷ್ಣುವಿನ ಶಯನ ಪರಿವರ್ತನ.'));
      if (t(13)) events.add(AstroEvent(name: 'ಅನಂತ ಚತುರ್ದಶಿ (ಗಣೇಶ ವಿಸರ್ಜನ)', description: 'ಗಣೇಶ ವಿಸರ್ಜನೆ. ಅನಂತ ಪದ್ಮನಾಭ ವ್ರತ.'));
      if (t(14)) events.add(AstroEvent(name: 'ಮಹಾಲಯಾರಂಭ', description: 'ಪಿತೃಪಕ್ಷದ ಆರಂಭ. ೧೫ ದಿನ ಪಿತೃ ಶ್ರಾದ್ಧ.'));
      if (t(29)) events.add(AstroEvent(name: 'ಮಹಾಲಯ ಅಮಾವಾಸ್ಯೆ', description: 'ಸರ್ವ ಪಿತೃಗಳಿಗೂ ತರ್ಪಣ. ಪಿತೃಪಕ್ಷ ಸಮಾಪ್ತಿ.'));
    }

    // 7. ಆಶ್ವಿನ ಮಾಸ
    if (masa == 'ಆಶ್ವಿನ') {
      if (t(0)) events.add(AstroEvent(name: 'ಶರನ್ನವರಾತ್ರಿ ಆರಂಭ / ಘಟಸ್ಥಾಪನೆ', description: '೯ ದಿನಗಳ ದೇವಿ ಆರಾಧನೆ. ಕಲಶ ಸ್ಥಾಪನೆ.'));
      if (t(1)) events.add(AstroEvent(name: 'ನವರಾತ್ರಿ ೨ನೇ ದಿನ - ಬ್ರಹ್ಮಚಾರಿಣಿ', description: 'ಬ್ರಹ್ಮಚಾರಿಣಿ ದೇವಿ ಪೂಜೆ.'));
      if (t(2)) events.add(AstroEvent(name: 'ನವರಾತ್ರಿ ೩ನೇ ದಿನ - ಚಂದ್ರಘಂಟಾ', description: 'ಚಂದ್ರಘಂಟಾ ದೇವಿ ಪೂಜೆ.'));
      if (t(3)) events.add(AstroEvent(name: 'ನವರಾತ್ರಿ ೪ನೇ ದಿನ - ಕೂಷ್ಮಾಂಡಾ', description: 'ಕೂಷ್ಮಾಂಡಾ ದೇವಿ ಪೂಜೆ.'));
      if (t(4)) events.add(AstroEvent(name: 'ಲಲಿತಾ ಪಂಚಮಿ / ನವರಾತ್ರಿ ೫ನೇ ದಿನ - ಸ್ಕಂದಮಾತಾ', description: 'ಸ್ಕಂದಮಾತಾ ಪೂಜೆ.'));
      if (t(5)) events.add(AstroEvent(name: 'ನವರಾತ್ರಿ ೬ನೇ ದಿನ - ಕಾತ್ಯಾಯನಿ', description: 'ಕಾತ್ಯಾಯನಿ ದೇವಿ ಪೂಜೆ.'));
      if (t(6)) events.add(AstroEvent(name: 'ಸರಸ್ವತೀ ಪೂಜೆ / ಸರಸ್ವತ್ಯಾವಾಹನ', description: 'ವಿದ್ಯಾದೇವತೆ ಸರಸ್ವತಿ ಪೂಜೆ. ಪುಸ್ತಕ ಪೂಜೆ.'));
      if (t(7)) events.add(AstroEvent(name: 'ದುರ್ಗಾಷ್ಟಮೀ / ಮಹಾಷ್ಟಮೀ', description: 'ದುರ್ಗಾ ದೇವಿ ವಿಶೇಷ ಪೂಜೆ. ಕುಮಾರಿ ಪೂಜೆ.'));
      if (t(8)) events.add(AstroEvent(name: 'ಮಹಾನವಮಿ / ಆಯುಧ ಪೂಜೆ', description: 'ಆಯುಧ, ವಾಹನ, ಯಂತ್ರಗಳ ಪೂಜೆ. ನವಮಿ ಹೋಮ.'));
      if (t(9)) events.add(AstroEvent(name: 'ವಿಜಯದಶಮಿ (ದಸರಾ)', description: 'ಬನ್ನಿ ಮಿಡಿ ಪೂಜೆ. ಸೀಮೋಲ್ಲಂಘನ. ಶಮಿ ಪೂಜೆ.'));
      // Karva Chauth: chandrodaya — Kr. Chaturthi at MOONRISE
      if (moonriseTithiIdx == 18) events.add(AstroEvent(name: 'ಕರ್ವಾ ಚೌತ್', description: 'ಪತಿಯ ದೀರ್ಘಾಯುಷ್ಯಕ್ಕಾಗಿ ಚಂದ್ರೋದಯ ವ್ರತ.'));
      if (t(28)) events.add(AstroEvent(name: 'ನರಕ ಚತುರ್ದಶಿ', description: 'ನರಕಾಸುರ ಸಂಹಾರ. ಅಭ್ಯಂಜನ ಸ್ನಾನ.'));
      if (t(29)) events.add(AstroEvent(name: 'ದೀಪಾವಳಿ / ಲಕ್ಷ್ಮಿ ಪೂಜೆ', description: 'ಮಹಾಲಕ್ಷ್ಮಿಯ ಆರಾಧನೆ. ದೀಪ ಬೆಳಗಿಸುವ ಹಬ್ಬ.'));
    }

    // 8. ಕಾರ್ತಿಕ ಮಾಸ
    if (masa == 'ಕಾರ್ತಿಕ') {
      if (t(0)) events.add(AstroEvent(name: 'ಬಲಿ ಪಾಡ್ಯಮಿ / ಗೋವರ್ಧನ ಪೂಜೆ', description: 'ಬಲೀಂದ್ರ ಪೂಜೆ, ಗೋಪೂಜೆ, ಗೋವರ್ಧನ ಪೂಜೆ.'));
      if (t(1)) events.add(AstroEvent(name: 'ಯಮ ದ್ವಿತೀಯಾ (ಭಾತೃ ದ್ವಿತೀಯಾ)', description: 'ಸಹೋದರ ಬಾಂಧವ್ಯದ ಹಬ್ಬ.'));
      if (t(8)) events.add(AstroEvent(name: 'ಗೋಪಾಷ್ಟಮೀ', description: 'ಗೋವುಗಳ ಪೂಜೆ. ಕೃಷ್ಣನ ಗೋ ಸೇವೆ ಸ್ಮರಣೆ.'));
      if (tPara(10)) events.add(AstroEvent(name: 'ಪ್ರಬೋಧಿನೀ ಏಕಾದಶಿ', description: 'ವಿಷ್ಣುವಿನ ನಿದ್ರೆಯಿಂದ ಎಚ್ಚರ.'));
      if (t(11)) events.add(AstroEvent(name: 'ಉತ್ಥಾನ ದ್ವಾದಶಿ / ತುಳಸಿ ವಿವಾಹ', description: 'ಚಾತುರ್ಮಾಸ್ಯ ಸಮಾಪ್ತಿ. ತುಳಸೀ ವಿವಾಹ.'));
      if (t(14)) events.add(AstroEvent(name: 'ಕಾರ್ತಿಕ ಪೌರ್ಣಿಮೆ / ಗುರು ನಾನಕ್ ಜಯಂತಿ', description: 'ಶಿವನಿಗೆ ದೀಪೋತ್ಸವ.'));
      if (t(26)) events.add(AstroEvent(name: 'ಗೋವತ್ಸ ದ್ವಾದಶಿ (ವಸು ಬಾರಸ್)', description: 'ಗೋವು ಮತ್ತು ಕರುವಿನ ಪೂಜೆ.'));
      if (t(27)) events.add(AstroEvent(name: 'ಧನ ತ್ರಯೋದಶಿ (ಧನ್ತೇರಸ್)', description: 'ಧನ್ವಂತರಿ ಜಯಂತಿ. ಹೊಸ ಪಾತ್ರೆ/ಬಂಗಾರ ಖರೀದಿ.'));
    }

    // 9. ಮಾರ್ಗಶಿರ ಮಾಸ
    if (masa == 'ಮಾರ್ಗಶಿರ') {
      if (t(5)) events.add(AstroEvent(name: 'ಸುಬ್ರಹ್ಮಣ್ಯ ಷಷ್ಠಿ (ಚಂಪಾ ಷಷ್ಠಿ)', description: 'ಸುಬ್ರಹ್ಮಣ್ಯ ಸ್ವಾಮಿಯ ಆರಾಧನೆ.'));
      if (tPara(10)) events.add(AstroEvent(name: 'ಗೀತಾ ಜಯಂತಿ / ವೈಕುಂಠ ಏಕಾದಶಿ', description: 'ಭಗವದ್ಗೀತೆ ಬೋಧಿಸಿದ ದಿನ.'));
      if (t(14)) events.add(AstroEvent(name: 'ದತ್ತಾತ್ರೇಯ ಜಯಂತಿ', description: 'ದತ್ತಾತ್ರೇಯನ ಅವತಾರ.'));
      // ಕಾಲಭೈರವ ಅಷ್ಟಮಿ — Kr. Ashtami at NISHITHA (midnight) per Dharma Sindhu
      if (midnightTithiIdx == 22) events.add(AstroEvent(name: 'ಕಾಲಭೈರವ ಅಷ್ಟಮಿ', description: 'ಕಾಲಭೈರವನ ಆರಾಧನೆ. ನಿಶೀಥ ಕಾಲದಲ್ಲಿ ಅಷ್ಟಮಿ ಇರಬೇಕು.'));
    }

    // 10. ಪುಷ್ಯ ಮಾಸ
    if (masa == 'ಪುಷ್ಯ') {
      if (tPara(10)) events.add(AstroEvent(name: 'ಪುತ್ರದಾ ಏಕಾದಶಿ', description: 'ಪುತ್ರಸಂತಾನಕ್ಕಾಗಿ ಏಕಾದಶಿ.'));
      if (t(14)) events.add(AstroEvent(name: 'ಪುಷ್ಯ ಪೌರ್ಣಿಮೆ', description: 'ದೇವಿ ಆರಾಧನೆಗೆ ಶ್ರೇಷ್ಠ.'));
      if (t(18)) events.add(AstroEvent(name: 'ತಿಲ ಚತುರ್ಥಿ', description: 'ಎಳ್ಳಿನೊಂದಿಗೆ ಗಣೇಶ ಪೂಜೆ.'));
      if (t(29)) events.add(AstroEvent(name: 'ಮೌನ ಅಮಾವಾಸ್ಯೆ', description: 'ಮೌನ ವ್ರತ ಮತ್ತು ಪಿತೃತರ್ಪಣ.'));
    }

    // 11. ಮಾಘ ಮಾಸ
    if (masa == 'ಮಾಘ') {
      if (t(4)) events.add(AstroEvent(name: 'ವಸಂತ ಪಂಚಮಿ (ಶ್ರೀ ಪಂಚಮಿ)', description: 'ಸರಸ್ವತಿ ಆರಾಧನೆ. ಹಳದಿ ವಸ್ತ್ರ ಧಾರಣೆ.'));
      if (t(6)) events.add(AstroEvent(name: 'ರಥ ಸಪ್ತಮಿ', description: 'ಸೂರ್ಯ ದೇವನ ಆರಾಧನೆ. ಎಕ್ಕೆ ಎಲೆ ಸ್ನಾನ.'));
      if (t(7)) events.add(AstroEvent(name: 'ಭೀಷ್ಮ ಅಷ್ಟಮಿ', description: 'ಭೀಷ್ಮಾಚಾರ್ಯರ ಸ್ಮರಣೆ.'));
      if (tPara(10)) events.add(AstroEvent(name: 'ಭೀಷ್ಮ ಏಕಾದಶಿ / ಜಯಾ ಏಕಾದಶಿ', description: 'ವಿಷ್ಣುಸಹಸ್ರನಾಮ ಉಪದೇಶಿಸಿದ ದಿನ.'));
      if (t(14)) events.add(AstroEvent(name: 'ಮಾಘ ಪೌರ್ಣಿಮೆ', description: 'ಮಾಘ ಸ್ನಾನ ಪ್ರಶಸ್ತ. ದಾನ-ಪುಣ್ಯ.'));
      // Maha Shivaratri: Chaturdashi at NISHITHA (midnight)
      if (midnightTithiIdx == 28) events.add(AstroEvent(name: 'ಮಹಾ ಶಿವರಾತ್ರಿ', description: 'ಶಿವನ ಆರಾಧನೆ. ಉಪವಾಸ ಮತ್ತು ಜಾಗರಣೆ. ನಿಶೀಥ ಕಾಲದಲ್ಲಿ ಚತುರ್ದಶಿ ಇರಬೇಕು.'));
      if (t(29)) events.add(AstroEvent(name: 'ಮೌನಿ ಅಮಾವಾಸ್ಯೆ / ಮಾಘ ಅಮಾವಾಸ್ಯೆ', description: 'ಮೌನ ವ್ರತ. ಸಂಗಮ ಸ್ನಾನ. ಪಿತೃ ತರ್ಪಣ.'));
    }

    // 12. ಫಾಲ್ಗುಣ ಮಾಸ
    if (masa == 'ಫಾಲ್ಗುಣ') {
      if (t(3)) events.add(AstroEvent(name: 'ಗಣೇಶ ಜಯಂತಿ', description: 'ಗಣೇಶನ ಜನ್ಮದಿನ.'));
      if (tPara(10)) events.add(AstroEvent(name: 'ಆಮಲಕೀ ಏಕಾದಶಿ', description: 'ನೆಲ್ಲಿ ವೃಕ್ಷ ಪೂಜೆ.'));
      if (t(14)) events.add(AstroEvent(name: 'ಹೋಳಿ ಹುಣ್ಣಿಮೆ / ಕಾಮ ದಹನ', description: 'ಬಣ್ಣಗಳ ಹಬ್ಬ. ಹೋಲಿಕಾ ದಹನ.'));
    }

    // ═══════════════════════════════════════════════════════
    //  MONTHLY RECURRING EVENTS
    // ═══════════════════════════════════════════════════════

    // ಏಕಾದಶಿ — Para Viddha (prefer second day of vriddhi)
    if (tPara(10) || tPara(25)) {
      events.add(AstroEvent(name: 'ಏಕಾದಶಿ ವ್ರತ', description: 'ಮಹಾವಿಷ್ಣುವಿನ ಆರಾಧನೆಗಾಗಿ ಉಪವಾಸ.'));
    }

    // ಪ್ರದೋಷ — Trayodashi at SUNSET
    if (sunsetTithiIdx == 12 || sunsetTithiIdx == 27) {
      events.add(AstroEvent(name: 'ಪ್ರದೋಷ ವ್ರತ', description: 'ಶಿವನ ಆರಾಧನೆ. ಸಂಧ್ಯಾ ಕಾಲದಲ್ಲಿ ತ್ರಯೋದಶಿ ಇರಬೇಕು.'));
    }

    // ಸಂಕಷ್ಟಹರ ಚತುರ್ಥಿ — Krishna Chaturthi at MOONRISE time = Sankashtha day
    // Simple rule: if tithi at moonrise is Krishna Chaturthi (index 18), it's Sankashtha
    if (moonriseTithiIdx == 18) {
      events.add(AstroEvent(name: 'ಸಂಕಷ್ಟಹರ ಚತುರ್ಥಿ', description: 'ವಿಘ್ನೇಶ್ವರನ ಚಂದ್ರೋದಯ ಪೂಜೆ. ಉಪವಾಸ ಮತ್ತು ಚಂದ್ರ ದರ್ಶನ.'));
    }

    // ವಿನಾಯಕ ಚತುರ್ಥಿ — Shukla Chaturthi at sunrise
    if (t(3)) {
      events.add(AstroEvent(name: 'ವಿನಾಯಕ ಚತುರ್ಥಿ', description: 'ಪ್ರತಿ ಮಾಸ ಶುಕ್ಲ ಚತುರ್ಥಿ. ಗಣಪತಿ ಪೂಜೆ.'));
    }

    // ಮಾಸ ಶಿವರಾತ್ರಿ — Kr. Chaturdashi at MIDNIGHT
    if (midnightTithiIdx == 28) {
      events.add(AstroEvent(name: 'ಮಾಸ ಶಿವರಾತ್ರಿ', description: 'ಪ್ರತಿ ಮಾಸ ಕೃಷ್ಣ ಚತುರ್ದಶಿ. ಶಿವ ಪೂಜೆ ಮತ್ತು ಜಾಗರಣೆ.'));
    }

    // ಹುಣ್ಣಿಮೆ / ಅಮಾವಾಸ್ಯೆ — sunrise
    if (t(14)) {
      events.add(AstroEvent(name: 'ಹುಣ್ಣಿಮೆ (ಪೌರ್ಣಿಮೆ)', description: 'ಸತ್ಯನಾರಾಯಣ ಪೂಜೆಗೆ ಪ್ರಶಸ್ತ. ಪೌರ್ಣಮಿ ವ್ರತ.'));
    }
    if (t(29)) {
      events.add(AstroEvent(name: 'ಅಮಾವಾಸ್ಯೆ', description: 'ಪಿತೃ ತರ್ಪಣಕ್ಕೆ ಶ್ರೇಷ್ಠ ದಿನ.'));
    }

    return events;
  }

  /// Map i18n masa key (cm0-cm11) to Kannada masa name
  static String masaKeyToKannada(String key) {
    const map = {
      'cm0': 'ಚೈತ್ರ', 'cm1': 'ವೈಶಾಖ', 'cm2': 'ಜ್ಯೇಷ್ಠ',
      'cm3': 'ಆಷಾಢ', 'cm4': 'ಶ್ರಾವಣ', 'cm5': 'ಭಾದ್ರಪದ',
      'cm6': 'ಆಶ್ವಿನ', 'cm7': 'ಕಾರ್ತಿಕ', 'cm8': 'ಮಾರ್ಗಶಿರ',
      'cm9': 'ಪುಷ್ಯ', 'cm10': 'ಮಾಘ', 'cm11': 'ಫಾಲ್ಗುಣ',
    };
    return map[key] ?? '';
  }
}
