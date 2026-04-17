import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/installed_themes/domain/models/installed_theme.dart';
import 'package:ani_to_xcursor/shared/services/logger_service.dart';

class InstalledThemesScanner {
  /// Escanea los directorios estándar de cursores en Linux
  Future<List<InstalledTheme>> scan() async {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isEmpty) return [];

    final paths = [
      p.join(home, '.icons'),
      p.join(home, '.local', 'share', 'icons'),
      '/usr/share/icons',
    ];

    final allThemes = <InstalledTheme>[];

    for (final basePath in paths) {
      final themesInPath = await _scanDirectory(
        basePath,
        basePath == '/usr/share/icons',
      );
      allThemes.addAll(themesInPath);
    }

    return _deduplicate(allThemes);
  }

  Future<List<InstalledTheme>> _scanDirectory(
    String basePath,
    bool isSystem,
  ) async {
    final dir = Directory(basePath);
    if (!await dir.exists()) return [];

    final themes = <InstalledTheme>[];

    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is Directory) {
          final theme = await _validateTheme(entity.path, isSystem);
          if (theme != null) {
            themes.add(theme);
          }
        }
      }
    } catch (e) {
      await LoggerService.log(
        'Error escaneando $basePath: $e',
        severity: LogSeverity.error,
      );
    }

    return themes;
  }

  Future<InstalledTheme?> _validateTheme(
    String themePath,
    bool isSystem,
  ) async {
    final indexThemeFile = File(p.join(themePath, 'index.theme'));
    final cursorsDir = Directory(p.join(themePath, 'cursors'));

    // 1. Validación básica: debe tener index.theme y carpeta cursors/
    if (!await indexThemeFile.exists() || !await cursorsDir.exists()) {
      return null;
    }

    try {
      // 2. Validación de contenido de index.theme
      final content = await indexThemeFile.readAsString();
      if (!content.contains('[Icon Theme]')) {
        return null;
      }

      String? displayName;
      final lines = content.split('\n');
      for (var line in lines) {
        if (line.startsWith('Name=')) {
          displayName = line.substring(5).trim();
          break;
        }
      }

      final themeName = p.basename(themePath);

      // 3. Metadatos para desduplicación
      int cursorCount = 0;
      int totalSize = 0;

      await for (final file in cursorsDir.list(followLinks: true)) {
        if (file is File) {
          cursorCount++;
          totalSize += await file.length();
        }
      }

      if (cursorCount == 0) return null;

      return InstalledTheme(
        name: themeName,
        path: themePath,
        displayName: displayName ?? themeName,
        isSystem: isSystem,
        cursorCount: cursorCount,
        totalSize: totalSize,
      );
    } catch (e) {
      return null;
    }
  }

  List<InstalledTheme> _deduplicate(List<InstalledTheme> themes) {
    // Usamos un mapa para quedarnos con uno por nombre y metadatos idénticos
    // Priorizamos los temas locales sobre los de sistema si son idénticos
    final Map<String, InstalledTheme> uniqueThemes = {};

    for (final theme in themes) {
      final key = '${theme.name}_${theme.cursorCount}_${theme.totalSize}';
      if (!uniqueThemes.containsKey(key)) {
        uniqueThemes[key] = theme;
      } else {
        // Si ya existe, preferimos el que NO es de sistema (local)
        if (uniqueThemes[key]!.isSystem && !theme.isSystem) {
          uniqueThemes[key] = theme;
        }
      }
    }

    return uniqueThemes.values.toList()..sort(
      (a, b) =>
          a.displayName!.toLowerCase().compareTo(b.displayName!.toLowerCase()),
    );
  }

  Future<bool> deleteTheme(String path) async {
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        return true;
      }
    } catch (e) {
      await LoggerService.log(
        'Error eliminando tema en $path: $e',
        severity: LogSeverity.error,
      );
    }
    return false;
  }
}
