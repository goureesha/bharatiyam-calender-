/// Data models for the Bharatiyam Panchanga app.

class PanchangaData {
  // 5 Core Limbs
  final String tithi;
  final String vara;
  final String nakshatra;
  final String yoga;
  final String karana;

  // Indices
  final int tithiIndex;
  final int nakshatraIndex;
  final int yogaIndex;
  final int karanaIndex;
  final int varaIndex;

  // End times
  final String tithiEndTime;
  final String nakEndTime;
  final String yogaEndTime;
  final String karanaEndTime;

  // Next day flags
  final bool tithiEndsNextDay;
  final bool nakEndsNextDay;
  final bool yogaEndsNextDay;
  final bool karanaEndsNextDay;

  // Ghati details (Gata=elapsed, Shesha=remaining, Parama=total)
  final String tithiGata;
  final String tithiShesha;
  final String tithiParama;
  final String nakGata;
  final String nakShesha;
  final String nakParama;
  final String yogaGata;
  final String yogaShesha;
  final String yogaParama;
  final String karanaGata;
  final String karanaShesha;
  final String karanaParama;
  final String udayadiGhati;

  // Current-time Gata/Shesha
  final String tithiGataNow;
  final String tithiSheshaNow;
  final String nakGataNow;
  final String nakSheshaNow;
  final String yogaGataNow;
  final String yogaSheshaNow;
  final String karanaGataNow;
  final String karanaSheshaNow;

  // Current anga names (may differ from sunrise if transitioned)
  final String currentTithi;
  final String currentNakshatra;
  final String currentYoga;
  final String currentKarana;
  // Current anga end times & parama (when transitioned)
  final String currentTithiEndTime;
  final String currentNakEndTime;
  final String currentYogaEndTime;
  final String currentKaranaEndTime;
  final String currentTithiParama;
  final String currentNakParama;
  final String currentYogaParama;
  final String currentKaranaParama;
  // End time in ghati-vighati from sunrise
  final String tithiEndGhati;
  final String nakEndGhati;
  final String yogaEndGhati;
  final String karanaEndGhati;

  // Sun & Moon
  final String sunrise;
  final String sunset;
  final String chandraRashi;
  final String chandraPada;
  final String suryaNakshatra;
  final String suryaPada;
  final double nakPercent;

  // Calendar systems
  final String amantaMasa;
  final String pournimantaMasa;
  final String souraMasa;
  final String souraMasaGataDina;
  final String samvatsara;
  final String rutu;
  final String ayana;
  final String divamana;
  final String ratrimana;

  // Ghatis
  final String vishaPraghati;
  final String amrutaPraghati;
  final String agniVasa;

  // Extra details
  final int shakaVarsha;
  final String paksha;
  final String chandraUdaya;
  final String chandraAsta;

  // Raw JDs for timing calculations
  final double sunriseJd;
  final double sunsetJd;
  final double tithiEndJd;

