import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

import '../sources/cursor_mapping_datasource.dart';
import '../sources/cursor_extraction_datasource.dart';
import '../sources/cursor_generation_datasource.dart';
import '../sources/theme_installation_datasource.dart';

class ConverterRepository {
  final CursorMappingDataSource _mappingDataSource;
  final CursorExtractionDataSource _extractionDataSource;
  final CursorGenerationDataSource _generationDataSource;
  final ThemeInstallationDataSource _installationDataSource;

  ConverterRepository(
    this._mappingDataSource,
    this._extractionDataSource,
    this._generationDataSource,
    this._installationDataSource,
  );

  /// Escanea la carpeta y retorna los cursores encontrados
  List<CursorFile> scanDirectory(String dirPath) {
    return _mappingDataSource.scanDirectory(dirPath);
  }

  /// Extrae frames de un archivo .ani o .cur
  Future<List<CursorFrame>> extractFrames(
    String fileOrAniPath,
    String framesDir,
    String name,
    int defaultDelay,
  ) {
    return _extractionDataSource.extractFrames(
      fileOrAniPath,
      framesDir,
      name,
      defaultDelay,
    );
  }

  /// Extrae solo el primer frame para vista previa rápida
  Future<String?> extractPreview(String fileOrAniPath, String name) {
    return _extractionDataSource.extractPreview(fileOrAniPath, name);
  }

  /// Genera el cursor Linux desde los frames
  Future<bool> generateCursor(
    List<CursorFrame> frames,
    String outputPath,
    List<int> sizes,
  ) {
    return _generationDataSource.generateCursor(frames, outputPath, sizes);
  }

  /// Crea symlinks para los aliases
  Future<void> createAliases(
    String cursorsDir,
    String linuxName,
    List<String> aliases,
  ) {
    return _generationDataSource.createAliases(cursorsDir, linuxName, aliases);
  }

  /// Crea los archivos de metadatos del tema
  Future<void> createThemeFile(String themeDir, String themeName) {
    return _installationDataSource.createThemeFile(themeDir, themeName);
  }

  /// Instala el tema en ~/.local/share/icons
  Future<bool> installTheme(
    String themeDir,
    String themeName,
    Settings settings,
  ) {
    return _installationDataSource.installTheme(themeDir, themeName, settings);
  }
}
