import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  final _storage = GetStorage();
  final _themeKey = 'theme_mode';
  
  final _isDarkMode = false.obs;
  
  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }
  
  void _loadThemeMode() {
    final savedThemeMode = _storage.read(_themeKey);
    if (savedThemeMode != null) {
      _isDarkMode.value = savedThemeMode == 'dark';
    } else {
      // Por defecto usar el tema del sistema
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _isDarkMode.value = brightness == Brightness.dark;
    }
  }
  
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _saveThemeMode();
    Get.changeThemeMode(themeMode);
  }
  
  void _saveThemeMode() {
    _storage.write(_themeKey, _isDarkMode.value ? 'dark' : 'light');
  }
  
  void setThemeMode(ThemeMode mode) {
    _isDarkMode.value = mode == ThemeMode.dark;
    _saveThemeMode();
    Get.changeThemeMode(mode);
  }
} 