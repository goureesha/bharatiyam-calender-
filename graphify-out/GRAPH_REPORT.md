# Graph Report - .  (2026-08-14)

## Corpus Check
- 60 files · ~70,562 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 960 nodes · 1182 edges · 47 communities (42 shown, 5 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 31 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Panchanga Data Model|Panchanga Data Model]]
- [[_COMMUNITY_App Theme & UI|App Theme & UI]]
- [[_COMMUNITY_Calculator Imports|Calculator Imports]]
- [[_COMMUNITY_Calendar Screen|Calendar Screen]]
- [[_COMMUNITY_Grahana Eclipse|Grahana Eclipse]]
- [[_COMMUNITY_Time Calculators|Time Calculators]]
- [[_COMMUNITY_City Data|City Data]]
- [[_COMMUNITY_Build Config|Build Config]]
- [[_COMMUNITY_Ephemeris Engine|Ephemeris Engine]]
- [[_COMMUNITY_Shraddha Calculator|Shraddha Calculator]]
- [[_COMMUNITY_Shraddha Imports|Shraddha Imports]]
- [[_COMMUNITY_Places Constants|Places Constants]]
- [[_COMMUNITY_Screen Navigation|Screen Navigation]]
- [[_COMMUNITY_Core Services|Core Services]]
- [[_COMMUNITY_Adhika Masa|Adhika Masa]]
- [[_COMMUNITY_Profile Firebase|Profile Firebase]]
- [[_COMMUNITY_Sankalpa Generator|Sankalpa Generator]]
- [[_COMMUNITY_i18n Locale|i18n Locale]]
- [[_COMMUNITY_Location Service|Location Service]]
- [[_COMMUNITY_Asta Calculator|Asta Calculator]]
- [[_COMMUNITY_Settings Screen|Settings Screen]]
- [[_COMMUNITY_App Main Entry|App Main Entry]]
- [[_COMMUNITY_Profile Setup|Profile Setup]]
- [[_COMMUNITY_String Maps|String Maps]]
- [[_COMMUNITY_Masa Calculator|Masa Calculator]]
- [[_COMMUNITY_Muhurta Calculator|Muhurta Calculator]]
- [[_COMMUNITY_Common Widgets|Common Widgets]]
- [[_COMMUNITY_Core Calculators|Core Calculators]]
- [[_COMMUNITY_Hora Calculator|Hora Calculator]]
- [[_COMMUNITY_Admin Dashboard|Admin Dashboard]]
- [[_COMMUNITY_Google Services|Google Services]]
- [[_COMMUNITY_Chougadiya|Chougadiya]]
- [[_COMMUNITY_Samvatsara|Samvatsara]]
- [[_COMMUNITY_Ghati Calculator|Ghati Calculator]]
- [[_COMMUNITY_Kala Calculator|Kala Calculator]]
- [[_COMMUNITY_Firebase Options|Firebase Options]]
- [[_COMMUNITY_i18n Strings|i18n Strings]]
- [[_COMMUNITY_Time Models|Time Models]]
- [[_COMMUNITY_Muhurta Models|Muhurta Models]]
- [[_COMMUNITY_Firebase Hosting|Firebase Hosting]]
- [[_COMMUNITY_Plugin Registry|Plugin Registry]]
- [[_COMMUNITY_Fix Scripts|Fix Scripts]]
- [[_COMMUNITY_Home Content|Home Content]]
- [[_COMMUNITY_Malayalam Strings|Malayalam Strings]]
- [[_COMMUNITY_Responsive Widget|Responsive Widget]]

## God Nodes (most connected - your core abstractions)
1. `Ephemeris` - 15 edges
2. `_HomeScreenState` - 13 edges
3. `_CalendarScreenState` - 9 edges
4. `state` - 8 edges
5. `PanchangaData` - 8 edges
6. `_SettingsScreenState` - 8 edges
7. `LocationService` - 8 edges
8. `dateTime` - 7 edges
9. `_PanchangaScreenState` - 7 edges
10. `App Icon (Panchanga emblem with Ganesha, Diyas, and Kannada title)` - 7 edges

