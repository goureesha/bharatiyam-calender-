/// Comprehensive offline place database for Bharatiyam Panchanga.
/// Karnataka Taluks + Major Indian cities + World capitals + World cities JSON.
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CityData {
  final String name;
  final String nameKn;
  final String state;
  final double lat;
  final double lon;
  final double tzOffset;

  const CityData({
    required this.name,
    required this.nameKn,
    required this.state,
    required this.lat,
    required this.lon,
    this.tzOffset = 5.5,
  });
}

// ══════════════════════════════════════════════════════════════
//  KARNATAKA TALUKS (All 31 districts, ~170 places)
// ══════════════════════════════════════════════════════════════

const List<CityData> karnatakaCities = [
  // ─── Bagalkot District ───
  CityData(name: 'Bagalkot', nameKn: 'ಬಾಗಲಕೋಟ', state: 'KA', lat: 16.18, lon: 75.70),
  CityData(name: 'Badami', nameKn: 'ಬಾದಾಮಿ', state: 'KA', lat: 15.92, lon: 75.68),
  CityData(name: 'Bilagi', nameKn: 'ಬೀಳಗಿ', state: 'KA', lat: 16.35, lon: 75.62),
  CityData(name: 'Hungund', nameKn: 'ಹುನಗುಂದ', state: 'KA', lat: 16.06, lon: 76.06),
  CityData(name: 'Jamkhandi', nameKn: 'ಜಮಖಂಡಿ', state: 'KA', lat: 16.50, lon: 75.29),
  CityData(name: 'Mudhol', nameKn: 'ಮುಧೋಳ', state: 'KA', lat: 16.33, lon: 75.28),

  // ─── Bangalore Urban ───
  CityData(name: 'Bangalore North', nameKn: 'ಬೆಂಗಳೂರು ಉತ್ತರ', state: 'KA', lat: 13.02, lon: 77.59),
  CityData(name: 'Bangalore South', nameKn: 'ಬೆಂಗಳೂರು ದಕ್ಷಿಣ', state: 'KA', lat: 12.90, lon: 77.58),
  CityData(name: 'Anekal', nameKn: 'ಅನೆಕಲ್', state: 'KA', lat: 12.71, lon: 77.70),

  // ─── Bangalore Rural ───
  CityData(name: 'Devanahalli', nameKn: 'ದೇವನಹಳ್ಳಿ', state: 'KA', lat: 13.25, lon: 77.71),
  CityData(name: 'Doddaballapur', nameKn: 'ದೊಡ್ಡಬಳ್ಳಾಪುರ', state: 'KA', lat: 13.29, lon: 77.54),
  CityData(name: 'Hoskote', nameKn: 'ಹೊಸಕೋಟೆ', state: 'KA', lat: 13.07, lon: 77.80),
  CityData(name: 'Nelamangala', nameKn: 'ನೆಲಮಂಗಲ', state: 'KA', lat: 13.10, lon: 77.39),

  // ─── Belagavi (Belgaum) District ───
  CityData(name: 'Belagavi', nameKn: 'ಬೆಳಗಾವಿ', state: 'KA', lat: 15.85, lon: 74.50),
  CityData(name: 'Athani', nameKn: 'ಅಥಣಿ', state: 'KA', lat: 16.72, lon: 75.06),
  CityData(name: 'Bailhongal', nameKn: 'ಬೈಲಹೊಂಗಲ', state: 'KA', lat: 15.81, lon: 74.86),
  CityData(name: 'Chikkodi', nameKn: 'ಚಿಕ್ಕೋಡಿ', state: 'KA', lat: 16.43, lon: 74.59),
  CityData(name: 'Gokak', nameKn: 'ಗೋಕಾಕ', state: 'KA', lat: 16.17, lon: 74.82),
  CityData(name: 'Hukkeri', nameKn: 'ಹುಕ್ಕೇರಿ', state: 'KA', lat: 16.23, lon: 74.60),
  CityData(name: 'Khanapur', nameKn: 'ಖಾನಾಪುರ', state: 'KA', lat: 15.64, lon: 74.51),
  CityData(name: 'Ramdurg', nameKn: 'ರಾಮದುರ್ಗ', state: 'KA', lat: 15.95, lon: 75.29),
  CityData(name: 'Raybag', nameKn: 'ರಾಯಬಾಗ', state: 'KA', lat: 16.49, lon: 74.77),
  CityData(name: 'Savadatti', nameKn: 'ಸವದತ್ತಿ', state: 'KA', lat: 15.77, lon: 75.34),

  // ─── Bellary District ───
  CityData(name: 'Bellary', nameKn: 'ಬಳ್ಳಾರಿ', state: 'KA', lat: 15.14, lon: 76.92),
  CityData(name: 'Hospet', nameKn: 'ಹೊಸಪೇಟೆ', state: 'KA', lat: 15.27, lon: 76.39),
  CityData(name: 'Kudligi', nameKn: 'ಕೂಡ್ಲಿಗಿ', state: 'KA', lat: 14.90, lon: 76.39),
  CityData(name: 'Sandur', nameKn: 'ಸಂಡೂರ', state: 'KA', lat: 15.09, lon: 76.55),
  CityData(name: 'Siruguppa', nameKn: 'ಸಿರುಗುಪ್ಪ', state: 'KA', lat: 15.63, lon: 76.90),
  CityData(name: 'Hadagali', nameKn: 'ಹಡಗಲಿ', state: 'KA', lat: 15.02, lon: 75.93),
  CityData(name: 'Hagaribommanahalli', nameKn: 'ಹಗರಿಬೊಮ್ಮನಹಳ್ಳಿ', state: 'KA', lat: 15.04, lon: 76.21),

  // ─── Bidar District ───
  CityData(name: 'Bidar', nameKn: 'ಬೀದರ', state: 'KA', lat: 17.91, lon: 77.52),
  CityData(name: 'Aurad', nameKn: 'ಔರಾದ', state: 'KA', lat: 18.25, lon: 77.42),
  CityData(name: 'Basavakalyan', nameKn: 'ಬಸವಕಲ್ಯಾಣ', state: 'KA', lat: 17.87, lon: 76.95),
  CityData(name: 'Bhalki', nameKn: 'ಭಾಲ್ಕಿ', state: 'KA', lat: 18.04, lon: 77.21),
  CityData(name: 'Humnabad', nameKn: 'ಹುಮನಾಬಾದ', state: 'KA', lat: 17.77, lon: 77.14),

  // ─── Chamarajanagar District ───
  CityData(name: 'Chamarajanagar', nameKn: 'ಚಾಮರಾಜನಗರ', state: 'KA', lat: 11.92, lon: 76.94),
  CityData(name: 'Gundlupet', nameKn: 'ಗುಂಡ್ಲುಪೇಟೆ', state: 'KA', lat: 11.80, lon: 76.69),
  CityData(name: 'Kollegal', nameKn: 'ಕೊಳ್ಳೇಗಾಲ', state: 'KA', lat: 12.15, lon: 77.11),
  CityData(name: 'Yelandur', nameKn: 'ಯಳಂದೂರು', state: 'KA', lat: 12.06, lon: 77.03),

  // ─── Chikballapur District ───
  CityData(name: 'Chikballapur', nameKn: 'ಚಿಕ್ಕಬಳ್ಳಾಪುರ', state: 'KA', lat: 13.44, lon: 77.73),
  CityData(name: 'Bagepalli', nameKn: 'ಬಾಗೇಪಲ್ಲಿ', state: 'KA', lat: 13.78, lon: 77.79),
  CityData(name: 'Chintamani', nameKn: 'ಚಿಂತಾಮಣಿ', state: 'KA', lat: 13.40, lon: 78.05),
  CityData(name: 'Gauribidanur', nameKn: 'ಗೌರಿಬಿದನೂರು', state: 'KA', lat: 13.61, lon: 77.52),
  CityData(name: 'Gudibande', nameKn: 'ಗುಡಿಬಂಡೆ', state: 'KA', lat: 13.62, lon: 77.70),
  CityData(name: 'Sidlaghatta', nameKn: 'ಶಿಡ್ಲಘಟ್ಟ', state: 'KA', lat: 13.39, lon: 77.86),

  // ─── Chikkamagalur District ───
  CityData(name: 'Chikmagalur', nameKn: 'ಚಿಕ್ಕಮಗಳೂರು', state: 'KA', lat: 13.32, lon: 75.77),
  CityData(name: 'Kadur', nameKn: 'ಕಡೂರು', state: 'KA', lat: 13.55, lon: 76.01),
  CityData(name: 'Koppa', nameKn: 'ಕೊಪ್ಪ', state: 'KA', lat: 13.53, lon: 75.35),
  CityData(name: 'Mudigere', nameKn: 'ಮೂಡಿಗೆರೆ', state: 'KA', lat: 13.13, lon: 75.64),
  CityData(name: 'NR Pura', nameKn: 'ನರಸಿಂಹರಾಜಪುರ', state: 'KA', lat: 13.60, lon: 75.52),
  CityData(name: 'Sringeri', nameKn: 'ಶೃಂಗೇರಿ', state: 'KA', lat: 13.42, lon: 75.25),
  CityData(name: 'Tarikere', nameKn: 'ತರೀಕೆರೆ', state: 'KA', lat: 13.71, lon: 75.81),

  // ─── Chitradurga District ───
  CityData(name: 'Chitradurga', nameKn: 'ಚಿತ್ರದುರ್ಗ', state: 'KA', lat: 14.22, lon: 76.40),
  CityData(name: 'Challakere', nameKn: 'ಚಲ್ಲಕೆರೆ', state: 'KA', lat: 14.32, lon: 76.65),
  CityData(name: 'Hiriyur', nameKn: 'ಹಿರಿಯೂರು', state: 'KA', lat: 13.94, lon: 76.62),
  CityData(name: 'Holalkere', nameKn: 'ಹೊಳಲ್ಕೆರೆ', state: 'KA', lat: 14.04, lon: 76.18),
  CityData(name: 'Hosadurga', nameKn: 'ಹೊಸದುರ್ಗ', state: 'KA', lat: 13.80, lon: 76.29),
  CityData(name: 'Molakalmuru', nameKn: 'ಮೊಳಕಾಲ್ಮುರು', state: 'KA', lat: 14.72, lon: 76.75),

  // ─── Dakshina Kannada District ───
  CityData(name: 'Mangalore', nameKn: 'ಮಂಗಳೂರು', state: 'KA', lat: 12.91, lon: 74.86),
  CityData(name: 'Bantwal', nameKn: 'ಬಂಟ್ವಾಳ', state: 'KA', lat: 12.89, lon: 75.03),
  CityData(name: 'Belthangady', nameKn: 'ಬೆಳ್ತಂಗಡಿ', state: 'KA', lat: 12.97, lon: 75.30),
  CityData(name: 'Kadaba', nameKn: 'ಕಡಬ', state: 'KA', lat: 12.76, lon: 75.21),
  CityData(name: 'Puttur', nameKn: 'ಪುತ್ತೂರು', state: 'KA', lat: 12.76, lon: 75.20),
  CityData(name: 'Sullia', nameKn: 'ಸುಳ್ಯ', state: 'KA', lat: 12.56, lon: 75.39),

  // ─── Davanagere District ───
  CityData(name: 'Davanagere', nameKn: 'ದಾವಣಗೆರೆ', state: 'KA', lat: 14.46, lon: 75.92),
  CityData(name: 'Channagiri', nameKn: 'ಚನ್ನಗಿರಿ', state: 'KA', lat: 14.02, lon: 75.93),
  CityData(name: 'Harihar', nameKn: 'ಹರಿಹರ', state: 'KA', lat: 14.52, lon: 75.81),
  CityData(name: 'Honnali', nameKn: 'ಹೊನ್ನಾಳಿ', state: 'KA', lat: 14.24, lon: 75.65),
  CityData(name: 'Jagalur', nameKn: 'ಜಗಳೂರು', state: 'KA', lat: 14.52, lon: 76.34),

  // ─── Dharwad District ───
  CityData(name: 'Dharwad', nameKn: 'ಧಾರವಾಡ', state: 'KA', lat: 15.46, lon: 75.01),
  CityData(name: 'Hubli', nameKn: 'ಹುಬ್ಬಳ್ಳಿ', state: 'KA', lat: 15.36, lon: 75.12),
  CityData(name: 'Kalghatgi', nameKn: 'ಕಲಘಟಗಿ', state: 'KA', lat: 15.18, lon: 75.07),
  CityData(name: 'Kundgol', nameKn: 'ಕುಂದಗೋಳ', state: 'KA', lat: 15.26, lon: 75.25),
  CityData(name: 'Navalgund', nameKn: 'ನವಲಗುಂದ', state: 'KA', lat: 15.57, lon: 75.37),

  // ─── Gadag District ───
  CityData(name: 'Gadag', nameKn: 'ಗದಗ', state: 'KA', lat: 15.43, lon: 75.63),
  CityData(name: 'Mundargi', nameKn: 'ಮುಂಡರಗಿ', state: 'KA', lat: 15.21, lon: 75.88),
  CityData(name: 'Nargund', nameKn: 'ನರಗುಂದ', state: 'KA', lat: 15.72, lon: 75.38),
  CityData(name: 'Ron', nameKn: 'ರೋಣ', state: 'KA', lat: 15.69, lon: 75.73),
  CityData(name: 'Shirahatti', nameKn: 'ಶಿರಹಟ್ಟಿ', state: 'KA', lat: 15.23, lon: 75.57),

  // ─── Kalaburagi (Gulbarga) District ───
  CityData(name: 'Kalaburagi', nameKn: 'ಕಲಬುರಗಿ', state: 'KA', lat: 17.33, lon: 76.83),
  CityData(name: 'Aland', nameKn: 'ಆಳಂದ', state: 'KA', lat: 17.57, lon: 76.57),
  CityData(name: 'Afzalpur', nameKn: 'ಅಫಜಲಪುರ', state: 'KA', lat: 17.20, lon: 76.36),
  CityData(name: 'Chincholi', nameKn: 'ಚಿಂಚೋಳಿ', state: 'KA', lat: 17.47, lon: 77.42),
  CityData(name: 'Chittapur', nameKn: 'ಚಿತ್ತಾಪುರ', state: 'KA', lat: 17.12, lon: 77.09),
  CityData(name: 'Jevargi', nameKn: 'ಜೇವರ್ಗಿ', state: 'KA', lat: 16.90, lon: 76.77),
  CityData(name: 'Sedam', nameKn: 'ಸೇಡಂ', state: 'KA', lat: 17.18, lon: 77.27),

  // ─── Hassan District ───
  CityData(name: 'Hassan', nameKn: 'ಹಾಸನ', state: 'KA', lat: 13.01, lon: 76.10),
  CityData(name: 'Alur', nameKn: 'ಅಲೂರು', state: 'KA', lat: 12.97, lon: 75.99),
  CityData(name: 'Arkalgud', nameKn: 'ಅರಕಲಗೂಡು', state: 'KA', lat: 12.76, lon: 76.06),
  CityData(name: 'Arsikere', nameKn: 'ಅರಸೀಕೆರೆ', state: 'KA', lat: 13.31, lon: 76.26),
  CityData(name: 'Belur', nameKn: 'ಬೇಲೂರು', state: 'KA', lat: 13.16, lon: 75.87),
  CityData(name: 'Channarayapatna', nameKn: 'ಚನ್ನರಾಯಪಟ್ಟಣ', state: 'KA', lat: 12.90, lon: 76.39),
  CityData(name: 'Holenarasipura', nameKn: 'ಹೊಳೆನರಸೀಪುರ', state: 'KA', lat: 12.79, lon: 76.24),
  CityData(name: 'Sakleshpur', nameKn: 'ಸಕಲೇಶಪುರ', state: 'KA', lat: 12.94, lon: 75.78),

  // ─── Haveri District ───
  CityData(name: 'Haveri', nameKn: 'ಹಾವೇರಿ', state: 'KA', lat: 14.79, lon: 75.40),
  CityData(name: 'Byadgi', nameKn: 'ಬ್ಯಾಡಗಿ', state: 'KA', lat: 14.67, lon: 75.49),
  CityData(name: 'Hangal', nameKn: 'ಹಾನಗಲ್', state: 'KA', lat: 14.77, lon: 75.12),
  CityData(name: 'Hirekerur', nameKn: 'ಹಿರೇಕೆರೂರ', state: 'KA', lat: 14.46, lon: 75.40),
  CityData(name: 'Ranebennur', nameKn: 'ರಾಣೆಬೆನ್ನೂರ', state: 'KA', lat: 14.62, lon: 75.63),
  CityData(name: 'Savanur', nameKn: 'ಸವಣೂರ', state: 'KA', lat: 14.98, lon: 75.33),
  CityData(name: 'Shiggaon', nameKn: 'ಶಿಗ್ಗಾಂವ', state: 'KA', lat: 14.99, lon: 75.22),

  // ─── Kodagu District ───
  CityData(name: 'Madikeri', nameKn: 'ಮಡಿಕೇರಿ', state: 'KA', lat: 12.42, lon: 75.74),
  CityData(name: 'Somwarpet', nameKn: 'ಸೋಮವಾರಪೇಟೆ', state: 'KA', lat: 12.59, lon: 75.86),
  CityData(name: 'Virajpet', nameKn: 'ವಿರಾಜಪೇಟೆ', state: 'KA', lat: 12.20, lon: 75.80),

  // ─── Kolar District ───
  CityData(name: 'Kolar', nameKn: 'ಕೋಲಾರ', state: 'KA', lat: 13.14, lon: 78.13),
  CityData(name: 'Bangarapet', nameKn: 'ಬಂಗಾರಪೇಟೆ', state: 'KA', lat: 12.99, lon: 78.18),
  CityData(name: 'KGF', nameKn: 'ಕೆ.ಜಿ.ಎಫ್', state: 'KA', lat: 12.96, lon: 78.27),
  CityData(name: 'Malur', nameKn: 'ಮಾಲೂರು', state: 'KA', lat: 13.00, lon: 77.94),
  CityData(name: 'Mulbagal', nameKn: 'ಮುಳಬಾಗಿಲು', state: 'KA', lat: 13.17, lon: 78.39),
  CityData(name: 'Srinivaspur', nameKn: 'ಶ್ರೀನಿವಾಸಪುರ', state: 'KA', lat: 13.34, lon: 78.21),

  // ─── Koppal District ───
  CityData(name: 'Koppal', nameKn: 'ಕೊಪ್ಪಳ', state: 'KA', lat: 15.35, lon: 76.15),
  CityData(name: 'Gangavathi', nameKn: 'ಗಂಗಾವತಿ', state: 'KA', lat: 15.43, lon: 76.53),
  CityData(name: 'Kushtagi', nameKn: 'ಕುಷ್ಟಗಿ', state: 'KA', lat: 15.76, lon: 76.19),
  CityData(name: 'Yelburga', nameKn: 'ಯಲಬುರ್ಗಾ', state: 'KA', lat: 15.59, lon: 76.01),

  // ─── Mandya District ───
  CityData(name: 'Mandya', nameKn: 'ಮಂಡ್ಯ', state: 'KA', lat: 12.52, lon: 76.90),
  CityData(name: 'KR Pet', nameKn: 'ಕೆ.ಆರ್.ಪೇಟೆ', state: 'KA', lat: 12.66, lon: 76.49),
  CityData(name: 'Maddur', nameKn: 'ಮದ್ದೂರು', state: 'KA', lat: 12.58, lon: 77.05),
  CityData(name: 'Malavalli', nameKn: 'ಮಳವಳ್ಳಿ', state: 'KA', lat: 12.39, lon: 77.06),
  CityData(name: 'Nagamangala', nameKn: 'ನಾಗಮಂಗಲ', state: 'KA', lat: 12.82, lon: 76.76),
  CityData(name: 'Pandavapura', nameKn: 'ಪಾಂಡವಪುರ', state: 'KA', lat: 12.49, lon: 76.68),
  CityData(name: 'Srirangapatna', nameKn: 'ಶ್ರೀರಂಗಪಟ್ಟಣ', state: 'KA', lat: 12.42, lon: 76.69),

  // ─── Mysore District ───
  CityData(name: 'Mysore', nameKn: 'ಮೈಸೂರು', state: 'KA', lat: 12.30, lon: 76.64),
  CityData(name: 'Hunsur', nameKn: 'ಹುಣಸೂರು', state: 'KA', lat: 12.30, lon: 76.29),
  CityData(name: 'KR Nagar', nameKn: 'ಕೆ.ಆರ್.ನಗರ', state: 'KA', lat: 12.43, lon: 76.39),
  CityData(name: 'Nanjangud', nameKn: 'ನಂಜನಗೂಡು', state: 'KA', lat: 12.12, lon: 76.68),
  CityData(name: 'Piriyapatna', nameKn: 'ಪಿರಿಯಾಪಟ್ಟಣ', state: 'KA', lat: 12.34, lon: 76.10),
  CityData(name: 'T Narasipura', nameKn: 'ತಿ.ನರಸೀಪುರ', state: 'KA', lat: 12.21, lon: 76.90),
  CityData(name: 'HD Kote', nameKn: 'ಎಚ್.ಡಿ.ಕೋಟೆ', state: 'KA', lat: 12.09, lon: 76.33),

  // ─── Raichur District ───
  CityData(name: 'Raichur', nameKn: 'ರಾಯಚೂರು', state: 'KA', lat: 16.21, lon: 77.35),
  CityData(name: 'Devadurga', nameKn: 'ದೇವದುರ್ಗ', state: 'KA', lat: 15.99, lon: 76.64),
  CityData(name: 'Lingsugur', nameKn: 'ಲಿಂಗಸುಗೂರು', state: 'KA', lat: 16.16, lon: 76.52),
  CityData(name: 'Manvi', nameKn: 'ಮಾನ್ವಿ', state: 'KA', lat: 15.99, lon: 77.05),
  CityData(name: 'Sindhanur', nameKn: 'ಸಿಂಧನೂರು', state: 'KA', lat: 15.77, lon: 76.76),

  // ─── Ramanagar District ───
  CityData(name: 'Ramanagar', nameKn: 'ರಾಮನಗರ', state: 'KA', lat: 12.72, lon: 77.28),
  CityData(name: 'Channapatna', nameKn: 'ಚನ್ನಪಟ್ಟಣ', state: 'KA', lat: 12.65, lon: 77.21),
  CityData(name: 'Kanakapura', nameKn: 'ಕನಕಪುರ', state: 'KA', lat: 12.55, lon: 77.42),
  CityData(name: 'Magadi', nameKn: 'ಮಾಗಡಿ', state: 'KA', lat: 12.96, lon: 77.23),

  // ─── Shimoga District ───
  CityData(name: 'Shimoga', nameKn: 'ಶಿವಮೊಗ್ಗ', state: 'KA', lat: 13.93, lon: 75.57),
  CityData(name: 'Bhadravathi', nameKn: 'ಭದ್ರಾವತಿ', state: 'KA', lat: 13.83, lon: 75.71),
  CityData(name: 'Hosanagar', nameKn: 'ಹೊಸನಗರ', state: 'KA', lat: 13.90, lon: 75.07),
  CityData(name: 'Sagar', nameKn: 'ಸಾಗರ', state: 'KA', lat: 14.17, lon: 75.02),
  CityData(name: 'Shikaripura', nameKn: 'ಶಿಕಾರಿಪುರ', state: 'KA', lat: 14.27, lon: 75.35),
  CityData(name: 'Sorab', nameKn: 'ಸೊರಬ', state: 'KA', lat: 14.38, lon: 75.09),
  CityData(name: 'Thirthahalli', nameKn: 'ತೀರ್ಥಹಳ್ಳಿ', state: 'KA', lat: 13.69, lon: 75.24),

  // ─── Tumkur District ───
  CityData(name: 'Tumkur', nameKn: 'ತುಮಕೂರು', state: 'KA', lat: 13.34, lon: 77.12),
  CityData(name: 'CN Halli', nameKn: 'ಚಿಕ್ಕನಾಯಕನಹಳ್ಳಿ', state: 'KA', lat: 13.39, lon: 76.62),
  CityData(name: 'Gubbi', nameKn: 'ಗುಬ್ಬಿ', state: 'KA', lat: 13.31, lon: 76.94),
  CityData(name: 'Kunigal', nameKn: 'ಕುಣಿಗಲ್', state: 'KA', lat: 13.02, lon: 77.03),
  CityData(name: 'Madhugiri', nameKn: 'ಮಧುಗಿರಿ', state: 'KA', lat: 13.66, lon: 77.21),
  CityData(name: 'Pavagada', nameKn: 'ಪಾವಗಡ', state: 'KA', lat: 14.10, lon: 77.28),
  CityData(name: 'Sira', nameKn: 'ಸಿರಾ', state: 'KA', lat: 13.74, lon: 76.90),
  CityData(name: 'Tiptur', nameKn: 'ತಿಪಟೂರು', state: 'KA', lat: 13.26, lon: 76.48),
  CityData(name: 'Turuvekere', nameKn: 'ತುರುವೆಕೆರೆ', state: 'KA', lat: 13.16, lon: 76.67),
  CityData(name: 'Koratagere', nameKn: 'ಕೊರಟಗೆರೆ', state: 'KA', lat: 13.52, lon: 77.24),

  // ─── Udupi District ───
  CityData(name: 'Udupi', nameKn: 'ಉಡುಪಿ', state: 'KA', lat: 13.34, lon: 74.74),
  CityData(name: 'Karkala', nameKn: 'ಕಾರ್ಕಳ', state: 'KA', lat: 13.22, lon: 74.99),
  CityData(name: 'Kundapura', nameKn: 'ಕುಂದಾಪುರ', state: 'KA', lat: 13.63, lon: 74.69),

  // ─── Uttara Kannada District ───
  CityData(name: 'Karwar', nameKn: 'ಕಾರವಾರ', state: 'KA', lat: 14.81, lon: 74.13),
  CityData(name: 'Ankola', nameKn: 'ಅಂಕೋಲ', state: 'KA', lat: 14.66, lon: 74.30),
  CityData(name: 'Bhatkal', nameKn: 'ಭಟ್ಕಳ', state: 'KA', lat: 13.97, lon: 74.56),
  CityData(name: 'Haliyal', nameKn: 'ಹಳಿಯಾಳ', state: 'KA', lat: 15.33, lon: 74.76),
  CityData(name: 'Honnavar', nameKn: 'ಹೊನ್ನಾವರ', state: 'KA', lat: 14.28, lon: 74.44),
  CityData(name: 'Joida', nameKn: 'ಜೋಯಿಡಾ', state: 'KA', lat: 15.28, lon: 74.48),
  CityData(name: 'Kumta', nameKn: 'ಕುಮಟ', state: 'KA', lat: 14.43, lon: 74.41),
  CityData(name: 'Mundgod', nameKn: 'ಮುಂಡಗೋಡ', state: 'KA', lat: 14.97, lon: 75.04),
  CityData(name: 'Siddapur', nameKn: 'ಸಿದ್ದಾಪುರ', state: 'KA', lat: 14.35, lon: 74.89),
  CityData(name: 'Sirsi', nameKn: 'ಸಿರ್ಸಿ', state: 'KA', lat: 14.62, lon: 74.83),
  CityData(name: 'Yellapur', nameKn: 'ಯಲ್ಲಾಪುರ', state: 'KA', lat: 14.98, lon: 74.73),

  // ─── Vijayapura (Bijapur) District ───
  CityData(name: 'Vijayapura', nameKn: 'ವಿಜಯಪುರ', state: 'KA', lat: 16.83, lon: 75.71),
  CityData(name: 'Basavana Bagevadi', nameKn: 'ಬಸವನ ಬಾಗೇವಾಡಿ', state: 'KA', lat: 16.57, lon: 75.97),
  CityData(name: 'Indi', nameKn: 'ಇಂಡಿ', state: 'KA', lat: 17.18, lon: 75.96),
  CityData(name: 'Muddebihal', nameKn: 'ಮುದ್ದೇಬಿಹಾಳ', state: 'KA', lat: 16.34, lon: 76.14),
  CityData(name: 'Sindagi', nameKn: 'ಸیندಗಿ', state: 'KA', lat: 16.92, lon: 76.23),

  // ─── Yadgir District ───
  CityData(name: 'Yadgir', nameKn: 'ಯಾದಗಿರಿ', state: 'KA', lat: 16.77, lon: 77.14),
  CityData(name: 'Shahapur', nameKn: 'ಶಹಾಪುರ', state: 'KA', lat: 16.70, lon: 76.84),
  CityData(name: 'Shorapur', nameKn: 'ಸುರಪುರ', state: 'KA', lat: 16.52, lon: 76.76),

  // ─── Vijayanagar District (new) ───
  CityData(name: 'Hosapete', nameKn: 'ಹೊಸಪೇಟೆ', state: 'KA', lat: 15.27, lon: 76.39),
  CityData(name: 'Hampi', nameKn: 'ಹಂಪಿ', state: 'KA', lat: 15.33, lon: 76.46),
  CityData(name: 'Babaleshwar', nameKn: 'ಬಾಬಲೇಶ್ವರ', state: 'KA', lat: 16.98, lon: 75.91),
];

