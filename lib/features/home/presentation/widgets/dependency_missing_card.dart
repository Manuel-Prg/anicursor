import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/shared/theme/design_system.dart';
import 'package:ani_to_xcursor/shared/theme/components.dart';
import 'package:ani_to_xcursor/shared/providers/dependency_provider.dart';

class DependencyMissingCard extends StatelessWidget {
  final DependencyState deps;

  const DependencyMissingCard({required this.deps, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            const SizedBox(height: SpacingTokens.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(RadiusTokens.md),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Distro: ${deps.distroName}',
                        style: AppTextStyles.bodySmall(
                          color: Colors.white.withValues(alpha: 0.6),
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Recomendado',
                        style: AppTextStyles.bodySmall(
                          color: DesignTokens.warningColor.withValues(alpha: 0.8),
                        ).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deps.recommendedCommand.isNotEmpty
                              ? deps.recommendedCommand
                              : 'Instalación manual requerida',
                          style: TextStyle(
                            fontFamily: TypographyTokens.mono,
                            fontSize: TypographyTokens.xs,
                            color: Colors.amber.shade200,
                          ),
                        ),
                      ),
                      if (deps.recommendedCommand.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          color: Colors.white.withValues(alpha: 0.6),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: deps.recommendedCommand),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Comando copiado al portapapeles'),
                                backgroundColor: theme.colorScheme.primary,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          tooltip: 'Copiar comando',
                        ),
                    ],
                  ),
                ],
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
                  final pmName = deps.packageManager.name;
                  final label = deps.packageManager == PackageManager.unknown
                      ? 'Instalar automáticamente (No soportado)'
                      : 'Instalar automáticamente ($pmName)';
                  final canInstall = deps.packageManager != PackageManager.unknown;

                  return FilledButton.icon(
                    style: AppButtonStyles.danger(
                      padding: SpacingTokens.lg,
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                    ),
                    onPressed: canInstall
                        ? () async {
                            await ref
                                .read(dependencyProvider.notifier)
                                .installDependencies();
                          }
                        : null,
                    icon: const Icon(Icons.download),
                    label: Text(label),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
