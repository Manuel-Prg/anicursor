import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum LogSeverity { info, warning, error, debug }

class LoggerService {
  static File? _logFile;

  static Future<void> init() async {
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      // Asegurarse de que el directorio existe
      if (!await appSupportDir.exists()) {
        await appSupportDir.create(recursive: true);
      }
      _logFile = File(p.join(appSupportDir.path, 'app.log'));
      
      // Rotar log si es muy grande (> 5MB)
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > 5 * 1024 * 1024) {
          await _logFile!.rename(p.join(appSupportDir.path, 'app.log.old'));
        }
      }

      await log('--- Sesión iniciada: ${DateTime.now()} ---', severity: LogSeverity.info);
    } catch (e) {
      print('Error inicializando LoggerService: $e');
    }
  }

  static Future<void> log(String message, {LogSeverity severity = LogSeverity.info}) async {
    final timestamp = DateTime.now().toIso8601String();
    final logLine = '[$timestamp] [${severity.name.toUpperCase()}] $message\n';
    
    // Imprimir en consola siempre
    print(logLine.trim());

    if (_logFile != null) {
      try {
        await _logFile!.writeAsString(logLine, mode: FileMode.append);
      } catch (e) {
        print('Error escribiendo en log: $e');
      }
    }
  }

  static Future<String> getLogPath() async {
    if (_logFile != null) return _logFile!.path;
    final appSupportDir = await getApplicationSupportDirectory();
    return p.join(appSupportDir.path, 'app.log');
  }

  static Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('');
      await log('Logs limpiados por el usuario', severity: LogSeverity.info);
    }
  }
}
