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

  // Raw JDs for timing calculations
  final double sunriseJd;
  final double sunsetJd;

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
    required this.sunriseJd,
    required this.sunsetJd,
  });
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
