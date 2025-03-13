import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _bottomNavIndex = 0;
  int _currentCardIndex = 0;

  int get bottomNavIndex => _bottomNavIndex;
  int get currentCardIndex => _currentCardIndex;

  void setBottomNavIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners(); // 상태 변경 알림
  }

  void setCurrentCardIndex(int index) {
    _currentCardIndex = index;
    notifyListeners(); // 상태 변경 알림
  }
}