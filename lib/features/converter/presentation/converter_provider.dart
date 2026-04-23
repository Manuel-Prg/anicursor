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

final cursorThemeProvider = NotifierProvider<CursorThemeNotifier, CursorTheme?>(() {
  return CursorThemeNotifier();
});

class CursorThemeNotifier extends Notifier<CursorTheme?> {
  @override
  CursorTheme? build() => null;

  Future<void> scanDirectory(String dirPath) async {
    final repo = ref.read(converterRepositoryProvider);
    final settings = ref.read(settingsProvider).current;
    final cursors = repo.scanDirectory(dirPath);
    final themeName = dirPath.split('/').last;

    state = CursorTheme(
      name: themeName,
      inputDir: dirPath,
      outputDir: settings.customOutputDir != null
          ? p.join(settings.customOutputDir!, '$themeName-Linux')
          : p.join(dirPath, '..', '$themeName-Linux'),
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
    state = state!.copyWith(name: name);
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
    final repo = ref.read(converterRepositoryProvider);
    final settings = ref.read(settingsProvider).current;

    await repo.createThemeFile(state!.outputDir, state!.name);
    return await repo.installTheme(state!.outputDir, state!.name, settings);
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

  void reset() => state = null;
}