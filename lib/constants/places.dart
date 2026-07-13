/// Indian cities database with coordinates and timezone offsets.
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

const List<CityData> indianCities = [
  // Karnataka
  CityData(name: 'Bangalore', nameKn: 'ಬೆಂಗಳೂರು', state: 'KA', lat: 12.9716, lon: 77.5946),
  CityData(name: 'Mysore', nameKn: 'ಮೈಸೂರು', state: 'KA', lat: 12.2958, lon: 76.6394),
  CityData(name: 'Mangalore', nameKn: 'ಮಂಗಳೂರು', state: 'KA', lat: 12.9141, lon: 74.8560),
  CityData(name: 'Hubli', nameKn: 'ಹುಬ್ಬಳ್ಳಿ', state: 'KA', lat: 15.3647, lon: 75.1240),
  CityData(name: 'Dharwad', nameKn: 'ಧಾರವಾಡ', state: 'KA', lat: 15.4589, lon: 75.0078),
  CityData(name: 'Belgaum', nameKn: 'ಬೆಳಗಾವಿ', state: 'KA', lat: 15.8497, lon: 74.4977),
  CityData(name: 'Gulbarga', nameKn: 'ಕಲಬುರಗಿ', state: 'KA', lat: 17.3297, lon: 76.8343),
  CityData(name: 'Shimoga', nameKn: 'ಶಿವಮೊಗ್ಗ', state: 'KA', lat: 13.9299, lon: 75.5681),
  CityData(name: 'Davangere', nameKn: 'ದಾವಣಗೆರೆ', state: 'KA', lat: 14.4644, lon: 75.9218),
  CityData(name: 'Bellary', nameKn: 'ಬಳ್ಳಾರಿ', state: 'KA', lat: 15.1394, lon: 76.9214),
  CityData(name: 'Bijapur', nameKn: 'ವಿಜಯಪುರ', state: 'KA', lat: 16.8302, lon: 75.7100),
  CityData(name: 'Raichur', nameKn: 'ರಾಯಚೂರು', state: 'KA', lat: 16.2076, lon: 77.3463),
  CityData(name: 'Udupi', nameKn: 'ಉಡುಪಿ', state: 'KA', lat: 13.3409, lon: 74.7421),
  CityData(name: 'Hassan', nameKn: 'ಹಾಸನ', state: 'KA', lat: 13.0072, lon: 76.1001),
  CityData(name: 'Tumkur', nameKn: 'ತುಮಕೂರು', state: 'KA', lat: 13.3379, lon: 77.1173),
  CityData(name: 'Chitradurga', nameKn: 'ಚಿತ್ರದುರ್ಗ', state: 'KA', lat: 14.2226, lon: 76.3980),

  // Major Indian Cities
  CityData(name: 'New Delhi', nameKn: 'ನವ ದೆಹಲಿ', state: 'DL', lat: 28.6139, lon: 77.2090),
  CityData(name: 'Mumbai', nameKn: 'ಮುಂಬೈ', state: 'MH', lat: 19.0760, lon: 72.8777),
  CityData(name: 'Chennai', nameKn: 'ಚೆನ್ನೈ', state: 'TN', lat: 13.0827, lon: 80.2707),
  CityData(name: 'Kolkata', nameKn: 'ಕೊಲ್ಕತ್ತಾ', state: 'WB', lat: 22.5726, lon: 88.3639),
  CityData(name: 'Hyderabad', nameKn: 'ಹೈದರಾಬಾದ್', state: 'TG', lat: 17.3850, lon: 78.4867),
  CityData(name: 'Pune', nameKn: 'ಪುಣೆ', state: 'MH', lat: 18.5204, lon: 73.8567),
  CityData(name: 'Ahmedabad', nameKn: 'ಅಹಮದಾಬಾದ್', state: 'GJ', lat: 23.0225, lon: 72.5714),
  CityData(name: 'Jaipur', nameKn: 'ಜೈಪುರ', state: 'RJ', lat: 26.9124, lon: 75.7873),
  CityData(name: 'Lucknow', nameKn: 'ಲಖನೌ', state: 'UP', lat: 26.8467, lon: 80.9462),
  CityData(name: 'Varanasi', nameKn: 'ವಾರಾಣಸಿ', state: 'UP', lat: 25.3176, lon: 82.9739),
  CityData(name: 'Ujjain', nameKn: 'ಉಜ್ಜೈನ್', state: 'MP', lat: 23.1765, lon: 75.7885),
  CityData(name: 'Kochi', nameKn: 'ಕೊಚ್ಚಿ', state: 'KL', lat: 9.9312, lon: 76.2673),
  CityData(name: 'Thiruvananthapuram', nameKn: 'ತಿರುವನಂತಪುರಂ', state: 'KL', lat: 8.5241, lon: 76.9366),
  CityData(name: 'Coimbatore', nameKn: 'ಕೊಯಮತ್ತೂರು', state: 'TN', lat: 11.0168, lon: 76.9558),
  CityData(name: 'Madurai', nameKn: 'ಮದುರೈ', state: 'TN', lat: 9.9252, lon: 78.1198),
  CityData(name: 'Visakhapatnam', nameKn: 'ವಿಶಾಖಪಟ್ಟಣಂ', state: 'AP', lat: 17.6868, lon: 83.2185),
  CityData(name: 'Tirupati', nameKn: 'ತಿರುಪತಿ', state: 'AP', lat: 13.6288, lon: 79.4192),
  CityData(name: 'Nagpur', nameKn: 'ನಾಗಪುರ', state: 'MH', lat: 21.1458, lon: 79.0882),
  CityData(name: 'Indore', nameKn: 'ಇಂದೋರ್', state: 'MP', lat: 22.7196, lon: 75.8577),
  CityData(name: 'Bhopal', nameKn: 'ಭೋಪಾಲ್', state: 'MP', lat: 23.2599, lon: 77.4126),
  CityData(name: 'Patna', nameKn: 'ಪಾಟ್ನಾ', state: 'BR', lat: 25.6093, lon: 85.1376),
  CityData(name: 'Puri', nameKn: 'ಪುರಿ', state: 'OD', lat: 19.7983, lon: 85.8315),
  CityData(name: 'Bhubaneswar', nameKn: 'ಭುವನೇಶ್ವರ', state: 'OD', lat: 20.2961, lon: 85.8245),
  CityData(name: 'Surat', nameKn: 'ಸೂರತ್', state: 'GJ', lat: 21.1702, lon: 72.8311),
  CityData(name: 'Guwahati', nameKn: 'ಗುವಾಹಾಟಿ', state: 'AS', lat: 26.1445, lon: 91.7362),
  CityData(name: 'Chandigarh', nameKn: 'ಚಂಡೀಗಡ', state: 'CH', lat: 30.7333, lon: 76.7794),
  CityData(name: 'Amritsar', nameKn: 'ಅಮೃತಸರ', state: 'PB', lat: 31.6340, lon: 74.8723),
  CityData(name: 'Rishikesh', nameKn: 'ಋಷಿಕೇಶ', state: 'UK', lat: 30.0869, lon: 78.2676),
  CityData(name: 'Haridwar', nameKn: 'ಹರಿದ್ವಾರ', state: 'UK', lat: 29.9457, lon: 78.1642),
];
