import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/shared/theme/design_system.dart';
import 'package:ani_to_xcursor/shared/theme/components.dart';
import 'package:ani_to_xcursor/shared/providers/dependency_provider.dart';

class DependencyMissingCard extends StatelessWidget {
  final DependencyState deps;

  const DependencyMissingCard({required this.deps, super.key});

  @override
  Widget build(BuildContext context) {
    return AppAnimationStyles.fadeAnimation(
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(SpacingTokens.xl),
        decoration: BoxDecoration(
          color: DesignTokens.errorColor.withValues(alpha: 0.1),
          border: Border.all(
            color: DesignTokens.errorColor.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(RadiusTokens.xxl),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.errorColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: DesignTokens.errorColor,
              size: 56,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Dependencias Faltantes',
              style: AppTextStyles.h3(color: DesignTokens.errorColor),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Para que la magia funcione en Linux, necesitamos ImageMagick y Xcursorgen.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                color: DesignTokens.errorColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            if (deps.isInstalling)
              const CircularProgressIndicator(
                color: DesignTokens.errorColor,
                strokeWidth: 3,
              )
            else
              Consumer(
                builder: (context, ref, _) {
                  return FilledButton.icon(
                    style: AppButtonStyles.danger(
                      padding: SpacingTokens.lg,
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                    ),
                    onPressed: () async {
                      await ref
                          .read(dependencyProvider.notifier)
                          .installDependencies();
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Instalar automáticamente (Apt)'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
