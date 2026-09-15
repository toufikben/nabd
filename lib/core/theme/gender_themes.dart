import 'package:flutter/material.dart';
import 'app_colors.dart';

enum GenderTheme { neutral, feminine, masculine }

class GenderThemes {
  static ThemeData feminineTheme() => _theme(AppColors.femininePrimary, AppColors.feminineBackground);
  static ThemeData masculineTheme() => _theme(AppColors.masculinePrimary, AppColors.masculineBackground);
  static ThemeData neutralTheme() => _theme(AppColors.primary, AppColors.background);

  static ThemeData _theme(Color seed, Color background) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
        cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
      );
}
