import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/data/repositories/converter_repository.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_theme.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/shared/services/logger_service.dart';

class ConvertThemeUsecase {
  final ConverterRepository _repository;

  ConvertThemeUsecase(this._repository);

  Stream<CursorTheme> execute(CursorTheme theme, Settings settings) async* {
    final framesDir = p.join(theme.outputDir, 'frames');
    final cursorsDir = p.join(theme.outputDir, 'cursors');

    await Directory(framesDir).create(recursive: true);
    await Directory(cursorsDir).create(recursive: true);

    var current = theme.copyWith(
      status: ThemeStatus.converting,
      overallProgress: 0.05,
      statusMessage: "Preparando directorio de salida...",
    );
    yield current;

    for (int i = 0; i < current.cursors.length; i++) {
      final cursor = current.cursors[i];

      if (cursor.status == ConversionStatus.error) continue;

      // Marcar como convirtiendo
      final updatedCursors = List<CursorFile>.from(current.cursors);
      updatedCursors[i] = cursor.copyWith(status: ConversionStatus.converting);
      
      final cursorProgress = (i / current.cursors.length);
      final overall = 0.05 + (cursorProgress * 0.85); // 5% to 90%

      current = current.copyWith(
        cursors: updatedCursors,
        progress: ((i / current.cursors.length) * 100).round(),
        overallProgress: overall,
        statusMessage: "Procesando ${cursor.windowsName}...",
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

        if (frames.isEmpty) {
          updatedCursors[i] = cursor.copyWith(
            status: ConversionStatus.error,
            errorMessage: 'No se pudieron extraer frames del archivo.',
          );
        } else {
          // Generar cursor
          final outputPath = p.join(cursorsDir, cursor.linuxName);
          final success = await _repository.generateCursor(
            frames,
            outputPath,
            settings.cursorSizes,
          );

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
            errorMessage: success ? null : 'Error en la generación del cursor (xcursorgen).',
          );
        }
      } catch (e, stack) {
        await LoggerService.log(
          'Error crítico detectado en conversion de ${cursor.windowsName}: $e',
          severity: LogSeverity.error,
        );
        await LoggerService.log(stack.toString(), severity: LogSeverity.debug);
        updatedCursors[i] = cursor.copyWith(
          status: ConversionStatus.error,
          errorMessage: e.toString(),
        );
      }

      current = current.copyWith(
        cursors: updatedCursors,
        progress: (((i + 1) / current.cursors.length) * 100).round(),
        overallProgress: 0.05 + (((i + 1) / current.cursors.length) * 0.85),
      );
      yield current;
    }

    try {
      current = current.copyWith(
        statusMessage: "Generando metadatos (index.theme)...",
        overallProgress: 0.95,
      );
      yield current;

      // Crear archivo cursor.theme
      await _repository.createThemeFile(theme.outputDir, theme.name);

      current = current.copyWith(
        status: current.errors > 0 ? ThemeStatus.error : ThemeStatus.done,
        progress: 100,
        overallProgress: 1.0,
        statusMessage: current.errors > 0 
            ? "Conversión finalizada con algunos errores" 
            : "¡Conversión completada con éxito!",
      );
    } catch (e) {
      await LoggerService.log('Error al finalizar el tema: $e', severity: LogSeverity.error);
      current = current.copyWith(
        status: ThemeStatus.error, 
        progress: 100,
        overallProgress: 1.0,
        statusMessage: "Error al generar archivos finales",
      );
    }
    yield current;
  }
}
