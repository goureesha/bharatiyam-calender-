/// Ad Service — Google AdMob banner ad management.
/// Uses test IDs in debug mode, real IDs in release.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;

  // ── Test Ad IDs (used in debug builds) ──
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';

  // ── Real Ad IDs (replace with your AdMob IDs) ──
  // TODO: Replace these with your actual AdMob Ad Unit IDs
  static const String _realBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  // Interstitial Ad IDs
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  // TODO: Replace with your actual Interstitial Ad Unit ID
  static const String _realInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  /// Initialize the Mobile Ads SDK (safe, never crashes)
  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    try {
      await MobileAds.instance.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('AdMob init timed out');
          return MobileAds.instance.initialize(); // just return something
        },
      );
      _initialized = true;
      debugPrint('AdMob initialized');
    } catch (e) {
      debugPrint('AdMob init failed (non-fatal): $e');
      // Don't set _initialized = true, ads just won't show
    }
  }

  /// Get the banner ad unit ID (test in debug, real in release)
  static String get bannerAdUnitId {
    if (kDebugMode) return _testBannerAdUnitId;
    return _realBannerAdUnitId;
  }

  /// Get the interstitial ad unit ID
  static String get interstitialAdUnitId {
    if (kDebugMode) return _testInterstitialAdUnitId;
    return _realInterstitialAdUnitId;
  }

  /// Load and show an interstitial ad
  /// [onAdDismissed] is called after the ad is closed (or if it fails to load)
  static void showInterstitial({VoidCallback? onAdDismissed}) {
    if (kIsWeb || !_initialized) {
      onAdDismissed?.call();
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdDismissed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial failed to show: ${error.message}');
              ad.dispose();
              onAdDismissed?.call();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: ${error.message}');
          onAdDismissed?.call();
        },
      ),
    );
  }

  /// Check if ads are supported (not on web)
  static bool get isSupported => !kIsWeb && _initialized;
}

/// A reusable banner ad widget — small 320x50 banner
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (kIsWeb) return; // No ads on web

    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner, // 320x50
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink(); // No space when no ad
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
