/// Ad Service — Google AdMob ad management with offline support.
/// Preloads ads aggressively when online. Cached ads can show offline.
/// AdMob SDK queues impression events and syncs when connectivity returns.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdService {
  static bool _initialized = false;

  // ── Ad Unit IDs ──
  static const String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-9748660125901669/3248306368';

  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-9748660125901669/9430571330';

  // ── Interstitial pool ──
  static InterstitialAd? _interstitialAd;
  static InterstitialAd? _backupInterstitialAd;
  static int _interstitialLoadAttempts = 0;
  static const int _maxInterstitialAttempts = 5;
  static bool _isLoadingInterstitial = false;

  // ── Connectivity tracking ──
  static bool _lastKnownOnline = true;
  static Timer? _connectivityTimer;
  static Timer? _preloadTimer;

  /// Initialize the Mobile Ads SDK and start aggressive preloading
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('AdMob initialized successfully');

      // Load primary + backup interstitials
      _loadInterstitial();
      Future.delayed(const Duration(seconds: 3), _loadBackupInterstitial);

      // Start connectivity monitor — reload ads when coming back online
      _startConnectivityMonitor();

      // Periodic preload — keep ads fresh every 15 minutes
      _preloadTimer = Timer.periodic(const Duration(minutes: 15), (_) {
        _refreshAdsIfNeeded();
      });
    } catch (e) {
      debugPrint('AdMob init failed: $e');
    }
  }

  static bool get isSupported => _initialized;
  static bool get hasInterstitial => _interstitialAd != null || _backupInterstitialAd != null;

  /// Check network connectivity
  static Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Monitor connectivity and reload ads when coming back online
  static void _startConnectivityMonitor() {
    _connectivityTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final online = await _isOnline();
      if (online && !_lastKnownOnline) {
        // Just came back online — reload ads
        debugPrint('Network restored — reloading ads');
        _refreshAdsIfNeeded();
      }
      _lastKnownOnline = online;
    });
  }

  /// Refresh ads if any slot is empty
  static void _refreshAdsIfNeeded() {
    if (_interstitialAd == null) _loadInterstitial();
    if (_backupInterstitialAd == null) {
      Future.delayed(const Duration(seconds: 2), _loadBackupInterstitial);
    }
  }

  /// Load primary interstitial ad
  static void _loadInterstitial() {
    if (_isLoadingInterstitial || _interstitialAd != null) return;
    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          _isLoadingInterstitial = false;
          debugPrint('Primary interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          _isLoadingInterstitial = false;
          debugPrint('Interstitial failed (attempt $_interstitialLoadAttempts): ${error.message}');
          if (_interstitialLoadAttempts < _maxInterstitialAttempts) {
            // Exponential backoff: 5s, 15s, 30s, 60s
            final delay = Duration(seconds: 5 * (1 << (_interstitialLoadAttempts - 1)));
            Future.delayed(delay, _loadInterstitial);
          }
        },
      ),
    );
  }

  /// Load backup interstitial (second ad ready to show immediately after first)
  static void _loadBackupInterstitial() {
    if (_backupInterstitialAd != null) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _backupInterstitialAd = ad;
          debugPrint('Backup interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Backup interstitial failed: ${error.message}');
        },
      ),
    );
  }

  /// Show interstitial ad — uses primary first, falls back to backup
  static void showInterstitial({VoidCallback? onAdDismissed}) {
    InterstitialAd? adToShow;

    if (_interstitialAd != null) {
      adToShow = _interstitialAd;
      _interstitialAd = null;
    } else if (_backupInterstitialAd != null) {
      adToShow = _backupInterstitialAd;
      _backupInterstitialAd = null;
    }

    if (adToShow == null) {
      onAdDismissed?.call();
      // Try to reload for next time
      _interstitialLoadAttempts = 0;
      _loadInterstitial();
      return;
    }

    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onAdDismissed?.call();
        // Immediately start loading next ads
        _interstitialLoadAttempts = 0;
        _loadInterstitial();
        Future.delayed(const Duration(seconds: 2), _loadBackupInterstitial);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        debugPrint('Interstitial show failed: ${error.message}');
        onAdDismissed?.call();
        _interstitialLoadAttempts = 0;
        _loadInterstitial();
      },
    );
    adToShow.show();
  }

  /// Dispose all resources
  static void dispose() {
    _connectivityTimer?.cancel();
    _preloadTimer?.cancel();
    _interstitialAd?.dispose();
    _backupInterstitialAd?.dispose();
    _interstitialAd = null;
    _backupInterstitialAd = null;
  }
}

/// Banner Ad Widget — drop-in widget for screens with auto-retry
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    if (AdService.isSupported) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-9748660125901669/3248306368',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
            _retryCount = 0;
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          if (mounted && _retryCount < 4) {
            _retryCount++;
            // Retry with exponential backoff: 10s, 30s, 60s, 120s
            final delay = Duration(seconds: 10 * (1 << (_retryCount - 1)));
            _retryTimer = Timer(delay, () {
              if (mounted) _loadAd();
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
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
