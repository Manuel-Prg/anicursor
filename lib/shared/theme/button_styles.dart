import 'package:flutter/material.dart';
import 'design_system.dart';

class AppButtonStyles {
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
      textStyle:
          textStyle ??
          const TextStyle(
            fontSize: TypographyTokens.sm,
            fontWeight: TypographyTokens.medium,
          ),
    );
  }

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
      textStyle:
          textStyle ??
          const TextStyle(
            fontSize: TypographyTokens.sm,
            fontWeight: TypographyTokens.medium,
          ),
    );
  }

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
      textStyle:
          textStyle ??
          const TextStyle(
            fontSize: TypographyTokens.sm,
            fontWeight: TypographyTokens.medium,
          ),
    );
  }

  static ButtonStyle success({double? padding, BorderRadius? borderRadius}) {
    return primary(
      backgroundColor: DesignTokens.successColor,
      foregroundColor: Colors.white,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  static ButtonStyle danger({double? padding, BorderRadius? borderRadius}) {
    return primary(
      backgroundColor: DesignTokens.errorColor,
      foregroundColor: Colors.white,
      padding: padding,
      borderRadius: borderRadius,
    );
  }
}
