import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

class ThemeInstallationDataSource {
  /// Crea los archivos de metadatos del tema
  Future<void> createThemeFile(String themeDir, String themeName) async {
    final content = '''
[Icon Theme]
Name=$themeName
Comment=$themeName cursor theme for Linux - converted with ANI to XCursor
Inherits=core
Example=left_ptr
''';
    await File(p.join(themeDir, 'index.theme')).writeAsString(content);
    // Para compatibilidad con algunos sistemas, también creamos cursor.theme
    await File(p.join(themeDir, 'cursor.theme')).writeAsString(content);
  }

  /// Instala el tema en ~/.local/share/icons
  Future<bool> installTheme(
    String themeDir,
    String themeName,
    Settings settings,
  ) async {
    final home = Platform.environment['HOME']!;
    final iconsDir = settings.systemInstall
        ? '/usr/share/icons'
        : p.join(home, '.local', 'share', 'icons');
    final dest = p.join(iconsDir, themeName);

    bool success = true;
    final cursorsSrc = p.join(themeDir, 'cursors');
    final indexThemeSrc = p.join(themeDir, 'index.theme');

    if (settings.systemInstall) {
      final commands = [
        "rm -rf '$dest'",
        "mkdir -p '$dest'",
        "cp -a '$cursorsSrc' '$dest'",
        "cp -a '$indexThemeSrc' '$dest'",
        "chmod -R 755 '$dest'",
        "sync",
      ];

      final res = await Process.run('pkexec', [
        'sh',
        '-c',
        commands.join(' && '),
      ]);
      if (res.exitCode != 0) success = false;
    } else {
      // Instalación local
      try {
        if (await Directory(dest).exists() || await Link(dest).exists()) {
          await Process.run('rm', ['-rf', dest]);
        }
        await Directory(dest).create(recursive: true);

        if (await Directory(cursorsSrc).exists()) {
          final res = await Process.run('cp', ['-a', cursorsSrc, dest]);
          if (res.exitCode != 0) success = false;
        }
        if (await File(indexThemeSrc).exists()) {
          final res = await Process.run('cp', ['-a', indexThemeSrc, dest]);
          if (res.exitCode != 0) success = false;
        }
        // También aplicamos chmod 755 de forma local para mayor robustez
        await Process.run('chmod', ['-R', '755', dest]);
        await Process.run('sync', []);
      } catch (e) {
        print('Error en instalación local: $e');
        success = false;
      }
    }

    if (success && settings.autoApplyCursor) {
      final res = await Process.run('gsettings', [
        'set',
        'org.gnome.desktop.interface',
        'cursor-theme',
        themeName,
      ]);
      if (res.exitCode != 0) {
        print('No se pudo auto-aplicar el cursor: ${res.stderr}');
      }
    }

    return success;
  }
}
