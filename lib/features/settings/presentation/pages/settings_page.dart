import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/shared/utils/snackbar_utils.dart';
import 'tabs/general_tab.dart';
import 'tabs/advanced_tab.dart';
import 'tabs/maintenance_tab.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Button actions ───────────────────────────────────────────────────────

  Future<void> _openConfigFolder() async {
    final notifier = ref.read(settingsProvider.notifier);
    try {
      await notifier.openConfigFolder();
    } catch (_) {
      if (mounted) {
        SnackBarUtils.show(
          context,
          'No se pudo abrir la carpeta de configuración.',
          isError: true,
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar valores por defecto'),
        content: const Text(
          '¿Estás seguro? Se perderán todos los ajustes personalizados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(settingsProvider.notifier).resetToDefaults();
      if (mounted) {
        SnackBarUtils.show(
          context,
          'Configuración restaurada a valores por defecto.',
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    await ref.read(settingsProvider.notifier).saveSettings();
    if (mounted) {
      SnackBarUtils.show(context, 'Configuración guardada correctamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasChanges = ref.watch(
      settingsProvider.select((s) => s.hasUnsavedChanges),
    );

    return PopScope(
      // Advertir si hay cambios pendientes al salir
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cambios sin guardar'),
            content: const Text(
              'Tienes cambios sin guardar. ¿Salir de todas formas?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Continuar editando'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Salir sin guardar'),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          ref.read(settingsProvider.notifier).discardChanges();
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header Row ─────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Configuración',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  // Badge de cambios pendientes
                  if (hasChanges) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'Sin guardar',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // ─── Abrir Carpeta ─────────────────────────────────────
                  _ActionButton(
                    icon: Icons.folder_open_outlined,
                    label: 'Abrir Carpeta',
                    onPressed: _openConfigFolder,
                  ),
                  const SizedBox(width: 8),
                  // ─── Restaurar ─────────────────────────────────────────
                  _ActionButton(
                    icon: Icons.refresh_outlined,
                    label: 'Restaurar',
                    onPressed: _resetToDefaults,
                  ),
                  const SizedBox(width: 8),
                  // ─── Guardar ───────────────────────────────────────────
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hasChanges ? 1.0 : 0.5,
                    child: FilledButton.icon(
                      onPressed: hasChanges ? _saveSettings : null,
                      icon: const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Guardar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        disabledBackgroundColor: colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                        disabledForegroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Tabs ───────────────────────────────────────────────────
              _PillTabBar(controller: _tabController),
              const SizedBox(height: 28),

              // ─── Tab Content ────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    GeneralTab(),
                    AdvancedTab(),
                    MaintenanceTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pill-style Tab Bar ───────────────────────────────────────────────────────

class _PillTabBar extends StatelessWidget {
  const _PillTabBar({required this.controller});

  final TabController controller;

  static const _tabs = [
    (icon: Icons.tune_outlined, label: 'General'),
    (icon: Icons.settings_outlined, label: 'Avanzado'),
    (icon: Icons.build_outlined, label: 'Mantenimiento'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_tabs.length, (i) {
            final isSelected = controller.index == i;
            final tab = _tabs[i];
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _PillTab(
                icon: tab.icon,
                label: tab.label,
                isSelected: isSelected,
                selectedColor: colorScheme.primary,
                onTap: () => controller.animateTo(i),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.15)
              : surface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.5)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? selectedColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? selectedColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Outline action button ────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.75),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
