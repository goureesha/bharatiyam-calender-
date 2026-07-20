/// Event Calculator — Hindu festivals and observances based on Chandra Masa and Tithi.
/// Ported from reference app's events.dart with all event rules intact.

class AstroEvent {
  final String name;
  final String description;
  final String shloka;
  final String meaning;
  final String source;

  AstroEvent({
    required this.name,
    required this.description,
    required this.shloka,
    this.meaning = '',
    required this.source,
  });
}

class EventCalculator {
  /// Returns events for a given Chandra Masa (Kannada name) and tithi index.
  /// masa: Kannada masa name (e.g., 'ಚೈತ್ರ', 'ವೈಶಾಖ')
  /// tIdx: 0-29 (0=Shukla Pratipada...14=Pournami...29=Amavasya) — tithi at SUNRISE
  /// sunsetTithiIdx: tithi at SUNSET (for Pradosha etc.)
  /// isAdhika: true if Adhika Masa — all events are skipped
  static List<AstroEvent> getEvents({
    required String masa,
    required int tIdx,
    int? sunsetTithiIdx,
    bool isAdhika = false,
  }) {
    final List<AstroEvent> events = [];
    if (isAdhika) return events;

    // 1. ಚೈತ್ರ ಮಾಸ (Chaitra)
    if (masa == 'ಚೈತ್ರ') {
      if (tIdx == 0) {
        events.add(AstroEvent(name: 'ಯುಗಾದಿ ಹಬ್ಬ (ಚಾಂದ್ರಮಾನ)', description: 'ಹೊಸ ವರ್ಷದ ಆರಂಭ. ಬೇವು-ಬೆಲ್ಲ ಸೇವನೆ ವಿಶೇಷ. ಪಂಚಾಂಗ ಶ್ರವಣ.', shloka: 'ಶತಾಯುರ್ವಜ್ರದೇಹತ್ವಾತ್ ಸರ್ವಸಂಪತ್ಕರಂ ಪರಮ್ |', meaning: 'ಚೈತ್ರ ಶುಕ್ಲ ಪ್ರತಿಪದೆ', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 2) {
        events.add(AstroEvent(name: 'ಗೌರೀ ತೃತೀಯಾ (ಸೌಭಾಗ್ಯ ಗೌರೀ ವ್ರತ) / ಮತ್ಸ್ಯ ಜಯಂತಿ', description: 'ಪಾರ್ವತೀ ದೇವಿ ಮತ್ತು ಮತ್ಸ್ಯಾವತಾರ ಆರಾಧನೆ.', shloka: 'ಚೈತ್ರೇ ಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ತೃತೀಯಾಯಾಂ ಸಮಾಹಿತಾ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 5) {
        events.add(AstroEvent(name: 'ಸ್ಕಂದ ಷಷ್ಠಿ', description: 'ಕಾರ್ತಿಕೇಯ ಸ್ವಾಮಿಯ ಆರಾಧನೆ.', shloka: 'ಚೈತ್ರೇ ಶುಕ್ಲೇ ಷಷ್ಠ್ಯಾಂ ತು ಸ್ಕಂದಂ ಸಂಪೂಜ್ಯ ಯತ್ನತಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 8) {
        events.add(AstroEvent(name: 'ಶ್ರೀರಾಮ ನವಮಿ', description: 'ಶ್ರೀರಾಮಚಂದ್ರನ ಜನ್ಮದಿನ. ಅಭಿಷೇಕ, ಪುಣ್ಯಕಾಲ.', shloka: 'ಚೈತ್ರೇ ನವಮ್ಯಾಂ ಪ್ರಾಕ್ಪಕ್ಷೇ ದಿವಾ ಪುಣ್ಯೇ ಪುನರ್ವಸೌ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಕಾಮದಾ ಏಕಾದಶಿ', description: 'ಸರ್ವ ಕಾಮನೆಗಳನ್ನು ಪೂರೈಸುವ ಏಕಾದಶಿ.', shloka: 'ಚೈತ್ರೇ ಶುಕ್ಲಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ಕಾಮದಾ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಹನುಮಜ್ಜಯಂತಿ / ಚಿತ್ರಾ ಪೌರ್ಣಿಮೆ', description: 'ಹನುಮಂತನ ಅವತಾರ ದಿನ. ಚಿತ್ರಗುಪ್ತ ಪೂಜೆ.', shloka: 'ಚೈತ್ರೇಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ಪೌರ್ಣಮಾಸ್ಯಾಂ ಕುಜೇಽಹನಿ |', source: 'ಆಗಮ ಗ್ರಂಥಗಳು'));
      } else if (tIdx == 27) {
        events.add(AstroEvent(name: 'ಅನಂಗ ತ್ರಯೋದಶೀ', description: 'ಕಾಮದೇವನ ಆರಾಧನೆ.', shloka: 'ಚೈತ್ರೇ ಕೃಷ್ಣತ್ರಯೋದಶ್ಯಾಂ ಅನಂಗಂ ಪೂಜಯೇತ್ ಸದಾ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 2. ವೈಶಾಖ ಮಾಸ (Vaishakha)
    if (masa == 'ವೈಶಾಖ') {
      if (tIdx == 2) {
        events.add(AstroEvent(name: 'ಅಕ್ಷಯ ತೃತೀಯಾ / ಪರಶುರಾಮ ಜಯಂತಿ', description: 'ಅತ್ಯಂತ ಶುಭದಿನ. ದಾನ, ಜಪಗಳು ಅಕ್ಷಯ ಫಲ ನೀಡುತ್ತವೆ. ಪರಶುರಾಮ ಅವತಾರ ದಿನ.', shloka: 'ವೈಶಾಖಸ್ಯ ಸಿತೇ ಪಕ್ಷೇ ತೃತೀಯಾಯಾಮುಪೋಷಿತಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 4) {
        events.add(AstroEvent(name: 'ಶಂಕರಾಚಾರ್ಯ ಜಯಂತಿ', description: 'ಆದಿ ಶಂಕರಾಚಾರ್ಯರ ಅವತಾರ ದಿನ.', shloka: 'ವೈಶಾಖೇ ಶುಕ್ಲಪಂಚಮ್ಯಾಂ ಶಂಕರೋ ಭಗವಾನ್ ಜನಿಃ |', source: 'ಶಂಕರ ವಿಜಯ'));
      } else if (tIdx == 6) {
        events.add(AstroEvent(name: 'ಗಂಗೋತ್ಪತ್ತಿ / ಜಹ್ನು ಸಪ್ತಮಿ', description: 'ಗಂಗಾದೇವಿಯ ಅವತರಣ ದಿನ.', shloka: 'ವೈಶಾಖೇ ಶುಕ್ಲಸಪ್ತಮ್ಯಾಂ ಗಂಗಾ ಸಾಗರಮಾಗತಾ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಮೋಹಿನೀ ಏಕಾದಶಿ', description: 'ಮೋಹಿನೀ ಅವತಾರದ ಸ್ಮರಣೆ.', shloka: 'ವೈಶಾಖಸ್ಯ ಸಿತೇ ಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ನಿರಾಮಿಷಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 13) {
        events.add(AstroEvent(name: 'ಶ್ರೀ ನರಸಿಂಹ ಜಯಂತಿ', description: 'ನರಸಿಂಹನ ಅವತಾರ ದಿನ. ಸಂಧ್ಯಾ ಕಾಲದಲ್ಲಿ ಪ್ರಾದುರ್ಭಾವ.', shloka: 'ವೈಶಾಖಸ್ಯ ಸಿತೇ ಪಕ್ಷೇ ಚತುರ್ದಶ್ಯಾಂ ಮಧುಸೂದನಃ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಬುದ್ಧ ಪೌರ್ಣಿಮೆ / ಕೂರ್ಮ ಜಯಂತಿ', description: 'ಬುದ್ಧ ಮತ್ತು ಕೂರ್ಮಾವತಾರದ ಜನ್ಮದಿನ.', shloka: 'ವೈಶಾಖೇ ಪೌರ್ಣಮಾಸ್ಯಾಂ ತು ಕೂರ್ಮರೂಪೀ ಜನಾರ್ದನಃ |', source: 'ಪುರಾಣೋಕ್ತ'));
      } else if (tIdx == 29) {
        events.add(AstroEvent(name: 'ಶನೈಶ್ಚರ ಜಯಂತಿ', description: 'ಶನಿ ದೇವನ ಜನ್ಮ ದಿನ. ತೈಲಾಭಿಷೇಕ.', shloka: 'ವೈಶಾಖೇ ಅಮಾವಾಸ್ಯಾಯಾಂ ಶನೈಶ್ಚರಜನ್ಮ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 3. ಜ್ಯೇಷ್ಠ ಮಾಸ (Jyeshtha)
    if (masa == 'ಜ್ಯೇಷ್ಠ') {
      if (tIdx == 9) {
        events.add(AstroEvent(name: 'ಗಂಗಾ ದಶಹರಾ', description: 'ಗಂಗಾ ನದಿಯ ಭೂಮಿಗೆ ಅವತರಣ ದಿನ. ಗಂಗಾ ಸ್ನಾನ ವಿಶೇಷ.', shloka: 'ಜ್ಯೇಷ್ಠೇ ಶುಕ್ಲೇ ದಶಮ್ಯಾಂ ತು ಗಂಗಾ ದಶಹರಾ ಸ್ಮೃತಾ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ನಿರ್ಜಲಾ ಏಕಾದಶಿ', description: '೨೪ ಏಕಾದಶಿಗಳ ಫಲ ನೀಡುವ ಕಠಿಣ ವ್ರತ. ಜಲ ಸಹಿತ ಸಂಪೂರ್ಣ ಉಪವಾಸ.', shloka: 'ಜ್ಯೇಷ್ಠೇ ಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ನಿರಂಬುಕಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ವಟ ಸಾವಿತ್ರಿ ವ್ರತ / ಜ್ಯೇಷ್ಠ ಪೌರ್ಣಿಮೆ', description: 'ಪತಿಯ ದೀರ್ಘಾಯುಷ್ಯಕ್ಕಾಗಿ ವ್ರತ.', shloka: 'ಜ್ಯೇಷ್ಟೇ ಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ಪೌರ್ಣಮಾಸ್ಯಾಂ ವಿಶೇಷತಃ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 29) {
        events.add(AstroEvent(name: 'ಜ್ಯೇಷ್ಠ ಅಮಾವಾಸ್ಯೆ / ಶನಿ ಅಮಾವಾಸ್ಯೆ', description: 'ಪಿತೃ ತರ್ಪಣ. ಶನಿ ಪ್ರೀತಿಗಾಗಿ ತೈಲಾಭಿಷೇಕ.', shloka: 'ಜ್ಯೇಷ್ಠೇ ಅಮಾವಾಸ್ಯಾಯಾಂ ಪಿತೃಪೂಜಾ ವಿಶೇಷತಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 4. ಆಷಾಢ ಮಾಸ (Ashadha)
    if (masa == 'ಆಷಾಢ') {
      if (tIdx == 1) {
        events.add(AstroEvent(name: 'ರಥ ಯಾತ್ರಾ', description: 'ಜಗನ್ನಾಥ ಸ್ವಾಮಿಯ ರಥೋತ್ಸವ.', shloka: 'ಆಷಾಢಸ್ಯ ಸಿತೇ ಪಕ್ಷೇ ದ್ವಿತೀಯಾಯಾಂ ಮಹೋತ್ಸವಃ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಶಯನೀ ಏಕಾದಶಿ (ಪ್ರಥಮ ಏಕಾದಶಿ)', description: 'ಚಾತುರ್ಮಾಸ್ಯ ವ್ರತದ ಆರಂಭ.', shloka: 'ಆಷಾಢಸ್ಯ ಸಿತೇ ಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ಹರಿಃ ಸ್ವಪನ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಗುರು ಪೌರ್ಣಿಮೆ (ವ್ಯಾಸ ಪೌರ್ಣಿಮೆ)', description: 'ಗುರುಪೂಜೆಗೆ ಶ್ರೇಷ್ಠ ದಿನ.', shloka: 'ಅಜ್ಞಾನತಿಮಿರಾನ್ಧಸ್ಯ ಜ್ಞಾನಾಞ್ಜನಶಲಾಕಯಾ |', source: 'ಗುರು ಗೀತಾ'));
      } else if (tIdx == 29) {
        events.add(AstroEvent(name: 'ದೀಪ ಅಮಾವಾಸ್ಯೆ', description: 'ಪಿತೃಗಳ ಆರಾಧನೆ. ದೀಪ ಬೆಳಗಿಸಿ ಪಿತೃತರ್ಪಣ.', shloka: 'ಆಷಾಢಸ್ಯ ಅಮಾವಾಸ್ಯಾಯಾಂ ದೀಪದಾನಂ ವಿಶೇಷತಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 5. ಶ್ರಾವಣ ಮಾಸ (Shravana)
    if (masa == 'ಶ್ರಾವಣ') {
      if (tIdx == 2) {
        events.add(AstroEvent(name: 'ಮಂಗಳ ಗೌರಿ ವ್ರತ ಆರಂಭ', description: 'ಶ್ರಾವಣ ಮಾಸದ ಪ್ರಾರಂಭದಲ್ಲಿ ಗೌರಿ ವ್ರತ.', shloka: 'ಶ್ರಾವಣೇ ಶುಕ್ಲಪಕ್ಷೇ ತೃತೀಯಾಯಾಂ ಗೌರೀಪೂಜಾ |', source: 'ವ್ರತ ಪರಂಪರೆ'));
      } else if (tIdx == 4) {
        events.add(AstroEvent(name: 'ನಾಗ ಪಂಚಮಿ', description: 'ನಾಗ ದೇವತೆಗಳ ಆರಾಧನೆ. ಹಾಲು ಅರ್ಪಣೆ.', shloka: 'ಶ್ರಾವಣೇ ಶುಕ್ಲಪಂಚಮ್ಯಾಂ ಸ್ನಾತ್ವಾ ನಾಗಾನ್ ಪ್ರಪೂಜಯೇತ್ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಉಪಾಕರ್ಮ / ರಕ್ಷಾ ಬಂಧನ', description: 'ನೂತನ ಯಜ್ಞೋಪವೀತ ಧಾರಣೆ. ಸಹೋದರ ಪ್ರೇಮ.', shloka: 'ಯೇನ ಬದ್ಧೋ ಬಲೀ ರಾಜಾ ದಾನವೇಂದ್ರೋ ಮಹಾಬಲಃ |', source: 'ಭವಿಷ್ಯ ಪುರಾಣ'));
      } else if (tIdx == 17) {
        events.add(AstroEvent(name: 'ಕಜ್ಜಾಯ ತದಿಗೆ', description: 'ಕಜ್ಜಾಯ ತಯಾರಿಸಿ ದೇವತೆಗಳಿಗೆ ಅರ್ಪಿಸುವ ಆಚರಣೆ.', shloka: 'ಶ್ರಾವಣೇ ಕೃಷ್ಣಪಕ್ಷೇ ತು ತೃತೀಯಾಯಾಂ ವಿಶೇಷತಃ |', source: 'ಆಚಾರ ಪರಂಪರೆ'));
      } else if (tIdx == 22) {
        events.add(AstroEvent(name: 'ಶ್ರೀ ಕೃಷ್ಣ ಜನ್ಮಾಷ್ಟಮಿ', description: 'ಭಗವಾನ್ ಶ್ರೀಕೃಷ್ಣನ ಅವತಾರ ದಿನ. ಅರ್ಧರಾತ್ರಿ ಪುಣ್ಯಕಾಲ.', shloka: 'ಶ್ರಾವಣೇ ಬಹುಳೇಽಷ್ಟಮ್ಯಾಂ ರೋಹಿಣ್ಯಾಮರ್ಧರಾತ್ರಕೇ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 25) {
        events.add(AstroEvent(name: 'ಅಜಾ ಏಕಾದಶಿ', description: 'ಶ್ರಾವಣ ಕೃಷ್ಣ ಏಕಾದಶಿ. ಪಾಪ ವಿಮೋಚನ.', shloka: 'ಶ್ರಾವಣೇ ಕೃಷ್ಣಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ಅಜಾ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 6. ಭಾದ್ರಪದ ಮಾಸ (Bhadrapada)
    if (masa == 'ಭಾದ್ರಪದ') {
      if (tIdx == 2) {
        events.add(AstroEvent(name: 'ಸ್ವರ್ಣಗೌರಿ ವ್ರತ / ಹರ್ತಾಲಿಕಾ ತೃತೀಯಾ', description: 'ಸೌಭಾಗ್ಯಕ್ಕಾಗಿ ಪಾರ್ವತಿ ವ್ರತ. ಹರ್ತಾಲಿಕಾ ಪೂಜೆ.', shloka: 'ಭಾದ್ರೇ ಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ತೃತೀಯಾಯಾಂ ಸುಶೋಭನೇ |', source: 'ವ್ರತ ರತ್ನಾವಳಿ'));
      } else if (tIdx == 3) {
        events.add(AstroEvent(name: 'ಗಣೇಶ ಚತುರ್ಥಿ', description: 'ಮಹಾಗಣಪತಿಯ ಅವತಾರ ದಿನ. ಮಣ್ಣಿನ ಗಣೇಶ ಸ್ಥಾಪನೆ.', shloka: 'ಭಾದ್ರಶುಕ್ಲಚತುರ್ಥ್ಯಾಂ ತು ಯನ್ಮಹಾಗಣಪತೇರ್ದಿನಮ್ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 4) {
        events.add(AstroEvent(name: 'ಋಷಿ ಪಂಚಮಿ', description: 'ಸಪ್ತ ಋಷಿಗಳ ಆರಾಧನೆ.', shloka: 'ಭಾದ್ರೇ ಶುಕ್ಲೇ ಪಂಚಮ್ಯಾಂ ತು ಸಪ್ತರ್ಷೀನ್ ಪೂಜಯೇತ್ ಸದಾ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 6) {
        events.add(AstroEvent(name: 'ಲಲಿತಾ ಸಪ್ತಮಿ', description: 'ಲಲಿತಾ ದೇವಿ ಆರಾಧನೆ.', shloka: 'ಭಾದ್ರೇ ಶುಕ್ಲೇ ಸಪ್ತಮ್ಯಾಂ ಲಲಿತಾ ಸಂಪೂಜನಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಪರಿವರ್ತಿನೀ ಏಕಾದಶಿ', description: 'ವಿಷ್ಣುವಿನ ಶಯನ ಪರಿವರ್ತನ.', shloka: 'ಭಾದ್ರೇ ಶುಕ್ಲೇ ಏಕಾದಶ್ಯಾಂ ಪರಿವರ್ತಿನೀ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 13) {
        events.add(AstroEvent(name: 'ಅನಂತ ಚತುರ್ದಶಿ (ಗಣೇಶ ವಿಸರ್ಜನ)', description: 'ಗಣೇಶ ವಿಸರ್ಜನೆ. ಅನಂತ ಪದ್ಮನಾಭ ವ್ರತ.', shloka: 'ಭಾದ್ರಪದ ಶುಕ್ಲ ಚತುರ್ದಶ್ಯಾಂ ಅನಂತವ್ರತಮಾಚರೇತ್ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಮಹಾಲಯಾರಂಭ', description: 'ಪಿತೃಪಕ್ಷದ ಆರಂಭ. ೧೫ ದಿನ ಪಿತೃ ಶ್ರಾದ್ಧ.', shloka: 'ಪೌರ್ಣಮಾಸ್ಯಾಂ ಚ ಪಿತೃಭ್ಯೋ ಶ್ರಾದ್ಧಮಾರಭೇತ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 29) {
        events.add(AstroEvent(name: 'ಮಹಾಲಯ ಅಮಾವಾಸ್ಯೆ', description: 'ಸರ್ವ ಪಿತೃಗಳಿಗೂ ತರ್ಪಣ. ಪಿತೃಪಕ್ಷ ಸಮಾಪ್ತಿ.', shloka: 'ಆಯುಃ ಪ್ರಜಾಂ ಧನಂ ವಿದ್ಯಾಂ ಸ್ವರ್ಗಂ ಮೋಕ್ಷಂ ಸುಖಾನಿ ಚ |', source: 'ಯಾಜ್ಞವಲ್ಕ್ಯ ಸ್ಮೃತಿ'));
      }
    }

    // 7. ಆಶ್ವಿನ ಮಾಸ (Ashwina)
    if (masa == 'ಆಶ್ವಿನ') {
      if (tIdx == 0) {
        events.add(AstroEvent(name: 'ಶರನ್ನವರಾತ್ರಿ ಆರಂಭ / ಘಟಸ್ಥಾಪನೆ', description: '೯ ದಿನಗಳ ದೇವಿ ಆರಾಧನೆ. ಕಲಶ ಸ್ಥಾಪನೆ.', shloka: 'ಜಯಂತೀ ಮಂಗಲಾ ಕಾಳೀ ಭದ್ರಕಾಲೀ ಕಪಾಲಿನೀ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 1) {
        events.add(AstroEvent(name: 'ನವರಾತ್ರಿ ೨ನೇ ದಿನ - ಬ್ರಹ್ಮಚಾರಿಣಿ', description: 'ಬ್ರಹ್ಮಚಾರಿಣಿ ದೇವಿ ಪೂಜೆ.', shloka: 'ದಧಾನಾ ಕರಪದ್ಮಾಭ್ಯಾಮಕ್ಷಮಾಲಾಕಮಂಡಲೂ |', source: 'ದುರ್ಗಾ ಸಪ್ತಶತೀ'));
      } else if (tIdx == 2) {
        events.add(AstroEvent(name: 'ನವರಾತ್ರಿ ೩ನೇ ದಿನ - ಚಂದ್ರಘಂಟಾ', description: 'ಚಂದ್ರಘಂಟಾ ದೇವಿ ಪೂಜೆ.', shloka: 'ಪಿಂಡಜಪ್ರವರಾರೂಢಾ ಚಂಡಕೋಪಾಸ್ತ್ರಕೈರ್ಯುತಾ |', source: 'ದುರ್ಗಾ ಸಪ್ತಶತೀ'));
      } else if (tIdx == 3) {
        events.add(AstroEvent(name: 'ನವರಾತ್ರಿ ೪ನೇ ದಿನ - ಕೂಷ್ಮಾಂಡಾ', description: 'ಕೂಷ್ಮಾಂಡಾ ದೇವಿ ಪೂಜೆ.', shloka: 'ಸುರಾಸಂಪೂರ್ಣಕಲಶಂ ರುಧಿರಾಪ್ಲುತಮೇವ ಚ |', source: 'ದುರ್ಗಾ ಸಪ್ತಶತೀ'));
      } else if (tIdx == 4) {
        events.add(AstroEvent(name: 'ಲಲಿತಾ ಪಂಚಮಿ / ನವರಾತ್ರಿ ೫ನೇ ದಿನ - ಸ್ಕಂದಮಾತಾ', description: 'ಸ್ಕಂದಮಾತಾ ಪೂಜೆ.', shloka: 'ಪಂಚಮ್ಯಾಂ ಲಲಿತಾಂ ದೇವೀಂ ಪೂಜಯೇತ್ ಸರ್ವಸಿದ್ಧಿದಾಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 5) {
        events.add(AstroEvent(name: 'ನವರಾತ್ರಿ ೬ನೇ ದಿನ - ಕಾತ್ಯಾಯನಿ', description: 'ಕಾತ್ಯಾಯನಿ ದೇವಿ ಪೂಜೆ.', shloka: 'ಚಂದ್ರಹಾಸೋಜ್ಜ್ವಲಕರಾ ಶಾರ್ದೂಲವರವಾಹನಾ |', source: 'ದುರ್ಗಾ ಸಪ್ತಶತೀ'));
      } else if (tIdx == 6) {
        events.add(AstroEvent(name: 'ಸರಸ್ವತೀ ಪೂಜೆ / ಸರಸ್ವತ್ಯಾವಾಹನ', description: 'ವಿದ್ಯಾದೇವತೆ ಸರಸ್ವತಿ ಪೂಜೆ. ಪುಸ್ತಕ ಪೂಜೆ.', shloka: 'ಮೂಲೇ ಪುಸ್ತಸ್ಥಾಪನಂ ದೇವ್ಯಾಃ ಪೂರ್ವಾಷಾಢಾಸು ಪೂಜನಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 7) {
        events.add(AstroEvent(name: 'ದುರ್ಗಾಷ್ಟಮೀ / ಮಹಾಷ್ಟಮೀ', description: 'ದುರ್ಗಾ ದೇವಿ ವಿಶೇಷ ಪೂಜೆ. ಕುಮಾರಿ ಪೂಜೆ.', shloka: 'ಅಷ್ಟಮ್ಯಾಂ ಪೂಜಯೇದ್ದುರ್ಗಾಂ ಸರ್ವಮಂಗಲ ಮಾಂಗಲ್ಯೇ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 8) {
        events.add(AstroEvent(name: 'ಮಹಾನವಮಿ / ಆಯುಧ ಪೂಜೆ', description: 'ಆಯುಧ, ವಾಹನ, ಯಂತ್ರಗಳ ಪೂಜೆ. ನವಮಿ ಹೋಮ.', shloka: 'ನವಮ್ಯಾಂ ಪೂಜಯೇದ್ದೇವಿಂ ಮಂತ್ರತಂತ್ರವಿಶಾರದಃ |', source: 'ದುರ್ಗಾ ಸಪ್ತಶತೀ'));
      } else if (tIdx == 9) {
        events.add(AstroEvent(name: 'ವಿಜಯದಶಮಿ (ದಸರಾ)', description: 'ಬನ್ನಿ ಮರಕ್ಕೆ ಪೂಜೆ. ಸೀಮೋಲ್ಲಂಘನ. ಶಮಿ ಪೂಜೆ.', shloka: 'ಶಮೀ ಶಮಯತೇ ಪಾಪಂ ಶಮೀ ಶತ್ರುವಿನಾಶಿನೀ |', source: 'ಪರಂಪರಾಗತ ಶ್ಲೋಕ'));
      } else if (tIdx == 18) {
        events.add(AstroEvent(name: 'ಕರ್ವಾ ಚೌತ್', description: 'ಪತಿಯ ದೀರ್ಘಾಯುಷ್ಯಕ್ಕಾಗಿ ಚಂದ್ರೋದಯ ವ್ರತ.', shloka: 'ಆಶ್ವಿನೇ ಕೃಷ್ಣಪಕ್ಷೇ ಚತುರ್ಥ್ಯಾಂ ಕರ್ವಾ |', source: 'ವ್ರತ ಪರಂಪರೆ'));
      } else if (tIdx == 28) {
        events.add(AstroEvent(name: 'ನರಕ ಚತುರ್ದಶಿ', description: 'ನರಕಾಸುರ ಸಂಹಾರ. ಅಭ್ಯಂಜನ ಸ್ನಾನ. ಅರುಣೋದಯ ಪುಣ್ಯಕಾಲ.', shloka: 'ಆಶ್ವಿನೇ ಕೃಷ್ಣಪಕ್ಷೇ ತು ಚತುರ್ದಶ್ಯಾಂ ವಿಧೂದಯೇ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 29) {
        events.add(AstroEvent(name: 'ದೀಪಾವಳಿ / ಲಕ್ಷ್ಮಿ ಪೂಜೆ', description: 'ಮಹಾಲಕ್ಷ್ಮಿಯ ಆರಾಧನೆ. ದೀಪ ಬೆಳಗಿಸುವ ಹಬ್ಬ. ಪಟಾಕಿ.', shloka: 'ನಮಸ್ತೇಽಸ್ತು ಮಹಾಮಾಯೇ ಶ್ರೀಪೀಠೇ ಸುರಪೂಜಿತೇ |', source: 'ಮಹಾಲಕ್ಷ್ಮ್ಯಷ್ಟಕ'));
      }
    }

    // 8. ಕಾರ್ತಿಕ ಮಾಸ (Kartika)
    if (masa == 'ಕಾರ್ತಿಕ') {
      if (tIdx == 0) {
        events.add(AstroEvent(name: 'ಬಲಿ ಪಾಡ್ಯಮಿ / ಗೋವರ್ಧನ ಪೂಜೆ', description: 'ಬಲೀಂದ್ರ ಪೂಜೆ, ಗೋಪೂಜೆ, ಗೋವರ್ಧನ ಪೂಜೆ.', shloka: 'ಬಲಿರಾಜ ನಮಸ್ತುಭ್ಯಂ ವಿರೋಚನಸುತ ಪ್ರಭೋ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 1) {
        events.add(AstroEvent(name: 'ಯಮ ದ್ವಿತೀಯಾ (ಭಾತೃ ದ್ವಿತೀಯಾ)', description: 'ಸಹೋದರ ಬಾಂಧವ್ಯದ ಹಬ್ಬ. ಭಾವನ ಮನೆಗೆ ಭೇಟಿ.', shloka: 'ಕಾರ್ತಿಕೇ ಶುಕ್ಲಪಕ್ಷೇ ತು ದ್ವಿತೀಯಾಯಾಂ ವಿಶೇಷತಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 8) {
        events.add(AstroEvent(name: 'ಗೋಪಾಷ್ಟಮೀ', description: 'ಗೋವುಗಳ ಪೂಜೆ. ಕೃಷ್ಣನ ಗೋ ಸೇವೆ ಸ್ಮರಣೆ.', shloka: 'ಕಾರ್ತಿಕೇ ಶುಕ್ಲಪಕ್ಷೇ ಅಷ್ಟಮ್ಯಾಂ ಗೋಪೂಜನಮ್ |', source: 'ವೈಷ್ಣವ ಸಂಪ್ರದಾಯ'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಪ್ರಬೋಧಿನೀ ಏಕಾದಶಿ', description: 'ವಿಷ್ಣುವಿನ ನಿದ್ರೆಯಿಂದ ಎಚ್ಚರ.', shloka: 'ಕಾರ್ತಿಕೇ ಶುಕ್ಲಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ಪ್ರಬೋಧಿನೀ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 11) {
        events.add(AstroEvent(name: 'ಉತ್ಥಾನ ದ್ವಾದಶಿ / ತುಳಸಿ ವಿವಾಹ', description: 'ಚಾತುರ್ಮಾಸ್ಯ ಸಮಾಪ್ತಿ. ತುಳಸೀ ವಿವಾಹ.', shloka: 'ಉತ್ತಿಷ್ಠೋತ್ತಿಷ್ಠ ಗೋವಿಂದ ತ್ಯಜ ನಿದ್ರಾಂ ಜಗತ್ಪತೇ |', source: 'ಪದ್ಮ ಪುರಾಣ'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಕಾರ್ತಿಕ ಪೌರ್ಣಿಮೆ / ಜ್ವಾಲಾತೋರಣ / ಗುರು ನಾನಕ್ ಜಯಂತಿ', description: 'ಶಿವನಿಗೆ ದೀಪೋತ್ಸವ.', shloka: 'ಕಾರ್ತಿಕ್ಯಾಂ ಪೌರ್ಣಮಾಸ್ಯಾಂ ತು ಕೃತ್ತಿಕಾಂ ಶಿವದರ್ಶನಮ್ |', source: 'ಸ್ಕಂದ ಪುರಾಣ'));
      } else if (tIdx == 26) {
        events.add(AstroEvent(name: 'ಗೋವತ್ಸ ದ್ವಾದಶಿ (ವಸು ಬಾರಸ್)', description: 'ಗೋವು ಮತ್ತು ಕರುವಿನ ಪೂಜೆ.', shloka: 'ಕಾರ್ತಿಕೇ ಕೃಷ್ಣಪಕ್ಷೇ ದ್ವಾದಶ್ಯಾಂ ಗೋವತ್ಸ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 27) {
        events.add(AstroEvent(name: 'ಧನ ತ್ರಯೋದಶಿ (ಧನ್ತೇರಸ್)', description: 'ಧನ್ವಂತರಿ ಜಯಂತಿ. ಹೊಸ ಪಾತ್ರೆ/ಬಂಗಾರ ಖರೀದಿ.', shloka: 'ಕಾರ್ತಿಕೇ ಕೃಷ್ಣಪಕ್ಷೇ ತು ತ್ರಯೋದಶ್ಯಾಂ ಧನಂ ಯಜೇತ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 9. ಮಾರ್ಗಶಿರ ಮಾಸ (Margashira)
    if (masa == 'ಮಾರ್ಗಶಿರ') {
      if (tIdx == 5) {
        events.add(AstroEvent(name: 'ಸುಬ್ರಹ್ಮಣ್ಯ ಷಷ್ಠಿ (ಚಂಪಾ ಷಷ್ಠಿ)', description: 'ಸುಬ್ರಹ್ಮಣ್ಯ ಸ್ವಾಮಿಯ ಆರಾಧನೆ.', shloka: 'ಮಾರ್ಗಶೀರ್ಷೇ ಸಿತೇ ಪಕ್ಷೇ ಷಷ್ಠ್ಯಾಂ ಸ್ಕಂದಂ ಪ್ರಪೂಜಯೇತ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಗೀತಾ ಜಯಂತಿ / ವೈಕುಂಠ ಏಕಾದಶಿ', description: 'ಭಗವದ್ಗೀತೆ ಬೋಧಿಸಿದ ದಿನ.', shloka: 'ಯತ್ರ ಯೋಗೇಶ್ವರಃ ಕೃಷ್ಣೋ ಯತ್ರ ಪಾರ್ಥೋ ಧನುರ್ಧರಃ |', source: 'ಭಗವದ್ಗೀತಾ'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ದತ್ತಾತ್ರೇಯ ಜಯಂತಿ', description: 'ದತ್ತಾತ್ರೇಯನ ಅವತಾರ.', shloka: 'ಬ್ರಹ್ಮಜ್ಞಾನಮಯೀ ಮುದ್ರಾ ವಸ್ತ್ರೇ ಚಾಕಾಶಭೂತಲೇ |', source: 'ದತ್ತ ಪುರಾಣ'));
      } else if (tIdx == 22) {
        events.add(AstroEvent(name: 'ಕಾಲಭೈರವ ಅಷ್ಟಮಿ', description: 'ಕಾಲಭೈರವನ ಆರಾಧನೆ.', shloka: 'ಮಾರ್ಗಶೀರ್ಷೇ ಕೃಷ್ಣಪಕ್ಷೇ ಅಷ್ಟಮ್ಯಾಂ ಕಾಲಭೈರವಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 10. ಪುಷ್ಯ ಮಾಸ (Pushya)
    if (masa == 'ಪುಷ್ಯ') {
      if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಪುತ್ರದಾ ಏಕಾದಶಿ', description: 'ಪುತ್ರಸಂತಾನಕ್ಕಾಗಿ ಏಕಾದಶಿ.', shloka: 'ಪುಷ್ಯೇ ಶುಕ್ಲಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ಪುತ್ರದಾ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಪುಷ್ಯ ಪೌರ್ಣಿಮೆ', description: 'ದೇವಿ ಆರಾಧನೆಗೆ ಶ್ರೇಷ್ಠ.', shloka: 'ಪುಷ್ಯೇ ಪೌರ್ಣಮಾಸ್ಯಾಂ ತು ಸ್ನಾನಂ ಪುಣ್ಯಫಲಪ್ರದಮ್ |', source: 'ಸಾಮಾನ್ಯ ನಿಯಮ'));
      } else if (tIdx == 18) {
        events.add(AstroEvent(name: 'ತಿಲ ಚತುರ್ಥಿ', description: 'ಎಳ್ಳಿನೊಂದಿಗೆ ಗಣೇಶ ಪೂಜೆ.', shloka: 'ಪುಷ್ಯೇ ಕೃಷ್ಣಪಕ್ಷೇ ಚತುರ್ಥ್ಯಾಂ ತಿಲೈರ್ಯಜೇತ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 29) {
        events.add(AstroEvent(name: 'ಮೌನ ಅಮಾವಾಸ್ಯೆ', description: 'ಮೌನ ವ್ರತ ಮತ್ತು ಪಿತೃತರ್ಪಣ.', shloka: 'ಪುಷ್ಯೇ ಅಮಾವಾಸ್ಯಾಯಾಂ ಮೌನವ್ರತಂ ವಿಶೇಷತಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 11. ಮಾಘ ಮಾಸ (Magha)
    if (masa == 'ಮಾಘ') {
      if (tIdx == 4) {
        events.add(AstroEvent(name: 'ವಸಂತ ಪಂಚಮಿ (ಶ್ರೀ ಪಂಚಮಿ)', description: 'ಸರಸ್ವತಿ ಆರಾಧನೆ. ಹಳದಿ ವಸ್ತ್ರ ಧಾರಣೆ.', shloka: 'ಮಾಘ ಶುಕ್ಲ ಪಂಚಮ್ಯಾಂ ಶ್ರೀಪಂಚಮೀ ವ್ರತಮಾಚರೇತ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 6) {
        events.add(AstroEvent(name: 'ರಥ ಸಪ್ತಮಿ', description: 'ಸೂರ್ಯ ದೇವನ ಆರಾಧನೆ. ಎಕ್ಕೆ ಎಲೆ ಸ್ನಾನ. ಮಾಘ ಸ್ನಾನ ಸಮಾಪ್ತಿ.', shloka: 'ರಥಸ್ಥಂ ರಥಸಪ್ತಮ್ಯಾಂ ತ್ವಾಂ ದೃಷ್ಟ್ವಾ ಯಾದವಪ್ರಭೋ |', source: 'ಆದಿತ್ಯ ಹೃದಯ'));
      } else if (tIdx == 7) {
        events.add(AstroEvent(name: 'ಭೀಷ್ಮ ಅಷ್ಟಮಿ', description: 'ಭೀಷ್ಮಾಚಾರ್ಯರ ಸ್ಮರಣೆ.', shloka: 'ಮಾಘೇ ಶುಕ್ಲೇ ಅಷ್ಟಮ್ಯಾಂ ಭೀಷ್ಮ ನಿರ್ವಾಣಮ್ |', source: 'ಮಹಾಭಾರತ'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಭೀಷ್ಮ ಏಕಾದಶಿ / ಜಯಾ ಏಕಾದಶಿ', description: 'ವಿಷ್ಣುಸಹಸ್ರನಾಮ ಉಪದೇಶಿಸಿದ ದಿನ.', shloka: 'ಮಾಘಮಾಸೇ ಸಿತೇ ಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ಮಹಾಮತಿಃ |', source: 'ಮಹಾಭಾರತ'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಮಾಘ ಪೌರ್ಣಿಮೆ', description: 'ಮಾಘ ಸ್ನಾನ ಪ್ರಶಸ್ತ. ದಾನ-ಪುಣ್ಯ.', shloka: 'ಮಾಘೇ ಪೌರ್ಣಮಾಸ್ಯಾಂ ಸ್ನಾನಂ ಪುಣ್ಯಫಲಪ್ರದಮ್ |', source: 'ಪದ್ಮ ಪುರಾಣ'));
      } else if (tIdx == 28) {
        events.add(AstroEvent(name: 'ಮಹಾ ಶಿವರಾತ್ರಿ', description: 'ಶಿವನ ಆರಾಧನೆ. ಉಪವಾಸ ಮತ್ತು ಜಾಗರಣೆ. ನಿಶೀಥ ಕಾಲದಲ್ಲಿ (ಮಧ್ಯರಾತ್ರಿ) ಚತುರ್ದಶಿ ಇರಬೇಕು.', shloka: 'ಮಾಘ ಕೃಷ್ಣ ಚತುರ್ದಶ್ಯಾಂ ಆದಿದೇವೋ ಮಹಾನಿಶಿ |', source: 'ಈಶಾನ ಸಂಹಿತೆ'));
      } else if (tIdx == 29) {
        events.add(AstroEvent(name: 'ಮೌನಿ ಅಮಾವಾಸ್ಯೆ / ಮಾಘ ಅಮಾವಾಸ್ಯೆ', description: 'ಮೌನ ವ್ರತ. ಸಂಗಮ ಸ್ನಾನ. ಪಿತೃ ತರ್ಪಣ.', shloka: 'ಮಾಘೇ ಅಮಾವಾಸ್ಯಾಯಾಂ ಮೌನವ್ರತಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 12. ಫಾಲ್ಗುಣ ಮಾಸ (Phalguna)
    if (masa == 'ಫಾಲ್ಗುಣ') {
      if (tIdx == 3) {
        events.add(AstroEvent(name: 'ಗಣೇಶ ಜಯಂತಿ', description: 'ಗಣೇಶನ ಜನ್ಮದಿನ.', shloka: 'ಫಾಲ್ಗುಣೇ ಶುಕ್ಲಪಕ್ಷೇ ಚತುರ್ಥ್ಯಾಂ ಗಣೇಶಜನ್ಮ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಆಮಲಕೀ ಏಕಾದಶಿ', description: 'ನೆಲ್ಲಿ ವೃಕ್ಷ ಪೂಜೆ.', shloka: 'ಫಾಲ್ಗುಣೇ ಶುಕ್ಲಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ಆಮಲಕೀ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಹೋಳಿ ಹುಣ್ಣಿಮೆ / ಕಾಮ ದಹನ', description: 'ಬಣ್ಣಗಳ ಹಬ್ಬ. ಹೋಲಿಕಾ ದಹನ.', shloka: 'ಫಾಲ್ಗುಣೇ ಪೌರ್ಣಮಾಸ್ಯಾಂ ತು ಹೋಲಿಕಾ ದಹನಂ ಸ್ಮೃತಮ್ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      }
    }

    // ═══ General Monthly Events ═══

    // ಏಕಾದಶಿ (both pakshas)
    if (tIdx == 10 || tIdx == 25) {
      events.add(AstroEvent(name: 'ಏಕಾದಶಿ ವ್ರತ', description: 'ಮಹಾವಿಷ್ಣುವಿನ ಆರಾಧನೆಗಾಗಿ ಉಪವಾಸ.', shloka: 'ಏಕಾದಶ್ಯಾಂ ನ ಭುಂಜೀತ ಪಕ್ಷಯೋರುಭಯೋರಪಿ |', source: 'ವೈಷ್ಣವ ಸಂಪ್ರದಾಯ'));
    }

    // ಪ್ರದೋಷ (both pakshas) — Trayodashi must prevail at SUNSET (Sandhya Kala)
    // Rule: If Trayodashi tithi is running at sunset time, it is Pradosha
    final pradoshaTithi = sunsetTithiIdx ?? tIdx; // fallback to sunrise if sunset not provided
    if (pradoshaTithi == 12 || pradoshaTithi == 27) {
      events.add(AstroEvent(name: 'ಪ್ರದೋಷ ವ್ರತ', description: 'ಶಿವನ ಆರಾಧನೆ ಸರ್ವ ಪಾಪ ನಾಶಕ. ಸಂಧ್ಯಾ ಕಾಲದಲ್ಲಿ (ಸೂರ್ಯಾಸ್ತ ಸಮಯ) ತ್ರಯೋದಶಿ ಇರಬೇಕು.', shloka: 'ತ್ರಯೋದಶ್ಯಾಂ ನಿಶಾಮುಖೇ ಪ್ರದೋಷಸಮಯೇ ಹರಮ್ |', source: 'ಸ್ಕಂದ ಪುರಾಣ'));
    }

    // ಸಂಕಷ್ಟಹರ ಚತುರ್ಥಿ (Krishna Chaturthi)
    if (tIdx == 18) {
      events.add(AstroEvent(name: 'ಸಂಕಷ್ಟಹರ ಚತುರ್ಥಿ', description: 'ವಿಘ್ನೇಶ್ವರನ ಚಂದ್ರೋದಯ ಪೂಜೆ. ಉಪವಾಸ ಮತ್ತು ಚಂದ್ರ ದರ್ಶನ.', shloka: 'ಕೃಷ್ಣಪಕ್ಷೇ ಚತುರ್ಥ್ಯಾಂ ತು ಸಂಪೂಜ್ಯ ಗಣನಾಯಕಮ್ |', source: 'ಗಣೇಶ ಪುರಾಣ'));
    }

    // ವಿನಾಯಕ ಚತುರ್ಥಿ (Shukla Chaturthi — every month)
    if (tIdx == 3) {
      events.add(AstroEvent(name: 'ವಿನಾಯಕ ಚತುರ್ಥಿ', description: 'ಪ್ರತಿ ಮಾಸ ಶುಕ್ಲ ಚತುರ್ಥಿ. ಗಣಪತಿ ಪೂಜೆ.', shloka: 'ಶುಕ್ಲಪಕ್ಷೇ ಚತುರ್ಥ್ಯಾಂ ತು ವಿನಾಯಕಂ ಸಮರ್ಚಯೇತ್ |', source: 'ಗಣೇಶ ಪುರಾಣ'));
    }

    // ಮಾಸ ಶಿವರಾತ್ರಿ (Krishna Chaturdashi — every month)
    if (tIdx == 28) {
      events.add(AstroEvent(name: 'ಮಾಸ ಶಿವರಾತ್ರಿ', description: 'ಪ್ರತಿ ಮಾಸ ಕೃಷ್ಣ ಚತುರ್ದಶಿ. ಶಿವ ಪೂಜೆ ಮತ್ತು ಜಾಗರಣೆ.', shloka: 'ಕೃಷ್ಣಪಕ್ಷೇ ಚತುರ್ದಶ್ಯಾಂ ಶಿವರಾತ್ರಿವ್ರತಂ ಚರೇತ್ |', source: 'ಶಿವ ಪುರಾಣ'));
    }

    // ಹುಣ್ಣಿಮೆ / ಅಮಾವಾಸ್ಯೆ
    if (tIdx == 14) {
      events.add(AstroEvent(name: 'ಹುಣ್ಣಿಮೆ (ಪೌರ್ಣಿಮೆ)', description: 'ಸತ್ಯನಾರಾಯಣ ಪೂಜೆಗೆ ಪ್ರಶಸ್ತ. ಪೌರ್ಣಮಿ ವ್ರತ.', shloka: 'ಪೌರ್ಣಮಾಸ್ಯಾಂ ಚ ಸಂಪೂಜ್ಯ ದೇವಂ ನಾರಾಯಣಂ ಪ್ರಭುಮ್ |', source: 'ಸ್ಕಂದ ಪುರಾಣ'));
    } else if (tIdx == 29) {
      events.add(AstroEvent(name: 'ಅಮಾವಾಸ್ಯೆ', description: 'ಪಿತೃ ತರ್ಪಣಕ್ಕೆ ಶ್ರೇಷ್ಠ ದಿನ.', shloka: 'ಅಮಾವಾಸ್ಯಾಯಾಂ ಪಿತೃಭ್ಯೋ ದದ್ಯಾಚ್ಚ ತಿಲತರ್ಪಣಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
    }

    return events;
  }

  /// Map i18n masa key (cm0-cm11) to Kannada masa name for event lookup
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
