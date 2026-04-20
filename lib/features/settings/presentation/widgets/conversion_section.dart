import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'sizes_dialog.dart';

class ConversionSection extends ConsumerWidget {
  const ConversionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversión',
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
                dense: true,
                title: const Text('Tamaños de Cursor'),
                subtitle: Text('${settings.cursorSizes.join('px, ')}px'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SizesDialog(
                        initialSizes: List.from(settings.cursorSizes),
                        onSaved: notifier.updateSizes,
                      );
                    },
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                title: const Text('Delay por defecto (ms)'),
                subtitle: Text(
                  'Usado si no hay retardos: ${settings.defaultDelay}ms',
                ),
                trailing: SizedBox(
                  width: 140,
                  child: Slider(
                    value: settings.defaultDelay.toDouble(),
                    min: 10,
                    max: 500,
                    divisions: 49,
                    label: settings.defaultDelay.toString(),
                    onChanged: (val) =>
                        notifier.updateDefaultDelay(val.toInt()),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                title: const Text('Directorio de Salida'),
                subtitle: Text(
                  settings.customOutputDir != null 
                    ? p.basename(settings.customOutputDir!)
                    : 'Carpeta de entrada (automático)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (settings.customOutputDir != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => notifier.updateCustomOutputDir(null),
                      ),
                    IconButton(
                      icon: const Icon(Icons.folder_open, size: 20),
                      onPressed: () async {
                        final dir = await FilePicker.getDirectoryPath();
                        if (dir != null) {
                          notifier.updateCustomOutputDir(dir);
                        }
                      },
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
