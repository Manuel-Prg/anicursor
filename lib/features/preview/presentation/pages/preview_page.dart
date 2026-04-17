import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_theme.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/features/converter/presentation/converter_provider.dart';

class PreviewPage extends ConsumerWidget {
  const PreviewPage({super.key});

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

    final doneCursors = cursorTheme.cursors
        .where((c) => c.status == ConversionStatus.done)
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vista Previa',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              cursorTheme.name,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
            ),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => _handleInstall(context, ref),
            icon: const Icon(Icons.system_update_alt_outlined),
            label: const Text('Instalar Tema'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          _StatsSection(cursorTheme: cursorTheme),

          const Divider(height: 1, color: Colors.white10),

          // Main Content
          Expanded(
            child: doneCursors.isEmpty
                ? _NoPreviewResult()
                : _PreviewGrid(cursors: doneCursors),
          ),
        ],
      ),
    );
  }

  Future<void> _handleInstall(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(cursorThemeProvider.notifier);
    final success = await notifier.install();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Tema instalado con éxito' : 'Error al instalar el tema',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}

class _StatsSection extends StatelessWidget {
  final CursorTheme cursorTheme;

  const _StatsSection({required this.cursorTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          _StatBadge(
            label: 'Total',
            value: '${cursorTheme.total}',
            color: Colors.blueGrey,
            icon: Icons.list_alt,
          ),
          const SizedBox(width: 12),
          _StatBadge(
            label: 'Visibles',
            value: '${cursorTheme.done}',
            color: Colors.green,
            icon: Icons.remove_red_eye_outlined,
          ),
          if (cursorTheme.errors > 0) ...[
            const SizedBox(width: 12),
            _StatBadge(
              label: 'Errores',
              value: '${cursorTheme.errors}',
              color: Colors.red,
              icon: Icons.error_outline,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBadge({
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

class _PreviewGrid extends StatelessWidget {
  final List<CursorFile> cursors;

  const _PreviewGrid({required this.cursors});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 100,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cursors.length,
      itemBuilder: (context, index) => _PreviewCard(cursor: cursors[index]),
    );
  }
}

class _PreviewCard extends StatefulWidget {
  final CursorFile cursor;

  const _PreviewCard({required this.cursor});

  @override
  State<_PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<_PreviewCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

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
                ? accentColor
                : Colors.white.withValues(alpha: 0.05),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Animation Preview Circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: _AnimatedCursor(cursor: widget.cursor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.cursor.linuxName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.cursor.windowsName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white38,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCursor extends StatefulWidget {
  final CursorFile cursor;
  const _AnimatedCursor({required this.cursor});

  @override
  State<_AnimatedCursor> createState() => _AnimatedCursorState();
}

class _AnimatedCursorState extends State<_AnimatedCursor> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    if (widget.cursor.framesData.length <= 1) return;
    _scheduleNextFrame();
  }

  void _scheduleNextFrame() {
    int delay = widget.cursor.framesData[_currentIndex].delay;
    if (delay <= 0) delay = 100;

    _timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.cursor.framesData.length;
      });
      _scheduleNextFrame();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cursor.framesData.isEmpty) {
      return const Icon(Icons.mouse, color: Colors.white24);
    }

    final currentFrame = widget.cursor.framesData[_currentIndex];
    return Image.file(
      File(currentFrame.imagePath),
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 16),
    );
  }
}

class _NoPreviewResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_off_outlined, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          const Text(
            'No hay cursores para previsualizar',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
