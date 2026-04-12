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

    final doneCursors =
        cursorTheme.cursors.where((c) => c.status == ConversionStatus.done).toList();
    final errorCursors =
        cursorTheme.cursors.where((c) => c.status == ConversionStatus.error).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(cursorTheme.name),
        actions: [
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
            label: const Text('Instalar'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats
            _StatsRow(cursorTheme: cursorTheme),
            const SizedBox(height: 24),

            // Cursores convertidos
            Text(
              'Cursores convertidos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2,
                ),
                itemCount: doneCursors.length,
                itemBuilder: (context, index) {
                  return _CursorCard(cursor: doneCursors[index]);
                },
              ),
            ),

            // Errores
            if (errorCursors.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Con errores (${errorCursors.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: errorCursors
                    .map((c) => Chip(
                          label: Text(c.windowsName),
                          backgroundColor: Colors.red.withOpacity(0.1),
                          side: const BorderSide(color: Colors.red),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final CursorTheme cursorTheme;

  const _StatsRow({required this.cursorTheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          label: 'Total',
          value: '${cursorTheme.total}',
          color: Colors.white54,
        ),
        const SizedBox(width: 12),
        _StatChip(
          label: 'Convertidos',
          value: '${cursorTheme.done}',
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _StatChip(
          label: 'Errores',
          value: '${cursorTheme.errors}',
          color: Colors.red,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class _CursorCard extends StatelessWidget {
  final CursorFile cursor;

  const _CursorCard({required this.cursor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _AnimatedCursorPreview(cursor: cursor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cursor.linuxName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cursor.aliases.isNotEmpty)
                    Text(
                      '+${cursor.aliases.length} aliases',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCursorPreview extends StatefulWidget {
  final CursorFile cursor;

  const _AnimatedCursorPreview({required this.cursor});

  @override
  State<_AnimatedCursorPreview> createState() => _AnimatedCursorPreviewState();
}

class _AnimatedCursorPreviewState extends State<_AnimatedCursorPreview> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    if (widget.cursor.framesData.isEmpty || widget.cursor.framesData.length == 1) return;
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
      return const Icon(Icons.mouse, color: Colors.white38, size: 32);
    }
    
    final currentFrame = widget.cursor.framesData[_currentIndex];
    return Image.file(
      File(currentFrame.imagePath),
      width: 32,
      height: 32,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red, size: 32),
    );
  }
}