import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n/app_locale.dart';

/// Cross-promotion popup for Bharatiyam Vedic Astrology app.
/// Shows once per day after a delay, with a "Don't show again" option.
class CrossPromotion {
  static const _prefLastShown = 'cross_promo_last_shown';
  static const _prefDismissed = 'cross_promo_dismissed';

  // ── Links (update these later) ──
  static const appLink = 'https://play.google.com/store/apps/details?id=com.bharatheeyam.app';
  static const videoLink = 'https://youtu.be/j4-4O-t7VYw';

  /// Call this from your main screen's initState (after build).
  /// Shows the popup once per day after [delay], unless user chose "Don't show again".
  static Future<void> maybeShow(BuildContext context, {Duration delay = const Duration(seconds: 3)}) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if permanently dismissed
    if (prefs.getBool(_prefDismissed) ?? false) return;

    // Check if already shown today
    final lastShown = prefs.getString(_prefLastShown) ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd
    if (lastShown == today) return;

    // Wait for the delay
    await Future.delayed(delay);

    // Check if context is still mounted
    if (!context.mounted) return;

    // Mark as shown today
    await prefs.setString(_prefLastShown, today);

    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _CrossPromoDialog(),
    );
  }
}

class _CrossPromoDialog extends StatefulWidget {
  const _CrossPromoDialog();

  @override
  State<_CrossPromoDialog> createState() => _CrossPromoDialogState();
}

class _CrossPromoDialogState extends State<_CrossPromoDialog> {
  bool _dontShowAgain = false;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _dismiss() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(CrossPromotion._prefDismissed, true);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── App Icon ──
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6F00),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 14),

            // ── Title ──
            const Text(
              'Bharatiyam Vedic Astrology',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // ── Description ──
            const Text(
              'ನಮ್ಮ ಕುಂಡಲಿ ಆ್ಯಪ್ ಸಹ ಬಳಸಿ ನೋಡಿ!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // ── Features ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  _FeatureRow(icon: Icons.donut_large, text: 'ಕುಂಡಲಿ (Kundali)'),
                  _FeatureRow(icon: Icons.star, text: 'ತಾರಾನುಕೂಲ (Tara Bala)'),
                  _FeatureRow(icon: Icons.access_time, text: 'ಮುಹೂರ್ತ (Muhoorta)'),
                  _FeatureRow(icon: Icons.home, text: 'ವಾಸ್ತು (Vastu)'),
                  _FeatureRow(icon: Icons.favorite, text: 'ಜಾತಕ ಹೊಂದಾಣಿಕೆ (Matchmaking)'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Action Buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openUrl(CrossPromotion.videoLink),
                    icon: const Icon(Icons.play_circle_outline, size: 20),
                    label: Text(AppLocale.t('video'), style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE65100),
                      side: const BorderSide(color: Color(0xFFE65100)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openUrl(CrossPromotion.appLink),
                    icon: const Icon(Icons.download, size: 20),
                    label: Text(AppLocale.t('download'), style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Don't show again + Close ──
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _dontShowAgain,
                    onChanged: (v) => setState(() => _dontShowAgain = v ?? false),
                    activeColor: const Color(0xFFE65100),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'ಮತ್ತೆ ತೋರಿಸಬೇಡಿ',
                  style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _dismiss,
                  child: const Text(
                    'ಮುಚ್ಚಿ',
                    style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF6F00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
            ),
          ),
        ],
      ),
    );
  }
}
