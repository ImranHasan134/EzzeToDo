import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  late Box _prefs;
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    _prefs = await Hive.openBox('prefs');
    _isDark = _prefs.get('isDark', defaultValue: false);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    await _prefs.put('isDark', _isDark);
    notifyListeners();
  }
}
