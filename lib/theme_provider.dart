import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString("themeMode");

    if (theme == "light") {
      _themeMode = ThemeMode.light;
    } else if (theme == "dark") {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("themeMode", mode == ThemeMode.light
        ? "light"
        : mode == ThemeMode.dark
        ? "dark"
        : "system");

    notifyListeners();
  }
}
