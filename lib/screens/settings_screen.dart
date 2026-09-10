/// Settings Screen — Profile editor, language selector, location picker, about info.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../i18n/app_locale.dart';
import '../services/location_service.dart';
import '../services/profile_service.dart';
import '../constants/places.dart';
import 'dart:io';
import '../widgets/common.dart';
import '../services/profile_image_service.dart';

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
              SectionHeader(icon: Icons.person_rounded, title: AppLocale.t('profileHeader')),
              const SizedBox(height: 8),
              // Profile Photo Upload
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final ok = await ProfileImageService.pickAndSave();
                    if (ok && mounted) setState(() {});
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kGold, width: 2),
                          color: kCard,
                        ),
                        child: ProfileImageService.hasImage
                          ? ClipOval(child: Image.file(File(ProfileImageService.imagePath!), width: 80, height: 80, fit: BoxFit.cover))
                          : Icon(Icons.person, size: 40, color: kMuted),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: kGold),
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (ProfileImageService.hasImage)
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      await ProfileImageService.remove();
                      if (mounted) setState(() {});
                    },
                    icon: Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: Text(AppLocale.t('removePhoto'), style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ),
              const SizedBox(height: 12),
              _profileField(_nameCtrl, AppLocale.t('profileName'), Icons.person_outline_rounded),
              const SizedBox(height: 10),
              _profileField(_addressCtrl, AppLocale.t('profileAddress'), Icons.location_on_outlined, maxLines: 2),
              const SizedBox(height: 10),
              _profileField(_mobileCtrl, AppLocale.t('profileMobile'), Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: Icon(_profileSaved ? Icons.check : Icons.save_rounded, color: Colors.white, size: 18),
                      label: Text(_profileSaved ? AppLocale.t('savedSuccess') : AppLocale.t('saveProfile'),
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

        // ── About (expandable dropdown with all info) ──
        const _AboutDropdown(),

        // ── Privacy Policy ──
        AppCard(
          child: Column(
            children: [
              const SectionHeader(icon: Icons.privacy_tip_outlined, title: 'Privacy & Policy'),
              const SizedBox(height: 8),
              Text(
                AppLocale.t('privacyTitle'),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGold),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocale.t('privacyDesc'),
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

  Widget _ruleHeader(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: kGold.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kGold)),
    );
  }

  Widget _ruleItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 10, color: kGold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '$title: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kText)),
                  TextSpan(text: desc, style: TextStyle(fontSize: 9, color: kMuted, height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _masaRule(String masa, String events) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(masa, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTeal)),
          ),
          Expanded(
            child: Text(events, style: TextStyle(fontSize: 9, color: kMuted, height: 1.3)),
          ),
        ],
      ),
    );
  }
}

/// About dropdown — expandable card with app info, events, and license at the bottom
class _AboutDropdown extends StatefulWidget {
  const _AboutDropdown();

  @override
  State<_AboutDropdown> createState() => _AboutDropdownState();
}

class _AboutDropdownState extends State<_AboutDropdown> {
  bool _expanded = false;

  Widget _sectionTitle(String emoji, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      margin: const EdgeInsets.only(top: 14, bottom: 6),
      decoration: BoxDecoration(
        color: kGold.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$emoji $title', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kGold)),
    );
  }

