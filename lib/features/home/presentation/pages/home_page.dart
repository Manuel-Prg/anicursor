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

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final deps = ref.watch(dependencyProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / título
            SvgPicture.asset(
              isLight ? 'assets/ani_xcursor_logo_light.svg' : 'assets/ani_xcursor_logo_v3.svg',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'AniCursor',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Convierte cursores de Windows a Linux',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.54),
              ),
            ),
            const SizedBox(height: 48),

            if (deps.status == DependencyStatus.checking)
              const CircularProgressIndicator()
            else if (deps.status == DependencyStatus.missing)
              Container(
                width: 400,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Dependencias Faltantes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Para que la magia funcione en Linux, necesitamos soporte de ImageMagick y Xcursorgen.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red[200]),
                    ),
                    const SizedBox(height: 16),
                    if (deps.isInstalling)
                      const CircularProgressIndicator()
                    else
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final success = await ref.read(dependencyProvider.notifier).installDependencies();
                          if (!success && context.mounted) {
                            showDialog(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Instalación Manual Requerida'),
                                content: const Text(
                                  'Tu sistema operativo bloqueó la instalación automática o no admite "apt-get".\n\n'
                                  'Por favor instala "imagemagick" y "xcursorgen" desde la terminal usando tu gestor de paquetes (pacman, dnf, zypper).',
                                ),
                                actions: [
                                  FilledButton(
                                    onPressed: () => Navigator.pop(c),
                                    child: const Text('Entendido'),
                                  )
                                ],
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Instalar (Apt)'),
                      ),
                  ],
                ),
              )
            else ...[
              // Drop zone
              _DropZone(
                onFolderSelected: (path) {
                  ref.read(cursorThemeProvider.notifier).scanDirectory(path);
                  context.push('/converter');
                },
              ),
              const SizedBox(height: 24),
              // Botón seleccionar carpeta
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
                ),
              ),
            ],

            const SizedBox(height: 48),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.github),
                  tooltip: 'GitHub',
                  onPressed: () => launchUrl(Uri.parse('https://github.com/Manuel-Prg')),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Acerca de',
                  onPressed: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'AniCursor',
                      applicationVersion: '1.0.0',
                      applicationIcon: SvgPicture.asset(
                        isLight ? 'assets/ani_xcursor_logo_light.svg' : 'assets/ani_xcursor_logo_v3.svg',
                        width: 48,
                        height: 48,
                      ),
                      children: const [
                        Text('Creado por manuelprz.\nUn conversor de temas de Windows (.ani) hacia cursores nativos XCursor para Linux.'),
                      ]
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.coffee),
                  tooltip: 'Apóyame en Ko-fi',
                  onPressed: () => launchUrl(Uri.parse('https://ko-fi.com/manuelprz0180')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Made with ♥ by manuelprz',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropZone extends StatefulWidget {
  final void Function(String path) onFolderSelected;

  const _DropZone({required this.onFolderSelected});

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropTarget(
      onDragDone: (detail) {
        // Obtenemos la primera ruta. Idealmente se verifica que sea directorio
        if (detail.files.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onFolderSelected(detail.files.first.path);
          });
        }
      },
      onDragEntered: (detail) => setState(() => _hovering = true),
      onDragExited: (detail) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () async {
          final result = await FilePicker.getDirectoryPath();
          if (result != null) widget.onFolderSelected(result);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 400,
          height: 200,
          decoration: BoxDecoration(
            color: _hovering
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovering
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.15),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file,
                size: 48,
                color: _hovering
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.38),
              ),
              const SizedBox(height: 12),
              Text(
                'Arrastra la carpeta aquí',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _hovering
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.54),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'o haz clic para seleccionar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}