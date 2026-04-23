import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/features/converter/data/sources/cursor_mapping_datasource.dart';
import 'package:ani_to_xcursor/features/converter/data/sources/cursor_extraction_datasource.dart';
import 'package:ani_to_xcursor/features/converter/data/sources/cursor_generation_datasource.dart';
import 'package:ani_to_xcursor/features/converter/data/sources/theme_installation_datasource.dart';
import 'package:ani_to_xcursor/features/converter/data/repositories/converter_repository.dart';
import 'package:ani_to_xcursor/features/converter/domain/usecases/convert_theme_usecase.dart';

final mappingDataSourceProvider = Provider<CursorMappingDataSource>((ref) {
  return CursorMappingDataSource();
});

final extractionDataSourceProvider = Provider<CursorExtractionDataSource>((ref) {
  return CursorExtractionDataSource();
});

final generationDataSourceProvider = Provider<CursorGenerationDataSource>((ref) {
  return CursorGenerationDataSource();
});

final installationDataSourceProvider = Provider<ThemeInstallationDataSource>((ref) {
  return ThemeInstallationDataSource();
});

final converterRepositoryProvider = Provider<ConverterRepository>((ref) {
  return ConverterRepository(
    ref.watch(mappingDataSourceProvider),
    ref.watch(extractionDataSourceProvider),
    ref.watch(generationDataSourceProvider),
    ref.watch(installationDataSourceProvider),
  );
});

final convertThemeUsecaseProvider = Provider<ConvertThemeUsecase>((ref) {
  return ConvertThemeUsecase(ref.watch(converterRepositoryProvider));
});