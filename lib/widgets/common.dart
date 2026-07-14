/// Design system and common widgets for Bharatiyam Panchanga.
/// Multi-theme support with 5 color presets.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── THEME PRESET ───

class AppThemePreset {
  final String id;
  final String name;
  final String emoji;
  final Color bg;
  final Color card;
  final Color primary;
  final Color accent;
  final Color text;
  final Color muted;
  final Color shubha;
  final Color ashubha;
  final Color madhyama;
  final Brightness brightness;
  final List<Color> gradientColors;

  const AppThemePreset({
    required this.id, required this.name, required this.emoji,
    required this.bg, required this.card, required this.primary,
    required this.accent, required this.text, required this.muted,
    required this.shubha, required this.ashubha, required this.madhyama,
    required this.brightness, required this.gradientColors,
  });

  Color get border => primary.withAlpha(26);
  Color get cardBorder => brightness == Brightness.dark
      ? primary.withAlpha(51) : Colors.black.withAlpha(26);
}

// ─── 5 THEME PRESETS ───

const _themes = <AppThemePreset>[
  // 1. Saffron Light
  AppThemePreset(
    id: 'saffron', name: 'Saffron Light', emoji: '🟠',
    bg: Color(0xFFF8F6F2), card: Color(0xFFFFFFFF),
    primary: Color(0xFFE65100), accent: Color(0xFF00897B),
    text: Color(0xFF212121), muted: Color(0xFF9E9E9E),
    shubha: Color(0xFF2E7D32), ashubha: Color(0xFFD32F2F), madhyama: Color(0xFFEF6C00),
    brightness: Brightness.light,
    gradientColors: [Color(0xFFFFF3E0), Color(0xFFF8F6F2), Color(0xFFF5F0E8)],
  ),
  // 2. Royal Purple Dark
  AppThemePreset(
    id: 'purple', name: 'Royal Purple', emoji: '🟣',
    bg: Color(0xFF0D0221), card: Color(0xFF1A0533),
    primary: Color(0xFFD4A639), accent: Color(0xFF00BFA5),
    text: Color(0xFFF5F0E8), muted: Color(0xFF8B7FA3),
    shubha: Color(0xFF00C853), ashubha: Color(0xFFFF1744), madhyama: Color(0xFFFFB300),
    brightness: Brightness.dark,
    gradientColors: [Color(0xFF1A0533), Color(0xFF0D0221), Color(0xFF0A0118)],
  ),
  // 3. Ocean Blue Dark
  AppThemePreset(
    id: 'ocean', name: 'Ocean Blue', emoji: '🔵',
    bg: Color(0xFF0A1628), card: Color(0xFF132240),
    primary: Color(0xFF42A5F5), accent: Color(0xFF80CBC4),
    text: Color(0xFFE8EAF0), muted: Color(0xFF7B8DA0),
    shubha: Color(0xFF66BB6A), ashubha: Color(0xFFEF5350), madhyama: Color(0xFFFFCA28),
    brightness: Brightness.dark,
    gradientColors: [Color(0xFF132240), Color(0xFF0A1628), Color(0xFF061020)],
  ),
  // 4. Earthy Green Light
  AppThemePreset(
    id: 'earth', name: 'Earthy Green', emoji: '🟢',
    bg: Color(0xFFF5F2EB), card: Color(0xFFFFFFFF),
    primary: Color(0xFF2E7D32), accent: Color(0xFF8D6E63),
    text: Color(0xFF263238), muted: Color(0xFF90A4AE),
    shubha: Color(0xFF388E3C), ashubha: Color(0xFFC62828), madhyama: Color(0xFFF57F17),
    brightness: Brightness.light,
    gradientColors: [Color(0xFFE8F5E9), Color(0xFFF5F2EB), Color(0xFFF1EDE4)],
  ),
  // 5. Maroon Temple
  AppThemePreset(
    id: 'temple', name: 'Temple Maroon', emoji: '🔴',
    bg: Color(0xFF1A0A0A), card: Color(0xFF2D1515),
    primary: Color(0xFFFF8A65), accent: Color(0xFFFFD54F),
    text: Color(0xFFFBE9E7), muted: Color(0xFFA1887F),
    shubha: Color(0xFF81C784), ashubha: Color(0xFFE57373), madhyama: Color(0xFFFFB74D),
    brightness: Brightness.dark,
    gradientColors: [Color(0xFF2D1515), Color(0xFF1A0A0A), Color(0xFF120808)],
  ),
];

// ─── THEME SERVICE ───

class ThemeService {
  static final ThemeService _instance = ThemeService._();
  factory ThemeService() => _instance;
  ThemeService._();

  static final ValueNotifier<String> themeNotifier = ValueNotifier('saffron');

  static AppThemePreset get current =>
      _themes.firstWhere((t) => t.id == themeNotifier.value, orElse: () => _themes[0]);

  static List<AppThemePreset> get allThemes => _themes;

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    themeNotifier.value = prefs.getString('app_theme') ?? 'saffron';
  }

  static Future<void> setTheme(String id) async {
    themeNotifier.value = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', id);
  }
}

// ─── DYNAMIC COLOR GETTERS ───

Color get kBg => ThemeService.current.bg;
Color get kCard => ThemeService.current.card;
Color get kGold => ThemeService.current.primary;
Color get kTeal => ThemeService.current.accent;
Color get kPurple => const Color(0xFF5C6BC0);
Color get kText => ThemeService.current.text;
Color get kMuted => ThemeService.current.muted;
Color get kShubha => ThemeService.current.shubha;
Color get kAshubha => ThemeService.current.ashubha;
Color get kMadhyama => ThemeService.current.madhyama;
Color get kBorder => ThemeService.current.border;
Color get kCardBorder => ThemeService.current.cardBorder;

