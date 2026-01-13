// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'AdHelper.dart';
//
// class AdProvider with ChangeNotifier {
//   /// Ad states
//   final Map<AdType, bool> _loaded = {
//     AdType.homeAd1: false,
//     AdType.homeAd2: false,
//     AdType.calendarAd: false,
//     AdType.myGardenAd: false,
//     AdType.discoverPlantAd: false,
//     AdType.discoverPlantDetailAd: false,
//     AdType.lensAd: false,
//   };
//
//   // Ad objects
//   NativeAd? _homeAd1;
//   NativeAd? _homeAd2;
//   NativeAd? _calendarAd;
//   NativeAd? _myGardenAd;
//   NativeAd? _discoverPlantAd;
//   NativeAd? _discoverPlantDetailAd;
//   RewardedAd? _lensAd;
//
//   /// Public getters
//   bool get isHomeAd1 => _loaded[AdType.homeAd1]!;
//   bool get isHomeAd2 => _loaded[AdType.homeAd2]!;
//   bool get isCalendarAd => _loaded[AdType.calendarAd]!;
//   bool get isMyGardenAd => _loaded[AdType.myGardenAd]!;
//   bool get isDiscoverPlantAd => _loaded[AdType.discoverPlantAd]!;
//   bool get isDiscoverPlantDetailAd => _loaded[AdType.discoverPlantDetailAd]!;
//   bool get isLensAd => _loaded[AdType.lensAd]!;
//
//   NativeAd? get homeAd1 => _homeAd1;
//   NativeAd? get homeAd2 => _homeAd2;
//   NativeAd? get calendarAd => _calendarAd;
//   NativeAd? get myGardenAd => _myGardenAd;
//   NativeAd? get discoverPlantAd => _discoverPlantAd;
//   NativeAd? get discoverPlantDetailAd => _discoverPlantDetailAd;
//   RewardedAd? get lensAd => _lensAd;
//
//   // --------------------------------------------------------------------
//   //                ⚡ SIMPLE iOS-ONLY PRELOAD METHOD
//   // --------------------------------------------------------------------
//
//   Future<void> preloadAd(AdType type, {dynamic adSize}) async {
//     switch (type) {
//       case AdType.lensAd:
//         return _loadRewarded(type);
//       default:
//         return _loadNative(type, adSize);
//     }
//   }
//
//   // --------------------------------------------------------------------
//   //                         LOAD NATIVE ADS
//   // --------------------------------------------------------------------
//
//   Future<void> _loadNative(AdType type, dynamic size) async {
//     final id = _adId(type);
//
//     final ad = NativeAd(
//       adUnitId: id,
//       request: const AdRequest(),
//       nativeTemplateStyle: NativeTemplateStyle(templateType: size),
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           _setState(type, true);
//           _assignNative(type, ad as NativeAd);
//         },
//         onAdFailedToLoad: (ad, err) {
//           _setState(type, false);
//           ad.dispose();
//         },
//       ),
//     );
//
//     await ad.load();
//   }
//
//   void _assignNative(AdType type, NativeAd ad) {
//     switch (type) {
//       case AdType.homeAd1:
//         _homeAd1 = ad;
//         break;
//       case AdType.homeAd2:
//         _homeAd2 = ad;
//         break;
//       case AdType.calendarAd:
//         _calendarAd = ad;
//         break;
//       case AdType.myGardenAd:
//         _myGardenAd = ad;
//         break;
//       case AdType.discoverPlantAd:
//         _discoverPlantAd = ad;
//         break;
//       case AdType.discoverPlantDetailAd:
//         _discoverPlantDetailAd = ad;
//         break;
//       default:
//         ad.dispose();
//     }
//   }
//
//   // --------------------------------------------------------------------
//   //                       LOAD REWARDED ADS (iOS)
//   // --------------------------------------------------------------------
//
//   Future<void> _loadRewarded(AdType type) async {
//     final id = AdHelper.lensAd;
//
//     await RewardedAd.load(
//       adUnitId: id,
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (ad) {
//           _lensAd = ad;
//           _setState(type, true);
//         },
//         onAdFailedToLoad: (err) {
//           _setState(type, false);
//         },
//       ),
//     );
//   }
//
//   // --------------------------------------------------------------------
//   // Helpers
//   // --------------------------------------------------------------------
//
//   void _setState(AdType type, bool value) {
//     _loaded[type] = value;
//     notifyListeners();
//   }
//
//   String _adId(AdType type) {
//     switch (type) {
//       case AdType.homeAd1:
//         return AdHelper.homeAd1;
//       case AdType.homeAd2:
//         return AdHelper.homeAd2;
//       case AdType.calendarAd:
//         return AdHelper.calendarAd;
//       case AdType.myGardenAd:
//         return AdHelper.myGardenAd;
//       case AdType.discoverPlantAd:
//         return AdHelper.discoverPlantAd;
//       case AdType.discoverPlantDetailAd:
//         return AdHelper.discoverPlantDetailAd;
//       case AdType.lensAd:
//         return AdHelper.lensAd;
//     }
//   }
// }
//
// enum AdType {
//   homeAd1,
//   homeAd2,
//   calendarAd,
//   myGardenAd,
//   discoverPlantAd,
//   discoverPlantDetailAd,
//   lensAd,
// }

// secon


import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../modules/my_garden/services/CreditManager.dart';
import 'AdHelper.dart';

class AdProvider with ChangeNotifier {
  final CreditManager creditManager;

  AdProvider({required this.creditManager});

  /// Ad states
  final Map<AdType, bool> _loaded = {
    AdType.homeAd1: false,
    AdType.homeAd2: false,
    AdType.calendarAd: false,
    AdType.myGardenAd: false,
    AdType.discoverPlantAd: false,
    AdType.discoverPlantDetailAd: false,
    AdType.rewardedAd: false,
  };

  // Ad objects
  NativeAd? _homeAd1;
  NativeAd? _homeAd2;
  NativeAd? _calendarAd;
  NativeAd? _myGardenAd;
  NativeAd? _discoverPlantAd;
  NativeAd? _discoverPlantDetailAd;
  RewardedAd? _rewardedAd;

  bool _isEarningCredits = false;

  /// Public getters
  bool get isHomeAd1 => _loaded[AdType.homeAd1]!;
  bool get isHomeAd2 => _loaded[AdType.homeAd2]!;
  bool get isCalendarAd => _loaded[AdType.calendarAd]!;
  bool get isMyGardenAd => _loaded[AdType.myGardenAd]!;
  bool get isDiscoverPlantAd => _loaded[AdType.discoverPlantAd]!;
  bool get isDiscoverPlantDetailAd => _loaded[AdType.discoverPlantDetailAd]!;
  bool get isRewardedAdLoaded => _loaded[AdType.rewardedAd]!;
  bool get isEarningCredits => _isEarningCredits;

  NativeAd? get homeAd1 => _homeAd1;
  NativeAd? get homeAd2 => _homeAd2;
  NativeAd? get calendarAd => _calendarAd;
  NativeAd? get myGardenAd => _myGardenAd;
  NativeAd? get discoverPlantAd => _discoverPlantAd;
  NativeAd? get discoverPlantDetailAd => _discoverPlantDetailAd;

  /// Preload ad
  Future<void> preloadAd(AdType type, {dynamic adSize}) async {
    switch (type) {
      case AdType.rewardedAd:
        return _loadRewarded();
      default:
        return _loadNative(type, adSize);
    }
  }

  /// Load native ads
  Future<void> _loadNative(AdType type, dynamic size) async {
    final id = _adId(type);

    final ad = NativeAd(
      adUnitId: id,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: size),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _setState(type, true);
          _assignNative(type, ad as NativeAd);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint("❌ [Ad] Native ad failed: $err");
          _setState(type, false);
          ad.dispose();
        },
      ),
    );

    await ad.load();
  }

  void _assignNative(AdType type, NativeAd ad) {
    switch (type) {
      case AdType.homeAd1:
        _homeAd1 = ad;
        break;
      case AdType.homeAd2:
        _homeAd2 = ad;
        break;
      case AdType.calendarAd:
        _calendarAd = ad;
        break;
      case AdType.myGardenAd:
        _myGardenAd = ad;
        break;
      case AdType.discoverPlantAd:
        _discoverPlantAd = ad;
        break;
      case AdType.discoverPlantDetailAd:
        _discoverPlantDetailAd = ad;
        break;
      default:
        ad.dispose();
    }
  }

  /// Load rewarded ad
  Future<void> _loadRewarded() async {
    if (_isEarningCredits) {
      debugPrint("⏳ [Ad] Already loading rewarded ad");
      return;
    }

    try {
      _isEarningCredits = true;
      notifyListeners();

      debugPrint("📺 [Ad] Loading rewarded ad...");

      await RewardedAd.load(
        adUnitId: AdHelper.lensAd,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint("✅ [Ad] Rewarded ad loaded");
            _rewardedAd = ad;
            _setState(AdType.rewardedAd, true);
            _isEarningCredits = false;
            notifyListeners();
          },
          onAdFailedToLoad: (err) {
            debugPrint("❌ [Ad] Rewarded ad failed: $err");
            _setState(AdType.rewardedAd, false);
            _isEarningCredits = false;
            notifyListeners();
          },
        ),
      );
    } catch (e) {
      debugPrint("❌ [Ad] Rewarded ad error: $e");
      _isEarningCredits = false;
      notifyListeners();
    }
  }

  /// Show rewarded ad and earn credits
  Future<bool> showRewardedAdForCredits() async {
    if (_rewardedAd == null) {
      debugPrint("⚠️ [Ad] Rewarded ad not loaded");
      return false;
    }

    try {
      bool earnedCredits = false;

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint("📺 [Ad] Rewarded ad showed");
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint("👋 [Ad] Rewarded ad dismissed");
          ad.dispose();
          _rewardedAd = null;
          _setState(AdType.rewardedAd, false);
          // Preload next ad
          _loadRewarded();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          debugPrint("❌ [Ad] Failed to show: $err");
          ad.dispose();
          _rewardedAd = null;
          _setState(AdType.rewardedAd, false);
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) async {
          debugPrint("🎁 [Ad] User earned reward!");

          // Add credits
          final success = await creditManager.rewardForAd();

          if (success) {
            earnedCredits = true;
            debugPrint("✅ [Ad] Added ${CreditManager.rewardedAdCredits} credits");
          }
        },
      );

      return earnedCredits;
    } catch (e) {
      debugPrint("❌ [Ad] Show rewarded ad error: $e");
      return false;
    }
  }

  /// Helpers
  void _setState(AdType type, bool value) {
    _loaded[type] = value;
    notifyListeners();
  }

  String _adId(AdType type) {
    switch (type) {
      case AdType.homeAd1:
        return AdHelper.homeAd1;
      case AdType.homeAd2:
        return AdHelper.homeAd2;
      case AdType.calendarAd:
        return AdHelper.calendarAd;
      case AdType.myGardenAd:
        return AdHelper.myGardenAd;
      case AdType.discoverPlantAd:
        return AdHelper.discoverPlantAd;
      case AdType.discoverPlantDetailAd:
        return AdHelper.discoverPlantDetailAd;
      case AdType.rewardedAd:
        return AdHelper.lensAd;
    }
  }

  @override
  void dispose() {
    _homeAd1?.dispose();
    _homeAd2?.dispose();
    _calendarAd?.dispose();
    _myGardenAd?.dispose();
    _discoverPlantAd?.dispose();
    _discoverPlantDetailAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}

enum AdType {
  homeAd1,
  homeAd2,
  calendarAd,
  myGardenAd,
  discoverPlantAd,
  discoverPlantDetailAd,
  rewardedAd,
}