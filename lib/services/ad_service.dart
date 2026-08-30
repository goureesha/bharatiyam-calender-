/// Ad Service — Google AdMob ad management.
/// Banner ads on screens, interstitial between transitions.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;

  // ── Ad Unit IDs ──
  // TODO: Replace test IDs with your real Ad Unit IDs from AdMob console
  static const String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // Google test banner
      : 'ca-app-pub-9748660125901669/BANNER_ID';  // Replace BANNER_ID

  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Google test interstitial
      : 'ca-app-pub-9748660125901669/INTERSTITIAL_ID'; // Replace INTERSTITIAL_ID

  static InterstitialAd? _interstitialAd;
  static int _interstitialLoadAttempts = 0;
  static const int _maxInterstitialAttempts = 3;

  /// Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('AdMob initialized successfully');
      _loadInterstitial();
    } catch (e) {
      debugPrint('AdMob init failed: $e');
    }
  }

  static bool get isSupported => _initialized;

  /// Load an interstitial ad
  static void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          debugPrint('Interstitial failed to load: ${error.message}');
          if (_interstitialLoadAttempts < _maxInterstitialAttempts) {
            Future.delayed(const Duration(seconds: 10), _loadInterstitial);
          }
        },
      ),
    );
  }

  /// Show interstitial ad (falls back to just calling onAdDismissed if no ad)
  static void showInterstitial({VoidCallback? onAdDismissed}) {
    if (_interstitialAd == null) {
      onAdDismissed?.call();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial(); // pre-load next one
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        onAdDismissed?.call();
      },
    );
    _interstitialAd!.show();
  }
}

/// Banner Ad Widget — drop-in widget for screens
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
    if (AdService.isSupported) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-9748660125901669/BANNER_ID', // Replace BANNER_ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: ${error.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
