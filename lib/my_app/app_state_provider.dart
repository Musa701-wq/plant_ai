// // lib/providers/app_state_provider.dart
// import 'package:flutter/material.dart';
//
// class AppStateProvider with ChangeNotifier {
//   int _currentIndex = 0;
//
//   int get currentIndex => _currentIndex;
//
//   void changeTab(int index) {
//     _currentIndex = index;
//     notifyListeners();
//   }
// }

// lib/providers/app_state_provider.dart
import 'package:flutter/material.dart';

class AppStateProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (index < 0 || index > 4) {
      debugPrint('[AppStateProvider] ❌ Invalid tab index: $index');
      return;
    }
    debugPrint('[AppStateProvider] ✅ Changing tab from $_currentIndex to $index');
    _currentIndex = index;
    notifyListeners();
  }

  void reset() {
    _currentIndex = 0;
    notifyListeners();
  }
}