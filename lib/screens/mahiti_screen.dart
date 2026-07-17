/// Mahiti (Info) Screen — Astronomical information: Grahana, Guru/Shukra Asta, etc.
import 'package:flutter/material.dart';
import '../widgets/common.dart';
import '../i18n/app_locale.dart';

class MahitiScreen extends StatefulWidget {
  const MahitiScreen({super.key});

  @override
  State<MahitiScreen> createState() => _MahitiScreenState();
}

class _MahitiScreenState extends State<MahitiScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: kGold, size: 22),
                const SizedBox(width: 8),
                Text('ಮಾಹಿತಿ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGold)),
              ],
            ),
          ),

          // ── Grahana (Eclipses) ──
          _InfoSection(
            icon: Icons.dark_mode_rounded,
            title: 'ಗ್ರಹಣ (Eclipses)',
            color: const Color(0xFFE53935),
            items: const [
              _InfoItem(
                title: 'ಸೂರ್ಯ ಗ್ರಹಣ — 2026',
                details: [
                  '🌑 ಫೆಬ್ರವರಿ 17, 2026 — ಕಂಕಣ ಸೂರ್ಯ ಗ್ರಹಣ',
                  '   ⏰ ಸ್ಪರ್ಶ: 12:52 PM IST',
                  '   ⏰ ಮಧ್ಯ: 02:24 PM IST',
                  '   ⏰ ಮೋಕ್ಷ: 03:56 PM IST',
                  '   📍 ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಹೌದು (ಭಾಗಶಃ)',
                  '',
                  '🌑 ಆಗಸ್ಟ್ 12, 2026 — ಪೂರ್ಣ ಸೂರ್ಯ ಗ್ರಹಣ',
                  '   ⏰ ಸ್ಪರ್ಶ: 11:17 PM IST',
                  '   📍 ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಇಲ್ಲ',
                ],
              ),
              _InfoItem(
                title: 'ಚಂದ್ರ ಗ್ರಹಣ — 2026',
                details: [
                  '🌕 ಮಾರ್ಚ್ 03, 2026 — ಪೂರ್ಣ ಚಂದ್ರ ಗ್ರಹಣ',
                  '   ⏰ ಸ್ಪರ್ಶ: 09:20 PM IST',
                  '   ⏰ ಗ್ರಾಸ: 10:39 PM IST',
                  '   ⏰ ಮಧ್ಯ: 11:33 PM IST',
                  '   ⏰ ಮೋಕ್ಷ: 01:47 AM IST (ಮರುದಿನ)',
                  '   📍 ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಹೌದು (ಪೂರ್ಣ)',
                  '',
                  '🌕 ಆಗಸ್ಟ್ 28, 2026 — ಭಾಗಶಃ ಚಂದ್ರ ಗ್ರಹಣ',
                  '   ⏰ ಸ್ಪರ್ಶ: 07:35 AM IST',
                  '   📍 ಭಾರತದಲ್ಲಿ ಗೋಚರ: ಇಲ್ಲ',
                ],
              ),
            ],
          ),

          // ── Guru Asta (Jupiter Combustion) ──
          _InfoSection(
            icon: Icons.brightness_7_rounded,
            title: 'ಗುರು ಅಸ್ತ (Jupiter Combustion)',
            color: const Color(0xFFFF9800),
            items: const [
              _InfoItem(
                title: 'ಗುರು ಅಸ್ತ 2026',
                details: [
                  '🪐 ಗುರು ಅಸ್ತ (ಸೂರ್ಯನ ಸಮೀಪ):',
                  '   📅 ಜೂನ್ 06, 2026 — ಜುಲೈ 24, 2026',
                  '   📍 ಮಿಥುನ / ಕರ್ಕಾಟಕ ರಾಶಿ',
                  '',
                  '⚠️ ಗುರು ಅಸ್ತ ಸಮಯದಲ್ಲಿ:',
                  '   • ಶುಭ ಕಾರ್ಯಗಳನ್ನು ಮಾಡಬಾರದು',
                  '   • ವಿವಾಹ, ಉಪನಯನ ನಿಷೇಧ',
                  '   • ಗೃಹ ಪ್ರವೇಶ ಮಾಡಬಾರದು',
                ],
              ),
            ],
          ),

          // ── Shukra Asta (Venus Combustion) ──
          _InfoSection(
            icon: Icons.brightness_5_rounded,
            title: 'ಶುಕ್ರ ಅಸ್ತ (Venus Combustion)',
            color: const Color(0xFFAB47BC),
            items: const [
              _InfoItem(
                title: 'ಶುಕ್ರ ಅಸ್ತ 2026',
                details: [
                  '💎 ಶುಕ್ರ ಅಸ್ತ (ಸೂರ್ಯನ ಸಮೀಪ):',
                  '   📅 ಮಾರ್ಚ್ 15, 2026 — ಏಪ್ರಿಲ್ 20, 2026',
                  '   📍 ಮೀನ / ಮೇಷ ರಾಶಿ',
                  '',
                  '⚠️ ಶುಕ್ರ ಅಸ್ತ ಸಮಯದಲ್ಲಿ:',
                  '   • ವಿವಾಹ ನಿಷೇಧ',
                  '   • ಶುಭ ಕಾರ್ಯಗಳಿಗೆ ಅಶುಭ',
                  '   • ಹೊಸ ವಸ್ತು ಖರೀದಿ ಮಾಡಬಾರದು',
                ],
              ),
            ],
          ),

          // ── Adhika Masa ──
          _InfoSection(
            icon: Icons.add_circle_outline_rounded,
            title: 'ಅಧಿಕ ಮಾಸ (Leap Month)',
            color: const Color(0xFF26A69A),
            items: const [
              _InfoItem(
                title: 'ಅಧಿಕ ಮಾಸ 2026',
                details: [
                  '📅 ಈ ವರ್ಷ ಅಧಿಕ ಮಾಸ ಇಲ್ಲ',
                  '',
                  'ℹ️ ಅಧಿಕ ಮಾಸ ಎಂದರೆ:',
                  '   • ಎರಡು ಅಮಾವಾಸ್ಯೆಗಳ ನಡುವೆ ಸಂಕ್ರಾಂತಿ ಇಲ್ಲದಿದ್ದರೆ',
                  '   • ಆ ಮಾಸವನ್ನು ಅಧಿಕ ಮಾಸ ಎಂದು ಕರೆಯುತ್ತಾರೆ',
                  '   • ಅಧಿಕ ಮಾಸದಲ್ಲಿ ಶುಭ ಕಾರ್ಯ ಮಾಡಬಾರದು',
                  '   • ದಾನ, ಜಪ, ತಪಸ್ಸಿಗೆ ವಿಶೇಷ ಫಲ',
                ],
              ),
            ],
          ),

          // ── Kshaya Masa ──
          _InfoSection(
            icon: Icons.remove_circle_outline_rounded,
            title: 'ಕ್ಷಯ ಮಾಸ (Lost Month)',
            color: const Color(0xFFEF5350),
            items: const [
              _InfoItem(
                title: 'ಕ್ಷಯ ಮಾಸ ವಿವರ',
                details: [
                  'ℹ️ ಕ್ಷಯ ಮಾಸ ಎಂದರೆ:',
                  '   • ಎರಡು ಅಮಾವಾಸ್ಯೆಗಳ ನಡುವೆ ಎರಡು ಸಂಕ್ರಾಂತಿ ಬಂದರೆ',
                  '   • ಒಂದು ಮಾಸ ಕ್ಷಯವಾಗುತ್ತದೆ (ಬಿಡುತ್ತದೆ)',
                  '   • ಇದು ಬಹಳ ಅಪರೂಪ (19-141 ವರ್ಷಕ್ಕೊಮ್ಮೆ)',
                  '   • 2026ರಲ್ಲಿ ಕ್ಷಯ ಮಾಸ ಇಲ್ಲ',
                ],
              ),
            ],
          ),

          // ── Uttarayana / Dakshinayana ──
          _InfoSection(
            icon: Icons.swap_vert_rounded,
            title: 'ಅಯನ (Solstice)',
            color: const Color(0xFF42A5F5),
            items: const [
              _InfoItem(
                title: 'ಅಯನ 2026',
                details: [
                  '☀️ ಮಕರ ಸಂಕ್ರಾಂತಿ / ಉತ್ತರಾಯಣ:',
                  '   📅 ಜನವರಿ 14, 2026',
                  '   ⏰ ಸೂರ್ಯ ಮಕರ ರಾಶಿ ಪ್ರವೇಶ',
                  '',
                  '☀️ ಕರ್ಕ ಸಂಕ್ರಾಂತಿ / ದಕ್ಷಿಣಾಯನ:',
                  '   📅 ಜುಲೈ 16, 2026',
                  '   ⏰ ಸೂರ್ಯ ಕರ್ಕಾಟಕ ರಾಶಿ ಪ್ರವೇಶ',
                  '',
                  'ℹ️ ಉತ್ತರಾಯಣ = ಶುಭ ಕಾಲ (ದೇವರ ಹಗಲು)',
                  'ℹ️ ದಕ್ಷಿಣಾಯನ = ಪಿತೃ ಕಾಲ (ದೇವರ ರಾತ್ರಿ)',
                ],
              ),
            ],
          ),

          // ── Sankranti Dates ──
          _InfoSection(
            icon: Icons.wb_sunny_outlined,
            title: 'ಸಂಕ್ರಾಂತಿ (Solar Transit)',
            color: const Color(0xFFFFA726),
            items: const [
              _InfoItem(
                title: '2026 ಸಂಕ್ರಾಂತಿ ದಿನಗಳು',
                details: [
                  '♑ ಮಕರ ಸಂಕ್ರಾಂತಿ — ಜನವರಿ 14',
                  '♒ ಕುಂಭ ಸಂಕ್ರಾಂತಿ — ಫೆಬ್ರವರಿ 13',
                  '♓ ಮೀನ ಸಂಕ್ರಾಂತಿ — ಮಾರ್ಚ್ 15',
                  '♈ ಮೇಷ ಸಂಕ್ರಾಂತಿ — ಏಪ್ರಿಲ್ 14',
                  '♉ ವೃಷಭ ಸಂಕ್ರಾಂತಿ — ಮೇ 15',
                  '♊ ಮಿಥುನ ಸಂಕ್ರಾಂತಿ — ಜೂನ್ 15',
                  '♋ ಕರ್ಕ ಸಂಕ್ರಾಂತಿ — ಜುಲೈ 16',
                  '♌ ಸಿಂಹ ಸಂಕ್ರಾಂತಿ — ಆಗಸ್ಟ್ 17',
                  '♍ ಕನ್ಯಾ ಸಂಕ್ರಾಂತಿ — ಸೆಪ್ಟೆಂಬರ್ 17',
                  '♎ ತುಲಾ ಸಂಕ್ರಾಂತಿ — ಅಕ್ಟೋಬರ್ 17',
                  '♏ ವೃಶ್ಚಿಕ ಸಂಕ್ರಾಂತಿ — ನವೆಂಬರ್ 16',
                  '♐ ಧನು ಸಂಕ್ರಾಂತಿ — ಡಿಸೆಂಬರ್ 16',
                ],
              ),
            ],
          ),

          // ── Shraddha Niyama ──
          _InfoSection(
            icon: Icons.self_improvement_rounded,
            title: 'ಶ್ರಾದ್ಧ ನಿಯಮ',
            color: const Color(0xFFFFD54F),
            items: const [
              _InfoItem(
                title: 'ಶ್ರಾದ್ಧ ನಿಯಮಗಳು',
                details: [
                  '📜 ಕುತುಪ ಕಾಲ:',
                  '   • 15 ಮುಹೂರ್ತಗಳಲ್ಲಿ 8ನೇ ಮುಹೂರ್ತ',
                  '   • ಶ್ರಾದ್ಧ ತಿಥಿ ಕುತುಪ ಕಾಲದಲ್ಲಿ ಇರಬೇಕು',
                  '',
                  '📜 ದ್ವಿತೀಯಾ ಶ್ರಾದ್ಧ ನಿಯಮ:',
                  '   • ತಿಥಿ ಎರಡು ದಿನ ಕುತುಪದಲ್ಲಿ ಇದ್ದರೆ → ಪ್ರಥಮ ದಿನ',
                  '',
                  '📜 ಕ್ಷಯೇ ಪೂರ್ವ:',
                  '   • ಕ್ಷಯ ತಿಥಿ (ಕುತುಪ ಕಾಲ ಎರಡು ದಿನವೂ ಇಲ್ಲ)',
                  '   • ಪ್ರಥಮ ದಿನ (ಹಿಂದಿನ ದಿನ) ಶ್ರಾದ್ಧ ಮಾಡಬೇಕು',
                  '',
                  '📜 ಅಪರಾಹ್ನ ಕಾಲ:',
                  '   • ಹಗಲಿನ 5 ಭಾಗಗಳಲ್ಲಿ 4ನೇ ಭಾಗ',
                  '   • ಶ್ರಾದ್ಧ ಅಪರಾಹ್ನ ಕಾಲದಲ್ಲಿ ಮಾಡಬೇಕು',
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Reusable Info Section (Expandable) ───

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCard.withAlpha(178),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
          leading: Icon(icon, color: color, size: 20),
          title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          iconColor: color,
          collapsedIconColor: color.withAlpha(150),
          children: items.map((item) => _buildInfoItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoItem(_InfoItem item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kText)),
          const SizedBox(height: 6),
          ...item.details.map((line) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 10,
                color: line.startsWith('⚠') ? kAshubha : kMuted,
                fontWeight: line.startsWith('⚠') ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String title;
  final List<String> details;

  const _InfoItem({required this.title, required this.details});
}
