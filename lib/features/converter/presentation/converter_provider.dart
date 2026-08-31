import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_theme.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/shared/services/logger_service.dart';
import 'package:ani_to_xcursor/shared/utils/string_utils.dart';

import 'datasources_provider.dart';
import '../data/sources/system_audio_service.dart';
import '../data/sources/theme_export_service.dart';

final systemAudioServiceProvider = Provider<SystemAudioService>((ref) {
  return SystemAudioService();
});

final themeExportServiceProvider = Provider<ThemeExportService>((ref) {
  return ThemeExportService();
});

final cursorThemeProvider = NotifierProvider<CursorThemeNotifier, CursorTheme?>(
  () {
    return CursorThemeNotifier();
  },
);

class CursorThemeNotifier extends Notifier<CursorTheme?> {
  @override
  CursorTheme? build() {
    ref.onDispose(() {
      _cleanupFrames();
    });
    return null;
  }

  void _cleanupFrames() {
    if (state != null) {
      final framesDir = p.join(state!.outputDir, 'frames');
      try {
        final dir = Directory(framesDir);
        if (dir.existsSync()) {
          dir.deleteSync(recursive: true);
        }
      } catch (e) {
        LoggerService.log(
          'Error limpiando directorio de frames temporales: $e',
          severity: LogSeverity.warning,
        );
      }
    }
  }

  String _generateUniqueThemeName(String baseName) {
    final home = Platform.environment['HOME'] ?? '';
    final localIconsDir = p.join(home, '.local', 'share', 'icons');
    final usrIconsDir = '/usr/share/icons';

    var sanitized = StringUtils.sanitizeFilename(baseName).toLowerCase();
    if (sanitized.isEmpty) sanitized = 'custom-cursor';

    String candidate = sanitized;
    int counter = 1;

    while (Directory(p.join(localIconsDir, candidate)).existsSync() ||
        Directory(p.join(usrIconsDir, candidate)).existsSync() ||
        Link(p.join(localIconsDir, candidate)).existsSync()) {
      candidate = '$sanitized-$counter';
      counter++;
    }

    return candidate;
  }

  Future<void> scanDirectory(String dirPath) async {
    _cleanupFrames();
    final repo = ref.read(converterRepositoryProvider);
    final settings = ref.read(settingsProvider).current;
    final cursors = repo.scanDirectory(dirPath);
    final rawThemeName = dirPath.split('/').last;
    final themeName = _generateUniqueThemeName(rawThemeName);

    state = CursorTheme(
      name: themeName,
      inputDir: dirPath,
      outputDir: settings.customOutputDir != null
          ? p.join(settings.customOutputDir!, '$themeName-linux')
          : p.join(dirPath, '..', '$themeName-linux'),
      cursors: cursors,
    );

    for (int i = 0; i < cursors.length; i++) {
      final cursor = cursors[i];
      final previewPath = await repo.extractPreview(
        cursor.aniPath,
        StringUtils.sanitizeFilename(cursor.windowsName),
      );

      if (previewPath != null && state != null && state!.inputDir == dirPath) {
        final updatedCursors = List<CursorFile>.from(state!.cursors);
        if (i < updatedCursors.length &&
            updatedCursors[i].windowsName == cursor.windowsName) {
          updatedCursors[i] = updatedCursors[i].copyWith(
            previewPath: previewPath,
          );
          state = state!.copyWith(cursors: updatedCursors);
        }
      }
    }
  }

  void updateThemeName(String name) {
    if (state == null) return;
    final settings = ref.read(settingsProvider).current;
    final themeName = StringUtils.sanitizeFilename(name).toLowerCase();
    state = state!.copyWith(
      name: themeName,
      outputDir: settings.customOutputDir != null
          ? p.join(settings.customOutputDir!, '$themeName-linux')
          : p.join(state!.inputDir, '..', '$themeName-linux'),
    );
  }

  Future<void> convert() async {
    if (state == null) return;

    final usecase = ref.read(convertThemeUsecaseProvider);
    final settings = ref.read(settingsProvider).current;
    final audioService = ref.read(systemAudioServiceProvider);

    try {
      await for (final theme in usecase.execute(state!, settings)) {
        state = theme;
      }

      if (state != null) {
        if (state!.status == ThemeStatus.error ||
            (state!.status == ThemeStatus.done && state!.errors > 0)) {
          await audioService.playSound('assets/sounds/error_1.mp3');
        } else if (state!.status == ThemeStatus.done) {
          await audioService.playSound('assets/sounds/notification_1.mp3');
        }
      }
    } catch (e) {
      await LoggerService.log(
        'Error durante la conversión (UI): $e',
        severity: LogSeverity.error,
      );
    }
  }

  Future<bool> install() async {
    if (state == null) return false;
    final settings = ref.read(settingsProvider).current;
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final installationSource = ref.read(installationDataSourceProvider);

    await installationSource.createThemeFile(state!.outputDir, state!.name);
    return await installationSource.installTheme(
      state!.outputDir,
      state!.name,
      settings,
      settingsNotifier: settingsNotifier,
    );
  }

  Future<void> exportZip() async {
    if (state == null) return;
    final exportService = ref.read(themeExportServiceProvider);
    await exportService.exportZip(state!.name, state!.outputDir);
  }

  Future<void> exportTarGz() async {
    if (state == null) return;
    final exportService = ref.read(themeExportServiceProvider);
    await exportService.exportTarGz(state!.name, state!.outputDir);
  }

  void reset() {
    _cleanupFrames();
    state = null;
  }
}