  const PanchangaData({
    required this.tithi,
    required this.vara,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.tithiIndex,
    required this.nakshatraIndex,
    required this.yogaIndex,
    required this.karanaIndex,
    required this.varaIndex,
    required this.tithiEndTime,
    required this.nakEndTime,
    required this.yogaEndTime,
    required this.karanaEndTime,
    required this.tithiEndsNextDay,
    required this.nakEndsNextDay,
    required this.yogaEndsNextDay,
    required this.karanaEndsNextDay,
    required this.tithiGata,
    required this.tithiShesha,
    required this.tithiParama,
    required this.nakGata,
    required this.nakShesha,
    required this.nakParama,
    required this.yogaGata,
    required this.yogaShesha,
    required this.yogaParama,
    required this.karanaGata,
    required this.karanaShesha,
    required this.karanaParama,
    required this.udayadiGhati,
    this.tithiGataNow = '',
    this.tithiSheshaNow = '',
    this.nakGataNow = '',
    this.nakSheshaNow = '',
    this.yogaGataNow = '',
    this.yogaSheshaNow = '',
    this.karanaGataNow = '',
    this.karanaSheshaNow = '',
    this.currentTithi = '',
    this.currentNakshatra = '',
    this.currentYoga = '',
    this.currentKarana = '',
    this.currentTithiEndTime = '',
    this.currentNakEndTime = '',
    this.currentYogaEndTime = '',
    this.currentKaranaEndTime = '',
    this.currentTithiParama = '',
    this.currentNakParama = '',
    this.currentYogaParama = '',
    this.currentKaranaParama = '',
    this.tithiEndGhati = '',
    this.nakEndGhati = '',
    this.yogaEndGhati = '',
    this.karanaEndGhati = '',
    required this.sunrise,
    required this.sunset,
    required this.chandraRashi,
    required this.chandraPada,
    required this.suryaNakshatra,
    required this.suryaPada,
    required this.nakPercent,
    required this.amantaMasa,
    required this.pournimantaMasa,
    required this.souraMasa,
    required this.souraMasaGataDina,
    required this.samvatsara,
    required this.rutu,
    required this.ayana,
    required this.divamana,
    required this.ratrimana,
    required this.vishaPraghati,
    required this.amrutaPraghati,
    required this.agniVasa,
    required this.shakaVarsha,
    required this.paksha,
    required this.chandraUdaya,
    required this.chandraAsta,
    required this.sunriseJd,
    required this.sunsetJd,
    this.tithiEndJd = 0,
  });

  PanchangaData copyWith({
    String? amantaMasa,
    String? pournimantaMasa,
    String? samvatsara,
    String? rutu,
    String? vishaPraghati,
    String? amrutaPraghati,
    String? tithiGataNow,
    String? tithiSheshaNow,
    String? nakGataNow,
    String? nakSheshaNow,
    String? yogaGataNow,
    String? yogaSheshaNow,
    String? karanaGataNow,
    String? karanaSheshaNow,
    String? currentTithi,
    String? currentNakshatra,
    String? currentYoga,
    String? currentKarana,
    String? currentTithiEndTime,
    String? currentNakEndTime,
    String? currentYogaEndTime,
    String? currentKaranaEndTime,
    String? currentTithiParama,
    String? currentNakParama,
    String? currentYogaParama,
    String? currentKaranaParama,
    String? tithiEndGhati,
    String? nakEndGhati,
    String? yogaEndGhati,
    String? karanaEndGhati,
  }) => PanchangaData(
    tithi: tithi, vara: vara, nakshatra: nakshatra, yoga: yoga, karana: karana,
    tithiIndex: tithiIndex, nakshatraIndex: nakshatraIndex, yogaIndex: yogaIndex,
    karanaIndex: karanaIndex, varaIndex: varaIndex,
    tithiEndTime: tithiEndTime, nakEndTime: nakEndTime, yogaEndTime: yogaEndTime,
    karanaEndTime: karanaEndTime,
    tithiEndsNextDay: tithiEndsNextDay, nakEndsNextDay: nakEndsNextDay,
    yogaEndsNextDay: yogaEndsNextDay, karanaEndsNextDay: karanaEndsNextDay,
    tithiGata: tithiGata, tithiShesha: tithiShesha, tithiParama: tithiParama,
    nakGata: nakGata, nakShesha: nakShesha, nakParama: nakParama,
    yogaGata: yogaGata, yogaShesha: yogaShesha, yogaParama: yogaParama,
    karanaGata: karanaGata, karanaShesha: karanaShesha, karanaParama: karanaParama,
    udayadiGhati: udayadiGhati,
    tithiGataNow: tithiGataNow ?? this.tithiGataNow,
    tithiSheshaNow: tithiSheshaNow ?? this.tithiSheshaNow,
    nakGataNow: nakGataNow ?? this.nakGataNow,
    nakSheshaNow: nakSheshaNow ?? this.nakSheshaNow,
    yogaGataNow: yogaGataNow ?? this.yogaGataNow,
    yogaSheshaNow: yogaSheshaNow ?? this.yogaSheshaNow,
    karanaGataNow: karanaGataNow ?? this.karanaGataNow,
    karanaSheshaNow: karanaSheshaNow ?? this.karanaSheshaNow,
    currentTithi: currentTithi ?? this.currentTithi,
    currentNakshatra: currentNakshatra ?? this.currentNakshatra,
    currentYoga: currentYoga ?? this.currentYoga,
    currentKarana: currentKarana ?? this.currentKarana,
    currentTithiEndTime: currentTithiEndTime ?? this.currentTithiEndTime,
    currentNakEndTime: currentNakEndTime ?? this.currentNakEndTime,
    currentYogaEndTime: currentYogaEndTime ?? this.currentYogaEndTime,
    currentKaranaEndTime: currentKaranaEndTime ?? this.currentKaranaEndTime,
    currentTithiParama: currentTithiParama ?? this.currentTithiParama,
    currentNakParama: currentNakParama ?? this.currentNakParama,
    currentYogaParama: currentYogaParama ?? this.currentYogaParama,
    currentKaranaParama: currentKaranaParama ?? this.currentKaranaParama,
    tithiEndGhati: tithiEndGhati ?? this.tithiEndGhati,
    nakEndGhati: nakEndGhati ?? this.nakEndGhati,
    yogaEndGhati: yogaEndGhati ?? this.yogaEndGhati,
    karanaEndGhati: karanaEndGhati ?? this.karanaEndGhati,
    sunrise: sunrise, sunset: sunset,
    chandraRashi: chandraRashi, chandraPada: chandraPada,
    suryaNakshatra: suryaNakshatra, suryaPada: suryaPada, nakPercent: nakPercent,
    amantaMasa: amantaMasa ?? this.amantaMasa,
    pournimantaMasa: pournimantaMasa ?? this.pournimantaMasa,
    souraMasa: souraMasa, souraMasaGataDina: souraMasaGataDina,
    samvatsara: samvatsara ?? this.samvatsara,
    rutu: rutu ?? this.rutu,
    ayana: ayana, divamana: divamana, ratrimana: ratrimana,
    vishaPraghati: vishaPraghati ?? this.vishaPraghati,
    amrutaPraghati: amrutaPraghati ?? this.amrutaPraghati,
    agniVasa: agniVasa,
    shakaVarsha: shakaVarsha, paksha: paksha,
    chandraUdaya: chandraUdaya, chandraAsta: chandraAsta,
    sunriseJd: sunriseJd, sunsetJd: sunsetJd,
  );