// ══════════════════════════════════════════════════════════════
//  MAJOR INDIAN CITIES (all states)
// ══════════════════════════════════════════════════════════════

const List<CityData> otherIndianCities = [
  CityData(name: 'Hyderabad', nameKn: 'ಹೈದರಾಬಾದ್', state: 'TG', lat: 17.39, lon: 78.49),
  CityData(name: 'Chennai', nameKn: 'ಚೆನ್ನೈ', state: 'TN', lat: 13.08, lon: 80.27),
  CityData(name: 'Mumbai', nameKn: 'ಮುಂಬೈ', state: 'MH', lat: 19.08, lon: 72.88),
  CityData(name: 'New Delhi', nameKn: 'ನವ ದೆಹಲಿ', state: 'DL', lat: 28.70, lon: 77.10),
  CityData(name: 'Kolkata', nameKn: 'ಕೊಲ್ಕತ್ತಾ', state: 'WB', lat: 22.57, lon: 88.36),
  CityData(name: 'Pune', nameKn: 'ಪುಣೆ', state: 'MH', lat: 18.52, lon: 73.86),
  CityData(name: 'Ahmedabad', nameKn: 'ಅಹಮದಾಬಾದ್', state: 'GJ', lat: 23.02, lon: 72.57),
  CityData(name: 'Jaipur', nameKn: 'ಜೈಪುರ', state: 'RJ', lat: 26.91, lon: 75.79),
  CityData(name: 'Lucknow', nameKn: 'ಲಖನೌ', state: 'UP', lat: 26.85, lon: 80.95),
  CityData(name: 'Bhopal', nameKn: 'ಭೋಪಾಲ್', state: 'MP', lat: 23.26, lon: 77.41),
  CityData(name: 'Coimbatore', nameKn: 'ಕೊಯಮತ್ತೂರು', state: 'TN', lat: 11.01, lon: 76.96),
  CityData(name: 'Madurai', nameKn: 'ಮದುರೈ', state: 'TN', lat: 9.92, lon: 78.12),
  CityData(name: 'Kochi', nameKn: 'ಕೊಚ್ಚಿ', state: 'KL', lat: 9.93, lon: 76.27),
  CityData(name: 'Thiruvananthapuram', nameKn: 'ತಿರುವನಂತಪುರಂ', state: 'KL', lat: 8.52, lon: 76.94),
  CityData(name: 'Visakhapatnam', nameKn: 'ವಿಶಾಖಪಟ್ಟಣಂ', state: 'AP', lat: 17.69, lon: 83.22),
  CityData(name: 'Vijayawada', nameKn: 'ವಿಜಯವಾಡ', state: 'AP', lat: 16.51, lon: 80.65),
  CityData(name: 'Tirupati', nameKn: 'ತಿರುಪತಿ', state: 'AP', lat: 13.63, lon: 79.42),
  CityData(name: 'Nagpur', nameKn: 'ನಾಗಪುರ', state: 'MH', lat: 21.15, lon: 79.09),
  CityData(name: 'Surat', nameKn: 'ಸೂರತ್', state: 'GJ', lat: 21.17, lon: 72.83),
  CityData(name: 'Varanasi', nameKn: 'ವಾರಾಣಸಿ', state: 'UP', lat: 25.32, lon: 82.97),
  CityData(name: 'Ujjain', nameKn: 'ಉಜ್ಜೈನ್', state: 'MP', lat: 23.18, lon: 75.79),
  CityData(name: 'Indore', nameKn: 'ಇಂದೋರ್', state: 'MP', lat: 22.72, lon: 75.86),
  CityData(name: 'Patna', nameKn: 'ಪಾಟ್ನಾ', state: 'BR', lat: 25.61, lon: 85.14),
  CityData(name: 'Chandigarh', nameKn: 'ಚಂಡೀಗಡ', state: 'CH', lat: 30.73, lon: 76.77),
  CityData(name: 'Goa', nameKn: 'ಗೋವಾ', state: 'GA', lat: 15.50, lon: 73.83),
  CityData(name: 'Puri', nameKn: 'ಪುರಿ', state: 'OD', lat: 19.80, lon: 85.83),
  CityData(name: 'Bhubaneswar', nameKn: 'ಭುವನೇಶ್ವರ', state: 'OD', lat: 20.30, lon: 85.82),
  CityData(name: 'Guwahati', nameKn: 'ಗುವಾಹಾಟಿ', state: 'AS', lat: 26.14, lon: 91.74),
  CityData(name: 'Amritsar', nameKn: 'ಅಮೃತಸರ', state: 'PB', lat: 31.63, lon: 74.87),
  CityData(name: 'Rishikesh', nameKn: 'ಋಷಿಕೇಶ', state: 'UK', lat: 30.09, lon: 78.27),
  CityData(name: 'Haridwar', nameKn: 'ಹರಿದ್ವಾರ', state: 'UK', lat: 29.95, lon: 78.16),
];

