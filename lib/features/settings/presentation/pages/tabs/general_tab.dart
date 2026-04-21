import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import '../../widgets/color_picker_row.dart';
import '../../widgets/sizes_dialog.dart';
import '../../widgets/settings_shared_widgets.dart';

class GeneralTab extends ConsumerWidget {
  const GeneralTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).current;
    final notifier = ref.read(settingsProvider.notifier);

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Columna izquierda ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Directorio de salida
                SettingsField(
                  label: 'Directorio de Salida',
                  child: Row(
                    children: [
                      Expanded(
                        child: FlatTextField(
                          value: settings.customOutputDir != null
                              ? p.basename(settings.customOutputDir!)
                              : 'Carpeta de entrada (automático)',
                        ),
                      ),
                      const SizedBox(width: 8),
                      FlatIconButton(
                        icon: Icons.folder_open_outlined,
                        label: 'Explorar',
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
                const SizedBox(height: 20),

                // Modo de pantalla
                SettingsField(
                  label: 'Modo de Pantalla',
                  child: FlatSegmentedRow<ThemeMode>(
                    value: settings.themeMode,
                    items: const [
                      (
                        value: ThemeMode.system,
                        icon: Icons.computer,
                        label: 'Sistema'
                      ),
                      (
                        value: ThemeMode.light,
                        icon: Icons.light_mode_outlined,
                        label: 'Claro'
                      ),
                      (
                        value: ThemeMode.dark,
                        icon: Icons.dark_mode_outlined,
                        label: 'Oscuro'
                      ),
                    ],
                    onChanged: notifier.updateThemeMode,
                  ),
                ),
                const SizedBox(height: 20),

                // Color primario
                SettingsField(
                  label: 'Color Primario',
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: ColorPickerRow(),
                  ),
                ),
                const SizedBox(height: 20),

                // Delay por defecto
                SettingsField(
                  label: 'Delay por defecto (ms)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${settings.defaultDelay} ms',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Slider(
                        value: settings.defaultDelay.toDouble(),
                        min: 10,
                        max: 500,
                        divisions: 49,
                        label: '${settings.defaultDelay}ms',
                        onChanged: (val) =>
                            notifier.updateDefaultDelay(val.toInt()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),

          // ─── Columna derecha ────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tamaños de cursor
                SettingsField(
                  label: 'Tamaños de Cursor',
                  child: Row(
                    children: [
                      Expanded(
                        child: FlatTextField(
                          value: settings.cursorSizes
                              .map((s) => '${s}px')
                              .join(', '),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FlatIconButton(
                        icon: Icons.tune_outlined,
                        label: 'Editar',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => SizesDialog(
                              initialSizes: List.from(settings.cursorSizes),
                              onSaved: notifier.updateSizes,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Instalar globalmente
                SettingsField(
                  label: 'Instalar Globalmente',
                  child: FlatSwitch(
                    value: settings.systemInstall,
                    label: 'Requiere pkexec/root (/usr/share/icons)',
                    onChanged: notifier.updateSystemInstall,
                  ),
                ),
                const SizedBox(height: 20),

                // Auto-Aplicar cursor
                SettingsField(
                  label: 'Auto-Aplicar Cursor',
                  child: FlatSwitch(
                    value: settings.autoApplyCursor,
                    label: 'Forzar inmediatamente vía gsettings',
                    onChanged: notifier.updateAutoApply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
