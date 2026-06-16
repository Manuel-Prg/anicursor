import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/shared/services/logger_service.dart';

class SystemAudioService {
  Future<void> playSound(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final cacheDir = Directory(
        p.join(Directory.systemTemp.path, 'anicursor_audio'),
      );
      if (!await cacheDir.exists()) await cacheDir.create();

      final tempFile = File(p.join(cacheDir.path, p.basename(assetPath)));
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      final process = await Process.start('gst-launch-1.0', [
        'playbin',
        'uri=file://${tempFile.path}',
        'video-sink=fakesink',
        'audio-sink=autoaudiosink',
      ]);
      // Drenar las salidas para evitar bloqueos del proceso
      process.stdout.drain();
      process.stderr.drain();

      await LoggerService.log(
        'Sonido sistema ejecutado: $assetPath',
        severity: LogSeverity.debug,
      );
    } catch (e) {
      await LoggerService.log(
        'Audio del sistema no disponible o falló: $e',
        severity: LogSeverity.warning,
      );
    }
  }
}
