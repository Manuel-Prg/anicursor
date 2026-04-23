import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ani_to_xcursor/features/converter/presentation/converter_provider.dart';
import 'package:ani_to_xcursor/shared/providers/dependency_provider.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/features/home/presentation/widgets/onboarding_dialog.dart';
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

    // Si es la primera vez, mostramos onboarding después del primer frame
    if (settings.showedOnboarding != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Doble verificación con el estado actual del notifier para evitar race conditions
        if (context.mounted &&
            ref.read(settingsProvider).current.showedOnboarding != true) {
          ref.read(settingsProvider.notifier).updateShowedOnboarding(true);
          OnboardingDialog.show(context);
        }
      });
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
                      _DependencyMissingCard(deps: deps)
                    else ...[
                      _DropZone(
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
                          onPressed: () async {
                            final result = await FilePicker.getDirectoryPath();
                            if (result != null) {
                              ref
                                  .read(cursorThemeProvider.notifier)
                                  .scanDirectory(result);
                              if (context.mounted) context.push('/converter');
                            }
                          },
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
                    _SocialFooter(),
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

class _DependencyMissingCard extends StatelessWidget {
  final DependencyState deps;

  const _DependencyMissingCard({required this.deps});

  @override
  Widget build(BuildContext context) {
    final _ = Theme.of(context);
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

class _DropZone extends StatefulWidget {
  final Function(List<String>) onFilesDropped;

  const _DropZone({required this.onFilesDropped});

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropTarget(
      onDragEntered: (_) => setState(() => _hovering = true),
      onDragExited: (_) => setState(() => _hovering = false),
      onDragDone: (detail) =>
          widget.onFilesDropped(detail.files.map((f) => f.path).toList()),
      child: AnimatedContainer(
        duration: AnimationTokens.normal,
        curve: AnimationTokens.easeOutBack,
        width: 520,
        height: 280,
        transform: Matrix4.identity()..scaled(_hovering ? 1.03 : 1.0),
        decoration: BoxDecoration(
          color: _hovering
              ? DesignTokens.primaryColor.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.6,
                ),
          borderRadius: BorderRadius.circular(RadiusTokens.xxl),
          border: Border.all(
            color: _hovering
                ? DesignTokens.primaryColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: _hovering ? 3.0 : 2.0,
          ),
          boxShadow: [
            if (_hovering)
              BoxShadow(
                color: DesignTokens.primaryColor.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: -8,
                offset: const Offset(0, 12),
              ),
            if (!_hovering) ...ShadowTokens.sm,
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AnimationTokens.normal,
              padding: const EdgeInsets.all(SpacingTokens.lg),
              decoration: BoxDecoration(
                color: _hovering
                    ? DesignTokens.primaryColor.withValues(alpha: 0.1)
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _hovering
                      ? DesignTokens.primaryColor.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: AnimatedSwitcher(
                duration: AnimationTokens.fast,
                child: Icon(
                  _hovering
                      ? Icons.download_rounded
                      : Icons.move_to_inbox_rounded,
                  key: ValueKey(_hovering),
                  size: 72,
                  color: _hovering
                      ? DesignTokens.primaryColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            AnimatedSwitcher(
              duration: AnimationTokens.fast,
              child: Text(
                _hovering ? '¡Suelta para empezar!' : 'Suelta la carpeta aquí',
                key: ValueKey(_hovering),
                style: AppTextStyles.h4(
                  color: _hovering
                      ? DesignTokens.primaryColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'o haz clic para seleccionar manualmente',
              style: AppTextStyles.body(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              child: Text(
                'Soporta: .ani, .cur',
                style: AppTextStyles.caption(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Social Footer ────────────────────────────────────────────────────────────

class _SocialFooter extends StatelessWidget {
  const _SocialFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIcon(
              tooltip: 'GitHub',
              iconWidget: const FaIcon(FontAwesomeIcons.github, size: 19),
              onTap: () => launchUrl(
                Uri.parse('https://github.com/Manuel-Prg/anicursor'),
              ),
            ),
            const SizedBox(width: 4),
            _SocialIcon(
              tooltip: 'Acerca de',
              iconWidget: const Icon(Icons.info_outline, size: 20),
              onTap: () => _showAboutDialog(context),
            ),
            const SizedBox(width: 4),
            _SocialIcon(
              tooltip: 'Ko-fi — Apoyar el proyecto',
              iconWidget: const Icon(Icons.coffee_outlined, size: 20),
              onTap: () => launchUrl(Uri.parse('https://ko-fi.com/manuelprz')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Made with ♥ by manuelprz',
          style: theme.textTheme.bodySmall?.copyWith(color: iconColor),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mouse_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            const Text('AniCursor'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Convierte cursores animados de Windows (.ani) al formato XCursor de Linux, manteniendo animaciones y generando symlinks.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _AboutRow(icon: Icons.person_outline, label: 'manuelprz'),
            const SizedBox(height: 6),
            _AboutRow(
              icon: Icons.code,
              label: 'github.com/manuelprz/anicursor',
            ),
            const SizedBox(height: 6),
            _AboutRow(
              icon: Icons.build_outlined,
              label: 'imagemagick + xcursorgen',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              launchUrl(Uri.parse('https://github.com/manuelprz/anicursor'));
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Ver en GitHub'),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({
    required this.tooltip,
    required this.iconWidget,
    required this.onTap,
  });

  final String tooltip;
  final Widget iconWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.45);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: IconTheme(
            data: IconThemeData(color: iconColor, size: 20),
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}
