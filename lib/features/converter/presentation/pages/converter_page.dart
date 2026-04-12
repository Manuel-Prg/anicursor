import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_theme.dart';
import 'package:ani_to_xcursor/features/converter/presentation/converter_provider.dart';

class ConverterPage extends ConsumerWidget {
  const ConverterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cursorTheme = ref.watch(cursorThemeProvider);

    if (cursorTheme == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(cursorThemeProvider.notifier).reset();
            context.go('/');
          },
        ),
        title: const Text('Convertir tema'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del tema
            _ThemeNameField(cursorTheme: cursorTheme),
            const SizedBox(height: 24),

            // Info del directorio
            Text(
              'Directorio: ${cursorTheme.inputDir}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
            ),
            const SizedBox(height: 24),

            // Progress bar
            if (cursorTheme.status == ThemeStatus.converting) ...[
              LinearProgressIndicator(
                value: cursorTheme.progress / 100,
                backgroundColor: Colors.white12,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                '${cursorTheme.progress}% — ${cursorTheme.done}/${cursorTheme.total} cursores',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Lista de cursores
            Expanded(child: _CursorList(cursors: cursorTheme.cursors)),

            const SizedBox(height: 24),

            // Botones
            _ActionButtons(cursorTheme: cursorTheme),
          ],
        ),
      ),
    );
  }
}

class _ThemeNameField extends ConsumerStatefulWidget {
  final CursorTheme cursorTheme;

  const _ThemeNameField({required this.cursorTheme});

  @override
  ConsumerState<_ThemeNameField> createState() => _ThemeNameFieldState();
}

class _ThemeNameFieldState extends ConsumerState<_ThemeNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.cursorTheme.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Nombre del tema',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.palette),
      ),
      onChanged: (value) {
        ref.read(cursorThemeProvider.notifier).updateThemeName(value);
      },
    );
  }
}

class _CursorList extends StatelessWidget {
  final List<CursorFile> cursors;

  const _CursorList({required this.cursors});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: cursors.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cursor = cursors[index];
        return _CursorTile(cursor: cursor);
      },
    );
  }
}

class _CursorTile extends StatelessWidget {
  final CursorFile cursor;

  const _CursorTile({required this.cursor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: _StatusIcon(status: cursor.status),
        title: Text(cursor.windowsName),
        subtitle: Text(
          cursor.linuxName,
          style: TextStyle(color: theme.colorScheme.primary),
        ),
        trailing: cursor.aliases.isNotEmpty
            ? Tooltip(
                message: 'Aliases: ${cursor.aliases.join(', ')}',
                child: const Icon(Icons.link, color: Colors.white38),
              )
            : null,
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final ConversionStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ConversionStatus.pending => const Icon(
        Icons.hourglass_empty,
        color: Colors.white38,
      ),
      ConversionStatus.converting => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      ConversionStatus.done => const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
      ConversionStatus.error => const Icon(Icons.error, color: Colors.red),
    };
  }
}

class _ActionButtons extends ConsumerWidget {
  final CursorTheme cursorTheme;

  const _ActionButtons({required this.cursorTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConverting = cursorTheme.status == ThemeStatus.converting;
    final isFinished =
        cursorTheme.status == ThemeStatus.done ||
        cursorTheme.status == ThemeStatus.error;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFinished) ...[
          OutlinedButton.icon(
            onPressed: () => context.push('/preview'),
            icon: const Icon(Icons.preview),
            label: const Text('Vista previa'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(cursorThemeProvider.notifier).exportZip();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.folder_zip_outlined, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Exportado en archivo ZIP correctamente'),
                      ],
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.archive),
            label: const Text('Exportar ZIP'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(cursorThemeProvider.notifier).install();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Tema instalado en el sistema'),
                      ],
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.download),
            label: const Text('Instalar tema'),
          ),
        ] else
          FilledButton.icon(
            onPressed: isConverting
                ? null
                : () => ref.read(cursorThemeProvider.notifier).convert(),
            icon: isConverting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(isConverting ? 'Convirtiendo...' : 'Convertir'),
          ),
      ],
    );
  }
}
