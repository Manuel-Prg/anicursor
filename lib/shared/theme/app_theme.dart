import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFFE91E8C);
  static const _backgroundColor = Color(0xFF0F0F0F);
  static const _surfaceColor = Color(0xFF1A1A1A);
  static const _cardColor = Color(0xFF242424);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _primaryColor,
          background: _backgroundColor,
          surface: _surfaceColor,
          surfaceVariant: _cardColor,
        ),
        scaffoldBackgroundColor: _backgroundColor,
        cardTheme: const CardThemeData(
          color: _cardColor,
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _backgroundColor,
          elevation: 0,
        ),
      );
}