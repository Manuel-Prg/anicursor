import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class ThemeExportService {
  Future<void> exportZip(String themeName, String outputDir) async {
    final zipPath = await FilePicker.saveFile(
      dialogTitle: 'Exportar tema como ZIP',
      fileName: '$themeName.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (zipPath == null) return;

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    _addThemeFiles(encoder, outputDir);
    encoder.close();
  }

  Future<void> exportTarGz(String themeName, String outputDir) async {
    final tarPath = await FilePicker.saveFile(
      dialogTitle: 'Exportar tema como TAR.GZ',
      fileName: '$themeName.tar.gz',
      type: FileType.custom,
      allowedExtensions: ['tar.gz', 'gz'],
    );

    if (tarPath == null) return;

    final tmpTar = File(p.join(Directory.systemTemp.path, '$themeName.tar'));
    final encoder = TarFileEncoder();
    encoder.create(tmpTar.path);

    _addThemeFiles(encoder, outputDir);
    encoder.close();

    final tarBytes = await tmpTar.readAsBytes();
    final gzipBytes = GZipEncoder().encode(tarBytes);
    if (gzipBytes != null) {
      await File(tarPath).writeAsBytes(gzipBytes);
    }

    if (await tmpTar.exists()) await tmpTar.delete();
  }

  void _addThemeFiles(dynamic encoder, String outputDir) {
    final cursorsDir = p.join(outputDir, 'cursors');
    final indexTheme = p.join(outputDir, 'index.theme');
    final cursorTheme = p.join(outputDir, 'cursor.theme');

    if (Directory(cursorsDir).existsSync()) {
      encoder.addDirectory(Directory(cursorsDir));
    }
    if (File(indexTheme).existsSync()) {
      encoder.addFile(File(indexTheme));
    }
    if (File(cursorTheme).existsSync()) {
      encoder.addFile(File(cursorTheme));
    }
  }
}