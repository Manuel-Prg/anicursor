import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/shared/services/logger_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class MaintenanceSection extends ConsumerWidget {
  const MaintenanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mantenimiento y Diagnóstico',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Utilice estas herramientas si experimenta problemas con la conversión o aplicación de temas.',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.white.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Registros de la aplicación (Logs)',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            'Contiene información técnica sobre el proceso de conversión.',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final path = await LoggerService.getLogPath();
                        final file = File(path);
                        if (await file.exists()) {
                          final content = await file.readAsString();
                          if (context.mounted) {
                            _showLogsDialog(context, content);
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No hay registros disponibles aún.')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Ver Logs'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _exportLogs(context),
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: const Text('Exportar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.privacy_tip_outlined, size: 20, color: Colors.blue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Privacidad: Los logs incluyen rutas de archivos locales. No se comparten automáticamente; usted decide si enviarlos para reportar un bug.',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportLogs(BuildContext context) async {
    final logPath = await LoggerService.getLogPath();
    final file = File(logPath);
    
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay logs para exportar.')),
        );
      }
      return;
    }

    // FilePicker.saveFile es el método estático disponible según el uso en el resto del proyecto
    final result = await FilePicker.saveFile(
      dialogTitle: 'Exportar logs de la aplicación',
      fileName: 'anicursor_app.log',
      type: FileType.any,
    );

    if (result != null) {
      await file.copy(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logs exportados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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
            child: const Text('Limpiar logs', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
