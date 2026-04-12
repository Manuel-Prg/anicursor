import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

class ConverterRepository {
  static const List<(String, List<String>, List<String>, List<String>)>
      _cursorRoles = [
    (
      'left_ptr',
      ['default', 'arrow'],
      ['pointer', 'arrow'],
      ['normal', 'pointer', 'default']
    ),
    (
      'hand2',
      ['pointer', 'pointing_hand'],
      ['link'],
      ['link', 'pointing', 'hand']
    ),
    (
      'watch',
      ['wait', 'progress'],
      ['busy'],
      ['busy', 'wait', 'loading']
    ),
    (
      'left_ptr_watch',
      ['half-busy'],
      ['working', 'work', 'alternate'],
      ['working', 'work', 'progress', 'loading']
    ),
    (
      'question_arrow',
      ['help'],
      ['help'],
      ['help', 'question']
    ),
    (
      'xterm',
      ['text', 'ibeam'],
      ['text'],
      ['text', 'ibeam', 'select']
    ),
    (
      'pencil',
      [],
      ['hand'],
      ['handwriting', 'pencil', 'pen']
    ),
    (
      'cross',
      ['crosshair'],
      ['precision', 'cross'],
      ['precision', 'cross', 'crosshair']
    ),
    (
      'not-allowed',
      ['forbidden'],
      ['unavailable'],
      ['unavailable', 'not-allowed', 'forbidden', 'no']
    ),
    (
      'sb_v_double_arrow',
      ['n-resize', 's-resize', 'ns-resize'],
      ['vert'],
      ['vertical', 'ns-resize', 'v-resize']
    ),
    (
      'sb_h_double_arrow',
      ['e-resize', 'w-resize', 'ew-resize'],
      ['horz'],
      ['horizontal', 'ew-resize', 'h-resize']
    ),
    (
      'top_left_corner',
      ['nw-resize', 'se-resize', 'nwse-resize'],
      ['dgn1'],
      ['diagonal1', 'nwse', 'top_left']
    ),
    (
      'top_right_corner',
      ['ne-resize', 'sw-resize', 'nesw-resize'],
      ['dgn2'],
      ['diagonal2', 'nesw', 'top_right']
    ),
    (
      'fleur',
      ['move', 'all-scroll'],
      ['move'],
      ['move', 'all-scroll', 'fleur']
    ),
    (
      'alias',
      [],
      ['person'],
      ['person', 'alias']
    ),
    (
      'crosshair',
      [],
      ['pin'],
      ['pin', 'location']
    ),
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

  /// Extrae frames de un archivo .ani o .cur
  Future<List<CursorFrame>> extractFrames(
    String fileOrAniPath,
    String framesDir,
    String name,
    int defaultDelay,
  ) async {
    final ext = p.extension(fileOrAniPath).toLowerCase();

    // Soporte para archivos .cur (no animados)
    if (ext == '.cur') {
      final data = await File(fileOrAniPath).readAsBytes();
      final frame = await _parseCurFrame(fileOrAniPath, framesDir, name, 0, data, defaultDelay);
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
      final iconPos = _findChunkFrom(data, 'icon', pos);
      if (iconPos == -1) break;

      final size = _readUint32(data, iconPos + 4);
      final frameData = data.sublist(iconPos + 8, iconPos + 8 + size);

      final frame = await _parseCurFrame(
          null, framesDir, name, frameNum, frameData, delay);
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
        // En fallback no podemos saber el hotspot fácilmente sin identificar
        frames.add(CursorFrame(
          imagePath: fallbackPng,
          delay: defaultDelay,
          hotspotX: 0,
          hotspotY: 0,
          width: 32,
          height: 32,
        ));
      }
    }

    return frames;
  }

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
        final resizedPath =
            p.join(framesDir, 'res_${size}_${p.basename(frame.imagePath)}');

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
    } else {
      print('Cursor generado con éxito: $outputPath');
    }

    // Cleanup resized frames
    // for (final size in sizes) { ... } // Se limpian al borrar el directorio temporal del proceso completo

    await File(confPath).delete();
    return result.exitCode == 0;
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
      print('Frame extraído: ${p.basename(pngPath)} (${width}x$height) Hotspot: ($hX, $hY)');
      return CursorFrame(
        imagePath: pngPath,
        delay: delay,
        hotspotX: hX,
        hotspotY: hY,
        width: width,
        height: height,
      );
    } else {
      print('Error al convertir frame $frameNum a PNG: ${result.stderr}');
    }
    return null;
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

  /// Crea el archivo cursor.theme
  Future<void> createThemeFile(String themeDir, String themeName) async {
    final content =
        '''
[Icon Theme]
Name=$themeName
Comment=$themeName cursor theme for Linux - converted with ANI to XCursor
''';
    await File(p.join(themeDir, 'cursor.theme')).writeAsString(content);
  }

  /// Instala el tema en ~/.local/share/icons
  Future<bool> installTheme(
    String themeDir,
    String themeName,
    Settings settings,
  ) async {
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
      await Process.run('gsettings', [
        'set',
        'org.gnome.desktop.interface',
        'cursor-theme',
        themeName,
      ]);
    }

    return success;
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
