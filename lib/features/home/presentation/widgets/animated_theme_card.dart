import 'dart:io';
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
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _hovering
                    ? [
                        colorScheme.surfaceContainerHigh,
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                      ]
                    : [
                        colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
                        colorScheme.surfaceContainerLow.withValues(alpha: 0.4),
                      ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _hovering
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                width: 1.5,
              ),
              boxShadow: [
                if (_hovering)
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: _hovering
                                ? colorScheme.primary.withValues(alpha: 0.18)
                                : colorScheme.onSurface.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _hovering
                                  ? colorScheme.primary.withValues(alpha: 0.4)
                                  : colorScheme.onSurface.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 300),
                              scale: _hovering ? 1.15 : 1.0,
                              curve: Curves.easeOutBack,
                              child: widget.theme.previewPath != null
                                  ? Image.file(
                                      File(widget.theme.previewPath!),
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.medium,
                                      errorBuilder: (context, _, __) => Icon(
                                        Icons.mouse_outlined,
                                        size: 32,
                                        color: _hovering
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.4),
                                      ),
                                    )
                                  : Icon(
                                      Icons.mouse_outlined,
                                      size: 32,
                                      color: _hovering
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.4),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.theme.isSystem)
                        Positioned(
                          top: 18,
                          right: 18,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Info & Actions Area
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.03),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
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
                          letterSpacing: -0.2,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.theme.cursorCount} cursores',
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: widget.isApplying
                                ? Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  )
                                : FilledButton(
                                    onPressed: widget.onApply,
                                    style: FilledButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      backgroundColor: _hovering
                                          ? colorScheme.primary
                                          : colorScheme.primary
                                              .withValues(alpha: 0.1),
                                      foregroundColor: _hovering
                                          ? colorScheme.onPrimary
                                          : colorScheme.primary,
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Aplicar',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                          ),
                          if (!widget.theme.isSystem) ...[
                            const SizedBox(width: 8),
                            widget.isDeleting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red,
                                    ),
                                  )
                                : IconButton.filledTonal(
                                    onPressed: widget.onDelete,
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          Colors.red.withValues(alpha: 0.1),
                                      foregroundColor: Colors.red.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    tooltip: 'Eliminar tema',
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
