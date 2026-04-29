import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class _CursorRole {
  final String linuxName;
  final List<String> aliases;
  final List<String> winRoles;
  final List<String> keywords;

  const _CursorRole(this.linuxName, this.aliases, this.winRoles, this.keywords);
}

class MockScanner {
  static const _cursorRoles = [
    _CursorRole('left_ptr', ['default', 'arrow'], ['pointer', 'arrow'], [
      'normal',
      'pointer',
      'default',
    ]),
    _CursorRole('hand2', ['pointer', 'pointing_hand'], ['link'], [
      'link',
      'pointing',
      'hand',
    ]),
    _CursorRole('watch', ['wait', 'progress'], ['busy'], [
      'busy',
      'wait',
      'loading',
    ]),
    _CursorRole(
      'left_ptr_watch',
      ['half-busy'],
      ['working', 'work', 'alternate'],
      ['working', 'work', 'progress', 'loading'],
    ),
    _CursorRole('question_arrow', ['help'], ['help'], ['help', 'question']),
    _CursorRole('xterm', ['text', 'ibeam'], ['text'], [
      'text',
      'ibeam',
      'select',
    ]),
    _CursorRole('pencil', [], ['hand'], ['handwriting', 'pencil', 'pen']),
    _CursorRole('cross', ['crosshair'], ['precision', 'cross'], [
      'precision',
      'cross',
      'crosshair',
    ]),
    _CursorRole('not-allowed', ['forbidden'], ['unavailable'], [
      'unavailable',
      'not-allowed',
      'forbidden',
      'no',
    ]),
    _CursorRole(
      'sb_v_double_arrow',
      ['n-resize', 's-resize', 'ns-resize'],
      ['vert'],
      ['vertical', 'ns-resize', 'v-resize'],
    ),
    _CursorRole(
      'sb_h_double_arrow',
      ['e-resize', 'w-resize', 'ew-resize'],
      ['horz'],
      ['horizontal', 'ew-resize', 'h-resize'],
    ),
    _CursorRole(
      'top_left_corner',
      ['nw-resize', 'se-resize', 'nwse-resize'],
      ['dgn1'],
      ['diagonal1', 'nwse', 'top_left'],
    ),
    _CursorRole(
      'top_right_corner',
      ['ne-resize', 'sw-resize', 'nesw-resize'],
      ['dgn2'],
      ['diagonal2', 'nesw', 'top_right'],
    ),
    _CursorRole('fleur', ['move', 'all-scroll'], ['move'], [
      'move',
      'all-scroll',
      'fleur',
    ]),
    _CursorRole('alias', [], ['person'], ['person', 'alias']),
    _CursorRole('crosshair', [], ['pin'], ['pin', 'location']),
  ];

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
        if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        }
        mapping[key] = value;
      }
    }
    return mapping;
  }

  void scan(String dirPath) {
    if (kDebugMode) {
      print('Testing directory: $dirPath');
    }
    final dir = Directory(dirPath);
    final files = dir.listSync().whereType<File>().toList();

    Map<String, String> infMapping = {};
    try {
      final infFile = files.firstWhere(
        (f) => p.extension(f.path).toLowerCase() == '.inf',
      );
      infMapping = _parseInfFile(infFile.path);
      if (kDebugMode) {
        print('Found INF file: ${p.basename(infFile.path)}');
      }
    } catch (_) {
      if (kDebugMode) {
        print('No INF file found.');
      }
    }

    for (final file in files) {
      final name = p.basename(file.path);
      final ext = p.extension(name).toLowerCase();
      if (ext != '.ani' && ext != '.cur') continue;

      final lowerName = name.toLowerCase();
      String? matchedLinuxName;

      // Priority 1: INF
      for (final roleEntry in infMapping.entries) {
        if (roleEntry.value.toLowerCase() == lowerName) {
          final roleKey = roleEntry.key.toLowerCase();
          final config = _cursorRoles.firstWhere(
            (c) => c.winRoles.any((role) => roleKey.contains(role)),
            orElse: () => _CursorRole('', [], [], []),
          );
          if (config.linuxName.isNotEmpty) {
            matchedLinuxName = config.linuxName;
            if (kDebugMode) {
              print(' [INF] $name -> $matchedLinuxName');
            }
            break;
          }
        }
      }

      // Priority 2: Fuzzy
      if (matchedLinuxName == null) {
        for (final config in _cursorRoles) {
          bool matched = false;
          for (final kw in config.keywords) {
            if (lowerName.contains(kw)) {
              matched = true;
              break;
            }
          }
          if (matched) {
            matchedLinuxName = config.linuxName;
            if (kDebugMode) {
              print(' [FUZZY] $name -> $matchedLinuxName');
            }
            break;
          }
        }
      }

      if (matchedLinuxName == null) {
        if (kDebugMode) {
          print(' [NONE] $name');
        }
      }
    }
  }
}

void main() {
  final scanner = MockScanner();
  scanner.scan('/home/manuelprz/Documentos/cursores/niko_cursor');
  if (kDebugMode) {
    print('\n---\n');
  }
  scanner.scan('/home/manuelprz/Documentos/cursores/Roxy_Cursor');
}
