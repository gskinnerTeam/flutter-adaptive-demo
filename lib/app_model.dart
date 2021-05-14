import 'package:flutter/material.dart';

class AppModel with ChangeNotifier {
  // Main menu, selected page
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) => notify(() => _selectedIndex = value);

  // Touch mode, determines density of views
  bool _touchMode = false;
  bool get touchMode => _touchMode;
  set touchMode(bool value) => notify(() => _touchMode = value);
  void toggleTouchMode() => touchMode = !touchMode;

  // Indicates whether a user is logged in or not
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool value) => notify(() => _isLoggedIn = value);

  void logout() {
    _selectedIndex = 0;
    isLoggedIn = false;
  }

  void login() => isLoggedIn = true;
  // Helper method for single-line state changes
  void notify(VoidCallback stateChange) {
    stateChange.call();
    notifyListeners();
  }
}
