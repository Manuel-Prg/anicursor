import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/features/installed_themes/data/sources/installed_themes_scanner.dart';
import 'package:ani_to_xcursor/features/installed_themes/domain/models/installed_theme.dart';
import 'package:ani_to_xcursor/features/converter/presentation/datasources_provider.dart';
import 'package:ani_to_xcursor/shared/services/logger_service.dart';

final installedThemesScannerProvider = Provider(
  (ref) => InstalledThemesScanner(),
);

final installedThemesProvider =
    NotifierProvider<InstalledThemesNotifier, AsyncValue<List<InstalledTheme>>>(
      () {
        return InstalledThemesNotifier();
      },
    );

class InstalledThemesNotifier
    extends Notifier<AsyncValue<List<InstalledTheme>>> {
  late final InstalledThemesScanner _scanner;

  @override
  AsyncValue<List<InstalledTheme>> build() {
    _scanner = ref.watch(installedThemesScannerProvider);
    // Iniciamos la carga asíncrona pero devolvemos loading inicial
    _init();
    return const AsyncValue.loading();
  }

  Future<void> _init() async {
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final themes = await _scanner.scan();
      state = AsyncValue.data(themes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> apply(InstalledTheme theme) async {
    try {
      final installationSource = ref.read(installationDataSourceProvider);
      await installationSource.applyTheme(theme.name);
      await LoggerService.log(
        'Tema ${theme.displayName} aplicado desde el gestor',
      );
      return true;
    } catch (e) {
      await LoggerService.log(
        'Error al aplicar tema ${theme.name}: $e',
        severity: LogSeverity.error,
      );
      return false;
    }
  }

  Future<bool> delete(InstalledTheme theme) async {
    try {
      final success = await _scanner.deleteTheme(theme.path);
      if (success) {
        await LoggerService.log(
          'Tema ${theme.displayName} eliminado del sistema',
        );
        await refresh();
      }
      return success;
    } catch (e) {
      await LoggerService.log(
        'Error al eliminar tema ${theme.name}: $e',
        severity: LogSeverity.error,
      );
      return false;
    }
  }
}
