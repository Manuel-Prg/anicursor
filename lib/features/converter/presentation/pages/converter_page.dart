import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_theme.dart';
import 'package:ani_to_xcursor/features/converter/presentation/converter_provider.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/shared/utils/snackbar_utils.dart';

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
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(cursorThemeProvider.notifier).reset();
            context.go('/');
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cursorTheme.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'En progreso: ${cursorTheme.inputDir}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          _ActionButtons(cursorTheme: cursorTheme),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Header / Summary Section
          _HeaderSection(cursorTheme: cursorTheme),

          const Divider(height: 1, color: Colors.white10),

          // Grid of Cursors
          Expanded(child: _CursorGrid(cursors: cursorTheme.cursors)),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final CursorTheme cursorTheme;

  const _HeaderSection({required this.cursorTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConverting = cursorTheme.status == ThemeStatus.converting;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: Column(
        children: [
          Row(
            children: [
              _StatusBadge(
                label: 'Total',
                value: '${cursorTheme.total}',
                color: Colors.blueGrey,
                icon: Icons.list_alt,
              ),
              const SizedBox(width: 12),
              _StatusBadge(
                label: 'Listos',
                value: '${cursorTheme.done}',
                color: Colors.green,
                icon: Icons.check_circle_outlined,
              ),
              const SizedBox(width: 12),
              _StatusBadge(
                label: 'Errores',
                value:
                    '${cursorTheme.cursors.where((c) => c.status == ConversionStatus.error).length}',
                color: Colors.red,
                icon: Icons.error_outline,
              ),
            ],
          ),
          if (isConverting || cursorTheme.status == ThemeStatus.done) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cursorTheme.statusMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(cursorTheme.overallProgress * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: cursorTheme.overallProgress,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CursorGrid extends StatelessWidget {
  final List<CursorFile> cursors;

  const _CursorGrid({required this.cursors});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 130,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cursors.length,
      itemBuilder: (context, index) {
        final cursor = cursors[index];
        return _CursorCard(cursor: cursor);
      },
    );
  }
}

class _CursorCard extends StatefulWidget {
  final CursorFile cursor;

  const _CursorCard({required this.cursor});

  @override
  State<_CursorCard> createState() => _CursorCardState();
}

class _CursorCardState extends State<_CursorCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(widget.cursor.status);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: _isHovered ? 0.4 : 0.2,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? statusColor
                : Colors.white.withValues(alpha: 0.05),
            width: 1.5,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: statusColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Preview section
            _CursorPreview(cursor: widget.cursor, size: 40),
            const SizedBox(width: 16),
            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.cursor.linuxName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 12, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        '+${widget.cursor.aliases.length} aliases',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status Indicator
            _StatusIndicator(status: widget.cursor.status, size: 14),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ConversionStatus status) {
    return switch (status) {
      ConversionStatus.pending => Colors.white38,
      ConversionStatus.converting => Colors.blue,
      ConversionStatus.done => Colors.green,
      ConversionStatus.error => Colors.red,
    };
  }
}

class _CursorPreview extends StatelessWidget {
  final CursorFile cursor;
  final double size;

  const _CursorPreview({required this.cursor, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Prioridad: framesData[0] (ya convertido) > previewPath (pre-extracción)
    String? imagePath;
    if (cursor.framesData.isNotEmpty) {
      imagePath = cursor.framesData.first.imagePath;
    } else {
      imagePath = cursor.previewPath;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: imagePath != null
            ? Image.file(
                File(imagePath),
                width: size * 0.8,
                height: size * 0.8,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              )
            : Icon(
                Icons.mouse_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                size: size * 0.5,
              ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final ConversionStatus status;
  final double size;

  const _StatusIndicator({required this.status, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ConversionStatus.pending => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
        ),
      ),
      ConversionStatus.converting => SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      ConversionStatus.done => Icon(
        Icons.check_circle,
        color: Colors.green,
        size: size,
      ),
      ConversionStatus.error => Icon(
        Icons.error,
        color: Colors.red,
        size: size,
      ),
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

    if (!isFinished) {
      return FilledButton.icon(
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
      );
    }

    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () => context.push('/preview'),
          icon: const Icon(Icons.remove_red_eye_outlined),
          tooltip: 'Vista previa',
        ),
        const SizedBox(width: 8),
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: () =>
                  ref.read(cursorThemeProvider.notifier).exportZip(),
              leadingIcon: const Icon(Icons.folder_zip_outlined),
              child: const Text('Exportar como .zip'),
            ),
            MenuItemButton(
              onPressed: () =>
                  ref.read(cursorThemeProvider.notifier).exportTarGz(),
              leadingIcon: const Icon(Icons.compress),
              child: const Text('Exportar como .tar.gz'),
            ),
          ],
          builder: (context, controller, child) => IconButton.filledTonal(
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'Exportar temas',
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => _handleInstall(context, ref),
          icon: const Icon(Icons.system_update_alt_outlined),
          label: const Text('Instalar'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _handleInstall(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(cursorThemeProvider.notifier);
    final settings = ref.read(settingsProvider);
    final installationSource = ref.read(installationDataSourceProvider);

    bool exists = await installationSource.themeExists(
      notifier.state!.name,
      settings.systemInstall,
    );

    if (exists && context.mounted) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tema ya existe'),
          content: Text(
            'Ya hay un tema con el nombre "${notifier.state!.name}". ¿Deseas reemplazarlo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'replace'),
              child: const Text('Reemplazar'),
            ),
          ],
        ),
      );
      if (result != 'replace') return;
    }

    await notifier.install();
    if (context.mounted) {
      SnackBarUtils.show(context, 'Tema instalado correctamente');
    }
  }
}
