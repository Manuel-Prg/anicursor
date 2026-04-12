import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:typed_data';

class DebugConverter {
  int _readUint32(Uint8List data, int offset) {
    return data[offset] | (data[offset + 1] << 8) | (data[offset + 2] << 16) | (data[offset + 3] << 24);
  }

  int _findChunkFrom(Uint8List data, String tag, int start) {
    final tagBytes = tag.codeUnits;
    for (int i = start; i < data.length - 4; i++) {
      if (data[i] == tagBytes[0] && data[i + 1] == tagBytes[1] && data[i + 2] == tagBytes[2] && data[i + 3] == tagBytes[3]) {
        return i;
      }
    }
    return -1;
  }

  Future<void> run() async {
    final file = File('/home/manuelprz/Documentos/cursores/Roxy_Cursor/07-Precision.ani');
    if (!file.existsSync()) {
      print('File not found!');
      return;
    }
    final data = await file.readAsBytes();
    final framesDir = 'scratch/debug_frames';
    await Directory(framesDir).create(recursive: true);

    print('Processing ${file.path}');
    int pos = 0;
    int frameNum = 0;
    
    while (true) {
      final iconPos = _findChunkFrom(data, 'icon', pos);
      if (iconPos == -1) break;

      final size = _readUint32(data, iconPos + 4);
      final frameData = data.sublist(iconPos + 8, iconPos + 8 + size);
      
      final curPath = p.join(framesDir, 'frame_$frameNum.cur');
      final pngPath = p.join(framesDir, 'frame_$frameNum.png');
      await File(curPath).writeAsBytes(frameData);
      
      print('Frame $frameNum: Found icon chunk at $iconPos with size $size');
      
      final res = await Process.run('convert', [curPath, 'PNG32:$pngPath']);
      print('  convert frame $frameNum -> png: exitCode ${res.exitCode}');
      if (res.exitCode != 0) {
        print('  stderr: ${res.stderr}');
      }

      for (int s in [24, 32, 48]) {
        final resized = p.join(framesDir, 'res_${s}_frame_$frameNum.png');
        final resR = await Process.run('convert', [pngPath, '-resize', '${s}x$s!', 'PNG32:$resized']);
        print('    resize $s px: exitCode ${resR.exitCode}');
        if (resR.exitCode != 0) {
          print('    stderr: ${resR.stderr}');
        }
      }

      pos = iconPos + 8 + size;
      frameNum++;
    }

    final conf = StringBuffer();
    // Replicating a simple conf for frame 0
    conf.writeln('32 16 16 scratch/debug_frames/res_32_frame_0.png 100');
    
    final confPath = 'scratch/debug_precision.conf';
    await File(confPath).writeAsString(conf.toString());
    
    final xres = await Process.run('xcursorgen', [confPath, 'scratch/debug_precision.cursor']);
    print('xcursorgen exitCode: ${xres.exitCode}');
    if (xres.exitCode != 0) {
      print('xcursorgen stderr: ${xres.stderr}');
    }
  }
}

void main() async {
  await DebugConverter().run();
}
