import 'dart:io';
import 'package:flutter/material.dart';

class SandboxedEnvironmentsSection extends StatelessWidget {
  const SandboxedEnvironmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entornos Aislados (Flatpak / Snap)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Evitar cursor fantasma en Flatpak'),
                subtitle: const Text(
                  'Otorga permiso de lectura a Flatpak para poder ver tus cursores personalizados.',
                ),
                trailing: FilledButton.tonal(
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 12),
                                Text('Permisos de Flatpak actualizados'),
                              ],
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 12),
                                Text('No se detectó Flatpak o hubo un error'),
                              ],
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Aplicar Parche'),
                ),
              ),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Nota de Snap: Las aplicaciones Snap no miran el directorio del usuario. Para aplicarlos, enciende "Instalar globalmente" en la sección superior para subirlos a /usr/share/icons.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
