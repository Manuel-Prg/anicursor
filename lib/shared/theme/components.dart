import 'package:flutter/material.dart';
import 'design_system.dart';

class AppButtonStyles {
  // Primary Button
  static ButtonStyle primary({
    Color? backgroundColor,
    Color? foregroundColor,
    double? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? DesignTokens.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: padding ?? SpacingTokens.lg,
        vertical: SpacingTokens.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(RadiusTokens.sm),
      ),
      textStyle: textStyle ?? const TextStyle(
        fontSize: TypographyTokens.sm,
        fontWeight: TypographyTokens.medium,
      ),
    );
  }
  
  // Secondary Button
  static ButtonStyle secondary({
    Color? backgroundColor,
    Color? foregroundColor,
    double? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    return OutlinedButton.styleFrom(
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor ?? DesignTokens.primaryColor,
      side: BorderSide(
        color: foregroundColor ?? DesignTokens.primaryColor,
        width: 1.5,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: padding ?? SpacingTokens.lg,
        vertical: SpacingTokens.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(RadiusTokens.sm),
      ),
      textStyle: textStyle ?? const TextStyle(
        fontSize: TypographyTokens.sm,
        fontWeight: TypographyTokens.medium,
      ),
    );
  }
  
  // Ghost Button
  static ButtonStyle ghost({
    Color? foregroundColor,
    double? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    return TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? DesignTokens.primaryColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: padding ?? SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(RadiusTokens.sm),
      ),
      textStyle: textStyle ?? const TextStyle(
        fontSize: TypographyTokens.sm,
        fontWeight: TypographyTokens.medium,
      ),
    );
  }
  
  // Success Button
  static ButtonStyle success({
    double? padding,
    BorderRadius? borderRadius,
  }) {
    return primary(
      backgroundColor: DesignTokens.successColor,
      foregroundColor: Colors.white,
      padding: padding,
      borderRadius: borderRadius,
    );
  }
  
  // Danger Button
  static ButtonStyle danger({
    double? padding,
    BorderRadius? borderRadius,
  }) {
    return primary(
      backgroundColor: DesignTokens.errorColor,
      foregroundColor: Colors.white,
      padding: padding,
      borderRadius: borderRadius,
    );
  }
}

class AppCardStyles {
  // Default Card
  static BoxDecoration defaultCard({
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? DesignTokens.surface200,
      borderRadius: BorderRadius.circular(borderRadius ?? RadiusTokens.lg),
      border: Border.all(
        color: borderColor ?? DesignTokens.neutral700.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: boxShadow ?? ShadowTokens.sm,
    );
  }
  
  // Elevated Card
  static BoxDecoration elevatedCard({
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? DesignTokens.surface200,
      borderRadius: BorderRadius.circular(borderRadius ?? RadiusTokens.lg),
      border: Border.all(
        color: borderColor ?? DesignTokens.neutral700.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: boxShadow ?? ShadowTokens.md,
    );
  }
  
  // Interactive Card
  static BoxDecoration interactiveCard({
    Color? backgroundColor,
    Color? borderColor,
    Color? hoverColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? DesignTokens.surface200,
      borderRadius: BorderRadius.circular(borderRadius ?? RadiusTokens.lg),
      border: Border.all(
        color: borderColor ?? DesignTokens.neutral700.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: boxShadow ?? ShadowTokens.sm,
    );
  }
}

class AppInputStyles {
  // Default TextField
  static InputDecoration defaultInput({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
    Color? borderColor,
    double? borderRadius,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? DesignTokens.surface300,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? RadiusTokens.sm),
        borderSide: BorderSide(
          color: borderColor ?? DesignTokens.neutral600,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? RadiusTokens.sm),
        borderSide: BorderSide(
          color: borderColor ?? DesignTokens.neutral600,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? RadiusTokens.sm),
        borderSide: BorderSide(
          color: DesignTokens.primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? RadiusTokens.sm),
        borderSide: BorderSide(
          color: DesignTokens.errorColor,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? RadiusTokens.sm),
        borderSide: BorderSide(
          color: DesignTokens.errorColor,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      hintStyle: TextStyle(
        color: DesignTokens.neutral500,
        fontSize: TypographyTokens.sm,
      ),
      labelStyle: TextStyle(
        color: DesignTokens.neutral400,
        fontSize: TypographyTokens.sm,
      ),
    );
  }
  
  // Search Input
  static InputDecoration searchInput({
    String? hintText,
    Widget? prefixIcon,
    Color? fillColor,
    double? borderRadius,
  }) {
    return defaultInput(
      hintText: hintText ?? 'Buscar...',
      prefixIcon: prefixIcon ?? Icon(
        Icons.search,
        color: DesignTokens.neutral500,
        size: 20,
      ),
      fillColor: fillColor ?? DesignTokens.surface300,
      borderRadius: borderRadius ?? RadiusTokens.xxl,
      borderColor: DesignTokens.neutral700.withValues(alpha: 0.3),
    );
  }
}

class AppTextStyles {
  // Headings
  static TextStyle h1({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.huge,
      fontWeight: fontWeight ?? TypographyTokens.bold,
      color: color ?? DesignTokens.neutral100,
      height: TypographyTokens.tight,
    );
  }
  
  static TextStyle h2({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.xxxl,
      fontWeight: fontWeight ?? TypographyTokens.bold,
      color: color ?? DesignTokens.neutral100,
      height: TypographyTokens.tight,
    );
  }
  
  static TextStyle h3({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.xxl,
      fontWeight: fontWeight ?? TypographyTokens.semibold,
      color: color ?? DesignTokens.neutral100,
      height: TypographyTokens.tight,
    );
  }
  
  static TextStyle h4({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.xl,
      fontWeight: fontWeight ?? TypographyTokens.semibold,
      color: color ?? DesignTokens.neutral100,
      height: TypographyTokens.tight,
    );
  }
  
  // Body Text
  static TextStyle bodyLarge({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.lg,
      fontWeight: fontWeight ?? TypographyTokens.normal,
      color: color ?? DesignTokens.neutral200,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle body({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.normal,
      color: color ?? DesignTokens.neutral200,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle bodySmall({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.sm,
      fontWeight: fontWeight ?? TypographyTokens.normal,
      color: color ?? DesignTokens.neutral300,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle caption({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.xs,
      fontWeight: fontWeight ?? TypographyTokens.normal,
      color: color ?? DesignTokens.neutral400,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  // Special Text
  static TextStyle primary({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.medium,
      color: color ?? DesignTokens.primaryColor,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle success({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.medium,
      color: color ?? DesignTokens.successColor,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle warning({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.medium,
      color: color ?? DesignTokens.warningColor,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle error({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.medium,
      color: color ?? DesignTokens.errorColor,
      height: TypographyTokens.lineHeightNormal,
    );
  }
}

class AppAnimationStyles {
  // Hover Animation
  static AnimationController? hoverController;
  static Animation<double>? hoverAnimation;
  
  // Scale Animation
  static Widget scaleAnimation({
    required Widget child,
    double scale = 0.95,
    Duration duration = AnimationTokens.fast,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: scale),
      duration: duration,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Fade Animation
  static Widget fadeAnimation({
    required Widget child,
    Duration duration = AnimationTokens.normal,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: AnimationTokens.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Slide Animation
  static Widget slideAnimation({
    required Widget child,
    Offset begin = const Offset(0, 0.2),
    Duration duration = AnimationTokens.normal,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: begin, end: Offset.zero),
      duration: duration,
      curve: AnimationTokens.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value * 100,
          child: child,
        );
      },
      child: child,
    );
  }
}
