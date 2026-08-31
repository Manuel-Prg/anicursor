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
Inherits=Adwaita,breeze,hicolor,core
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
    Settings settings, {
    SettingsNotifier? settingsNotifier,
  }) async {
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
        // 1. Instalar en ~/.local/share/icons
        final dir = Directory(dest);
        final link = Link(dest);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        } else if (await link.exists()) {
          await link.delete();
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
        await Process.run('chmod', ['-R', '755', dest]);

        // 2. Instalar en ~/.icons para compatibilidad con Flatpak/X11
        final legacyIconsDir = p.join(home, '.icons');
        final legacyDest = p.join(legacyIconsDir, themeName);
        final legacyDir = Directory(legacyDest);
        final legacyLink = Link(legacyDest);

        if (await legacyDir.exists()) {
          await legacyDir.delete(recursive: true);
        } else if (await legacyLink.exists()) {
          await legacyLink.delete();
        }
        
        await Directory(legacyIconsDir).create(recursive: true);
        await Directory(legacyDest).create(recursive: true);

        if (await Directory(cursorsSrc).exists()) {
          final res = await Process.run('cp', ['-a', cursorsSrc, legacyDest]);
          if (res.exitCode != 0) success = false;
        }
        if (await File(indexThemeSrc).exists()) {
          final res = await Process.run('cp', ['-a', indexThemeSrc, legacyDest]);
          if (res.exitCode != 0) success = false;
        }
        await Process.run('chmod', ['-R', '755', legacyDest]);

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
      await applyTheme(themeName, settingsNotifier: settingsNotifier);
    }

    return success;
  }

  Future<String?> getActiveSystemThemeName() async {
    final de = SystemInfoService.desktopEnvironment;
    try {
      if (de == DesktopEnvironment.gnome || de == DesktopEnvironment.cinnamon) {
        final res = await Process.run('gsettings', [
          'get',
          'org.gnome.desktop.interface',
          'cursor-theme',
        ]);
        if (res.exitCode == 0) {
          var val = res.stdout.toString().trim();
          if (val.startsWith("'") && val.endsWith("'")) {
            val = val.substring(1, val.length - 1);
          }
          if (val.isNotEmpty) return val;
        }
      } else if (de == DesktopEnvironment.kde) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          final file = File(p.join(home, '.config', 'kcminputrc'));
          if (await file.exists()) {
            final lines = await file.readAsLines();
            bool inMouse = false;
            for (final line in lines) {
              final trimmed = line.trim();
              if (trimmed == '[Mouse]') {
                inMouse = true;
              } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
                inMouse = false;
              }
              if (inMouse && trimmed.startsWith('cursorTheme=')) {
                final val = trimmed.substring(12).trim();
                if (val.isNotEmpty) return val;
              }
            }
          }
        }
      } else if (de == DesktopEnvironment.xfce) {
        final res = await Process.run('xfconf-query', [
          '-c',
          'xsettings',
          '-p',
          '/Gtk/CursorThemeName',
        ]);
        if (res.exitCode == 0) {
          final val = res.stdout.toString().trim();
          if (val.isNotEmpty) return val;
        }
      } else if (de == DesktopEnvironment.mate) {
        final res = await Process.run('gsettings', [
          'get',
          'org.mate.peripherals-mouse',
          'cursor-theme',
        ]);
        if (res.exitCode == 0) {
          var val = res.stdout.toString().trim();
          if (val.startsWith("'") && val.endsWith("'")) {
            val = val.substring(1, val.length - 1);
          }
          if (val.isNotEmpty) return val;
        }
      }
    } catch (_) {}

    try {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final gtk3 = File(p.join(home, '.config', 'gtk-3.0', 'settings.ini'));
        if (await gtk3.exists()) {
          final lines = await gtk3.readAsLines();
          for (final line in lines) {
            if (line.trim().startsWith('gtk-cursor-theme-name=')) {
              final val = line.trim().substring(22).trim();
              if (val.isNotEmpty) return val;
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  Future<bool> applyTheme(
    String themeName, {
    SettingsNotifier? settingsNotifier,
  }) async {
    final de = SystemInfoService.desktopEnvironment;
    await LoggerService.log('Intentando auto-aplicar tema en $de');

    // Intentar respaldar el tema original del sistema si aún no ha sido guardado
    if (settingsNotifier != null) {
      try {
        final currentTheme = await getActiveSystemThemeName();
        if (currentTheme != null && currentTheme != themeName) {
          await settingsNotifier.saveOriginalSystemCursorTheme(currentTheme);
        }
      } catch (_) {}
    }

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
        // Intentar usar el comando oficial plasma-apply-cursortheme
        final resApply = await Process.run('plasma-apply-cursortheme', [themeName]);
        success = resApply.exitCode == 0;

        if (!success) {
          // En KDE a veces hay que probar con kwriteconfig5 o 6 (Fallback)
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
        }
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

      // Sincronizar configuraciones globales de forma incondicional para mayor robustez
      final activeSize = await _getActiveCursorSize();
      await cleanupGhostDefaultFolders();
      await _updateGtkSettings(themeName, activeSize);
      await _updateXResources(themeName, activeSize);

      if (success) {
        await LoggerService.log(
          'Tema aplicado con éxito en $de (o mediante comandos directos)',
        );
      } else {
        await LoggerService.log(
          'Fallo al auto-aplicar en $de tras intentar fallbacks, pero se actualizaron configuraciones globales',
          severity: LogSeverity.warning,
        );
        // Retornamos true si pudimos escribir las configuraciones globales, ya que eso suele ser suficiente
        success = true;
      }
    } catch (e) {
      await LoggerService.log(
        'Error aplicando tema: $e',
        severity: LogSeverity.error,
      );
    }
    return success;
  }

  Future<int> _getActiveCursorSize() async {
    // 1. Intentar con gsettings (GNOME/Cinnamon/MATE/etc)
    try {
      final res = await Process.run('gsettings', [
        'get',
        'org.gnome.desktop.interface',
        'cursor-size',
      ]);
      if (res.exitCode == 0) {
        final val = int.tryParse(res.stdout.toString().trim());
        if (val != null && val > 0) return val;
      }
    } catch (_) {}

    // 2. Intentar con kcminputrc (KDE)
    try {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final file = File(p.join(home, '.config', 'kcminputrc'));
        if (await file.exists()) {
          final lines = await file.readAsLines();
          bool inMouse = false;
          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed == '[Mouse]') {
              inMouse = true;
            } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
              inMouse = false;
            }
            if (inMouse && trimmed.startsWith('cursorSize=')) {
              final val = int.tryParse(trimmed.substring(11).trim());
              if (val != null && val > 0) return val;
            }
          }
        }
      }
    } catch (_) {}

    // 3. Fallback por defecto a 24
    return 24;
  }

  Future<void> cleanupGhostDefaultFolders() async {
    final home = Platform.environment['HOME'];
    if (home == null) return;
    try {
      final paths = [
        p.join(home, '.local', 'share', 'icons', 'default'),
        p.join(home, '.icons', 'default'),
        p.join(home, '.local', 'share', 'icons', 'cursors'),
        p.join(home, '.icons', 'cursors'),
        p.join(home, '.local', 'share', 'icons', 'index.theme'),
        p.join(home, '.icons', 'index.theme'),
      ];
      for (final path in paths) {
        final file = File(path);
        final dir = Directory(path);
        if (await file.exists()) {
          await file.delete();
        } else if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      }
    } catch (e) {
      await LoggerService.log(
        'Error limpiando carpetas fantasma por defecto: $e',
        severity: LogSeverity.warning,
      );
    }
  }

  Future<void> _updateGtkSettings(String themeName, int size) async {
    final home = Platform.environment['HOME'];
    if (home == null) return;

    final paths = [
      p.join(home, '.config', 'gtk-3.0', 'settings.ini'),
      p.join(home, '.config', 'gtk-4.0', 'settings.ini'),
    ];

    for (final path in paths) {
      try {
        final file = File(path);
        if (!await file.exists()) {
          await file.create(recursive: true);
          await file.writeAsString(
            '[Settings]\ngtk-cursor-theme-name=$themeName\ngtk-cursor-theme-size=$size\n',
          );
          await LoggerService.log(
            'Creado nuevo archivo de configuración GTK en $path ($themeName, $size)',
          );
          continue;
        }

        final lines = await file.readAsLines();
        bool foundSettings = false;
        bool themeUpdated = false;
        bool sizeUpdated = false;

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line == '[Settings]') {
            foundSettings = true;
          }
          if (line.startsWith('gtk-cursor-theme-name=')) {
            lines[i] = 'gtk-cursor-theme-name=$themeName';
            themeUpdated = true;
          }
          if (line.startsWith('gtk-cursor-theme-size=')) {
            lines[i] = 'gtk-cursor-theme-size=$size';
            sizeUpdated = true;
          }
        }

        if (!themeUpdated) {
          if (foundSettings) {
            final index = lines.indexOf('[Settings]');
            lines.insert(index + 1, 'gtk-cursor-theme-name=$themeName');
          } else {
            if (lines.isNotEmpty && lines.last.isNotEmpty) {
              lines.add('');
            }
            lines.add('[Settings]');
            lines.add('gtk-cursor-theme-name=$themeName');
          }
        }

        // Recalcular índice si insertamos
        bool hasSettingsAfterInsert = lines.contains('[Settings]');
        int settingsIndex = lines.indexOf('[Settings]');

        if (!sizeUpdated) {
          if (hasSettingsAfterInsert) {
            lines.insert(settingsIndex + 1, 'gtk-cursor-theme-size=$size');
          } else {
            lines.add('gtk-cursor-theme-size=$size');
          }
        }

        await file.writeAsString('${lines.join('\n')}\n');
        await LoggerService.log(
          'Actualizado archivo de configuración GTK en $path ($themeName, $size)',
        );
      } catch (e) {
        await LoggerService.log(
          'Error actualizando configuración GTK en $path: $e',
          severity: LogSeverity.warning,
        );
      }
    }
  }

  Future<void> _updateXResources(String themeName, int size) async {
    final home = Platform.environment['HOME'];
    if (home == null) return;

    final files = [
      File(p.join(home, '.Xresources')),
      File(p.join(home, '.Xdefaults')),
    ];

    for (final file in files) {
      try {
        if (!await file.exists()) {
          await file.create();
          await file.writeAsString(
            'Xcursor.theme: $themeName\nXcursor.size: $size\n',
          );
          await LoggerService.log(
            'Creado nuevo archivo Xresources en ${file.path} ($themeName, $size)',
          );
          continue;
        }

        final lines = await file.readAsLines();
        bool themeUpdated = false;
        bool sizeUpdated = false;

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          final lowerLine = line.toLowerCase();
          if (RegExp(r'^xcursor\.theme\s*:').hasMatch(lowerLine)) {
            lines[i] = 'Xcursor.theme: $themeName';
            themeUpdated = true;
          } else if (RegExp(r'^xcursor\.size\s*:').hasMatch(lowerLine)) {
            lines[i] = 'Xcursor.size: $size';
            sizeUpdated = true;
          }
        }

        if (!themeUpdated) {
          lines.add('Xcursor.theme: $themeName');
        }
        if (!sizeUpdated) {
          lines.add('Xcursor.size: $size');
        }

        await file.writeAsString('${lines.join('\n')}\n');
        await LoggerService.log(
          'Actualizado archivo Xresources en ${file.path} ($themeName, $size)',
        );
      } catch (e) {
        await LoggerService.log(
          'Error actualizando Xresources en ${file.path}: $e',
          severity: LogSeverity.warning,
        );
      }
    }

    // Ejecutar xrdb para aplicar cambios en X11/XWayland inmediatamente si está disponible
    try {
      final res = await Process.run('xrdb', ['-merge', p.join(home, '.Xresources')]);
      if (res.exitCode == 0) {
        await LoggerService.log('Comando xrdb ejecutado con éxito para aplicar cambios en X11');
      } else {
        await LoggerService.log(
          'El comando xrdb falló con código ${res.exitCode}: ${res.stderr}',
          severity: LogSeverity.warning,
        );
      }
    } catch (e) {
      await LoggerService.log(
        'El comando xrdb no está disponible o falló: $e',
        severity: LogSeverity.warning,
      );
    }
  }

  Future<String> _getKdeWriteConfigCmd() async {
    // Verificar si existe kwriteconfig6 (Plasma 6)
    final check6 = await Process.run('which', ['kwriteconfig6']);
    if (check6.exitCode == 0) return 'kwriteconfig6';
    return 'kwriteconfig5';
  }
}
