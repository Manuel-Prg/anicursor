import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ani_to_xcursor/features/converter/presentation/converter_provider.dart';
import 'package:ani_to_xcursor/shared/providers/dependency_provider.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/features/home/presentation/widgets/onboarding_dialog.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final deps = ref.watch(dependencyProvider);
    final settings = ref.watch(settingsProvider);

    // Si es la primera vez, mostramos onboarding después del primer frame
    if (settings.showedOnboarding != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) OnboardingDialog.show(context);
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
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo e info
                  Hero(
                    tag: 'logo',
                    child: SvgPicture.asset(
                      isLight
                          ? 'assets/ani_xcursor_logo_light.svg'
                          : 'assets/ani_xcursor_logo_v3.svg',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AniCursor',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Convierte cursores de Windows a Linux',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 48),

                  if (deps.status == DependencyStatus.checking)
                    const CircularProgressIndicator()
                  else if (deps.status == DependencyStatus.missing)
                    _DependencyMissingCard(deps: deps)
                  else ...[
                    _DropZone(
                      onFilesDropped: (paths) {
                        ref.read(cursorThemeProvider.notifier).scanDirectory(paths.first);
                        context.push('/converter');
                      },
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.getDirectoryPath();
                        if (result != null) {
                          ref.read(cursorThemeProvider.notifier).scanDirectory(result);
                          if (context.mounted) context.push('/converter');
                        }
                      },
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Seleccionar carpeta'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 64),
                ],
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
    final theme = Theme.of(context);
    return Container(
      width: 450,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 56),
          const SizedBox(height: 16),
          Text(
            'Dependencias Faltantes',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Para que la magia funcione en Linux, necesitamos ImageMagick y Xcursorgen.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red[200]),
          ),
          const SizedBox(height: 24),
          if (deps.isInstalling)
            const CircularProgressIndicator(color: Colors.red)
          else
            Consumer(builder: (context, ref, _) {
              return FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await ref.read(dependencyProvider.notifier).installDependencies();
                },
                icon: const Icon(Icons.download),
                label: const Text('Instalar automáticamente (Apt)'),
              );
            }),
        ],
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
      onDragDone: (detail) => widget.onFilesDropped(detail.files.map((f) => f.path).toList()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: 500,
        height: 250,
        transform: Matrix4.identity()..scale(_hovering ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: _hovering
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _hovering
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 2.5,
          ),
          boxShadow: [
            if (_hovering)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: -5,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _hovering 
                    ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                    : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.move_to_inbox_rounded,
                size: 64,
                color: _hovering ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Suelta la carpeta aquí',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _hovering ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'o haz clic para seleccionar manualmente',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
