import 'package:flutter/material.dart';
import 'design_system.dart';

class AppTextStyles {
  static TextStyle h1({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.huge,
      fontWeight: fontWeight ?? TypographyTokens.bold,
      color: color ?? DesignTokens.neutral100,
      height: TypographyTokens.tight,
    );
  }
  
  static TextStyle h2({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.xxxl,
      fontWeight: fontWeight ?? TypographyTokens.bold,
      color: color ?? DesignTokens.neutral100,
      height: TypographyTokens.tight,
    );
  }
  
  static TextStyle h3({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.xxl,
      fontWeight: fontWeight ?? TypographyTokens.semibold,
      color: color ?? DesignTokens.neutral100,
      height: TypographyTokens.tight,
    );
  }
  
  static TextStyle h4({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.xl,
      fontWeight: fontWeight ?? TypographyTokens.semibold,
      color: color ?? DesignTokens.neutral100,
      height: TypographyTokens.tight,
    );
  }
  
  static TextStyle bodyLarge({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.lg,
      fontWeight: fontWeight ?? TypographyTokens.normal,
      color: color ?? DesignTokens.neutral200,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle body({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.normal,
      color: color ?? DesignTokens.neutral200,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle bodySmall({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.sm,
      fontWeight: fontWeight ?? TypographyTokens.normal,
      color: color ?? DesignTokens.neutral300,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle caption({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.xs,
      fontWeight: fontWeight ?? TypographyTokens.normal,
      color: color ?? DesignTokens.neutral400,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle primary({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.medium,
      color: color ?? DesignTokens.primaryColor,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle success({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.medium,
      color: color ?? DesignTokens.successColor,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle warning({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.medium,
      color: color ?? DesignTokens.warningColor,
      height: TypographyTokens.lineHeightNormal,
    );
  }
  
  static TextStyle error({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: TypographyTokens.base,
      fontWeight: fontWeight ?? TypographyTokens.medium,
      color: color ?? DesignTokens.errorColor,
      height: TypographyTokens.lineHeightNormal,
    );
  }
}