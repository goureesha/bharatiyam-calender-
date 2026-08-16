/// Ad Service — Google AdMob ad management.
/// Currently in STUB mode (no real AdMob SDK).
/// To enable ads:
/// 1. Uncomment google_mobile_ads in pubspec.yaml
/// 2. Add your real AdMob App ID in AndroidManifest.xml
/// 3. Replace this file with the real implementation
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdService {
  static bool _initialized = false;

  // TODO: Replace with your actual AdMob Ad Unit IDs
  static const String _realBannerAdUnitId = 'YOUR_BANNER_AD_UNIT_ID';
  static const String _realInterstitialAdUnitId = 'YOUR_INTERSTITIAL_AD_UNIT_ID';

  /// Initialize (stub — does nothing until AdMob is configured)
  static Future<void> initialize() async {
    // Ads disabled until real AdMob App ID is configured
    debugPrint('AdMob stub: ads disabled (no real App ID configured)');
  }

  static bool get isSupported => false;

  /// Show interstitial (stub — just calls onAdDismissed immediately)
  static void showInterstitial({VoidCallback? onAdDismissed}) {
    onAdDismissed?.call();
  }
}

/// Banner ad widget (stub — renders nothing)
class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
