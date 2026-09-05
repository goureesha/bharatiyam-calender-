/// Ad Service — Google AdMob ad management with offline support & bypass protection.
/// Preloads ads aggressively when online. Cached ads can show offline.
/// AdMob SDK queues impression events and syncs when connectivity returns.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // ── Anti-bypass protection ──
  static int _consecutiveAdFailures = 0;
  static const int _maxConsecutiveFailures = 5;
  static bool _adBlockerDetected = false;
  static DateTime? _lastAdShownTime;
  static int _adShowCount = 0;
  static const String _prefKeyAdShown = '_bp_as';
  static const String _prefKeyLastTime = '_bp_lt';
  static const String _prefKeyFailCount = '_bp_fc';

  /// Initialize the Mobile Ads SDK and start aggressive preloading
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('AdMob initialized successfully');

      // Restore anti-bypass state
      await _restoreState();

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
  static bool get adBlockerDetected => _adBlockerDetected;

  // ═══════════════════════════════════════════════════════
  //  ANTI-BYPASS PROTECTION
  // ═══════════════════════════════════════════════════════

  /// Restore persisted anti-bypass state
  static Future<void> _restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _adShowCount = prefs.getInt(_prefKeyAdShown) ?? 0;
      _consecutiveAdFailures = prefs.getInt(_prefKeyFailCount) ?? 0;
      final lastTime = prefs.getInt(_prefKeyLastTime);
      if (lastTime != null) {
        _lastAdShownTime = DateTime.fromMillisecondsSinceEpoch(lastTime);
      }
      // If too many failures persisted, flag blocker
      if (_consecutiveAdFailures >= _maxConsecutiveFailures) {
        _adBlockerDetected = true;
      }
    } catch (_) {}
  }

  /// Persist anti-bypass state (survives app restart)
  static Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyAdShown, _adShowCount);
      await prefs.setInt(_prefKeyFailCount, _consecutiveAdFailures);
      if (_lastAdShownTime != null) {
        await prefs.setInt(_prefKeyLastTime, _lastAdShownTime!.millisecondsSinceEpoch);
      }
    } catch (_) {}
  }

  /// Called when an ad loads successfully — reset failure counter
  static void _onAdLoadSuccess() {
    _consecutiveAdFailures = 0;
    _adBlockerDetected = false;
    _saveState();
  }

  /// Called when ad fails to load — track for blocker detection
  static void _onAdLoadFailure() {
    _consecutiveAdFailures++;
    if (_consecutiveAdFailures >= _maxConsecutiveFailures) {
      _adBlockerDetected = true;
      debugPrint('⚠️ Ad blocker detected: $_consecutiveAdFailures consecutive failures');
    }
    _saveState();
  }

  /// Record that an ad was successfully shown
  static void _recordAdShown() {
    _lastAdShownTime = DateTime.now();
    _adShowCount++;
    _saveState();
  }

  /// Check if enough time has passed since last ad (anti-rapid-tap)
  static bool _canShowAd() {
    if (_lastAdShownTime == null) return true;
    return DateTime.now().difference(_lastAdShownTime!).inSeconds > 5;
  }

  /// Show content with ad gate — blocks content until ad completes or times out.
  /// [onComplete] is called when content should be revealed.
  /// [context] is used to show notification when ad blocker delay is active.
  static void showWithAdGate({
    required VoidCallback onComplete,
    BuildContext? context,
    VoidCallback? onBlocked,
    int timeoutSeconds = 8,
  }) {
    // Anti-rapid-tap protection
    if (!_canShowAd()) {
      onComplete();
      return;
    }

    // If ad blocker detected, add a delay to discourage blocking
    if (_adBlockerDetected && !hasInterstitial) {
      debugPrint('Ad blocker active — adding delay');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: Text(
                'Ad blocked — please disable ad blocker to support this free app. Loading in ${timeoutSeconds}s...',
                style: const TextStyle(fontSize: 11),
              )),
            ],
          ),
          duration: Duration(seconds: timeoutSeconds),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
      Future.delayed(Duration(seconds: timeoutSeconds), () {
        onComplete();
      });
      return;
    }

    // No ad available — proceed immediately
    if (!hasInterstitial) {
      onComplete();
      return;
    }

    // Show ad with timeout protection
    bool completed = false;
    Timer? timeout;

    timeout = Timer(Duration(seconds: timeoutSeconds), () {
      if (!completed) {
        completed = true;
        onComplete();
      }
    });

    showInterstitial(onAdDismissed: () {
      timeout?.cancel();
      if (!completed) {
        completed = true;
        onComplete();
      }
    });
  }

  // ═══════════════════════════════════════════════════════
  //  CONNECTIVITY
  // ═══════════════════════════════════════════════════════

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
        debugPrint('Network restored — reloading ads');
        _consecutiveAdFailures = 0; // Reset on reconnect
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

  // ═══════════════════════════════════════════════════════
  //  AD LOADING
  // ═══════════════════════════════════════════════════════

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
          _onAdLoadSuccess();
          debugPrint('Primary interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          _isLoadingInterstitial = false;
          _onAdLoadFailure();
          debugPrint('Interstitial failed (attempt $_interstitialLoadAttempts): ${error.message}');
          if (_interstitialLoadAttempts < _maxInterstitialAttempts) {
            final delay = Duration(seconds: 5 * (1 << (_interstitialLoadAttempts - 1)));
            Future.delayed(delay, _loadInterstitial);
          }
        },
      ),
    );
  }

  /// Load backup interstitial
  static void _loadBackupInterstitial() {
    if (_backupInterstitialAd != null) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _backupInterstitialAd = ad;
          _onAdLoadSuccess();
          debugPrint('Backup interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _onAdLoadFailure();
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
      _interstitialLoadAttempts = 0;
      _loadInterstitial();
      return;
    }

    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _recordAdShown();
        onAdDismissed?.call();
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
