import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';

class CursorGenerationDataSource {
  /// Genera el cursor Linux desde los frames
  Future<bool> generateCursor(
    List<CursorFrame> frames,
    String outputPath,
    List<int> sizes,
  ) async {
    if (frames.isEmpty) return false;

    final confPath = '$outputPath.conf';
    final conf = StringBuffer();
    final framesDir = p.dirname(frames.first.imagePath);

    for (final frame in frames) {
      for (final size in sizes) {
        // Redimensionar frame para cada tamaño solicitado
        final resizedPath = p.join(
          framesDir,
          'res_${size}_${p.basename(frame.imagePath)}',
        );

        final res = await Process.run('convert', [
          frame.imagePath,
          '-resize',
          '${size}x$size!',
          'PNG32:$resizedPath', // Forzar PNG32 para xcursorgen
        ]);

        if (res.exitCode != 0) {
          print('Error redimensionando a $size px: ${res.stderr}');
          return false;
        }

        // Escalar hotspots proporcionalmente
        final scaleX = size / frame.width;
        final scaleY = size / frame.height;
        final hX = (frame.hotspotX * scaleX).round();
        final hY = (frame.hotspotY * scaleY).round();

        conf.writeln('$size $hX $hY $resizedPath ${frame.delay}');
      }
    }

    print('Generando .conf en: $confPath');
    print('Contenido .conf:\n${conf.toString()}');

    await File(confPath).writeAsString(conf.toString());

    // Borrar el destino si ya existe (podría ser un symlink de un alias previo)
    final output = File(outputPath);
    if (await output.exists() || await Link(outputPath).exists()) {
      await Process.run('rm', ['-f', outputPath]);
    }

    final result = await Process.run('xcursorgen', [confPath, outputPath]);

    if (result.exitCode != 0) {
      print('Error en xcursorgen: ${result.stderr}');
      return false;
    } else {
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        final size = await outputFile.length();
        if (size > 0) {
          print('Cursor generado con éxito: $outputPath ($size bytes)');
        } else {
          print('Error: xcursorgen generó un archivo vacío para $outputPath');
          return false;
        }
      } else {
        print('Error: xcursorgen falló al crear el archivo $outputPath');
        return false;
      }
    }

    print('Limpiando archivos redimensionados basura para $outputPath...');
    try {
      final dir = Directory(framesDir);
      if (await dir.exists()) {
        final files = dir.listSync();
        for (var file in files) {
          final fileName = p.basename(file.path);
          // Borramos solo los archivos que empiezan con 'res_' y pertenecen a este cursor
          if (fileName.startsWith('res_') &&
              fileName.contains(p.basenameWithoutExtension(outputPath))) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Error no fatal limpiando frames basura: $e');
    }

    await File(confPath).delete();
    return result.exitCode == 0;
  }

  /// Crea symlinks para los aliases
  Future<void> createAliases(
    String cursorsDir,
    String linuxName,
    List<String> aliases,
  ) async {
    for (final alias in aliases) {
      try {
        final linkPath = p.join(cursorsDir, alias);
        final link = Link(linkPath);

        // Si ya existe algo ahí, lo borramos para poder crear el link
        if (await File(linkPath).exists() || await Link(linkPath).exists()) {
          await Process.run('rm', ['-f', linkPath]);
        }

        print('Creando alias: $alias -> $linuxName');
        await link.create(linuxName);
      } catch (e) {
        print('Error no fatal al crear alias $alias: $e');
      }
    }
  }
}
