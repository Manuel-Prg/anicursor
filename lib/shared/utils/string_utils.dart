import 'package:path/path.dart' as p;

class StringUtils {
  /// Sanitiza un nombre de archivo para evitar problemas con comandos de sistema y xcursorgen
  static String sanitizeFilename(String name) {
    // Quitar la extensión si existe
    final base = p.basenameWithoutExtension(name);
    // Reemplazar espacios y caracteres especiales por guiones bajos
    return base.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
  }
}
