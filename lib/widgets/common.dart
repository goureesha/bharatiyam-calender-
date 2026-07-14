/// Design system and common widgets for Bharatiyam Panchanga.
/// Clean white & orange modern minimalist theme.
import 'package:flutter/material.dart';

// ─── COLOR CONSTANTS ───

const Color kBg = Color(0xFFF8F6F2);           // Warm off-white
const Color kCard = Color(0xFFFFFFFF);           // Pure white cards
const Color kGold = Color(0xFFE65100);           // Deep orange (primary)
const Color kTeal = Color(0xFF00897B);           // Teal accent
const Color kPurple = Color(0xFF5C6BC0);         // Indigo accent
const Color kText = Color(0xFF212121);           // Near-black text
const Color kMuted = Color(0xFF9E9E9E);          // Grey muted
const Color kShubha = Color(0xFF2E7D32);         // Green for shubha
const Color kAshubha = Color(0xFFD32F2F);        // Red for ashubha
const Color kMadhyama = Color(0xFFEF6C00);       // Orange for madhyama
const Color kBorder = Color(0x1AE65100);         // Orange at 10%
const Color kCardBorder = Color(0x1A000000);     // Black at 10%

// ─── THEME ───

ThemeData appTheme() => ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: kBg,
  primaryColor: kGold,
  colorScheme: const ColorScheme.light(
    primary: kGold,
    secondary: kTeal,
    surface: kCard,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kText,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'NotoSansKannada',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: kGold,
    ),
    iconTheme: IconThemeData(color: kGold),
  ),
  cardTheme: CardThemeData(
    color: kCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: kCardBorder, width: 1),
    ),
    elevation: 2,
    shadowColor: Colors.black12,
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 20, fontWeight: FontWeight.bold, color: kGold),
    titleLarge: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 16, fontWeight: FontWeight.bold, color: kGold),
    titleMedium: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 14, fontWeight: FontWeight.w600, color: kText),
    bodyLarge: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 14, color: kText),
    bodyMedium: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 13, color: kText),
    bodySmall: TextStyle(fontFamily: 'NotoSansKannada', fontSize: 11, color: kMuted),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kCard,
    selectedItemColor: kGold,
    unselectedItemColor: kMuted,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: kGold,
    unselectedLabelColor: kMuted,
    indicatorColor: kGold,
  ),
);

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
