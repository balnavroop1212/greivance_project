import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserThemeProvider with ChangeNotifier {
  static const String _userThemeKey = "user_theme_preference";
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  UserThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userThemeKey, _themeMode.toString());
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeStr = prefs.getString(_userThemeKey);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => ThemeMode.light,
      );
      notifyListeners();
    }
  }
}