  Map<String, dynamic> toJson() => {
    'ti': tithi, 'va': vara, 'na': nakshatra, 'yo': yoga, 'ka': karana,
    'tI': tithiIndex, 'nI': nakshatraIndex, 'yI': yogaIndex, 'kI': karanaIndex, 'vI': varaIndex,
    'tE': tithiEndTime, 'nE': nakEndTime, 'yE': yogaEndTime, 'kE': karanaEndTime,
    'tN': tithiEndsNextDay, 'nN': nakEndsNextDay, 'yN': yogaEndsNextDay, 'kN': karanaEndsNextDay,
    'tG': tithiGata, 'tS': tithiShesha, 'tP': tithiParama,
    'nG': nakGata, 'nS': nakShesha, 'nP': nakParama,
    'yG': yogaGata, 'yS': yogaShesha, 'yP': yogaParama,
    'kG': karanaGata, 'kS': karanaShesha, 'kP': karanaParama,
    'uG': udayadiGhati, 'sr': sunrise, 'ss': sunset,
    'cR': chandraRashi, 'cP': chandraPada, 'sN': suryaNakshatra, 'sP': suryaPada,
    'np': nakPercent, 'aM': amantaMasa, 'pM': pournimantaMasa,
    'sM': souraMasa, 'sD': souraMasaGataDina, 'sv': samvatsara,
    'ru': rutu, 'ay': ayana, 'dm': divamana, 'rm': ratrimana,
    'vP': vishaPraghati, 'aP': amrutaPraghati, 'ag': agniVasa,
    'sk': shakaVarsha, 'pk': paksha, 'cu': chandraUdaya, 'ca': chandraAsta,
    'rJ': sunriseJd, 'sJ': sunsetJd,
  };

