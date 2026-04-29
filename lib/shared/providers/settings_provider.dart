import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Debe ser sobreescrito en main()');
});

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

// ─── Defaults ─────────────────────────────────────────────────────────────────

class _Defaults {
  static const List<int> cursorSizes = [24, 32, 48];
  static const int defaultDelay = 100;
  static const String? customOutputDir = null;
  static const bool systemInstall = false;
  static const bool autoApplyCursor = false;
  static const Color primaryColor = Color(0xFFE91E8C);
  static const ThemeMode themeMode = ThemeMode.dark;
}

// ─── Settings model ───────────────────────────────────────────────────────────

class Settings {
  final List<int> cursorSizes;
  final int defaultDelay;
  final String? customOutputDir;
  final bool systemInstall;
  final bool autoApplyCursor;
  final Color primaryColor;
  final ThemeMode themeMode;
  final bool? showedOnboarding;

  const Settings({
    required this.cursorSizes,
    required this.defaultDelay,
    this.customOutputDir,
    required this.systemInstall,
    required this.autoApplyCursor,
    required this.primaryColor,
    required this.themeMode,
    this.showedOnboarding,
  });

  factory Settings.defaults() => const Settings(
    cursorSizes: _Defaults.cursorSizes,
    defaultDelay: _Defaults.defaultDelay,
    customOutputDir: _Defaults.customOutputDir,
    systemInstall: _Defaults.systemInstall,
    autoApplyCursor: _Defaults.autoApplyCursor,
    primaryColor: _Defaults.primaryColor,
    themeMode: _Defaults.themeMode,
    showedOnboarding: false,
  );

  Settings copyWith({
    List<int>? cursorSizes,
    int? defaultDelay,
    String? customOutputDir,
    bool? systemInstall,
    bool? autoApplyCursor,
    Color? primaryColor,
    ThemeMode? themeMode,
    bool? showedOnboarding,
    bool clearCustomOutputDir = false,
  }) {
    return Settings(
      cursorSizes: cursorSizes ?? this.cursorSizes,
      defaultDelay: defaultDelay ?? this.defaultDelay,
      customOutputDir: clearCustomOutputDir
          ? null
          : (customOutputDir ?? this.customOutputDir),
      systemInstall: systemInstall ?? this.systemInstall,
      autoApplyCursor: autoApplyCursor ?? this.autoApplyCursor,
      primaryColor: primaryColor ?? this.primaryColor,
      themeMode: themeMode ?? this.themeMode,
      showedOnboarding: showedOnboarding ?? this.showedOnboarding,
    );
  }

  bool equalTo(Settings other) {
    return cursorSizes.join(',') == other.cursorSizes.join(',') &&
        defaultDelay == other.defaultDelay &&
        customOutputDir == other.customOutputDir &&
        systemInstall == other.systemInstall &&
        autoApplyCursor == other.autoApplyCursor &&
        primaryColor.toARGB32() == other.primaryColor.toARGB32() &&
        themeMode == other.themeMode;
  }
}

// ─── SettingsState (expone current + saved para que Riverpod lo rastree) ──────

class SettingsState {
  final Settings current;
  final Settings saved;

  const SettingsState({required this.current, required this.saved});

  bool get hasUnsavedChanges => !current.equalTo(saved);