// ══════════════════════════════════════════════════════════════
//  WORLD CAPITALS (for NRIs)
// ══════════════════════════════════════════════════════════════

const List<CityData> worldCities = [
  CityData(name: 'London', nameKn: 'ಲಂಡನ್', state: 'UK', lat: 51.51, lon: -0.13, tzOffset: 0.0),
  CityData(name: 'New York', nameKn: 'ನ್ಯೂಯಾರ್ಕ್', state: 'US', lat: 40.71, lon: -74.01, tzOffset: -5.0),
  CityData(name: 'Dubai', nameKn: 'ದುಬೈ', state: 'AE', lat: 25.20, lon: 55.27, tzOffset: 4.0),
  CityData(name: 'Singapore', nameKn: 'ಸಿಂಗಾಪುರ', state: 'SG', lat: 1.35, lon: 103.82, tzOffset: 8.0),
  CityData(name: 'Sydney', nameKn: 'ಸಿಡ್ನಿ', state: 'AU', lat: -33.87, lon: 151.21, tzOffset: 10.0),
  CityData(name: 'Toronto', nameKn: 'ಟೊರಾಂಟೊ', state: 'CA', lat: 43.65, lon: -79.38, tzOffset: -5.0),
  CityData(name: 'Tokyo', nameKn: 'ಟೋಕಿಯೋ', state: 'JP', lat: 35.68, lon: 139.69, tzOffset: 9.0),
  CityData(name: 'Colombo', nameKn: 'ಕೊಲಂಬೊ', state: 'LK', lat: 6.93, lon: 79.84, tzOffset: 5.5),
  CityData(name: 'Kathmandu', nameKn: 'ಕಾಠ್ಮಂಡು', state: 'NP', lat: 27.72, lon: 85.32, tzOffset: 5.75),
];

