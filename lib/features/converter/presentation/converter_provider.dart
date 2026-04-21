import 'package:flutter/services.dart';

import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/data/repositories/converter_repository.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_theme.dart';
import 'package:ani_to_xcursor/features/converter/domain/usecases/convert_theme_usecase.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/shared/services/logger_service.dart';

import 'package:ani_to_xcursor/features/converter/data/sources/cursor_mapping_datasource.dart';
import 'package:ani_to_xcursor/features/converter/data/sources/cursor_extraction_datasource.dart';
import 'package:ani_to_xcursor/features/converter/data/sources/cursor_generation_datasource.dart';
import 'package:ani_to_xcursor/features/converter/data/sources/theme_installation_datasource.dart';
import 'package:ani_to_xcursor/shared/utils/string_utils.dart';

import '../domain/models/cursor_file.dart';

final mappingDataSourceProvider = Provider<CursorMappingDataSource>((ref) {
  return CursorMappingDataSource();
});

final extractionDataSourceProvider = Provider<CursorExtractionDataSource>((
  ref,
) {
  return CursorExtractionDataSource();
});

final generationDataSourceProvider = Provider<CursorGenerationDataSource>((
  ref,
) {
  return CursorGenerationDataSource();
});

final installationDataSourceProvider = Provider<ThemeInstallationDataSource>((
  ref,
) {
  return ThemeInstallationDataSource();
});

final converterRepositoryProvider = Provider<ConverterRepository>((ref) {
  return ConverterRepository(
    ref.watch(mappingDataSourceProvider),
    ref.watch(extractionDataSourceProvider),
    ref.watch(generationDataSourceProvider),
    ref.watch(installationDataSourceProvider),
  );
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

    // Extraer previews en segundo plano
    for (int i = 0; i < cursors.length; i++) {
      final cursor = cursors[i];
      final previewPath = await repo.extractPreview(
        cursor.aniPath,
        StringUtils.sanitizeFilename(cursor.windowsName),
      );

      // Verificamos que sigamos en el mismo tema antes de actualizar
      if (previewPath != null && state != null && state!.inputDir == dirPath) {
        final updatedCursors = List<CursorFile>.from(state!.cursors);
        // Doble verificación del índice por si acaso el estado cambió
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

    try {
      await for (final theme in usecase.execute(state!, settings)) {
        state = theme;
      }

      // Intentar reproducir sonido de finalización de forma ultra-segura (Sistema)
      if (state != null) {
        if (state!.status == ThemeStatus.error ||
            (state!.status == ThemeStatus.done && state!.errors > 0)) {
          await _playSound('assets/sounds/error_1.mp3');
        } else if (state!.status == ThemeStatus.done) {
          await _playSound('assets/sounds/notification_1.mp3');
        }
      }
    } catch (e) {
      await LoggerService.log('Error durante la conversión (UI): $e', severity: LogSeverity.error);
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      // 1. Extraer el asset a un archivo temporal (el sistema no lee assets directamente)
      final byteData = await rootBundle.load(assetPath);
      final cacheDir = Directory(
        p.join(Directory.systemTemp.path, 'anicursor_audio'),
      );
      if (!await cacheDir.exists()) await cacheDir.create();

      final tempFile = File(p.join(cacheDir.path, p.basename(assetPath)));
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      // 2. Ejecutar comando de sistema de forma asíncrona para no bloquear y evitar crashes
      // Intentamos con gst-launch-1.0 que es el estándar de Linux/GTK
      await Process.run('gst-launch-1.0', [
        'playbin',
        'uri=file://${tempFile.path}',
        'video-sink=fakesink',
        'audio-sink=autoaudiosink',
      ]);

      await LoggerService.log('Sonido sistema ejecutado: $assetPath', severity: LogSeverity.debug);
    } catch (e) {
      await LoggerService.log('Audio del sistema no disponible o falló: $e', severity: LogSeverity.warning);
      // No hacemos nada más, la app sigue funcionando perfectamente
    }
  }

  Future<bool> install() async {
    if (state == null) return false;
    final repo = ref.read(converterRepositoryProvider);
    final settings = ref.read(settingsProvider).current;

    // Al instalar, nos aseguramos de que los metadatos index.theme estén actualizados con el nombre actual (por si se renombró por conflicto)
    await repo.createThemeFile(state!.outputDir, state!.name);

    return await repo.installTheme(state!.outputDir, state!.name, settings);
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
    final indexTheme = p.join(state!.outputDir, 'index.theme');
    final cursorTheme = p.join(state!.outputDir, 'cursor.theme');

    if (Directory(cursorsDir).existsSync()) {
      encoder.addDirectory(Directory(cursorsDir));
    }
    if (File(indexTheme).existsSync()) {
      encoder.addFile(File(indexTheme));
    }
    if (File(cursorTheme).existsSync()) {
      encoder.addFile(File(cursorTheme));
    }

    encoder.close();
  }

  Future<void> exportTarGz() async {
    if (state == null) return;

    final tarPath = await FilePicker.saveFile(
      dialogTitle: 'Exportar tema como TAR.GZ',
      fileName: '${state!.name}.tar.gz',
      type: FileType.custom,
      allowedExtensions: ['tar.gz', 'gz'],
    );

    if (tarPath == null) return;

    final cursorsDir = p.join(state!.outputDir, 'cursors');
    final indexTheme = p.join(state!.outputDir, 'index.theme');
    final cursorTheme = p.join(state!.outputDir, 'cursor.theme');

    // TarFileEncoder en archive_io maneja gzip si el nombre termina en .gz o .tar.gz?
    // No, normalmente TarFileEncoder crea el tar. Para gzip necesitamos envolverlo.
    // Pero TarFileEncoder tiene un constructor que acepta un archivo y podemos comprimir después.

    final tmpTar = File(
      p.join(Directory.systemTemp.path, '${state!.name}.tar'),
    );
    final encoder = TarFileEncoder();
    encoder.create(tmpTar.path);

    if (Directory(cursorsDir).existsSync()) {
      encoder.addDirectory(Directory(cursorsDir));
    }
    if (File(indexTheme).existsSync()) {
      encoder.addFile(File(indexTheme));
    }
    if (File(cursorTheme).existsSync()) {
      encoder.addFile(File(cursorTheme));
    }

    encoder.close();

    // Comprimir Tar a GZip
    final tarBytes = await tmpTar.readAsBytes();
    final gzipBytes = GZipEncoder().encode(tarBytes);
    if (gzipBytes != null) {
      await File(tarPath).writeAsBytes(gzipBytes);
    }

    // Limpiar temporal
    if (await tmpTar.exists()) await tmpTar.delete();
  }

  void reset() => state = null;
}
