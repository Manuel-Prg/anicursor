import 'package:flutter/material.dart' hide showAboutDialog;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'social_icon.dart';
import 'about_dialog.dart';

class SocialFooter extends StatelessWidget {
  const SocialFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialIcon(
              tooltip: 'GitHub',
              iconWidget: const FaIcon(FontAwesomeIcons.github, size: 19),
              onTap: () => launchUrl(
                Uri.parse('https://github.com/Manuel-Prg/anicursor'),
              ),
            ),
            const SizedBox(width: 4),
            SocialIcon(
              tooltip: 'Acerca de',
              iconWidget: const Icon(Icons.info_outline, size: 20),
              onTap: () => showAboutDialog(context),
            ),
            const SizedBox(width: 4),
            SocialIcon(
              tooltip: 'Ko-fi — Apoyar el proyecto',
              iconWidget: const Icon(Icons.coffee_outlined, size: 20),
              onTap: () => launchUrl(Uri.parse('https://ko-fi.com/manuelprz')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Made with ♥ by manuelprz',
          style: theme.textTheme.bodySmall?.copyWith(color: iconColor),
        ),
      ],
    );
  }
}
