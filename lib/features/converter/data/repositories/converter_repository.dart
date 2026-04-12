import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_theme.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

class ConverterRepository {
  static const _cursorMap = {
    '01-Normal.ani': ('left_ptr', ['default', 'arrow']),
    '02-Link.ani': ('hand2', ['pointer', 'pointing_hand']),
    '03-Loading.ani': ('watch', ['wait', 'progress']),
    '04-Help.ani': ('question_arrow', ['help']),
    '05-Text Select.ani': ('xterm', ['text', 'ibeam']),
    '05-Text Select Alt.ani': ('vertical-text', []),
    '06-Handwriting.ani': ('pencil', []),
    '07-Precision.ani': ('cross', ['crosshair']),
    '08-Unavailable.ani': ('not-allowed', ['forbidden']),
    '09-Location Select.ani': ('crosshair', []),
    '10-Person Select.ani': ('alias', []),
    '11-Vertical Resize.ani': ('sb_v_double_arrow', ['n-resize', 's-resize', 'ns-resize']),
    '12-Horizontal Resize.ani': ('sb_h_double_arrow', ['e-resize', 'w-resize', 'ew-resize']),
    '13-Diagonal Resize 1.ani': ('top_left_corner', ['nw-resize', 'se-resize', 'nwse-resize']),
    '14-Diagonal Resize 2.ani': ('top_right_corner', ['ne-resize', 'sw-resize', 'nesw-resize']),
    '15-Move.ani': ('fleur', ['move', 'all-scroll']),
    '16-Alternate Select.ani': ('left_ptr_watch', ['half-busy']),
  };

  /// Escanea la carpeta y retorna los cursores encontrados
  List<CursorFile> scanDirectory(String dirPath) {
    final cursors = <CursorFile>[];
    final dir = Directory(dirPath);

    if (!dir.existsSync()) return cursors;

    final files = dir.listSync().whereType<File>().toList();

    for (final file in files) {
      final name = p.basename(file.path);
      final ext = p.extension(name).toLowerCase();
      
      if (ext != '.ani' && ext != '.cur') continue;

      final lowerName = name.toLowerCase();

      String? matchedKey;
      // 1. Exact match
      for (final entry in _cursorMap.entries) {
        final keyLower = entry.key.toLowerCase();
        if (lowerName == keyLower || lowerName.replaceAll(ext, '.ani') == keyLower) {
          matchedKey = entry.key;
          break;
        }
      }

      // 2. Fuzzy match
      if (matchedKey == null) {
        for (final entry in _cursorMap.entries) {
          final linuxName = entry.value.$1;
          final aliases = entry.value.$2;
          final baseWindows = entry.key.replaceAll('.ani', '').toLowerCase();
          
          // Split base windows name
          final keywords = baseWindows.split(RegExp(r'[\s-]+')).where((k) => k.isNotEmpty && !int.tryParse(k[0]).toString().isNotEmpty).toList();
          
          bool matched = false;
          if (linuxName.isNotEmpty && lowerName.contains(linuxName.replaceAll('_', ''))) { // left_ptr -> leftptr
            matched = true;
          } else if (aliases.any((a) => lowerName.contains(a.replaceAll('-', '')))) {
            matched = true;
          } else {
            // Check if any keyword > 3 chars matches
            for (final kw in keywords) {
              if (kw.length >= 3 && lowerName.contains(kw)) {
                matched = true;
                break;
              }
            }
          }

          if (matched) {
            matchedKey = entry.key;
            break;
          }
        }
      }

      if (matchedKey != null) {
        final (linuxName, aliases) = _cursorMap[matchedKey]!;
        cursors.add(CursorFile(
          windowsName: name,
          linuxName: linuxName,
          aniPath: file.path,
          aliases: List<String>.from(aliases),
          status: File(file.path).existsSync()
              ? ConversionStatus.pending
              : ConversionStatus.error,
        ));
      }
    }

    return cursors;
  }