## Surprising Connections (you probably didn't know these)
- `build-apk CI Job` --references--> `App Icon (Panchanga emblem with Ganesha, Diyas, and Kannada title)`  [INFERRED]
  .github/workflows/build.yml → assets/app_icon.png
- `firebase.json (Firebase Hosting Config)` --references--> `Admin Dashboard (admin/index.html)`  [EXTRACTED]
  firebase.json → admin/index.html
- `Firebase Admin Config` --shares_data_with--> `google-services.json (Android Firebase Config)`  [INFERRED]
  admin/index.html → android/app/google-services.json
- `flutter_launcher_icons Configuration` --references--> `App Icon (Panchanga emblem with Ganesha, Diyas, and Kannada title)`  [EXTRACTED]
  pubspec.yaml → assets/app_icon.png
- `fix_const.dart Script` --semantically_similar_to--> `fix_const.py Script`  [INFERRED] [semantically similar]
  fix_const.dart → fix_const.py

## Import Cycles
- None detected.

## Communities (47 total, 5 thin omitted)

### Community 0 - "Panchanga Data Model"
Cohesion: 0.02
Nodes (95): agniVasa, amantaMasa, amrutaPraghati, ayana, chandraAsta, chandraPada, chandraRashi, chandraUdaya (+87 more)

### Community 1 - "App Theme & UI"
Cohesion: 0.03
Nodes (66): Color get, EdgeInsetsGeometry?, static AppThemePreset get, static final ThemeService, Widget, accent, allThemes, appGradientColors (+58 more)

### Community 2 - "Calculator Imports"
Cohesion: 0.03
Nodes (57): Color, ../core/adhika_masa_calculator.dart, ../core/asta_calculator.dart, ../core/grahana_calculator.dart, ../core/sankalpa_generator.dart, IconData, build, _buildAmantaEntries (+49 more)

### Community 3 - "Calendar Screen"
Cohesion: 0.05
Nodes (42): state, ../core/samvatsara.dart, GlobalKey, int?, _angaRow, build, _buildFullDetail, _buildMonthBar (+34 more)

### Community 4 - "Grahana Eclipse"
Cohesion: 0.05
Nodes (42): _buildGlobalLunarEclipseInfo, _buildGlobalSolarEclipseInfo, _buildLunarEclipseInfo, _buildSolarEclipseInfo, _calcDuration, calculateForYear, date, durationText (+34 more)

### Community 5 - "Time Calculators"
Cohesion: 0.05
Nodes (39): ../core/chougadiya_calculator.dart, ../core/ghati_calculator.dart, ../core/hora_calculator.dart, ../core/lagna_calculator.dart, ../core/muhurta_calculator.dart, _abhijit, build, _buildAppBar (+31 more)

### Community 6 - "City Data"
Cohesion: 0.09
Nodes (39): CityData, indianCities, karnatakaCities, otherIndianCities, worldCities, WorldCitiesDb, CalendarScreen, _CalendarScreenState (+31 more)

### Community 7 - "Build Config"
Cohesion: 0.06
Nodes (32): gradlew (Gradle Wrapper Script), ic_launcher.png (mipmap-hdpi), ic_launcher.png (mipmap-mdpi), ic_launcher.png (mipmap-xhdpi), ic_launcher.png (mipmap-xxhdpi), ic_launcher.png (mipmap-xxxhdpi), App Icon (Panchanga emblem with Ganesha, Diyas, and Kannada title), panchanga_3yr.json (Bundled 3-Year Panchanga Cache) (+24 more)

### Community 8 - "Ephemeris Engine"
Cohesion: 0.05
Nodes (35): calcAll, findMoonriseSet, findSunriseSetForDate, formatDuration, formatGhati, formatTimeFromJd, getAltitudeManual, getAyanamsa (+27 more)

### Community 9 - "Shraddha Calculator"
Cohesion: 0.05
Nodes (36): aparahnaEnd, aparahnaShraddha, aparahnaStart, aparahnaStartGhati, aparahnaTimeEnd, aparahnaTimeStart, _calcAparahna, _calcKutupa (+28 more)