// ══════════════════════════════════════════════════════════════
//  COMBINED LIST (used by LocationService)
// ══════════════════════════════════════════════════════════════

const List<CityData> indianCities = [
  ...karnatakaCities,
  ...otherIndianCities,
  ...worldCities,
];

// ══════════════════════════════════════════════════════════════
//  WORLD CITIES DATABASE (loaded from JSON asset)
// ══════════════════════════════════════════════════════════════

/// Loaded world cities from bundled JSON: {n: name, c: country, la: lat, lo: lon, tz: offset}
List<Map<String, dynamic>>? _worldCitiesDb;
bool _worldCitiesLoading = false;

/// Load world cities from bundled JSON asset
Future<void> loadWorldCities() async {
  if (_worldCitiesDb != null || _worldCitiesLoading) return;
  _worldCitiesLoading = true;
  try {
    final jsonStr = await rootBundle.loadString('assets/world_cities.json');
    final List<dynamic> data = jsonDecode(jsonStr);
    _worldCitiesDb = data.cast<Map<String, dynamic>>();
  } catch (e) {
    _worldCitiesDb = [];
  }
  _worldCitiesLoading = false;
}

/// Whether world cities have been loaded
bool get worldCitiesLoaded => _worldCitiesDb != null && _worldCitiesDb!.isNotEmpty;

