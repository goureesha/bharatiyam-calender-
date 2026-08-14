/// Settings Screen — Profile editor, language selector, location picker, about info.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../i18n/app_locale.dart';
import '../services/location_service.dart';
import '../services/profile_service.dart';
import '../constants/places.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onLocationChanged;

  const SettingsScreen({super.key, this.onLocationChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController(text: ProfileService.name);
  final TextEditingController _addressCtrl = TextEditingController(text: ProfileService.address);
  final TextEditingController _mobileCtrl = TextEditingController(text: ProfileService.mobile);
  List<CityData> _filteredCities = indianCities;
  bool _detectingGps = false;
  bool _profileSaved = false;

  Future<void> _saveProfile() async {
    await ProfileService.save(
      name: _nameCtrl.text,
      address: _addressCtrl.text,
      mobile: _mobileCtrl.text,
    );
    setState(() => _profileSaved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _profileSaved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(AppLocale.t('settings'),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kGold)),
        ),

        // ── Profile ──
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(icon: Icons.person_rounded, title: 'ಪ್ರೊಫೈಲ್ / Profile'),
              const SizedBox(height: 12),
              _profileField(_nameCtrl, 'ಹೆಸರು / Name', Icons.person_outline_rounded),
              const SizedBox(height: 10),
              _profileField(_addressCtrl, 'ವಿಳಾಸ / Address', Icons.location_on_outlined, maxLines: 2),
              const SizedBox(height: 10),
              _profileField(_mobileCtrl, 'ಮೊಬೈಲ್ / Mobile', Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: Icon(_profileSaved ? Icons.check : Icons.save_rounded, color: Colors.white, size: 18),
                      label: Text(_profileSaved ? 'Saved ✓' : 'Save Profile',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _profileSaved ? Colors.green : kGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Firestore connection status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ProfileService.isFirebaseReady
                    ? Colors.green.withAlpha(20) : Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ProfileService.isFirebaseReady
                    ? Colors.green.withAlpha(76) : Colors.red.withAlpha(76)),
                ),
                child: Row(
                  children: [
                    Icon(
                      ProfileService.isFirebaseReady ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                      color: ProfileService.isFirebaseReady ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Firestore: ${ProfileService.firebaseStatus}',
                        style: TextStyle(
                          fontSize: 11,
                          color: ProfileService.isFirebaseReady ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await ProfileService.checkFirebase();
                        setState(() {});
                      },
                      child: Icon(Icons.refresh_rounded, color: kMuted, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(icon: Icons.language_rounded, title: AppLocale.t('language')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppLocale.languageNames.entries.map((e) {
                  final isSelected = AppLocale.current == e.key;
                  return GestureDetector(
                    onTap: () {
                      AppLocale.setLang(e.key);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? kGold.withAlpha(30) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? kGold : kBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(e.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? kGold : kText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // ── Theme ──
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(icon: Icons.palette_rounded, title: 'Theme'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ThemeService.allThemes.map((t) {
                  final isSelected = ThemeService.themeNotifier.value == t.id;
                  return GestureDetector(
                    onTap: () {
                      ThemeService.setTheme(t.id);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? t.primary.withAlpha(30) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? t.primary : kBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                              color: t.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: t.bg, width: 2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(t.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? kGold : kText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // ── Location ──
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                icon: Icons.location_on_rounded,
                title: AppLocale.t('location'),
                trailing: _detectingGps
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: kGold))
                  : GestureDetector(
                      onTap: _onDetectGps,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kTeal.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: kTeal.withAlpha(76)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gps_fixed_rounded, size: 12, color: kTeal),
                            const SizedBox(width: 4),
                            Text('GPS', style: TextStyle(fontSize: 10, color: kTeal, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
              ),
              const SizedBox(height: 8),

              // Current location
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kGold.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.place_rounded, color: kGold, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocale.isKannada ? LocationService.cityNameKn : LocationService.cityName,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold),
                          ),
                          Text(
                            '${LocationService.lat.toStringAsFixed(4)}°N, ${LocationService.lon.toStringAsFixed(4)}°E',
                            style: TextStyle(fontSize: 10, color: kMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // City search
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorder),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(fontSize: 13, color: kText),
                  decoration: InputDecoration(
                    hintText: AppLocale.t('search'),
                    hintStyle: TextStyle(color: kMuted, fontSize: 12),
                    prefixIcon: Icon(Icons.search_rounded, color: kMuted, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (q) {
                    setState(() => _filteredCities = LocationService.searchCities(q));
                  },
                ),
              ),
              const SizedBox(height: 8),

              // City list
              SizedBox(
                height: 240,
                child: ListView.builder(
                  itemCount: _filteredCities.length,
                  itemBuilder: (ctx, i) {
                    final city = _filteredCities[i];
                    final isSelected = LocationService.cityName == city.name;
                    return GestureDetector(
                      onTap: () => _onSelectCity(city),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? kGold.withAlpha(20) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: kGold.withAlpha(76)) : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                              size: 16,
                              color: isSelected ? kGold : kMuted,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocale.isKannada ? city.nameKn : city.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? kGold : kText,
                                    ),
                                  ),
                                  Text(city.state,
                                    style: TextStyle(fontSize: 10, color: kMuted)),
                                ],
                              ),
                            ),
                            Text(
                              '${city.lat.toStringAsFixed(2)}°N',
                              style: TextStyle(fontSize: 10, color: kMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── About ──
        AppCard(
          child: Column(
            children: [
              const SectionHeader(icon: Icons.info_outline_rounded, title: 'About'),
              const SizedBox(height: 8),
              Text(
                'ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGold),
              ),
              const SizedBox(height: 4),
              Text(
                'High-precision Hindu calendar using Swiss Ephemeris.\n'
                'Lahiri Ayanamsha • Mid-limb Sunrise\n'
                '4 Calendar Systems • 15+15 Muhurtas\n'
                '12-Rashi Lagna Transit • Hora • Chougadiya\n'
                '7 Languages • 1900-2100 CE',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: kMuted, height: 1.6),
              ),
              const SizedBox(height: 8),
              Text('v1.0.0', style: TextStyle(fontSize: 10, color: kMuted)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      '⚖️ Open Source License',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kGold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Swiss Ephemeris © Astrodienst AG\n'
                      'Licensed under AGPL-3.0\n'
                      'astro.com/swisseph',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 9, color: kMuted, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => showLicensePage(
                          context: context,
                          applicationName: 'ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ',
                          applicationVersion: 'v1.0.0',
                          applicationLegalese: '© 2024 Bharatiyam\nSwiss Ephemeris © Astrodienst AG (AGPL-3.0)',
                        ),
                        icon: Icon(Icons.description_outlined, size: 14),
                        label: Text('View All Licenses', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kGold,
                          side: BorderSide(color: kGold.withAlpha(80)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Privacy Policy ──
        AppCard(
          child: Column(
            children: [
              const SectionHeader(icon: Icons.privacy_tip_outlined, title: 'Privacy & Policy'),
              const SizedBox(height: 8),
              Text(
                'ನಿಮ್ಮ ಗೌಪ್ಯತೆ ನಮಗೆ ಮುಖ್ಯ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGold),
              ),
              const SizedBox(height: 6),
              Text(
                'ಈ ಅಪ್ಲಿಕೇಶನ್ ನಿಮ್ಮ ಸ್ಥಳ ಮತ್ತು ಪ್ರೊಫೈಲ್ ಮಾಹಿತಿಯನ್ನು '
                'ಪಂಚಾಂಗ ಲೆಕ್ಕಾಚಾರಕ್ಕಾಗಿ ಮಾತ್ರ ಬಳಸುತ್ತದೆ.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: kMuted, height: 1.5),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPrivacyPolicy(context),
                  icon: Icon(Icons.article_outlined, size: 14),
                  label: Text('Read Full Policy', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kGold,
                    side: BorderSide(color: kGold.withAlpha(80)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.privacy_tip_rounded, color: kGold, size: 22),
                  const SizedBox(width: 8),
                  Text('Privacy Policy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGold)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: kMuted, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ - ಗೌಪ್ಯತಾ ನೀತಿ\n'
                    'Bharatiyam Panchanga - Privacy Policy\n'
                    '━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n'
                    'Last Updated: August 2024\n\n'
                    '1. DATA WE COLLECT\n'
                    '─────────────────\n'
                    '• Location (GPS or manual city selection)\n'
                    '  Used solely for calculating accurate sunrise,\n'
                    '  sunset, and panchanga for your location.\n\n'
                    '• Profile Info (Name, Address, Mobile)\n'
                    '  Optional. Used only to display on shared\n'
                    '  panchanga cards if you choose to share.\n\n'
                    '• Device ID (anonymous UUID)\n'
                    '  Generated once on first launch. Used to\n'
                    '  track app usage statistics only.\n\n'
                    '2. HOW WE USE DATA\n'
                    '──────────────────\n'
                    '• Panchanga calculations (Tithi, Nakshatra,\n'
                    '  Yoga, Karana, Muhurta, etc.)\n'
                    '• Generating shareable panchanga cards\n'
                    '• Tracking last seen & share count for\n'
                    '  app improvement analytics\n\n'
                    '3. DATA STORAGE\n'
                    '───────────────\n'
                    '• Profile data is stored locally on your device\n'
                    '  using SharedPreferences.\n'
                    '• A copy is synced to Google Firebase Firestore\n'
                    '  for backup and analytics.\n'
                    '• No data is sold or shared with third parties.\n\n'
                    '4. THIRD-PARTY SERVICES\n'
                    '──────────────────────\n'
                    '• Google Firebase (Firestore) — for data sync\n'
                    '• Swiss Ephemeris — astronomical calculations\n'
                    '  (all computations happen on-device)\n\n'
                    '5. PERMISSIONS\n'
                    '─────────────\n'
                    '• Location: For accurate panchanga based on\n'
                    '  your geographic position.\n'
                    '• Internet: For Firebase sync and updates.\n'
                    '• Storage: For saving shared panchanga images.\n\n'
                    '6. DATA DELETION\n'
                    '────────────────\n'
                    '• Uninstalling the app removes all local data.\n'
                    '• To delete Firebase data, contact:\n'
                    '  bharatiyampanchanga@gmail.com\n\n'
                    '7. CHILDREN\'S PRIVACY\n'
                    '────────────────────\n'
                    '• This app does not knowingly collect data\n'
                    '  from children under 13.\n\n'
                    '8. CONTACT\n'
                    '──────────\n'
                    '• For questions about this policy:\n'
                    '  bharatiyampanchanga@gmail.com\n\n'
                    '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
                    'By using this app, you agree to this policy.',
                    style: TextStyle(fontSize: 11, color: kText, height: 1.6, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onDetectGps() async {
    setState(() => _detectingGps = true);
    final success = await LocationService.detectGps();
    setState(() => _detectingGps = false);
    if (success) {
      widget.onLocationChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('📍 ${LocationService.cityName}'),
          backgroundColor: kCard,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('GPS not available. Select a city manually.'),
          backgroundColor: kCard,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _onSelectCity(CityData city) async {
    await LocationService.setCity(city);
    setState(() {});
    widget.onLocationChanged?.call();
  }

  Widget _profileField(TextEditingController ctrl, String label, IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(color: kText, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: kMuted, fontSize: 12),
        prefixIcon: Icon(icon, color: kGold, size: 18),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: kBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kGold, width: 1.5)),
      ),
    );
  }
}
