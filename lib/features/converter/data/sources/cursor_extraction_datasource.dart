import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/shared/services/logger_service.dart';

class CursorExtractionDataSource {
  /// Extrae frames de un archivo .ani o .cur
  Future<List<CursorFrame>> extractFrames(
    String fileOrAniPath,
    String framesDir,
    String name,
    int defaultDelay,
  ) async {
    await LoggerService.log('Extrayendo frames de: $fileOrAniPath');
    final ext = p.extension(fileOrAniPath).toLowerCase();

    // Soporte para archivos .cur (no animados)
    if (ext == '.cur') {
      final data = await File(fileOrAniPath).readAsBytes();
      final frame = await _parseCurFrame(
        fileOrAniPath,
        framesDir,
        name,
        0,
        data,
        defaultDelay,
      );
      return frame != null ? [frame] : [];
    }

    final data = await File(fileOrAniPath).readAsBytes();
    final frames = <CursorFrame>[];
    int delay = defaultDelay;

    // Buscar chunk 'rate' para delays
    final ratePos = _findChunk(data, 'rate');
    if (ratePos != -1) {
      final count = _readUint32(data, ratePos + 4) ~/ 4;
      if (count > 0) {
        final jiffies = _readUint32(data, ratePos + 8);
        delay = ((jiffies / 60) * 1000).round();
      }
    }

    // Extraer frames icon
    int pos = 0;
    int frameNum = 0;

    while (true) {
      // Buscamos tanto 'icon' como 'ICON' para máxima compatibilidad
      int iconPosLower = _findChunkFrom(data, 'icon', pos);
      int iconPosUpper = _findChunkFrom(data, 'ICON', pos);

      int iconPos;
      if (iconPosLower == -1) {
        iconPos = iconPosUpper;
      } else if (iconPosUpper == -1) {
        iconPos = iconPosLower;
      } else {
        iconPos = min(iconPosLower, iconPosUpper);
      }
      if (iconPos == -1) break;

      final size = _readUint32(data, iconPos + 4);
      final frameData = data.sublist(iconPos + 8, iconPos + 8 + size);

      final frame = await _parseCurFrame(
        null,
        framesDir,
        name,
        frameNum,
        frameData,
        delay,
      );
      if (frame != null) {
        frames.add(frame);
        frameNum++;
      }

      pos = iconPos + 8 + size;
    }

    if (frames.isEmpty) {
      // Fallback: it might not be a valid RIFF .ani or it's a disguised .cur
      final fallbackPng = p.join(framesDir, '${name}_fallback.png');
      final result = await Process.run('convert', [fileOrAniPath, fallbackPng]);

      if (result.exitCode == 0 && await File(fallbackPng).exists()) {
        await LoggerService.log('Fallback: Imagen extraída con ImageMagick para $name');
        // En fallback no podemos saber el hotspot fácilmente sin identificar
        frames.add(
          CursorFrame(
            imagePath: fallbackPng,
            delay: defaultDelay,
            hotspotX: 0,
            hotspotY: 0,
            width: 32,
            height: 32,
          ),
        );
      } else {
        await LoggerService.log('Error en fallback convert para $name: ${result.stderr}', severity: LogSeverity.error);
      }
    }

    return frames;
  }

  Future<CursorFrame?> _parseCurFrame(
    String? curPathToRead,
    String framesDir,
    String name,
    int frameNum,
    Uint8List data,
    int delay,
  ) async {
    final curPath = curPathToRead ?? p.join(framesDir, '${name}_$frameNum.cur');
    final pngPath = p.join(framesDir, '${name}_$frameNum.png');

    if (curPathToRead == null) {
      await File(curPath).writeAsBytes(data);
    }

    // Parsear header CUR básica
    // Offset 6: Width, 7: Height, 10: HotspotX, 12: HotspotY
    if (data.length < 14) {
      print('Error: Datos de frame insuficientes (${data.length} bytes)');
      return null;
    }

    int width = data[6];
    int height = data[7];
    if (width == 0) width = 256;
    if (height == 0) height = 256;

    final hX = data[10] | (data[11] << 8);
    final hY = data[12] | (data[13] << 8);

    final result = await Process.run('convert', [curPath, 'PNG32:$pngPath']);

    if (curPathToRead == null) {
      await File(curPath).delete();
    }

    if (result.exitCode == 0 && await File(pngPath).exists()) {
      await LoggerService.log(
        'Frame extraído: ${p.basename(pngPath)} (${width}x$height) Hotspot: ($hX, $hY)',
      );
      return CursorFrame(
        imagePath: pngPath,
        delay: delay,
        hotspotX: hX,
        hotspotY: hY,
        width: width,
        height: height,
      );
    } else {
      await LoggerService.log(
        'Error al convertir frame $frameNum de $name a PNG: ${result.stderr}',
        severity: LogSeverity.error,
      );
    }
    return null;
  }

  // Helpers para parsear binario RIFF
  int _findChunk(Uint8List data, String tag) => _findChunkFrom(data, tag, 0);

  int _findChunkFrom(Uint8List data, String tag, int start) {
    final tagBytes = tag.codeUnits;
    for (int i = start; i < data.length - 4; i++) {
      if (data[i] == tagBytes[0] &&
          data[i + 1] == tagBytes[1] &&
          data[i + 2] == tagBytes[2] &&
          data[i + 3] == tagBytes[3]) {
        return i;
      }
    }
    return -1;
  }

  int _readUint32(Uint8List data, int offset) {
    return data[offset] |
        (data[offset + 1] << 8) |
        (data[offset + 2] << 16) |
        (data[offset + 3] << 24);
  }
}
