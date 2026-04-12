import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

const List<Color> _availableColors = [
  Color(0xFFE91E8C), // Pink
  Color(0xFF3F51B5), // Indigo
  Color(0xFF4CAF50), // Green
  Color(0xFFFF9800), // Orange
  Color(0xFF9C27B0), // Purple
  Color(0xFF00BCD4), // Cyan
];

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Sección Conversión
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
                  title: const Text('Tamaños de Cursor'),
                  subtitle: Text(settings.cursorSizes.join('px, ') + 'px'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSizesDialog(context, settings, notifier),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Delay por defecto (ms)'),
                  subtitle: Text(
                      'Usado cuando el archivo orginal no provee retardos: ${settings.defaultDelay}ms'),
                  trailing: SizedBox(
                    width: 200,
                    child: Slider(
                      value: settings.defaultDelay.toDouble(),
                      min: 10,
                      max: 500,
                      divisions: 49,
                      label: settings.defaultDelay.toString(),
                      onChanged: (val) => notifier.updateDefaultDelay(val.toInt()),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Directorio de Salida Perso.'),
                  subtitle: Text(settings.customOutputDir ?? 'Automático (junto a la carpeta de entrada)'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (settings.customOutputDir != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => notifier.updateCustomOutputDir(null),
                        ),
                      IconButton(
                        icon: const Icon(Icons.folder_open),
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
          const SizedBox(height: 32),

          // Sección Instalación
          Text(
            'Instalación',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Instalar globalmente'),
                  subtitle: const Text('Requiere pkexec/root (/usr/share/icons)'),
                  value: settings.systemInstall,
                  onChanged: notifier.updateSystemInstall,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-Aplicar Cursor'),
                  subtitle: const Text('Forzar inmediatamente vía gsettings x-cursor'),
                  value: settings.autoApplyCursor,
                  onChanged: notifier.updateAutoApply,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sección Apariencia
          Text(
            'Apariencia',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Modo de pantalla'),
                    trailing: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                            value: ThemeMode.system, icon: Icon(Icons.computer)),
                        ButtonSegment(
                            value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                        ButtonSegment(
                            value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (Set<ThemeMode> selection) {
                        notifier.updateThemeMode(selection.first);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Color Primario'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _availableColors.map((color) {
                        final isSelected = settings.primaryColor.value == color.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => notifier.updatePrimaryColor(color),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSizesDialog(
      BuildContext context, Settings settings, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        return _SizesDialog(
          initialSizes: List.from(settings.cursorSizes),
          onSaved: notifier.updateSizes,
        );
      },
    );
  }
}

class _SizesDialog extends StatefulWidget {
  final List<int> initialSizes;
  final ValueChanged<List<int>> onSaved;

  const _SizesDialog({required this.initialSizes, required this.onSaved});

  @override
  State<_SizesDialog> createState() => _SizesDialogState();
}

class _SizesDialogState extends State<_SizesDialog> {
  late List<int> _sizes;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sizes = widget.initialSizes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar Tamaños'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            children: _sizes.map((s) {
              return Chip(
                label: Text('${s}px'),
                onDeleted: () {
                  if (_sizes.length > 1) {
                    setState(() => _sizes.remove(s));
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Añadir tamaño',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final val = int.tryParse(_controller.text);
                  if (val != null && val > 0 && !_sizes.contains(val)) {
                    setState(() => _sizes.add(val));
                    _sizes.sort();
                    _controller.clear();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSaved(_sizes);
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        )
      ],
    );
  }
}
