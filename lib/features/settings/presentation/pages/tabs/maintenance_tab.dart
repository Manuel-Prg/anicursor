import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ani_to_xcursor/shared/services/logger_service.dart';
import 'package:ani_to_xcursor/shared/utils/snackbar_utils.dart';
import '../../widgets/settings_shared_widgets.dart';

class MaintenanceTab extends StatelessWidget {
  const MaintenanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Columna izquierda ─ Logs ─────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  icon: Icons.description_outlined,
                  label: 'Registros del Sistema',
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 8),
                Text(
                  'Información técnica sobre el proceso de conversión.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FlatOutlineButton(
                      icon: Icons.visibility_outlined,
                      label: 'Ver Logs',
                      onPressed: () async {
                        final path = await LoggerService.getLogPath();
                        final file = File(path);
                        if (await file.exists()) {
                          final content = await file.readAsString();
                          if (context.mounted) {
                            _showLogsDialog(context, content);
                          }
                        } else if (context.mounted) {
                          SnackBarUtils.show(
                            context,
                            'No hay registros disponibles aún.',
                          );
                        }
                      },
                    ),
                    FlatFilledButton(
                      icon: Icons.ios_share_outlined,
                      label: 'Exportar',
                      onPressed: () => _exportLogs(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Privacy note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.privacy_tip_outlined,
                        size: 15,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Los logs incluyen rutas de archivos locales. No se comparten '
                          'automáticamente; usted decide si enviarlos para reportar un bug.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade300,
                            fontSize: 11.5,
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

          // ─── Columna derecha ─ (reservada) ───────────────────────────────
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Future<void> _exportLogs(BuildContext context) async {
    final logPath = await LoggerService.getLogPath();
    final file = File(logPath);

    if (!await file.exists()) {
      if (context.mounted) {
        SnackBarUtils.show(context, 'No hay logs para exportar.');
      }
      return;
    }

    final result = await FilePicker.saveFile(
      dialogTitle: 'Exportar logs de la aplicación',
      fileName: 'anicursor_app.log',
      type: FileType.any,
    );

    if (result != null) {
      await file.copy(result);
      if (context.mounted) {
        _showExportedDialog(context, result);
      }
    }
  }

  void _showExportedDialog(BuildContext context, String savedPath) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Text('Logs exportados'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El archivo fue guardado en:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                savedPath,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: Colors.blueAccent, size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para reportar un bug, adjunta este archivo en el issue de GitHub o compártelo por correo. Puedes abrirlo con cualquier editor de texto.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade300,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              // Abrir la carpeta que contiene el archivo exportado
              final dir = File(savedPath).parent.path;
              await Process.run('xdg-open', [dir]);
            },
            icon: const Icon(Icons.folder_open_outlined, size: 15),
            label: const Text('Abrir carpeta'),
          ),
        ],
      ),
    );
  }

  void _showLogsDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registros del Sistema'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              content.isEmpty ? 'El archivo de logs está vacío.' : content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () async {
              await LoggerService.clearLogs();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              'Limpiar logs',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
