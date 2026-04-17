import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/shared/services/system_info_service.dart';
import 'package:ani_to_xcursor/shared/services/logger_service.dart';

class ThemeInstallationDataSource {
  /// Crea los archivos de metadatos del tema
  Future<void> createThemeFile(String themeDir, String themeName) async {
    final content =
        '''
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

  Future<bool> themeExists(String themeName, bool systemInstall) async {
    final home = Platform.environment['HOME']!;
    final iconsDir = systemInstall
        ? '/usr/share/icons'
        : p.join(home, '.local', 'share', 'icons');
    final dest = p.join(iconsDir, themeName);
    return await Directory(dest).exists() || await Link(dest).exists();
  }

  /// Instala el tema en ~/.local/share/icons
  Future<bool> installTheme(
    String themeDir,
    String themeName,
    Settings settings,
  ) async {
    await LoggerService.log('Iniciando instalación del tema: $themeName');
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
      if (res.exitCode != 0) {
        await LoggerService.log(
          'Error en instalación de sistema (pkexec): ${res.stderr}',
          severity: LogSeverity.error,
        );
        success = false;
      }
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
        await LoggerService.log(
          'Error en instalación local: $e',
          severity: LogSeverity.error,
        );
        success = false;
      }
    }

    if (success && settings.autoApplyCursor) {
      await applyTheme(themeName);
    }

    return success;
  }

  Future<bool> applyTheme(String themeName) async {
    final de = SystemInfoService.desktopEnvironment;
    await LoggerService.log('Intentando auto-aplicar tema en $de');
    bool success = false;

    try {
      if (de == DesktopEnvironment.gnome || de == DesktopEnvironment.cinnamon) {
        // Fallback 1: gsettings
        final res1 = await Process.run('gsettings', [
          'set',
          'org.gnome.desktop.interface',
          'cursor-theme',
          themeName,
        ]);
        success = res1.exitCode == 0;

        if (!success) {
          // Fallback 2: dconf
          final res2 = await Process.run('dconf', [
            'write',
            '/org/gnome/desktop/interface/cursor-theme',
            "'$themeName'",
          ]);
          success = res2.exitCode == 0;
        }
      } else if (de == DesktopEnvironment.kde) {
        // En KDE a veces hay que probar con kwriteconfig5 o 6
        final writeConfigCmd = await _getKdeWriteConfigCmd();
        final res1 = await Process.run(writeConfigCmd, [
          '--file',
          'kcminputrc',
          '--group',
          'Mouse',
          '--key',
          'cursorTheme',
          themeName,
        ]);
        success = res1.exitCode == 0;

        // Intentar recargar KWin para que tome el cambio (Wayland/X11)
        await Process.run('dbus-send', [
          '--type=method_call',
          '--dest=org.kde.KWin',
          '/KWin',
          'org.kde.KWin.reconfigure',
        ]);

        // Fallback para Plasma 5/6 si el anterior no tiene efecto inmediato en aplicaciones GTK
        await Process.run('dbus-send', [
          '--type=method_call',
          '--dest=org.kde.GtkConfig',
          '/GtkConfig',
          'org.kde.GtkConfig.setCursorTheme',
          'string:$themeName',
        ]);
      } else if (de == DesktopEnvironment.xfce) {
        final res1 = await Process.run('xfconf-query', [
          '-c',
          'xsettings',
          '-p',
          '/Gtk/CursorThemeName',
          '-s',
          themeName,
        ]);
        success = res1.exitCode == 0;
      } else if (de == DesktopEnvironment.mate) {
        final res1 = await Process.run('gsettings', [
          'set',
          'org.mate.peripherals-mouse',
          'cursor-theme',
          themeName,
        ]);
        success = res1.exitCode == 0;
      }

      if (success) {
        await LoggerService.log(
          'Tema aplicado con éxito en $de (o mediante comandos directos)',
        );
      } else {
        await LoggerService.log(
          'Fallo al auto-aplicar en $de tras intentar fallbacks',
          severity: LogSeverity.warning,
        );
      }
    } catch (e) {
      await LoggerService.log(
        'Error aplicando tema: $e',
        severity: LogSeverity.error,
      );
    }
    return success;
  }

  Future<String> _getKdeWriteConfigCmd() async {
    // Verificar si existe kwriteconfig6 (Plasma 6)
    final check6 = await Process.run('which', ['kwriteconfig6']);
    if (check6.exitCode == 0) return 'kwriteconfig6';
    return 'kwriteconfig5';
  }
}