  Widget _infoItem(String label, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 10, color: kGold)),
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kText))),
          Expanded(child: Text(desc, style: TextStyle(fontSize: 9, color: kMuted, height: 1.3))),
        ],
      ),
    );
  }

  Widget _masaItem(String masa, String events) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 75, child: Text(masa, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTeal))),
          Expanded(child: Text(events, style: TextStyle(fontSize: 9, color: kMuted, height: 1.3))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tap header to expand/collapse
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: kGold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(AppLocale.t('about'),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold)),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: kGold),
                ),
              ],
            ),
          ),

          // Collapsed: show brief summary
          if (!_expanded) ...[
            const SizedBox(height: 6),
            Text(
              AppLocale.t('appName'),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kGold),
            ),
            const SizedBox(height: 2),
            Text('v1.3.7 • Hindu Calendar & Panchanga',
              style: TextStyle(fontSize: 10, color: kMuted)),
          ],

          // Expanded: full content in a fixed-height scrollable area
          if (_expanded) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 400,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, Colors.white, Colors.white.withAlpha(0)],
                  stops: const [0.0, 0.85, 0.95, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ── App Info ──
                    Center(
                      child: Text(AppLocale.t('appName'),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGold)),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text('v1.3.7 • ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ',
                        style: TextStyle(fontSize: 11, color: kMuted)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bharatiyam Panchanga is a high-precision Hindu calendar app '
                      'built for the Dharmic community. It provides accurate daily '
                      'panchanga with Tithi, Nakshatra, Yoga, Karana, and Vara computed '
                      'using the Swiss Ephemeris astronomical engine with Lahiri Ayanamsha.',
                      style: TextStyle(fontSize: 10, color: kText, height: 1.5),
                    ),

                    // ── Features ──
                    _sectionTitle('✨', 'Features'),
                    _infoItem('Panchanga', '5-limb daily panchanga with Ghati-Vighati precision'),
                    _infoItem('Calendar', '4 calendar systems — Shaka, Amanta, Pournimanta, Soura'),
                    _infoItem('Muhurta', '15 day + 15 night Muhurtas with Abhijit & Godhuli'),
                    _infoItem('Hora', '24-hour planetary Hora cycle for auspicious timing'),
                    _infoItem('Lagna', '12-Rashi Lagna transit times with real-time tracking'),
                    _infoItem('Kala', 'Rahu Kala, Yama Ghanta, Gulika Kala, Durmuhurta'),
                    _infoItem('Chougadiya', '8-period Chougadiya with Shubha/Ashubha marking'),
                    _infoItem('Festivals', '88+ festivals with Dharma Sindhu timing rules'),
                    _infoItem('Shraddha', 'Pitru Shraddha calculator with Tithi matching'),
                    _infoItem('Languages', '7 languages — ಕನ್ನಡ, हिन्दी, தமிழ், తెలుగు, മലയാളം, संस्कृतम्, English'),
                    _infoItem('Date Range', '1900 CE to 2100 CE coverage'),
                    _infoItem('Sharing', 'Beautiful panchanga cards with profile photo'),

                    // ── Calculation Method ──
                    _sectionTitle('🔬', 'Calculation Method'),
                    Text(
                      'All astronomical calculations use the Swiss Ephemeris engine '
                      '(DE431 planetary ephemeris from NASA JPL). Accuracy: < 0.001 arc '
                      'seconds for planets, < 0.01 arc seconds for the Moon. Sunrise and '
                      'sunset are computed using mid-limb method with atmospheric refraction '
                      'correction. Ayanamsha: Lahiri (Chitrapaksha).',
                      style: TextStyle(fontSize: 10, color: kText, height: 1.5),
                    ),

                    // ── Timing Rules ──
                    _sectionTitle('⏰', 'Festival Timing Rules (Vyapti Nirnaya)'),
                    Text(
                      'All festivals follow authentic Dharma Sindhu and Nirnaya Sindhu '
                      'timing rules. Events are assigned using Vyapti (prevalence) at '
                      'specific time points:',
                      style: TextStyle(fontSize: 10, color: kMuted, height: 1.5),
                    ),
                    const SizedBox(height: 6),
                    _infoItem('Purva Viddha', 'Tithi at SUNRISE — first day observed'),
                    _infoItem('Para Viddha', 'Tithi at SUNRISE — second day observed (all Ekadashi)'),
                    _infoItem('Madhyahna', 'Tithi at NOON — Rama Navami, Ganesha Chaturthi, Sita Navami'),
                    _infoItem('Pradosha', 'Tithi at SUNSET — Narasimha Jayanti, Pradosha Vrata'),
                    _infoItem('Nishitha', 'Tithi at MIDNIGHT — Janmashtami, Maha Shivaratri'),
                    _infoItem('Chandrodaya', 'Tithi at MOONRISE — Sankashthahara, Karva Chauth'),

                    // ── Monthly Events ──
                    _sectionTitle('🔁', 'Monthly Recurring Events'),
                    _infoItem('Ekadashi', 'Shukla & Krishna — Para Viddha, Vishnu worship'),
                    _infoItem('Pradosha', 'Shukla & Krishna Trayodashi — Shiva worship at sunset'),
                    _infoItem('Sankashthahara', 'Krishna Chaturthi — Ganesha worship at moonrise'),
                    _infoItem('Vinayaka', 'Shukla Chaturthi — Monthly Ganapati puja'),
                    _infoItem('Shivaratri', 'Krishna Chaturdashi — Midnight Shiva worship'),
                    _infoItem('Purnima', 'Purva Viddha — Satyanarayan puja'),
                    _infoItem('Amavasya', 'Purva Viddha — Pitru Tarpana'),

                    // ── 88 Events by Masa ──
                    _sectionTitle('🎯', '88 Masa-Specific Events'),
                    _masaItem('Chaitra', 'Yugadi, Gauri Tritiya, Skanda Shashthi, Rama Navami, Kamada Ekadashi, Hanumaj Jayanti, Ananga Trayodashi'),
                    _masaItem('Vaishakha', 'Akshaya Tritiya, Shankaracharya Jayanti, Gangotpatti, Sita Navami, Mohini Ekadashi, Narasimha Jayanti, Buddha Purnima'),
                    _masaItem('Jyeshtha', 'Ganga Dashahara, Nirjala Ekadashi, Vata Savitri, Shani Amavasya'),
                    _masaItem('Ashadha', 'Ratha Yatra, Shayani Ekadashi, Guru Purnima, Deepa Amavasya'),
                    _masaItem('Shravana', 'Mangala Gauri, Hariyali Teej, Naga Panchami, Raksha Bandhan, Krishna Janmashtami'),
                    _masaItem('Bhadrapada', 'Swarna Gauri, Ganesha Chaturthi, Rishi Panchami, Ananta Chaturdashi, Mahalaya Amavasya'),
                    _masaItem('Ashvina', 'Sharad Navaratri, Vijayadashami, Karva Chauth, Dhana Trayodashi, Deepavali'),
                    _masaItem('Kartika', 'Bali Padyami, Yama Dvitiya, Gopashtami, Prabodhini Ekadashi, Kartika Purnima'),
                    _masaItem('Margashira', 'Subrahmanya Shashthi, Vaikuntha Ekadashi, Dattatreya Jayanti, Kalabhairava Ashtami'),
                    _masaItem('Pushya', 'Putrada Ekadashi, Pushya Purnima, Tila Chaturthi, Mauna Amavasya'),
                    _masaItem('Magha', 'Vasanta Panchami, Ratha Saptami, Bhishma Ashtami, Maha Shivaratri, Mauni Amavasya'),
                    _masaItem('Phalguna', 'Ganesha Jayanti, Amalaki Ekadashi, Holi/Kama Dahana'),

                    // ── Special Rules ──
                    _sectionTitle('📅', 'Vriddhi & Kshaya Tithi'),
                    Text(
                      'Vriddhi (extended): Same tithi at two sunrises — Purva Viddha on first day, '
                      'Para Viddha on second day.\n\n'
                      'Kshaya (skipped): Tithi ends before next sunrise — event fires on the day '
                      'where tithi exists at the specified vyapti time.\n\n'
                      'Adhika Masa: No festivals during intercalary month (Dharma Sindhu).',
                      style: TextStyle(fontSize: 10, color: kMuted, height: 1.5),
                    ),

                    // ── Contact ──
                    _sectionTitle('📧', 'Contact & Support'),
                    Text(
                      'Email: bharatiyampanchanga@gmail.com\n'
                      'Developer: Goureesha\n'
                      'Made with ❤️ for the Dharmic community',
                      style: TextStyle(fontSize: 10, color: kText, height: 1.6),
                    ),

                    const SizedBox(height: 40),

                    // ── License (buried at the bottom) ──
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        children: [
                          Text('Astronomical Engine', style: TextStyle(fontSize: 9, color: kMuted)),
                          Text('Swiss Ephemeris © Astrodienst AG', style: TextStyle(fontSize: 8, color: kMuted)),
                          Text('AGPL-3.0 • astro.com/swisseph', style: TextStyle(fontSize: 8, color: kMuted)),
                          const SizedBox(height: 4),
                          Text('Source: github.com/goureesha/bharatiyam-calender-',
                            style: TextStyle(fontSize: 7, color: kMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
