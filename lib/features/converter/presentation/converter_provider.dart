import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/data/repositories/converter_repository.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_theme.dart';
import 'package:ani_to_xcursor/features/converter/domain/usecases/convert_theme_usecase.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

final converterRepositoryProvider = Provider<ConverterRepository>((ref) {
  return ConverterRepository();
});

final convertThemeUsecaseProvider = Provider<ConvertThemeUsecase>((ref) {
  return ConvertThemeUsecase(ref.watch(converterRepositoryProvider));
});

final cursorThemeProvider = NotifierProvider<CursorThemeNotifier, CursorTheme?>(
  () {
    return CursorThemeNotifier();
  },
);

class CursorThemeNotifier extends Notifier<CursorTheme?> {
  @override
  CursorTheme? build() => null;

  void scanDirectory(String dirPath) {
    final repo = ref.read(converterRepositoryProvider);
    final settings = ref.read(settingsProvider);
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
  }

  void updateThemeName(String name) {
    if (state == null) return;
    state = state!.copyWith(name: name);
  }

  Future<void> convert() async {
    if (state == null) return;

    final usecase = ref.read(convertThemeUsecaseProvider);
    final settings = ref.read(settingsProvider);

    await for (final theme in usecase.execute(state!, settings)) {
      state = theme;
    }

    // Efectos de sonido personalizados (App Assets)
    if (state != null) {
      final player = AudioPlayer();
      if (state!.status == ThemeStatus.error ||
          (state!.status == ThemeStatus.done && state!.errors > 0)) {
        player.play(AssetSource('sounds/error_1.mp3'));
      } else if (state!.status == ThemeStatus.done) {
        player.play(AssetSource('sounds/notification_1.mp3'));
      }
    }
  }

  Future<void> install() async {
    if (state == null) return;
    final repo = ref.read(converterRepositoryProvider);
    final settings = ref.read(settingsProvider);
    await repo.installTheme(state!.outputDir, state!.name, settings);
  }

  Future<void> exportZip() async {
    if (state == null) return;

    final zipPath = await FilePicker.saveFile(
      dialogTitle: 'Exportar tema como ZIP',
      fileName: '${state!.name}.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (zipPath == null) return;

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    final cursorsDir = p.join(state!.outputDir, 'cursors');
    final themeFile = p.join(state!.outputDir, 'cursor.theme');

    if (Directory(cursorsDir).existsSync()) {
      encoder.addDirectory(Directory(cursorsDir));
    }
    if (File(themeFile).existsSync()) {
      encoder.addFile(File(themeFile));
    }

    encoder.close();
  }

  void reset() => state = null;
}