/// Search world cities by query (case-insensitive prefix/contains)
/// Returns up to [limit] results as CityData objects
List<CityData> searchWorldCitiesDb(String query, {int limit = 20}) {
  if (_worldCitiesDb == null || query.trim().isEmpty) return [];
  final q = query.trim().toLowerCase();
  final results = <CityData>[];

  // Prefix matches first
  for (final city in _worldCitiesDb!) {
    if (results.length >= limit) break;
    final name = (city['n'] as String).toLowerCase();
    if (name.startsWith(q)) {
      results.add(CityData(
        name: city['n'] as String,
        nameKn: city['n'] as String,
        state: city['c'] as String? ?? '',
        lat: (city['la'] as num).toDouble(),
        lon: (city['lo'] as num).toDouble(),
        tzOffset: (city['tz'] as num?)?.toDouble() ?? 0.0,
      ));
    }
  }

  // Contains matches if we need more
  if (results.length < limit) {
    final existingNames = results.map((r) => r.name.toLowerCase()).toSet();
    for (final city in _worldCitiesDb!) {
      if (results.length >= limit) break;
      final name = (city['n'] as String).toLowerCase();
      if (!existingNames.contains(name) && name.contains(q)) {
        results.add(CityData(
          name: city['n'] as String,
          nameKn: city['n'] as String,
          state: city['c'] as String? ?? '',
          lat: (city['la'] as num).toDouble(),
          lon: (city['lo'] as num).toDouble(),
          tzOffset: (city['tz'] as num?)?.toDouble() ?? 0.0,
        ));
      }
    }
  }

  return results;
}
