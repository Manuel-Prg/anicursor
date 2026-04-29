import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'about_row.dart';

void showAboutDialog(BuildContext context) {
  final theme = Theme.of(context);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.mouse_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          const Text('AniCursor'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Convierte cursores animados de Windows (.ani) al formato XCursor de Linux, manteniendo animaciones y generando symlinks.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const AboutRow(icon: Icons.person_outline, label: 'manuelprz'),
          const SizedBox(height: 6),
          const AboutRow(
            icon: Icons.code,
            label: 'github.com/manuelprz/anicursor',
          ),
          const SizedBox(height: 6),
          const AboutRow(
            icon: Icons.build_outlined,
            label: 'imagemagick + xcursorgen',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            launchUrl(Uri.parse('https://github.com/manuelprz/anicursor'));
          },
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('Ver en GitHub'),
        ),
      ],
    ),
  );
}
