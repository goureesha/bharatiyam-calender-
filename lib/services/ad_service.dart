/// Ad Service — Google AdMob interstitial + banner ads.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  /// Notifies widgets when AdMob is ready
  static final ValueNotifier<bool> initialized = ValueNotifier(false);

  // ── TEMPORARY: using test IDs to verify integration works ──
  // Once test ads show, switch back to real IDs:
  // Banner real:        ca-app-pub-9748660125901669/3248306368
  // Interstitial real:  ca-app-pub-9748660125901669/9430571330
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  static InterstitialAd? _interstitialAd;
  static int _loadAttempts = 0;

  /// Initialize AdMob SDK
  static Future<void> initialize() async {
    if (initialized.value) return;
    try {
      await MobileAds.instance.initialize();
      initialized.value = true;
      debugPrint('AdMob initialized successfully');
      _loadInterstitial();
    } catch (e) {
      debugPrint('AdMob init failed: $e');
    }
  }

  static bool get isSupported => initialized.value;

  static void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadAttempts = 0;
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          _loadAttempts++;
          _interstitialAd = null;
          debugPrint('Interstitial load failed: ${error.message}');
          if (_loadAttempts < 3) {
            Future.delayed(const Duration(seconds: 10), _loadInterstitial);
          }
        },
      ),
    );
  }

  /// Show interstitial ad
  static void showInterstitial({VoidCallback? onAdDismissed}) {
    if (_interstitialAd == null) {
      onAdDismissed?.call();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
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

  /// Show with ad gate — shows ad then calls onComplete
  static void showWithAdGate({
    required VoidCallback onComplete,
    BuildContext? context,
    VoidCallback? onBlocked,
    int timeoutSeconds = 8,
  }) {
    if (_interstitialAd != null) {
      showInterstitial(onAdDismissed: onComplete);
    } else {
      onComplete();
    }
  }
}

/// Banner ad widget — listens for AdService initialization
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
    } else {
      AdService.initialized.addListener(_onAdServiceReady);
    }
  }

  void _onAdServiceReady() {
    if (AdService.isSupported && mounted) {
      AdService.initialized.removeListener(_onAdServiceReady);
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService._bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded');
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
    AdService.initialized.removeListener(_onAdServiceReady);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
