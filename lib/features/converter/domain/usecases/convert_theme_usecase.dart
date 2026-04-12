import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/data/repositories/converter_repository.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_theme.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

class ConvertThemeUsecase {
  final ConverterRepository _repository;

  ConvertThemeUsecase(this._repository);

  Stream<CursorTheme> execute(CursorTheme theme, Settings settings) async* {
    final framesDir = p.join(theme.outputDir, 'frames');
    final cursorsDir = p.join(theme.outputDir, 'cursors');

    await Directory(framesDir).create(recursive: true);
    await Directory(cursorsDir).create(recursive: true);

    var current = theme.copyWith(status: ThemeStatus.converting);
    yield current;

    for (int i = 0; i < current.cursors.length; i++) {
      final cursor = current.cursors[i];

      if (cursor.status == ConversionStatus.error) continue;

      // Marcar como convirtiendo
      final updatedCursors = List<CursorFile>.from(current.cursors);
      updatedCursors[i] = cursor.copyWith(status: ConversionStatus.converting);
      current = current.copyWith(
        cursors: updatedCursors,
        progress: ((i / current.cursors.length) * 100).round(),
      );
      yield current;

      try {
        // Extraer frames
        final frames = await _repository.extractFrames(
          cursor.aniPath,
          framesDir,
          cursor.linuxName,
          settings.defaultDelay,
        );

        // Generar cursor
        final outputPath = p.join(cursorsDir, cursor.linuxName);
        final success = await _repository.generateCursor(frames, outputPath, settings.cursorSizes);

        // Crear aliases
        if (success && cursor.aliases.isNotEmpty) {
          await _repository.createAliases(
            cursorsDir,
            cursor.linuxName,
            cursor.aliases,
          );
        }

        updatedCursors[i] = cursor.copyWith(
          status: success ? ConversionStatus.done : ConversionStatus.error,
          framesData: frames,
        );
      } catch (e, stack) {
        print('Error crítico detectado en conversion de ${cursor.windowsName}: $e');
        print(stack);
        updatedCursors[i] = cursor.copyWith(status: ConversionStatus.error);
      }

      current = current.copyWith(
        cursors: updatedCursors,
        progress: (((i + 1) / current.cursors.length) * 100).round(),
      );
      yield current;
    }

    try {
      // Crear archivo cursor.theme
      await _repository.createThemeFile(theme.outputDir, theme.name);

      current = current.copyWith(
        status: current.errors > 0 ? ThemeStatus.error : ThemeStatus.done,
        progress: 100,
      );
    } catch (e) {
      print('Error al finalizar el tema: $e');
      current = current.copyWith(
        status: ThemeStatus.error,
        progress: 100,
      );
    }
    yield current;
  }
}