  /// Extrae frames de un archivo .ani o .cur
  Future<List<(String, int)>> extractFrames(
      String fileOrAniPath, String framesDir, String name, int defaultDelay) async {
    final ext = p.extension(fileOrAniPath).toLowerCase();
    
    // Soporte para archivos .cur (no animados)
    if (ext == '.cur') {
      final pngPath = p.join(framesDir, '${name}_0.png');
      final result = await Process.run('convert', [fileOrAniPath, pngPath]);
      if (result.exitCode == 0 && await File(pngPath).exists()) {
        return [(pngPath, defaultDelay)];
      }
      return [];
    }

    final data = await File(fileOrAniPath).readAsBytes();
    final frames = <(String, int)>[];
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
      final iconPos = _findChunkFrom(data, 'icon', pos);
      if (iconPos == -1) break;

      final size = _readUint32(data, iconPos + 4);
      final frameData = data.sublist(iconPos + 8, iconPos + 8 + size);

      final curPath = p.join(framesDir, '${name}_$frameNum.cur');
      final pngPath = p.join(framesDir, '${name}_$frameNum.png');

      await File(curPath).writeAsBytes(frameData);

      // Convertir .cur a .png con ImageMagick
      final result = await Process.run('convert', [curPath, pngPath]);

      if (result.exitCode == 0 && await File(pngPath).exists()) {
        frames.add((pngPath, delay));
        frameNum++;
      }

      await File(curPath).delete();
      pos = iconPos + 8 + size;
    }

    if (frames.isEmpty) {
      // Fallback: it might not be a valid RIFF .ani or it's a disguised .cur
      final fallbackPng = p.join(framesDir, '${name}_fallback.png');
      final fallbackResult = await Process.run('convert', [fileOrAniPath, fallbackPng]);
      if (fallbackResult.exitCode == 0 && await File(fallbackPng).exists()) {
        frames.add((fallbackPng, defaultDelay));
      }
    }

    return frames;
  }

  /// Genera el cursor Linux desde los frames
  Future<bool> generateCursor(
      List<(String, int)> frames, String outputPath, List<int> sizes) async {
    if (frames.isEmpty) return false;

    final confPath = '$outputPath.conf';
    final conf = StringBuffer();

    for (final (framePath, delay) in frames) {
      for (final size in sizes) {
        conf.writeln('$size 0 0 $framePath $delay');
      }
    }

    await File(confPath).writeAsString(conf.toString());

    final result = await Process.run('xcursorgen', [confPath, outputPath]);
    await File(confPath).delete();

    return result.exitCode == 0;
  }

  /// Crea symlinks para los aliases
  Future<void> createAliases(
      String cursorsDir, String linuxName, List<String> aliases) async {
    for (final alias in aliases) {
      final linkPath = p.join(cursorsDir, alias);
      final link = Link(linkPath);
      if (!link.existsSync()) {
        await link.create(linuxName);
      }
    }
  }

  /// Crea el archivo cursor.theme
  Future<void> createThemeFile(String themeDir, String themeName) async {
    final content = '''
[Icon Theme]
Name=$themeName
Comment=$themeName cursor theme for Linux - converted with ANI to XCursor
''';
    await File(p.join(themeDir, 'cursor.theme')).writeAsString(content);
  }

  /// Instala el tema en ~/.local/share/icons
  Future<bool> installTheme(String themeDir, String themeName, Settings settings) async {
    final home = Platform.environment['HOME']!;
    final iconsDir = settings.systemInstall
        ? '/usr/share/icons'
        : p.join(home, '.local', 'share', 'icons');
    final dest = p.join(iconsDir, themeName);

    bool success = true;
    final cursorsSrc = p.join(themeDir, 'cursors');
    final themeSrc = p.join(themeDir, 'cursor.theme');

    if (settings.systemInstall) {
      await Process.run('pkexec', ['rm', '-rf', dest]);
      await Process.run('pkexec', ['mkdir', '-p', dest]);

      if (await Directory(cursorsSrc).exists()) {
        final res = await Process.run('pkexec', ['cp', '-r', cursorsSrc, dest]);
        if (res.exitCode != 0) success = false;
      }
      if (await File(themeSrc).exists()) {
        final res = await Process.run('pkexec', ['cp', themeSrc, dest]);
        if (res.exitCode != 0) success = false;
      }
    } else {
      await Process.run('rm', '-rf $dest'.split(' '));
      await Directory(dest).create(recursive: true);

      if (await Directory(cursorsSrc).exists()) {
        final res = await Process.run('cp', ['-r', cursorsSrc, dest]);
        if (res.exitCode != 0) success = false;
      }
      if (await File(themeSrc).exists()) {
        final res = await Process.run('cp', [themeSrc, dest]);
        if (res.exitCode != 0) success = false;
      }
    }

    if (success && settings.autoApplyCursor) {
      await Process.run('gsettings', ['set', 'org.gnome.desktop.interface', 'cursor-theme', themeName]);
    }

    return success;
  }

  // Helpers para parsear binario RIFF
  int _findChunk(Uint8List data, String tag) =>
      _findChunkFrom(data, tag, 0);

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