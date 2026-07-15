/// Settings Screen — Language selector, location picker, about info.
import 'package:flutter/material.dart';
import '../i18n/app_locale.dart';
import '../services/location_service.dart';
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
  List<CityData> _filteredCities = indianCities;
  bool _detectingGps = false;

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

        // ── Language ──
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gps_fixed_rounded, size: 12, color: kTeal),
                            SizedBox(width: 4),
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
              const Text(
                'ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGold),
              ),
              const SizedBox(height: 4),
              const Text(
                'High-precision Hindu calendar using Swiss Ephemeris.\n'
                'Lahiri Ayanamsha • Mid-limb Sunrise\n'
                '4 Calendar Systems • 15+15 Muhurtas\n'
                '12-Rashi Lagna Transit • Hora • Chougadiya\n'
                '7 Languages • 1900-2100 CE',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: kMuted, height: 1.6),
              ),
              const SizedBox(height: 8),
              const Text('v1.0.0', style: TextStyle(fontSize: 10, color: kMuted)),
            ],
          ),
        ),
      ],
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
}