### Community 10 - "Shraddha Imports"
Cohesion: 0.06
Nodes (33): ../core/shraddha_calculator.dart, dart:io, dart:typed_data, dart:ui, dir, dynamicVars, main, ../i18n/app_locale.dart (+25 more)

### Community 11 - "Places Constants"
Cohesion: 0.06
Nodes (32): bool get, CityData, indianCities, karnatakaCities, lat, loadWorldCities, lon, name (+24 more)

### Community 12 - "Screen Navigation"
Cohesion: 0.06
Nodes (33): calendar_screen.dart, ../core/kala_calculator.dart, mahiti_screen.dart, panchanga_screen.dart, build, _buildDateBar, _buildHeader, _buildHome (+25 more)

### Community 13 - "Core Services"
Cohesion: 0.07
Nodes (26): ../core/ephemeris.dart, ../core/masa_calculator.dart, ../core/panchanga_calculator.dart, location_service.dart, computedDays, _computing, data, _dataCache (+18 more)

### Community 14 - "Adhika Masa"
Cohesion: 0.09
Nodes (22): AdhikaMasaCalculator, amavasya1, amavasya2, calculateForYear, _determineMasaName, _findAllAmavasyas, findAllPurnimas, findAllSankrantisForYear (+14 more)

### Community 15 - "Profile Firebase"
Cohesion: 0.09
Nodes (22): package:cloud_firestore/cloud_firestore.dart, package:flutter/foundation.dart, package:uuid/uuid.dart, _address, checkFirebase, _deviceId, _docId, _firebaseReady (+14 more)

### Community 16 - "Sankalpa Generator"
Cohesion: 0.09
Nodes (21): generate, getAyanaFromMonth, getNakshatraName, getPaksha, getRitu, getSamvatsara, getShakaYear, getTithiName (+13 more)

### Community 17 - "i18n Locale"
Cohesion: 0.09
Nodes (21): current, isKannada, langNotifier, languageNames, loadLang, _reverseCache, _reverseCacheLang, setLang (+13 more)

### Community 18 - "Location Service"
Cohesion: 0.11
Nodes (18): ../constants/places.dart, package:geolocator/geolocator.dart, package:shared_preferences/shared_preferences.dart, cityName, cityNameKn, detectGps, _findNearestCity, lat (+10 more)

### Community 19 - "Asta Calculator"
Cohesion: 0.11
Nodes (18): _angularSeparation, AstaCalculator, AstaPeriod, calculateGuruAsta, calculateShukraAsta, durationDays, end, _findAstaPeriods (+10 more)

### Community 20 - "Settings Screen"
Cohesion: 0.11
Nodes (18): List, _addressCtrl, build, createState, _detectingGps, _filteredCities, _mobileCtrl, _nameCtrl (+10 more)

### Community 21 - "App Main Entry"
Cohesion: 0.14
Nodes (17): firebase_options.dart, DefaultFirebaseOptions, _AppGate, _AppGateState, BharatiyamPanchangaApp, build, createState, _initFirebase (+9 more)

### Community 22 - "Profile Setup"
Cohesion: 0.13
Nodes (15): FormState, _addressCtrl, build, _buildField, createState, dispose, _formKey, _mobileCtrl (+7 more)

### Community 23 - "String Maps"
Cohesion: 0.13
Nodes (8): Map, enStrings, hiStrings, knStrings, mlStrings, saStrings, taStrings, teStrings

### Community 24 - "Masa Calculator"
Cohesion: 0.15
Nodes (12): calculateAmanta, calculatePournimanta, calculateSouraMasa, _findFullMoon, _findNewMoon, _masaFromSunRashi, masaKeys, _refineFullMoonTropical (+4 more)

### Community 25 - "Muhurta Calculator"
Cohesion: 0.15
Nodes (12): _amritaSiddhiCombos, calculateAbhijit, calculateDayMuhurtas, calculateDurmuhurta, calculateNightMuhurtas, calculateVarjyam, _dayMuhurtas, _durmuhurtaOffsets (+4 more)

### Community 26 - "Common Widgets"
Cohesion: 0.17
Nodes (12): _InfoSection, StatelessWidget, AppCard, InfoRow, KalaTimeBar, LagnaListItem, MuhurtaListItem, NaturePill (+4 more)

