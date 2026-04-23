import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/shared/services/logger_service.dart';

class XCursorParser {
  /// Extrae el primer frame de un archivo XCursor y lo convierte a PNG usando ImageMagick
  static Future<String?> extractFirstFrame(String xcursorPath, String name) async {
    final file = File(xcursorPath);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    if (bytes.length < 16) return null;

    // Verificar magia 'Xcur'
    if (bytes[0] != 0x58 || bytes[1] != 0x63 || bytes[2] != 0x75 || bytes[3] != 0x72) {
      return null;
    }

    final data = ByteData.view(bytes.buffer);
    final ntoc = data.getUint32(12, Endian.little);
    
    int firstImageOffset = -1;
    int width = 0;
    int height = 0;

    // Buscar la primera entrada de tipo imagen (0xfffd0002)
    for (int i = 0; i < ntoc; i++) {
      final tocEntryPos = 16 + (i * 12);
      if (tocEntryPos + 12 > bytes.length) break;

      final type = data.getUint32(tocEntryPos, Endian.little);
      if (type == 0xfffd0002) {
        firstImageOffset = data.getUint32(tocEntryPos + 8, Endian.little);
        break;
      }
    }

    if (firstImageOffset == -1 || firstImageOffset + 36 > bytes.length) return null;

    // Leer cabecera de la imagen
    // El tamaño de la cabecera es usualmente 36
    width = data.getUint32(firstImageOffset + 16, Endian.little);
    height = data.getUint32(firstImageOffset + 20, Endian.little);
    final pixelsOffset = firstImageOffset + 36;
    final pixelsSize = width * height * 4;

    if (pixelsOffset + pixelsSize > bytes.length) return null;

    final rawPixels = bytes.sublist(pixelsOffset, pixelsOffset + pixelsSize);
    
    // Guardar temporalmente los píxeles raw usando un nombre único
    final uniqueId = DateTime.now().microsecondsSinceEpoch;
    final tempDir = Directory.systemTemp.path;
    final rawPath = p.join(tempDir, 'anicursor_raw_${name}_$uniqueId');
    final outPath = p.join(tempDir, 'anicursor_preview_${name}_$uniqueId.png');

    await File(rawPath).writeAsBytes(rawPixels);

    await LoggerService.log('XCursor: Convirtiendo raw $width x $height para $name');

    // Convertir raw BGRA a PNG usando ImageMagick
    final result = await Process.run('convert', [
      '-size', '${width}x$height',
      '-depth', '8',
      'bgra:$rawPath',
      outPath,
    ]);

    // Limpiar raw
    await File(rawPath).delete();

    if (result.exitCode == 0 && await File(outPath).exists()) {
      return outPath;
    }

    return null;
  }
}
