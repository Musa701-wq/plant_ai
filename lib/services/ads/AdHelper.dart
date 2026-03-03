/*
import 'package:flutter/foundation.dart';

class AdHelper {
  // iOS REAL Ad IDs only
  static const Map<String, String> _iosAds = {
    //native ad
    'homeAd1': 'ca-app-pub-3774337907915828/4814707974',
    //'homeAd2': 'ca-app-pub-3774337907915828/8737926520',

    //'calendarAd': 'ca-app-pub-3774337907915828/3485599848',
    //'myGardenAd': 'ca-app-pub-3774337907915828/3266656738',
    //'discoverPlantAd': 'ca-app-pub-3774337907915828/9605544817',
    //'discoverPlantDetailAd': 'ca-app-pub-9286190198569219/5595831514',
    //rewarded ad
    'lensAd': 'ca-app-pub-3774337907915828/2301769861',
  };

  // iOS Test IDs
  static const Map<String, String> _testAds = {
    'native': 'ca-app-pub-3940256099942544/3986624511',
    'rewarded': 'ca-app-pub-3940256099942544/1712485313',
  };

  /// iOS → Always use REAL IDs (recommended)
  /// If you want test ads → change to: return kDebugMode;
  // static bool get useTestAds => false;
  static bool get useTestAds => kDebugMode;

  static String _getAd(String name, {bool rewarded = false}) {
    if (useTestAds) {
      return rewarded ? _testAds['rewarded']! : _testAds['native']!;
    }
    return _iosAds[name]!;
  }

  // final getters
  static String get homeAd1 => _getAd('homeAd1');
  static String get homeAd2 => _getAd('homeAd2');
  static String get calendarAd => _getAd('calendarAd');
  static String get myGardenAd => _getAd('myGardenAd');
  static String get discoverPlantAd => _getAd('discoverPlantAd');
  static String get discoverPlantDetailAd => _getAd('discoverPlantDetailAd');
  static String get lensAd => _getAd('lensAd', rewarded: true);
}
*/
import 'package:flutter/foundation.dart';

class AdHelper {
  // iOS REAL Ad IDs - Using common IDs for similar ad types
  static const Map<String, String> _iosAds = {
    // Native ads - All use the same ID
    'nativeAd': 'ca-app-pub-3774337907915828/4814707974',

    // Rewarded ad
    'rewardedAd': 'ca-app-pub-3774337907915828/2301769861',
  };

  // iOS Test IDs
  static const Map<String, String> _testAds = {
    'native': 'ca-app-pub-3940256099942544/3986624511',
    'rewarded': 'ca-app-pub-3940256099942544/1712485313',
  };

  /// iOS → Use test ads in debug mode, real ads in release
  static bool get useTestAds => kDebugMode;

  static String _getAd(String name, {bool rewarded = false}) {
    if (useTestAds) {
      return rewarded ? _testAds['rewarded']! : _testAds['native']!;
    }
    return _iosAds[name]!;
  }

  // All native ads use the same ID
  static String get homeAd1 => _getAd('nativeAd');
  static String get homeAd2 => _getAd('nativeAd');
  static String get calendarAd => _getAd('nativeAd');
  static String get myGardenAd => _getAd('nativeAd');
  static String get discoverPlantAd => _getAd('nativeAd');
  static String get discoverPlantDetailAd => _getAd('nativeAd');

  // Rewarded ad
  static String get lensAd => _getAd('rewardedAd', rewarded: true);
}