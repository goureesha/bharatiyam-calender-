/// Ad Service — Google AdMob interstitial + banner ads.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  /// Notifies widgets when AdMob is ready
  static final ValueNotifier<bool> initialized = ValueNotifier(false);
  static String _status = 'not started';

  // Google's official test ad IDs (work on any device)
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Real IDs (switch back after test ads work):
  // static const String _bannerAdUnitId = 'ca-app-pub-9748660125901669/3248306368';
  // static const String _interstitialAdUnitId = 'ca-app-pub-9748660125901669/9430571330';

  static InterstitialAd? _interstitialAd;
  static int _loadAttempts = 0;

  static String get status => _status;

  /// Initialize AdMob SDK
  static Future<void> initialize() async {
    if (initialized.value) return;
    _status = 'initializing...';
    try {
      await MobileAds.instance.initialize();
      initialized.value = true;
      _status = 'SDK ready ✓';
      debugPrint('AdMob: initialized OK');
      _loadInterstitial();
    } catch (e) {
      _status = 'init FAILED: $e';
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
        },
        onAdFailedToLoad: (error) {
          _loadAttempts++;
          _interstitialAd = null;
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

/// Banner ad widget — shows debug status when ads fail
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  String _adStatus = 'waiting';

  @override
  void initState() {
    super.initState();
    if (AdService.isSupported) {
      _loadAd();
    } else {
      _adStatus = 'waiting for SDK: ${AdService.status}';
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
    if (mounted) setState(() => _adStatus = 'loading banner...');
    _bannerAd = BannerAd(
      adUnitId: AdService._bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded OK');
          if (mounted) setState(() { _isLoaded = true; _adStatus = 'loaded ✓'; });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad FAILED: ${error.message}');
          if (mounted) setState(() => _adStatus = 'FAILED: ${error.message}');
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
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // DEBUG: show visible status so we know what's happening
    return Container(
      height: 50,
      color: Colors.orange.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: Text(
        'Ad: $_adStatus | SDK: ${AdService.status}',
        style: const TextStyle(fontSize: 11, color: Colors.deepOrange),
      ),
    );
  }
}
