import 'package:flutter/material.dart';
import 'package:ani_to_xcursor/features/installed_themes/domain/models/installed_theme.dart';

class AnimatedThemeCard extends StatefulWidget {
  final InstalledTheme theme;
  final VoidCallback onApply;
  final VoidCallback onDelete;
  final bool isDeleting;
  final bool isApplying;

  const AnimatedThemeCard({
    super.key,
    required this.theme,
    required this.onApply,
    required this.onDelete,
    this.isDeleting = false,
    this.isApplying = false,
  });

  @override
  State<AnimatedThemeCard> createState() => _AnimatedThemeCardState();
}

class _AnimatedThemeCardState extends State<AnimatedThemeCard>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;

    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _hovering
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _hovering
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                if (_hovering)
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview Area (Simplified and Purer)
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _hovering 
                                ? colorScheme.primary.withValues(alpha: 0.1) 
                                : colorScheme.onSurface.withValues(alpha: 0.03),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mouse_outlined,
                            size: 40,
                            color: _hovering
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      if (widget.theme.isSystem)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                        ),
                    ],
                  ),
                ),
                // Info & Actions Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.theme.displayName ?? widget.theme.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: themeData.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.theme.cursorCount} cursores',
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: widget.isApplying
                                ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                                : FilledButton(
                                    onPressed: widget.onApply,
                                    style: FilledButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                      foregroundColor: colorScheme.primary,
                                      elevation: 0,
                                    ),
                                    child: const Text('Aplicar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                          ),
                          if (!widget.theme.isSystem) ...[
                            const SizedBox(width: 8),
                            widget.isDeleting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: widget.onDelete,
                                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                      color: Colors.red.shade400,
                                      tooltip: 'Eliminar tema',
                                    ),
                                  ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
