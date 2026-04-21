import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ani_to_xcursor/shared/utils/snackbar_utils.dart';
import '../../widgets/settings_shared_widgets.dart';

class AdvancedTab extends StatelessWidget {
  const AdvancedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Columna izquierda ─ Entornos aislados ───────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(label: 'Entornos Aislados'),
                const SizedBox(height: 16),
                SettingsField(
                  label: 'Flatpak',
                  child: Row(
                    children: [
                      Expanded(
                        child: FlatTextField(
                          value: 'Otorga permiso de lectura a Flatpak',
                        ),
                      ),
                      const SizedBox(width: 8),
                      FlatIconButton(
                        icon: Icons.security_outlined,
                        label: 'Aplicar Parche',
                        onPressed: () async {
                          try {
                            final home = Platform.environment['HOME']!;
                            final iconsPath = '$home/.local/share/icons';
                            await Process.run('flatpak', [
                              'override',
                              '--user',
                              '--filesystem=$iconsPath:ro',
                            ]);
                            if (context.mounted) {
                              SnackBarUtils.show(
                                context,
                                'Permisos de Flatpak actualizados',
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              SnackBarUtils.show(
                                context,
                                'No se detectó Flatpak o hubo un error',
                                isError: true,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Snap note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Nota Snap: Las apps Snap no leen el directorio del usuario. '
                          'Activa "Instalar Globalmente" en General para subirlos a /usr/share/icons.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade300,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),

          // ─── Columna derecha ─ (reservada para futuros ajustes) ──────────
          const Expanded(
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        fontSize: 11,
      ),
    );
  }
}
