import 'package:flutter/material.dart';
import 'design_system.dart';

class AppInputStyles {
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