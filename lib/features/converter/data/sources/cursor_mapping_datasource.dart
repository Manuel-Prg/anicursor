import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';

class CursorMappingDataSource {
  static const List<(String, List<String>, List<String>, List<String>)>
  _cursorRoles = [
    (
      'left_ptr',
      ['default', 'arrow'],
      ['pointer', 'arrow'],
      ['normal', 'pointer', 'default'],
    ),
    (
      'hand2',
      ['pointer', 'pointing_hand'],
      ['link'],
      ['link', 'pointing', 'hand'],
    ),
    ('watch', ['wait', 'progress'], ['busy'], ['busy', 'wait', 'loading']),
    (
      'left_ptr_watch',
      ['half-busy'],
      ['working', 'work', 'alternate'],
      ['working', 'work', 'progress', 'loading'],
    ),
    ('question_arrow', ['help'], ['help'], ['help', 'question']),
    ('xterm', ['text', 'ibeam'], ['text'], ['text', 'ibeam', 'select']),
    ('pencil', [], ['hand'], ['handwriting', 'pencil', 'pen']),
    (
      'cross',
      ['crosshair'],
      ['precision', 'cross'],
      ['precision', 'cross', 'crosshair'],
    ),
    (
      'not-allowed',
      ['forbidden'],
      ['unavailable'],
      ['unavailable', 'not-allowed', 'forbidden', 'no'],
    ),
    (
      'sb_v_double_arrow',
      ['n-resize', 's-resize', 'ns-resize'],
      ['vert'],
      ['vertical', 'ns-resize', 'v-resize'],
    ),
    (
      'sb_h_double_arrow',
      ['e-resize', 'w-resize', 'ew-resize'],
      ['horz'],
      ['horizontal', 'ew-resize', 'h-resize'],
    ),
    (
      'top_left_corner',
      ['nw-resize', 'se-resize', 'nwse-resize'],
      ['dgn1'],
      ['diagonal1', 'nwse', 'top_left'],
    ),
    (
      'top_right_corner',
      ['ne-resize', 'sw-resize', 'nesw-resize'],
      ['dgn2'],
      ['diagonal2', 'nesw', 'top_right'],
    ),
    (
      'fleur',
      ['move', 'all-scroll'],
      ['move'],
      ['move', 'all-scroll', 'fleur'],
    ),
    ('alias', [], ['person'], ['person', 'alias']),
    ('crosshair', [], ['pin'], ['pin', 'location']),
  ];

  /// Escanea la carpeta y retorna los cursores encontrados
  List<CursorFile> scanDirectory(String dirPath) {
    final cursors = <CursorFile>[];
    final dir = Directory(dirPath);

    if (!dir.existsSync()) return cursors;

    final files = dir.listSync().whereType<File>().toList();

    // 1. Intentar parsear archivo .inf para mapeo exacto
    print('Scaneando directorio: $dirPath');
    Map<String, String> infMapping = {};
    for (final file in files) {
      if (p.extension(file.path).toLowerCase() == '.inf') {
        try {
          print('Encontrado archivo INF: ${file.path}');
          infMapping = _parseInfFile(file.path);
          break;
        } catch (e) {
          print('Error al parsear INF: $e');
        }
      }
    }

    for (final file in files) {
      final name = p.basename(file.path);
      final ext = p.extension(name).toLowerCase();

      if (ext != '.ani' && ext != '.cur') continue;

      final lowerName = name.toLowerCase();
      String? matchedLinuxName;
      List<String>? matchedAliases;

      // Prioridad 1: Mapeo por .inf
      for (final roleEntry in infMapping.entries) {
        if (roleEntry.value.toLowerCase() == lowerName) {
          final roleKey = roleEntry.key.toLowerCase();
          final config = _cursorRoles.firstWhere(
            (c) => c.$3.any((role) => roleKey.contains(role)),
            orElse: () => ('', <String>[], <String>[], <String>[]),
          );
          if (config.$1.isNotEmpty) {
            matchedLinuxName = config.$1;
            matchedAliases = config.$2;
            break;
          }
        }
      }

      // Prioridad 2: Fuzzy match por keywords
      if (matchedLinuxName == null) {
        for (final config in _cursorRoles) {
          final linuxName = config.$1;
          final aliases = config.$2;
          final keywords = config.$4;

          bool matched = false;
          // Check keywords
          for (final kw in keywords) {
            if (lowerName.contains(kw)) {
              matched = true;
              break;
            }
          }

          if (matched) {
            matchedLinuxName = linuxName;
            matchedAliases = aliases;
            break;
          }
        }
      }

      if (matchedLinuxName != null) {
        cursors.add(
          CursorFile(
            windowsName: name,
            linuxName: matchedLinuxName,
            aniPath: file.path,
            aliases: List<String>.from(matchedAliases ?? []),
            status: ConversionStatus.pending,
          ),
        );
      }
    }

    return cursors;
  }

  /// Parsea un archivo .inf para extraer el mapeo de cursores
  Map<String, String> _parseInfFile(String path) {
    final mapping = <String, String>{};
    final lines = File(path).readAsLinesSync();

    bool inStrings = false;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith(';')) continue;

      if (trimmed.toLowerCase().startsWith('[strings]')) {
        inStrings = true;
        continue;
      }

      if (trimmed.startsWith('[')) {
        inStrings = false;
        continue;
      }

      if (inStrings && trimmed.contains('=')) {
        final parts = trimmed.split('=');
        final key = parts[0].trim().toLowerCase();
        var value = parts[1].trim();
        // Quitar comillas si existen
        if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        }
        mapping[key] = value;
      }
    }
    return mapping;
  }
}