  factory PanchangaData.fromJson(Map<String, dynamic> j) => PanchangaData(
    tithi: j['ti'] ?? '', vara: j['va'] ?? '', nakshatra: j['na'] ?? '',
    yoga: j['yo'] ?? '', karana: j['ka'] ?? '',
    tithiIndex: j['tI'] ?? 0, nakshatraIndex: j['nI'] ?? 0,
    yogaIndex: j['yI'] ?? 0, karanaIndex: j['kI'] ?? 0, varaIndex: j['vI'] ?? 0,
    tithiEndTime: j['tE'] ?? '', nakEndTime: j['nE'] ?? '',
    yogaEndTime: j['yE'] ?? '', karanaEndTime: j['kE'] ?? '',
    tithiEndsNextDay: j['tN'] ?? false, nakEndsNextDay: j['nN'] ?? false,
    yogaEndsNextDay: j['yN'] ?? false, karanaEndsNextDay: j['kN'] ?? false,
    tithiGata: j['tG'] ?? '', tithiShesha: j['tS'] ?? '', tithiParama: j['tP'] ?? '',
    nakGata: j['nG'] ?? '', nakShesha: j['nS'] ?? '', nakParama: j['nP'] ?? '',
    yogaGata: j['yG'] ?? '', yogaShesha: j['yS'] ?? '', yogaParama: j['yP'] ?? '',
    karanaGata: j['kG'] ?? '', karanaShesha: j['kS'] ?? '', karanaParama: j['kP'] ?? '',
    udayadiGhati: j['uG'] ?? '',
    sunrise: j['sr'] ?? '', sunset: j['ss'] ?? '',
    chandraRashi: j['cR'] ?? '', chandraPada: j['cP'] ?? '',
    suryaNakshatra: j['sN'] ?? '', suryaPada: j['sP'] ?? '',
    nakPercent: (j['np'] ?? 0).toDouble(),
    amantaMasa: j['aM'] ?? '', pournimantaMasa: j['pM'] ?? '',
    souraMasa: j['sM'] ?? '', souraMasaGataDina: j['sD'] ?? '',
    samvatsara: j['sv'] ?? '', rutu: j['ru'] ?? '', ayana: j['ay'] ?? '',
    divamana: j['dm'] ?? '', ratrimana: j['rm'] ?? '',
    vishaPraghati: j['vP'] ?? '', amrutaPraghati: j['aP'] ?? '', agniVasa: j['ag'] ?? '',
    shakaVarsha: j['sk'] ?? 0, paksha: j['pk'] ?? '',
    chandraUdaya: j['cu'] ?? '', chandraAsta: j['ca'] ?? '',
    sunriseJd: (j['rJ'] ?? 0).toDouble(), sunsetJd: (j['sJ'] ?? 0).toDouble(),
  );
}

/// Lagna transit timing (when a rashi rises/sets)
class LagnaTransit {
  final String rashi;
  final int rashiIndex;
  final String startTime;
  final String endTime;

  const LagnaTransit({
    required this.rashi,
    required this.rashiIndex,
    required this.startTime,
    required this.endTime,
  });
}

/// Muhurta timing entry
class MuhurtaTiming {
  final String name;
  final String startTime;
  final String endTime;
  final String nature; // 'shubha', 'ashubha', 'madhyama'
  final bool isCurrent;

  const MuhurtaTiming({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.nature,
    this.isCurrent = false,
  });

  MuhurtaTiming copyWith({bool? isCurrent}) => MuhurtaTiming(
    name: name,
    startTime: startTime,
    endTime: endTime,
    nature: nature,
    isCurrent: isCurrent ?? this.isCurrent,
  );
}

/// Kala timing (Rahu, Yamaganda, Gulika)
class KalaTiming {
  final String name;
  final String startTime;
  final String endTime;

  const KalaTiming({
    required this.name,
    required this.startTime,
    required this.endTime,
  });
}

/// Hora (Planetary hour) timing
class HoraTiming {
  final String planet;
  final String startTime;
  final String endTime;

  const HoraTiming({
    required this.planet,
    required this.startTime,
    required this.endTime,
  });
}

/// Chougadiya timing
class ChougadiyaTiming {
  final String name;
  final String startTime;
  final String endTime;
  final String nature; // 'shubha', 'ashubha', 'madhyama', 'special'

  const ChougadiyaTiming({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.nature,
  });
}
