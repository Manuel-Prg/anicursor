import 'package:flutter/material.dart';
import 'design_system.dart';

class AppAnimationStyles {
  static Widget scaleAnimation({
    required Widget child,
    double scale = 0.95,
    Duration duration = AnimationTokens.fast,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: scale),
      duration: duration,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  static Widget fadeAnimation({
    required Widget child,
    Duration duration = AnimationTokens.normal,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: AnimationTokens.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

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
        return Transform.translate(offset: value * 100, child: child);
      },
      child: child,
    );
  }
}