### Community 27 - "Core Calculators"
Cohesion: 0.25
Nodes (11): Ephemeris, GhatiCalculator, LagnaCalculator, MasaCalculator, PanchangaCalculator, SamvatsaraCalculator, SankalpaGenerator, ShraddhaCalculator (+3 more)

### Community 28 - "Hora Calculator"
Cohesion: 0.20
Nodes (9): calculateDayHoras, calculateNightHoras, _dayStart, _planetOrder, calculateDayLagnas, calculateNightLagnas, _scanLagnas, ephemeris.dart (+1 more)

### Community 29 - "Admin Dashboard"
Cohesion: 0.33
Nodes (7): exportCSV() / Export Users CSV, Firebase Admin Config, Admin Dashboard (admin/index.html), refreshData() / Firestore User Query, signIn() / Google Auth Handler, google-services.json (Android Firebase Config), firebase.json (Firebase Hosting Config)

### Community 30 - "Google Services"
Cohesion: 0.29
Nodes (6): client, configuration_version, project_info, project_id, project_number, storage_bucket

### Community 31 - "Chougadiya"
Cohesion: 0.29
Nodes (6): calculateDay, calculateNight, _dayStart, _names, _natures, _nightStart

### Community 32 - "Samvatsara"
Cohesion: 0.29
Nodes (6): calculate, calculateAyana, calculateRutu, _oldYearMasaKeys, _rutuMap, samvatsaraKeys

### Community 33 - "Ghati Calculator"
Cohesion: 0.33
Nodes (5): amrutaGhatis, calculateAmrutaGhati, _calculateGhati, calculateVishaGhati, vishaGhatis

### Community 34 - "Kala Calculator"
Cohesion: 0.33
Nodes (5): calculate, _gulikaKala, _rahuKala, _yamaganda, static const List

### Community 35 - "Firebase Options"
Cohesion: 0.33
Nodes (5): android, currentPlatform, package:firebase_core/firebase_core.dart, static const FirebaseOptions, static FirebaseOptions get

### Community 36 - "i18n Strings"
Cohesion: 0.33
Nodes (6): enStrings, hiStrings, knStrings, saStrings, taStrings, teStrings

### Community 37 - "Time Models"
Cohesion: 0.50
Nodes (4): ChougadiyaCalculator, HoraCalculator, ChougadiyaTiming, HoraTiming

### Community 38 - "Muhurta Models"
Cohesion: 0.50
Nodes (4): KalaCalculator, MuhurtaCalculator, KalaTiming, MuhurtaTiming

### Community 39 - "Firebase Hosting"
Cohesion: 0.50
Nodes (3): hosting, ignore, public

## Knowledge Gaps
- **689 isolated node(s):** `project_number`, `project_id`, `storage_bucket`, `client`, `configuration_version` (+684 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PanchangaData` connect `Core Calculators` to `Panchanga Data Model`, `Time Calculators`, `Shraddha Imports`, `Screen Navigation`, `Core Services`?**
  _High betweenness centrality (0.173) - this node is a cross-community bridge._
- **Why does `Ephemeris` connect `Core Calculators` to `Time Models`, `Muhurta Models`, `City Data`, `Ephemeris Engine`, `Asta Calculator`?**
  _High betweenness centrality (0.089) - this node is a cross-community bridge._
- **Why does `dateTime` connect `Asta Calculator` to `Calculator Imports`, `Calendar Screen`, `Grahana Eclipse`, `Time Calculators`, `Screen Navigation`, `Adhika Masa`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **What connects `project_number`, `project_id`, `storage_bucket` to the rest of the system?**
  _689 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Panchanga Data Model` be split into smaller, more focused modules?**
  _Cohesion score 0.020833333333333332 - nodes in this community are weakly interconnected._
- **Should `App Theme & UI` be split into smaller, more focused modules?**
  _Cohesion score 0.029850746268656716 - nodes in this community are weakly interconnected._
- **Should `Calculator Imports` be split into smaller, more focused modules?**
  _Cohesion score 0.034482758620689655 - nodes in this community are weakly interconnected._