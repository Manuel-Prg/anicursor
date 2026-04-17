import 'package:flutter/material.dart';

class AppTheme {
  static const backgroundColorDark = Color(0xFF0F0F0F);
  static const surfaceColorDark = Color(0xFF1A1A1A);
  static const cardColorDark = Color(0xFF242424);

  static ThemeData light(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: primaryColor,
      cardTheme: const CardThemeData(elevation: 0),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData dark(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: primaryColor,
      scaffoldBackgroundColor: backgroundColorDark,
      cardTheme: const CardThemeData(color: cardColorDark, elevation: 0),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColorDark,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cardColorDark,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
