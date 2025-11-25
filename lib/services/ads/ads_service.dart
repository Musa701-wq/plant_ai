import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._private();
  static final AdService instance = AdService._private();

  // --- Interstitial ---
  InterstitialAd? _interstitial;
  bool _isInterstitialLoading = false;

  // --- Rewarded ---
  RewardedAd? _rewarded;
  bool _isRewardedLoading = false;

  // --- Banner ---
  BannerAd? _banner;

  /// Initialize Google Mobile Ads SDK (call this once in `main()`)
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Platform-safe ad IDs
  String get _interstitialId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/1033173712'; // ✅ Test Android
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // ✅ Test iOS
    } else {
      throw UnsupportedError('Unsupported platform for ads');
    }
  }

  String get _rewardedId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3774337907915828/4168674864'; // ✅ Test Android
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3774337907915828/4168674864'; // ✅ Test iOS
    } else {
      throw UnsupportedError('Unsupported platform for ads');
    }
  }

  String get _bannerId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111'; // ✅ Test Android
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // ✅ Test iOS
    } else {
      throw UnsupportedError('Unsupported platform for ads');
    }
  }

  // ---------------------------------------------------------------------------
  // 🧩 INTERSTITIAL
  // ---------------------------------------------------------------------------
  void loadInterstitial() {
    if (_interstitial != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _isInterstitialLoading = false;
          _attachInterstitialCallbacks(ad);
          debugPrint('AdService: Interstitial loaded');
        },
        onAdFailedToLoad: (err) {
          _isInterstitialLoading = false;
          debugPrint('AdService: Failed to load interstitial: $err');
        },
      ),
    );
  }

  void _attachInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
        loadInterstitial();
      },
    );
  }

  Future<bool> showInterstitialAndWait() async {
    if (_interstitial == null) {
      loadInterstitial();
      return false;
    }

    final ad = _interstitial!;
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        loadInterstitial();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
        loadInterstitial();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show();
    return completer.future;
  }

  // ---------------------------------------------------------------------------
  // 🪙 REWARDED
  // ---------------------------------------------------------------------------
  void loadRewarded() {
    if (_rewarded != null || _isRewardedLoading) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _isRewardedLoading = false;
          debugPrint('AdService: Rewarded loaded');
        },
        onAdFailedToLoad: (err) {
          _isRewardedLoading = false;
          debugPrint('AdService: Failed to load rewarded: $err');
        },
      ),
    );
  }

  Future<bool> showRewardedAndWait({required Function onReward}) async {
    if (_rewarded == null) {
      loadRewarded();
      return false;
    }

    final ad = _rewarded!;
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        loadRewarded();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewarded = null;
        loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show(onUserEarnedReward: (ad, reward) {
      onReward();
      debugPrint('AdService: Reward earned: ${reward.amount} ${reward.type}');
    });

    return completer.future;
  }

  // ---------------------------------------------------------------------------
  // 📱 BANNER
  // ---------------------------------------------------------------------------
  BannerAd createBanner({
    AdSize size = AdSize.banner,
    VoidCallback? onLoaded,
    Function(LoadAdError)? onFailed,
  }) {
    _banner = BannerAd(
      adUnitId: _bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          onLoaded?.call();
          debugPrint('AdService: Banner loaded');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed?.call(error);
          debugPrint('AdService: Banner failed to load: $error');
        },
      ),
    )..load();

    return _banner!;
  }

  // ---------------------------------------------------------------------------
  // ♻️ Dispose
  // ---------------------------------------------------------------------------
  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();
    _banner?.dispose();
    _interstitial = null;
    _rewarded = null;
    _banner = null;
  }
}
