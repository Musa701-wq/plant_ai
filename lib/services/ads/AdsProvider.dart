

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
        return;
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