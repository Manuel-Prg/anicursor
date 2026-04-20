import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'color_picker_row.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  dense: true,
                  title: const Text('Modo de pantalla'),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.computer, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode, size: 18),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (Set<ThemeMode> selection) {
                      notifier.updateThemeMode(selection.first);
                    },
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  dense: true,
                  title: Text('Color Primario'),
                  trailing: ColorPickerRow(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
