/// Ad Service — Google AdMob interstitial + banner ads with fallback.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

class AdService {
  /// Notifies widgets when AdMob is ready
  static final ValueNotifier<bool> initialized = ValueNotifier(false);

  // Test IDs for debug, real IDs for release
  static const String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-9748660125901669/3248306368';

  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-9748660125901669/9430571330';

  static InterstitialAd? _interstitialAd;
  static int _loadAttempts = 0;

  /// Initialize AdMob SDK
  static Future<void> initialize() async {
    if (initialized.value) return;
    try {
      await MobileAds.instance.initialize();
      initialized.value = true;
      debugPrint('AdMob initialized');
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

/// Banner ad widget — shows AdMob ad, falls back to promo banner on failure
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _adFailed = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    if (AdService.isSupported) {
      _loadAd();
    } else {
      AdService.initialized.addListener(_onAdServiceReady);
      // Show fallback after 5s if AdMob never initializes
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_isLoaded && !AdService.isSupported) {
          setState(() => _adFailed = true);
        }
      });
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
          if (mounted) setState(() { _isLoaded = true; _adFailed = false; });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          _retryCount++;
          if (mounted) {
            if (_retryCount < 3) {
              // Retry after delay
              Future.delayed(Duration(seconds: 15 * _retryCount), () {
                if (mounted && !_isLoaded) _loadAd();
              });
            }
            setState(() => _adFailed = true);
          }
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
    // Ad loaded — show real ad
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Ad failed — show fallback promo banner
    if (_adFailed) {
      return const _FallbackPromoBanner();
    }

    // Still loading — show nothing
    return const SizedBox.shrink();
  }
}

/// Fallback promo banner — shown when AdMob ads fail to load
/// Rotates between cross-promo, support message, and app features
class _FallbackPromoBanner extends StatefulWidget {
  const _FallbackPromoBanner();

  @override
  State<_FallbackPromoBanner> createState() => _FallbackPromoBannerState();
}

class _FallbackPromoBannerState extends State<_FallbackPromoBanner> {
  late int _promoIndex;

  static const _promos = [
    _PromoData(
      icon: Icons.star_rounded,
      text: '⭐ Rate Bharatiyam Panchanga on Play Store!',
      url: 'https://play.google.com/store/apps/details?id=com.bharatiyam.bharatiyam_panchanga',
      colors: [Color(0xFF1A237E), Color(0xFF283593)],
    ),
    _PromoData(
      icon: Icons.auto_awesome,
      text: '🔮 Try Bharatiyam Vedic Astrology App!',
      url: 'https://play.google.com/store/apps/details?id=com.bharatheeyam.app',
      colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
    ),
    _PromoData(
      icon: Icons.favorite_rounded,
      text: '🙏 Free app — please support by sharing!',
      url: null,
      colors: [Color(0xFFBF360C), Color(0xFFD84315)],
    ),
    _PromoData(
      icon: Icons.play_circle_filled_rounded,
      text: '▶️ Watch our Panchanga video on YouTube!',
      url: 'https://www.youtube.com/watch?v=j4-4O-t7VYw',
      colors: [Color(0xFFC62828), Color(0xFFD32F2F)],
    ),
    _PromoData(
      icon: Icons.shield_rounded,
      text: '🛡️ Ads support this free app. Whitelist us!',
      url: null,
      colors: [Color(0xFF00695C), Color(0xFF00897B)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Pick a random promo each time
    _promoIndex = DateTime.now().millisecond % _promos.length;
  }

  @override
  Widget build(BuildContext context) {
    final promo = _promos[_promoIndex];
    return GestureDetector(
      onTap: () {
        if (promo.url != null) {
          launchUrl(Uri.parse(promo.url!), mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 320,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: promo.colors),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(promo.icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                promo.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (promo.url != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withAlpha(180), size: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _PromoData {
  final IconData icon;
  final String text;
  final String? url;
  final List<Color> colors;

  const _PromoData({
    required this.icon,
    required this.text,
    required this.url,
    required this.colors,
  });
}