  SettingsState copyWith({Settings? current, Settings? saved}) {
    return SettingsState(
      current: current ?? this.current,
      saved: saved ?? this.saved,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class SettingsNotifier extends Notifier<SettingsState> {
  static const _sizesKey = 'cursor_sizes';
  static const _delayKey = 'default_delay';
  static const _outDirKey = 'custom_output_dir';
  static const _systemInstallKey = 'system_install';
  static const _autoApplyKey = 'auto_apply';
  static const _colorKey = 'primary_color';
  static const _themeModeKey = 'theme_mode';
  static const _onboardingKey = 'showed_onboarding';

  late final SharedPreferences _prefs;

  @override
  SettingsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final loaded = _loadSettings();
    return SettingsState(current: loaded, saved: loaded);
  }

  // ─── Acceso directo al settings actual (shortcut) ─────────────────────────

  /// Settings actualmente en pantalla (puede tener cambios sin guardar).
  Settings get settings => state.current;

  // ─── Carga ────────────────────────────────────────────────────────────────

  Settings _loadSettings() {
    final sizesStr = _prefs.getStringList(_sizesKey);
    final sizes = sizesStr != null
        ? sizesStr.map(int.parse).toList()
        : [24, 32, 48];
    final delay = _prefs.getInt(_delayKey) ?? 100;
    final outDir = _prefs.getString(_outDirKey);
    final systemInst = _prefs.getBool(_systemInstallKey) ?? false;
    final autoApply = _prefs.getBool(_autoApplyKey) ?? false;
    final colorVal = _prefs.getInt(_colorKey);
    final color = colorVal != null ? Color(colorVal) : const Color(0xFFE91E8C);
    final modeIdx = _prefs.getInt(_themeModeKey);
    final mode = modeIdx != null ? ThemeMode.values[modeIdx] : ThemeMode.dark;
    final onboarding = _prefs.getBool(_onboardingKey) ?? false;

    return Settings(
      cursorSizes: sizes,
      defaultDelay: delay,
      customOutputDir: outDir,
      systemInstall: systemInst,
      autoApplyCursor: autoApply,
      primaryColor: color,
      themeMode: mode,
      showedOnboarding: onboarding,
    );
  }

  // ─── Persistencia ────────────────────────────────────────────────────────

  Future<void> _persist(Settings s) async {
    await _prefs.setStringList(
      _sizesKey,
      s.cursorSizes.map((e) => e.toString()).toList(),
    );
    await _prefs.setInt(_delayKey, s.defaultDelay);
    if (s.customOutputDir != null) {
      await _prefs.setString(_outDirKey, s.customOutputDir!);
    } else {
      await _prefs.remove(_outDirKey);
    }
    await _prefs.setBool(_systemInstallKey, s.systemInstall);
    await _prefs.setBool(_autoApplyKey, s.autoApplyCursor);
    await _prefs.setInt(_colorKey, s.primaryColor.toARGB32());
    await _prefs.setInt(_themeModeKey, s.themeMode.index);
  }

  // ─── Acciones de los botones del header ──────────────────────────────────

  /// Guarda los cambios actuales en SharedPreferences.
  Future<void> saveSettings() async {
    await _persist(state.current);
    state = state.copyWith(saved: state.current);
  }

  /// Restaura valores por defecto y los guarda.
  Future<void> resetToDefaults() async {
    final defaults = Settings.defaults().copyWith(
      showedOnboarding: state.current.showedOnboarding,
    );
    await _persist(defaults);
    state = SettingsState(current: defaults, saved: defaults);
  }

  /// Descarta los cambios sin guardar.
  void discardChanges() {
    state = state.copyWith(current: state.saved);
  }

  /// Abre la carpeta de configuración con xdg-open.
  Future<void> openConfigFolder() async {
    final dir = await getApplicationSupportDirectory();
    await Process.run('xdg-open', [dir.path]);
  }

  // ─── Actualizaciones del borrador (sin persistir) ─────────────────────────

  void _updateCurrent(Settings updated) {
    state = state.copyWith(current: updated);
  }

  void updateSizes(List<int> sizes) =>
      _updateCurrent(state.current.copyWith(cursorSizes: sizes));

  void updateDefaultDelay(int delay) =>
      _updateCurrent(state.current.copyWith(defaultDelay: delay));

  void updateCustomOutputDir(String? dir) => _updateCurrent(
    state.current.copyWith(
      customOutputDir: dir,
      clearCustomOutputDir: dir == null,
    ),
  );

  void updateSystemInstall(bool install) =>
      _updateCurrent(state.current.copyWith(systemInstall: install));

  void updateAutoApply(bool apply) =>
      _updateCurrent(state.current.copyWith(autoApplyCursor: apply));

  void updatePrimaryColor(Color color) =>
      _updateCurrent(state.current.copyWith(primaryColor: color));

  void updateThemeMode(ThemeMode mode) =>
      _updateCurrent(state.current.copyWith(themeMode: mode));

  void updateShowedOnboarding(bool showed) {
    _updateCurrent(state.current.copyWith(showedOnboarding: showed));
    // El onboarding se persiste inmediatamente (no es preferencia editable por el usuario).
    _prefs.setBool(_onboardingKey, showed);
    state = state.copyWith(saved: state.current);
  }
}