// ─── THEME BUILDER ───

ThemeData appTheme() {
  final t = ThemeService.current;
  final isDark = t.brightness == Brightness.dark;
  return ThemeData(
    brightness: t.brightness,
    scaffoldBackgroundColor: t.bg,
    primaryColor: t.primary,
    colorScheme: isDark ? ColorScheme.dark(
      primary: t.primary, secondary: t.accent,
      surface: t.card, onPrimary: t.bg, onSecondary: t.bg, onSurface: t.text,
    ) : ColorScheme.light(
      primary: t.primary, secondary: t.accent,
      surface: t.card, onPrimary: Colors.white, onSecondary: Colors.white, onSurface: t.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 20, fontWeight: FontWeight.bold, color: t.primary),
      iconTheme: IconThemeData(color: t.primary),
    ),
    cardTheme: CardThemeData(
      color: t.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: t.cardBorder, width: 1)),
      elevation: isDark ? 8 : 2,
      shadowColor: isDark ? Colors.black54 : Colors.black12,
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 20, fontWeight: FontWeight.bold, color: t.primary),
      titleLarge: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 16, fontWeight: FontWeight.bold, color: t.primary),
      titleMedium: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 14, fontWeight: FontWeight.w600, color: t.text),
      bodyLarge: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 14, color: t.text),
      bodyMedium: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 13, color: t.text),
      bodySmall: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 11, color: t.muted),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: t.card, selectedItemColor: t.primary,
      unselectedItemColor: t.muted, type: BottomNavigationBarType.fixed, elevation: 8,
    ),
    tabBarTheme: TabBarThemeData(labelColor: t.primary, unselectedLabelColor: t.muted, indicatorColor: t.primary),
  );
}

/// Get gradient colors for the current theme
List<Color> get appGradientColors => ThemeService.current.gradientColors;

// ─── GLASSMORPHISM CARD ───

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({super.key, required this.child, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: kCard.withAlpha(178),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder, width: 1),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// ─── SECTION HEADER ───

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kGold.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border(bottom: BorderSide(color: kGold.withAlpha(51), width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGold, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: const TextStyle(
              fontFamily: 'NotoSansKannada',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kGold,
            )),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── KEY-VALUE ROW ───

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? endTime;
  final bool endsNextDay;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.endTime,
    this.endsNextDay = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 12, color: kMuted)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 13, color: valueColor ?? kText, fontWeight: FontWeight.w500)),
                if (endTime != null)
                  Text(
                    '${endsNextDay ? "↪ " : ""}$endTime',
                    style: TextStyle(
                      fontSize: 11,
                      color: endsNextDay ? kMadhyama.withAlpha(178) : kMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TIME CHIP ───

class TimeChip extends StatelessWidget {
  final String time;
  final Color color;

  const TimeChip({super.key, required this.time, this.color = kTeal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(76), width: 1),
      ),
      child: Text(time, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

// ─── NATURE PILL ───

class NaturePill extends StatelessWidget {
  final String nature; // 'shubha', 'ashubha', 'madhyama'

  const NaturePill({super.key, required this.nature});

  Color get _color {
    switch (nature) {
      case 'shubha': return kShubha;
      case 'ashubha': return kAshubha;
      case 'madhyama': return kMadhyama;
      default: return kMuted;
    }
  }

  String get _label {
    switch (nature) {
      case 'shubha': return 'ಶುಭ';
      case 'ashubha': return 'ಅಶುಭ';
      case 'madhyama': return 'ಮಧ್ಯಮ';
      default: return nature;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(_label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _color)),
    );
  }
}

// ─── KALA TIME BAR ───

class KalaTimeBar extends StatelessWidget {
  final String name;
  final String startTime;
  final String endTime;
  final Color color;

  const KalaTimeBar({
    super.key,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.color = kAshubha,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 4, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 12, color: kText))),
          TimeChip(time: '$startTime - $endTime', color: color),
        ],
      ),
    );
  }
}

// ─── MUHURTA LIST ITEM ───

class MuhurtaListItem extends StatelessWidget {
  final int index;
  final String name;
  final String startTime;
  final String endTime;
  final String nature;
  final bool isCurrent;

  const MuhurtaListItem({
    super.key,
    required this.index,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.nature,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? kGold.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent ? Border.all(color: kGold.withAlpha(76), width: 1) : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('${index + 1}', style: TextStyle(fontSize: 11, color: isCurrent ? kGold : kMuted))),
          if (isCurrent) ...[
            const Icon(Icons.play_arrow_rounded, color: kGold, size: 14),
            const SizedBox(width: 4),
          ],
          Expanded(child: Text(name, style: TextStyle(fontSize: 12, color: isCurrent ? kGold : kText))),
          NaturePill(nature: nature),
          const SizedBox(width: 8),
          Text('$startTime - $endTime', style: TextStyle(fontSize: 10, color: isCurrent ? kGold : kMuted)),
        ],
      ),
    );
  }
}

// ─── LAGNA LIST ITEM ───

class LagnaListItem extends StatelessWidget {
  final String rashi;
  final String startTime;
  final String endTime;
  final bool isCurrent;

  const LagnaListItem({
    super.key,
    required this.rashi,
    required this.startTime,
    required this.endTime,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? kTeal.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent ? Border.all(color: kTeal.withAlpha(76), width: 1) : null,
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: kTeal, size: 14),
          const SizedBox(width: 8),
          Expanded(child: Text(rashi, style: TextStyle(fontSize: 12, color: isCurrent ? kTeal : kText))),
          Text('$startTime - $endTime', style: TextStyle(fontSize: 10, color: isCurrent ? kTeal : kMuted)),
        ],
      ),
    );
  }
}

// ─── RESPONSIVE CENTER ───

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 600});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
