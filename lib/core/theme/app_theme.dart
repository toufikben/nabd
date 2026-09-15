import 'package:flutter/material.dart';
import 'gender_themes.dart';

class AppTheme {
  static final light = GenderThemes.neutralTheme();
  static final dark = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7), brightness: Brightness.dark), scaffoldBackgroundColor: const Color(0xFF0A0D14));

  static ThemeData getTheme(String themeName, GenderTheme genderTheme) {
    if (genderTheme == GenderTheme.feminine) return GenderThemes.feminineTheme();
    if (genderTheme == GenderTheme.masculine) return GenderThemes.masculineTheme();
    return themeName == 'dark' ? dark : light;
  }
}
