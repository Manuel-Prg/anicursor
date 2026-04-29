import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:ani_to_xcursor/shared/theme/design_system.dart';
import 'package:ani_to_xcursor/shared/theme/components.dart';

class DropZone extends StatefulWidget {
  final Function(List<String>) onFilesDropped;

  const DropZone({required this.onFilesDropped, super.key});

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _hovering = false;

  BoxDecoration _buildDecoration(ThemeData theme) {
    return BoxDecoration(
      color: _hovering
          ? DesignTokens.primaryColor.withValues(alpha: 0.08)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
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
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return AnimatedContainer(
      duration: AnimationTokens.normal,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: _hovering
            ? DesignTokens.primaryColor.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
          _hovering ? Icons.download_rounded : Icons.move_to_inbox_rounded,
          key: ValueKey(_hovering),
          size: 72,
          color: _hovering
              ? DesignTokens.primaryColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildText(ThemeData theme) {
    return AnimatedSwitcher(
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
    );
  }

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
        // ignore: deprecated_member_use
        transform: Matrix4.identity()
          // ignore: deprecated_member_use
          ..scale(_hovering ? 1.03 : 1.0, _hovering ? 1.03 : 1.0, 1.0),
        decoration: _buildDecoration(theme),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(theme),
            const SizedBox(height: SpacingTokens.lg),
            _buildText(theme),
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
