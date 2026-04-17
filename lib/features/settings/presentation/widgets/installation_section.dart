import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

class InstallationSection extends ConsumerWidget {
  const InstallationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                subtitle: const Text(
                  'Forzar inmediatamente vía gsettings x-cursor',
                ),
                value: settings.autoApplyCursor,
                onChanged: notifier.updateAutoApply,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
