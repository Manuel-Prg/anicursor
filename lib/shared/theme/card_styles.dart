import 'package:flutter/material.dart';
import 'design_system.dart';

class AppCardStyles {
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
