import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:ani_to_xcursor/features/converter/presentation/converter_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
            Icon(
              Icons.mouse,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'ANI to XCursor',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Convierte cursores de Windows a Linux',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 48),

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
                  : Colors.white24,
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
                    : Colors.white38,
              ),
              const SizedBox(height: 12),
              Text(
                'Arrastra la carpeta aquí',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _hovering
                      ? theme.colorScheme.primary
                      : Colors.white54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'o haz clic para seleccionar',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}