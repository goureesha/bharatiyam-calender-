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
  /// tIdx: 0-29 (0=Shukla Pratipada...14=Pournami...29=Amavasya)
  /// isAdhika: true if Adhika Masa — all events are skipped
  static List<AstroEvent> getEvents({
    required String masa,
    required int tIdx,
    bool isAdhika = false,
  }) {
    final List<AstroEvent> events = [];
    if (isAdhika) return events;

    // 1. ಚೈತ್ರ ಮಾಸ (Chaitra)
    if (masa == 'ಚೈತ್ರ') {
      if (tIdx == 0) {
        events.add(AstroEvent(name: 'ಯುಗಾದಿ ಹಬ್ಬ (ಚಾಂದ್ರಮಾನ)', description: 'ಹೊಸ ವರ್ಷದ ಆರಂಭ. ಬೇವು-ಬೆಲ್ಲ ಸೇವನೆ ವಿಶೇಷ.', shloka: 'ಶತಾಯುರ್ವಜ್ರದೇಹತ್ವಾತ್ ಸರ್ವಸಂಪತ್ಕರಂ ಪರಮ್ |', meaning: 'ಚೈತ್ರ ಶುಕ್ಲ ಪ್ರತಿಪದೆ', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 2) {
        events.add(AstroEvent(name: 'ಗೌರೀ ತೃತೀಯಾ (ಸೌಭಾಗ್ಯ ಗೌರೀ ವ್ರತ)', description: 'ಪಾರ್ವತೀ ದೇವಿಯ ಆರಾಧನೆ.', shloka: 'ಚೈತ್ರೇ ಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ತೃತೀಯಾಯಾಂ ಸಮಾಹಿತಾ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 5) {
        events.add(AstroEvent(name: 'ಸ್ಕಂದ ಷಷ್ಠಿ', description: 'ಕಾರ್ತಿಕೇಯ ಸ್ವಾಮಿಯ ಆರಾಧನೆ.', shloka: 'ಚೈತ್ರೇ ಶುಕ್ಲೇ ಷಷ್ಠ್ಯಾಂ ತು ಸ್ಕಂದಂ ಸಂಪೂಜ್ಯ ಯತ್ನತಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 8) {
        events.add(AstroEvent(name: 'ಶ್ರೀರಾಮ ನವಮಿ', description: 'ಶ್ರೀರಾಮಚಂದ್ರನ ಜನ್ಮದಿನ.', shloka: 'ಚೈತ್ರೇ ನವಮ್ಯಾಂ ಪ್ರಾಕ್ಪಕ್ಷೇ ದಿವಾ ಪುಣ್ಯೇ ಪುನರ್ವಸೌ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಹನುಮಜ್ಜಯಂತಿ / ಚಿತ್ರಾ ಪೌರ್ಣಿಮೆ', description: 'ಹನುಮಂತನ ಅವತಾರ ದಿನ.', shloka: 'ಚೈತ್ರೇಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ಪೌರ್ಣಮಾಸ್ಯಾಂ ಕುಜೇಽಹನಿ |', source: 'ಆಗಮ ಗ್ರಂಥಗಳು'));
      } else if (tIdx == 27) {
        events.add(AstroEvent(name: 'ಅನಂಗ ತ್ರಯೋದಶೀ', description: 'ಕಾಮದೇವನ ಆರಾಧನೆ.', shloka: 'ಚೈತ್ರೇ ಕೃಷ್ಣತ್ರಯೋದಶ್ಯಾಂ ಅನಂಗಂ ಪೂಜಯೇತ್ ಸದಾ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 2. ವೈಶಾಖ ಮಾಸ (Vaishakha)
    if (masa == 'ವೈಶಾಖ') {
      if (tIdx == 2) {
        events.add(AstroEvent(name: 'ಅಕ್ಷಯ ತೃತೀಯಾ', description: 'ಅತ್ಯಂತ ಶುಭದಿನ. ದಾನ, ಜಪಗಳು ಅಕ್ಷಯ ಫಲ ನೀಡುತ್ತವೆ.', shloka: 'ವೈಶಾಖಸ್ಯ ಸಿತೇ ಪಕ್ಷೇ ತೃತೀಯಾಯಾಮುಪೋಷಿತಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 6) {
        events.add(AstroEvent(name: 'ಗಂಗೋತ್ಪತ್ತಿ / ಜಹ್ನು ಸಪ್ತಮಿ', description: 'ಗಂಗಾದೇವಿಯ ಅವತರಣ ದಿನ.', shloka: 'ವೈಶಾಖೇ ಶುಕ್ಲಸಪ್ತಮ್ಯಾಂ ಗಂಗಾ ಸಾಗರಮಾಗತಾ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಮೋಹಿನೀ ಏಕಾದಶಿ', description: 'ಮೋಹಿನೀ ಅವತಾರದ ಸ್ಮರಣೆ.', shloka: 'ವೈಶಾಖಸ್ಯ ಸಿತೇ ಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ನಿರಾಮಿಷಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 13) {
        events.add(AstroEvent(name: 'ಶ್ರೀ ನರಸಿಂಹ ಜಯಂತಿ', description: 'ನರಸಿಂಹನ ಅವತಾರ ದಿನ.', shloka: 'ವೈಶಾಖಸ್ಯ ಸಿತೇ ಪಕ್ಷೇ ಚತುರ್ದಶ್ಯಾಂ ಮಧುಸೂದನಃ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಬುದ್ಧ ಪೌರ್ಣಿಮೆ / ಕೂರ್ಮ ಜಯಂತಿ', description: 'ಬುದ್ಧ ಮತ್ತು ಕೂರ್ಮಾವತಾರದ ಜನ್ಮದಿನ.', shloka: 'ವೈಶಾಖೇ ಪೌರ್ಣಮಾಸ್ಯಾಂ ತು ಕೂರ್ಮರೂಪೀ ಜನಾರ್ದನಃ |', source: 'ಪುರಾಣೋಕ್ತ'));
      }
    }

    // 3. ಜ್ಯೇಷ್ಠ ಮಾಸ (Jyeshtha)
    if (masa == 'ಜ್ಯೇಷ್ಠ') {
      if (tIdx == 10) {
        events.add(AstroEvent(name: 'ನಿರ್ಜಲಾ ಏಕಾದಶಿ', description: '೨೪ ಏಕಾದಶಿಗಳ ಫಲ ನೀಡುವ ಕಠಿಣ ವ್ರತ.', shloka: 'ಜ್ಯೇಷ್ಠೇ ಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ನಿರಂಬುಕಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ವಟ ಸಾವಿತ್ರಿ ವ್ರತ', description: 'ಪತಿಯ ದೀರ್ಘಾಯುಷ್ಯಕ್ಕಾಗಿ ವ್ರತ.', shloka: 'ಜ್ಯೇಷ್ಟೇ ಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ಪೌರ್ಣಮಾಸ್ಯಾಂ ವಿಶೇಷತಃ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
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
      if (tIdx == 4) {
        events.add(AstroEvent(name: 'ನಾಗ ಪಂಚಮಿ', description: 'ನಾಗ ದೇವತೆಗಳ ಆರಾಧನೆ.', shloka: 'ಶ್ರಾವಣೇ ಶುಕ್ಲಪಂಚಮ್ಯಾಂ ಸ್ನಾತ್ವಾ ನಾಗಾನ್ ಪ್ರಪೂಜಯೇತ್ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಉಪಾಕರ್ಮ / ರಕ್ಷಾ ಬಂಧನ', description: 'ನೂತನ ಯಜ್ಞೋಪವೀತ ಧಾರಣೆ. ಸಹೋದರ ಪ್ರೇಮ.', shloka: 'ಯೇನ ಬದ್ಧೋ ಬಲೀ ರಾಜಾ ದಾನವೇಂದ್ರೋ ಮಹಾಬಲಃ |', source: 'ಭವಿಷ್ಯ ಪುರಾಣ'));
      } else if (tIdx == 17) {
        events.add(AstroEvent(name: 'ಕಜ್ಜಾಯ ತದಿಗೆ', description: 'ಕಜ್ಜಾಯ ತಯಾರಿಸಿ ದೇವತೆಗಳಿಗೆ ಅರ್ಪಿಸುವ ಆಚರಣೆ.', shloka: 'ಶ್ರಾವಣೇ ಕೃಷ್ಣಪಕ್ಷೇ ತು ತೃತೀಯಾಯಾಂ ವಿಶೇಷತಃ |', source: 'ಆಚಾರ ಪರಂಪರೆ'));
      } else if (tIdx == 22) {
        events.add(AstroEvent(name: 'ಶ್ರೀ ಕೃಷ್ಣ ಜನ್ಮಾಷ್ಟಮಿ', description: 'ಭಗವಾನ್ ಶ್ರೀಕೃಷ್ಣನ ಅವತಾರ ದಿನ.', shloka: 'ಶ್ರಾವಣೇ ಬಹುಳೇಽಷ್ಟಮ್ಯಾಂ ರೋಹಿಣ್ಯಾಮರ್ಧರಾತ್ರಕೇ |', source: 'ಧರ್ಮಸಿಂಧು'));
      }
    }

    // 6. ಭಾದ್ರಪದ ಮಾಸ (Bhadrapada)
    if (masa == 'ಭಾದ್ರಪದ') {
      if (tIdx == 2) {
        events.add(AstroEvent(name: 'ಸ್ವರ್ಣಗೌರಿ ವ್ರತ', description: 'ಸೌಭಾಗ್ಯಕ್ಕಾಗಿ ಪಾರ್ವತಿ ವ್ರತ.', shloka: 'ಭಾದ್ರೇ ಮಾಸಿ ಸಿತೇ ಪಕ್ಷೇ ತೃತೀಯಾಯಾಂ ಸುಶೋಭನೇ |', source: 'ವ್ರತ ರತ್ನಾವಳಿ'));
      } else if (tIdx == 3) {
        events.add(AstroEvent(name: 'ಗಣೇಶ ಚತುರ್ಥಿ', description: 'ಮಹಾಗಣಪತಿಯ ಅವತಾರ ದಿನ.', shloka: 'ಭಾದ್ರಶುಕ್ಲಚತುರ್ಥ್ಯಾಂ ತು ಯನ್ಮಹಾಗಣಪತೇರ್ದಿನಮ್ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 4) {
        events.add(AstroEvent(name: 'ಋಷಿ ಪಂಚಮಿ', description: 'ಸಪ್ತ ಋಷಿಗಳ ಆರಾಧನೆ.', shloka: 'ಭಾದ್ರೇ ಶುಕ್ಲೇ ಪಂಚಮ್ಯಾಂ ತು ಸಪ್ತರ್ಷೀನ್ ಪೂಜಯೇತ್ ಸದಾ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 13) {
        events.add(AstroEvent(name: 'ಅನಂತ ಚತುರ್ದಶಿ (ಗಣೇಶ ವಿಸರ್ಜನ)', description: 'ಗಣೇಶ ವಿಸರ್ಜನೆ.', shloka: 'ಭಾದ್ರಪದ ಶುಕ್ಲ ಚತುರ್ದಶ್ಯಾಂ ಅನಂತವ್ರತಮಾಚರೇತ್ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಮಹಾಲಯಾರಂಭ', description: 'ಪಿತೃಪಕ್ಷದ ಆರಂಭ.', shloka: 'ಭಾದ್ರಪದ ಶುಕ್ಲ ಚತುರ್ದಶ್ಯಾಂ ಅನಂತವ್ರತಮಾಚರೇತ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 29) {
        events.add(AstroEvent(name: 'ಮಹಾಲಯ ಅಮಾವಾಸ್ಯೆ', description: 'ಸರ್ವ ಪಿತೃಗಳಿಗೂ ತರ್ಪಣ.', shloka: 'ಆಯುಃ ಪ್ರಜಾಂ ಧನಂ ವಿದ್ಯಾಂ ಸ್ವರ್ಗಂ ಮೋಕ್ಷಂ ಸುಖಾನಿ ಚ |', source: 'ಯಾಜ್ಞವಲ್ಕ್ಯ ಸ್ಮೃತಿ'));
      }
    }

    // 7. ಆಶ್ವಿನ ಮಾಸ (Ashwina)
    if (masa == 'ಆಶ್ವಿನ') {
      if (tIdx == 0) {
        events.add(AstroEvent(name: 'ಶರನ್ನವರಾತ್ರಿ ಆರಂಭ / ಘಟಸ್ಥಾಪನೆ', description: '೯ ದಿನಗಳ ದೇವಿ ಆರಾಧನೆ.', shloka: 'ಜಯಂತೀ ಮಂಗಲಾ ಕಾಳೀ ಭದ್ರಕಾಲೀ ಕಪಾಲಿನೀ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 4) {
        events.add(AstroEvent(name: 'ಲಲಿತಾ ಪಂಚಮಿ', description: 'ನವರಾತ್ರಿ ಐದನೆಯ ದಿನ.', shloka: 'ಪಂಚಮ್ಯಾಂ ಲಲಿತಾಂ ದೇವೀಂ ಪೂಜಯೇತ್ ಸರ್ವಸಿದ್ಧಿದಾಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 6) {
        events.add(AstroEvent(name: 'ಸರಸ್ವತೀ ಪೂಜೆ / ಸರಸ್ವತ್ಯಾವಾಹನ', description: 'ವಿದ್ಯಾದೇವತೆ ಸರಸ್ವತಿ ಪೂಜೆ.', shloka: 'ಮೂಲೇ ಪುಸ್ತಸ್ಥಾಪನಂ ದೇವ್ಯಾಃ ಪೂರ್ವಾಷಾಢಾಸು ಪೂಜನಮ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 7) {
        events.add(AstroEvent(name: 'ದುರ್ಗಾಷ್ಟಮೀ / ಮಹಾಷ್ಟಮೀ', description: 'ದುರ್ಗಾ ದೇವಿ ವಿಶೇಷ ಪೂಜೆ.', shloka: 'ಅಷ್ಟಮ್ಯಾಂ ಪೂಜಯೇದ್ದುರ್ಗಾಂ ಸರ್ವಮಂಗಲ ಮಾಂಗಲ್ಯೇ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 8) {
        events.add(AstroEvent(name: 'ಮಹಾನವಮಿ / ಆಯುಧ ಪೂಜೆ', description: 'ಆಯುಧ, ವಾಹನ, ಯಂತ್ರಗಳ ಪೂಜೆ.', shloka: 'ನವಮ್ಯಾಂ ಪೂಜಯೇದ್ದೇವಿಂ ಮಂತ್ರತಂತ್ರವಿಶಾರದಃ |', source: 'ದುರ್ಗಾ ಸಪ್ತಶತೀ'));
      } else if (tIdx == 9) {
        events.add(AstroEvent(name: 'ವಿಜಯದಶಮಿ (ದಸರಾ)', description: 'ಬನ್ನಿ ಮರಕ್ಕೆ ಪೂಜೆ. ಸೀಮೋಲ್ಲಂಘನ.', shloka: 'ಶಮೀ ಶಮಯತೇ ಪಾಪಂ ಶಮೀ ಶತ್ರುವಿನಾಶಿನೀ |', source: 'ಪರಂಪರಾಗತ ಶ್ಲೋಕ'));
      } else if (tIdx == 28) {
        events.add(AstroEvent(name: 'ನರಕ ಚತುರ್ದಶಿ', description: 'ನರಕಾಸುರ ಸಂಹಾರ. ಅಭ್ಯಂಜನ ಸ್ನಾನ.', shloka: 'ಆಶ್ವಿನೇ ಕೃಷ್ಣಪಕ್ಷೇ ತು ಚತುರ್ದಶ್ಯಾಂ ವಿಧೂದಯೇ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 29) {
        events.add(AstroEvent(name: 'ದೀಪಾವಳಿ / ಲಕ್ಷ್ಮಿ ಪೂಜೆ', description: 'ಮಹಾಲಕ್ಷ್ಮಿಯ ಆರಾಧನೆ. ದೀಪ ಬೆಳಗಿಸುವ ಹಬ್ಬ.', shloka: 'ನಮಸ್ತೇಽಸ್ತು ಮಹಾಮಾಯೇ ಶ್ರೀಪೀಠೇ ಸುರಪೂಜಿತೇ |', source: 'ಮಹಾಲಕ್ಷ್ಮ್ಯಷ್ಟಕ'));
      }
    }

    // 8. ಕಾರ್ತಿಕ ಮಾಸ (Kartika)
    if (masa == 'ಕಾರ್ತಿಕ') {
      if (tIdx == 0) {
        events.add(AstroEvent(name: 'ಬಲಿ ಪಾಡ್ಯಮಿ', description: 'ಬಲೀಂದ್ರ ಪೂಜೆ ಮತ್ತು ಗೋಪೂಜೆ.', shloka: 'ಬಲಿರಾಜ ನಮಸ್ತುಭ್ಯಂ ವಿರೋಚನಸುತ ಪ್ರಭೋ |', source: 'ನಿರ್ಣಯಸಿಂಧು'));
      } else if (tIdx == 1) {
        events.add(AstroEvent(name: 'ಯಮ ದ್ವಿತೀಯಾ (ಭಾತೃ ದ್ವಿತೀಯಾ)', description: 'ಸಹೋದರ ಬಾಂಧವ್ಯದ ಹಬ್ಬ.', shloka: 'ಕಾರ್ತಿಕೇ ಶುಕ್ಲಪಕ್ಷೇ ತು ದ್ವಿತೀಯಾಯಾಂ ವಿಶೇಷತಃ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 11) {
        events.add(AstroEvent(name: 'ಉತ್ಥಾನ ದ್ವಾದಶಿ / ತುಳಸಿ ವಿವಾಹ', description: 'ಚಾತುರ್ಮಾಸ್ಯ ಸಮಾಪ್ತಿ. ತುಳಸೀ ವಿವಾಹ.', shloka: 'ಉತ್ತಿಷ್ಠೋತ್ತಿಷ್ಠ ಗೋವಿಂದ ತ್ಯಜ ನಿದ್ರಾಂ ಜಗತ್ಪತೇ |', source: 'ಪದ್ಮ ಪುರಾಣ'));
      } else if (tIdx == 14) {
        events.add(AstroEvent(name: 'ಕಾರ್ತಿಕ ಪೌರ್ಣಿಮೆ / ಜ್ವಾಲಾತೋರಣ', description: 'ಶಿವನಿಗೆ ದೀಪೋತ್ಸವ.', shloka: 'ಕಾರ್ತಿಕ್ಯಾಂ ಪೌರ್ಣಮಾಸ್ಯಾಂ ತು ಕೃತ್ತಿಕಾಂ ಶಿವದರ್ಶನಮ್ |', source: 'ಸ್ಕಂದ ಪುರಾಣ'));
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
        events.add(AstroEvent(name: 'ವಸಂತ ಪಂಚಮಿ (ಶ್ರೀ ಪಂಚಮಿ)', description: 'ಸರಸ್ವತಿಯ ಆರಾಧನೆ.', shloka: 'ಮಾಘ ಶುಕ್ಲ ಪಂಚಮ್ಯಾಂ ಶ್ರೀಪಂಚಮೀ ವ್ರತಮಾಚರೇತ್ |', source: 'ಧರ್ಮಸಿಂಧು'));
      } else if (tIdx == 6) {
        events.add(AstroEvent(name: 'ರಥ ಸಪ್ತಮಿ', description: 'ಸೂರ್ಯ ದೇವನ ಆರಾಧನೆ.', shloka: 'ರಥಸ್ಥಂ ರಥಸಪ್ತಮ್ಯಾಂ ತ್ವಾಂ ದೃಷ್ಟ್ವಾ ಯಾದವಪ್ರಭೋ |', source: 'ಆದಿತ್ಯ ಹೃದಯ'));
      } else if (tIdx == 10) {
        events.add(AstroEvent(name: 'ಭೀಷ್ಮ ಏಕಾದಶಿ', description: 'ವಿಷ್ಣುಸಹಸ್ರನಾಮ ಉಪದೇಶಿಸಿದ ದಿನ.', shloka: 'ಮಾಘಮಾಸೇ ಸಿತೇ ಪಕ್ಷೇ ಏಕಾದಶ್ಯಾಂ ಮಹಾಮತಿಃ |', source: 'ಮಹಾಭಾರತ'));
      } else if (tIdx == 28 || tIdx == 27) {
        events.add(AstroEvent(name: 'ಮಹಾ ಶಿವರಾತ್ರಿ', description: 'ಶಿವನ ಆರಾಧನೆ. ಉಪವಾಸ ಮತ್ತು ಜಾಗರಣೆ.', shloka: 'ಮಾಘ ಕೃಷ್ಣ ಚತುರ್ದಶ್ಯಾಂ ಆದಿದೇವೋ ಮಹಾನಿಶಿ |', source: 'ಈಶಾನ ಸಂಹಿತೆ'));
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

    // ಪ್ರದೋಷ (both pakshas)
    if (tIdx == 12 || tIdx == 27) {
      events.add(AstroEvent(name: 'ಪ್ರದೋಷ ವ್ರತ', description: 'ಶಿವನ ಆರಾಧನೆ ಸರ್ವ ಪಾಪ ನಾಶಕ.', shloka: 'ತ್ರಯೋದಶ್ಯಾಂ ನಿಶಾಮುಖೇ ಪ್ರದೋಷಸಮಯೇ ಹರಮ್ |', source: 'ಸ್ಕಂದ ಪುರಾಣ'));
    }

    // ಸಂಕಷ್ಟಹರ ಚತುರ್ಥಿ (Krishna Chaturthi)
    if (tIdx == 18) {
      events.add(AstroEvent(name: 'ಸಂಕಷ್ಟಹರ ಚತುರ್ಥಿ', description: 'ವಿಘ್ನೇಶ್ವರನ ಚಂದ್ರೋದಯ ಪೂಜೆ.', shloka: 'ಕೃಷ್ಣಪಕ್ಷೇ ಚತುರ್ಥ್ಯಾಂ ತು ಸಂಪೂಜ್ಯ ಗಣನಾಯಕಮ್ |', source: 'ಗಣೇಶ ಪುರಾಣ'));
    }

    // ಹುಣ್ಣಿಮೆ / ಅಮಾವಾಸ್ಯೆ
    if (tIdx == 14) {
      events.add(AstroEvent(name: 'ಹುಣ್ಣಿಮೆ (ಪೌರ್ಣಿಮೆ)', description: 'ಸತ್ಯನಾರಾಯಣ ಪೂಜೆಗೆ ಪ್ರಶಸ್ತ.', shloka: 'ಪೌರ್ಣಮಾಸ್ಯಾಂ ಚ ಸಂಪೂಜ್ಯ ದೇವಂ ನಾರಾಯಣಂ ಪ್ರಭುಮ್ |', source: 'ಸ್ಕಂದ ಪುರಾಣ'));
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
