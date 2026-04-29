import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ani_to_xcursor/features/home/presentation/home_provider.dart';
import 'package:ani_to_xcursor/features/home/presentation/widgets/dependency_missing_card.dart';
import 'package:ani_to_xcursor/features/home/presentation/widgets/drop_zone.dart';
import 'package:ani_to_xcursor/features/home/presentation/widgets/social_footer.dart';
import 'package:ani_to_xcursor/features/converter/presentation/converter_provider.dart';
import 'package:ani_to_xcursor/shared/providers/dependency_provider.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/shared/theme/design_system.dart';
import 'package:ani_to_xcursor/shared/theme/components.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final deps = ref.watch(dependencyProvider);
    final settings = ref.watch(settingsProvider).current;
    final homeActions = ref.read(homeActionsProvider);

    // Mostrar onboarding si es la primera vez
    if (settings.showedOnboarding != true) {
      homeActions.handleOnboarding(context);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            padding: const EdgeInsets.all(12),
            onPressed: () => context.pushNamed('installed-themes'),
            tooltip: 'Gestor de Temas',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            padding: const EdgeInsets.all(12),
            onPressed: () => context.push('/settings'),
            tooltip: 'Configuración',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.xxxl,
              vertical: SpacingTokens.xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo e info con animación
                    AppAnimationStyles.fadeAnimation(
                      child: Hero(
                        tag: 'logo',
                        child: SvgPicture.asset(
                          isLight
                              ? 'assets/ani_xcursor_logo_light.svg'
                              : 'assets/ani_xcursor_logo_v3.svg',
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    AppAnimationStyles.slideAnimation(
                      child: Text(
                        'AniCursor',
                        style: AppTextStyles.h2(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    AppAnimationStyles.slideAnimation(
                      child: Text(
                        'Convierte cursores animados de Windows al formato XCursor de Linux',
                        style: AppTextStyles.bodyLarge(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xxl),

                    if (deps.status == DependencyStatus.checking)
                      AppAnimationStyles.fadeAnimation(
                        child: const CircularProgressIndicator(strokeWidth: 3),
                      )
                    else if (deps.status == DependencyStatus.missing)
                      DependencyMissingCard(deps: deps)
                    else ...[
                      DropZone(
                        onFilesDropped: (paths) {
                          ref
                              .read(cursorThemeProvider.notifier)
                              .scanDirectory(paths.first);
                          context.push('/converter');
                        },
                      ),
                      const SizedBox(height: 32),
                      AppAnimationStyles.slideAnimation(
                        begin: const Offset(0, 0.1),
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              homeActions.selectFolderAndConvert(context),
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Seleccionar carpeta'),
                          style: AppButtonStyles.secondary(
                            padding: SpacingTokens.lg,
                            borderRadius: BorderRadius.circular(
                              RadiusTokens.md,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.xxxl),
                    // ─── Footer social links ──────────────────────────────────
                    const SocialFooter(),
                    const SizedBox(height: SpacingTokens.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
