import 'package:flutter/material.dart';
import 'design_system.dart';
import 'components.dart';

class AppTheme {
  // Light Theme
  static ThemeData light({Color? primaryColor}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor ?? DesignTokens.primaryColor,
      brightness: Brightness.light,
      surface: DesignTokens.neutral50,
      onSurface: DesignTokens.neutral900,
      surfaceContainer: DesignTokens.neutral100,
      surfaceContainerHigh: DesignTokens.neutral200,
      surfaceContainerHighest: DesignTokens.neutral300,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DesignTokens.neutral50,
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1(color: DesignTokens.neutral900),
        displayMedium: AppTextStyles.h2(color: DesignTokens.neutral900),
        displaySmall: AppTextStyles.h3(color: DesignTokens.neutral900),
        headlineLarge: AppTextStyles.h4(color: DesignTokens.neutral900),
        headlineMedium: AppTextStyles.h4(color: DesignTokens.neutral900),
        headlineSmall: AppTextStyles.h4(color: DesignTokens.neutral900),
        titleLarge: AppTextStyles.h4(color: DesignTokens.neutral900),
        titleMedium: AppTextStyles.h3(color: DesignTokens.neutral900),
        titleSmall: AppTextStyles.bodyLarge(color: DesignTokens.neutral900),
        bodyLarge: AppTextStyles.bodyLarge(color: DesignTokens.neutral700),
        bodyMedium: AppTextStyles.body(color: DesignTokens.neutral700),
        bodySmall: AppTextStyles.bodySmall(color: DesignTokens.neutral600),
        labelLarge: AppTextStyles.body(color: DesignTokens.neutral900),
        labelMedium: AppTextStyles.bodySmall(color: DesignTokens.neutral700),
        labelSmall: AppTextStyles.caption(color: DesignTokens.neutral600),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: DesignTokens.neutral50,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.neutral50,
        foregroundColor: DesignTokens.neutral900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h4(color: DesignTokens.neutral900),
        iconTheme: IconThemeData(
          color: DesignTokens.neutral700,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: DesignTokens.neutral700,
          size: 24,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.primary(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.secondary(),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyles.ghost(),
      ),
      
      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: DesignTokens.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: DesignTokens.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: DesignTokens.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        hintStyle: AppTextStyles.bodySmall(color: DesignTokens.neutral500),
        labelStyle: AppTextStyles.bodySmall(color: DesignTokens.neutral600),
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: DesignTokens.neutral800,
        contentTextStyle: AppTextStyles.body(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        elevation: 8,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: DesignTokens.neutral50,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
        titleTextStyle: AppTextStyles.h4(color: DesignTokens.neutral900),
        contentTextStyle: AppTextStyles.body(color: DesignTokens.neutral700),
        elevation: 16,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: DesignTokens.neutral200,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: DesignTokens.neutral700,
        size: 24,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: DesignTokens.primaryColor,
        linearTrackColor: DesignTokens.neutral200,
        circularTrackColor: DesignTokens.neutral200,
      ),
    );
  }

  // Dark Theme
  static ThemeData dark({Color? primaryColor}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor ?? DesignTokens.primaryColor,
      brightness: Brightness.dark,
      surface: DesignTokens.surface200,
      onSurface: DesignTokens.neutral100,
      surfaceContainer: DesignTokens.surface300,
      surfaceContainerHigh: DesignTokens.surface400,
      surfaceContainerHighest: DesignTokens.surface500,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DesignTokens.surface100,
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1(),
        displayMedium: AppTextStyles.h2(),
        displaySmall: AppTextStyles.h3(),
        headlineLarge: AppTextStyles.h4(),
        headlineMedium: AppTextStyles.h4(),
        headlineSmall: AppTextStyles.h4(),
        titleLarge: AppTextStyles.h4(),
        titleMedium: AppTextStyles.h3(),
        titleSmall: AppTextStyles.bodyLarge(),
        bodyLarge: AppTextStyles.bodyLarge(),
        bodyMedium: AppTextStyles.body(),
        bodySmall: AppTextStyles.bodySmall(),
        labelLarge: AppTextStyles.body(),
        labelMedium: AppTextStyles.bodySmall(),
        labelSmall: AppTextStyles.caption(),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: DesignTokens.surface200,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.surface100,
        foregroundColor: DesignTokens.neutral100,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h4(),
        iconTheme: IconThemeData(
          color: DesignTokens.neutral300,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: DesignTokens.neutral300,
          size: 24,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.primary(),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.secondary(),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyles.ghost(),
      ),
      
      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.surface300,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: DesignTokens.neutral600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: DesignTokens.neutral600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: DesignTokens.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        hintStyle: AppTextStyles.bodySmall(),
        labelStyle: AppTextStyles.bodySmall(),
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: DesignTokens.surface300,
        contentTextStyle: AppTextStyles.body(color: DesignTokens.neutral100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        elevation: 8,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: DesignTokens.surface200,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
        titleTextStyle: AppTextStyles.h4(),
        contentTextStyle: AppTextStyles.body(),
        elevation: 16,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: DesignTokens.neutral700.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: DesignTokens.neutral300,
        size: 24,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: DesignTokens.primaryColor,
        linearTrackColor: DesignTokens.surface400,
        circularTrackColor: DesignTokens.surface400,
      ),
    );
  }
}
