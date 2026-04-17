import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Debe ser sobreescrito en main()');
});

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(() {
  return SettingsNotifier();
});

class Settings {
  final List<int> cursorSizes;
  final int defaultDelay;
  final String? customOutputDir;
  final bool systemInstall;
  final bool autoApplyCursor;
  final Color primaryColor;
  final ThemeMode themeMode;
  final bool? showedOnboarding;

  Settings({
    required this.cursorSizes,
    required this.defaultDelay,
    this.customOutputDir,
    required this.systemInstall,
    required this.autoApplyCursor,
    required this.primaryColor,
    required this.themeMode,
    this.showedOnboarding,
  });

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
}

class SettingsNotifier extends Notifier<Settings> {
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
  Settings build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadSettings();
  }

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

  void updateSizes(List<int> sizes) {
    state = state.copyWith(cursorSizes: sizes);
    _prefs.setStringList(_sizesKey, sizes.map((e) => e.toString()).toList());
  }

  void updateDefaultDelay(int delay) {
    state = state.copyWith(defaultDelay: delay);
    _prefs.setInt(_delayKey, delay);
  }

  void updateCustomOutputDir(String? dir) {
    state = state.copyWith(
      customOutputDir: dir,
      clearCustomOutputDir: dir == null,
    );
    if (dir != null) {
      _prefs.setString(_outDirKey, dir);
    } else {
      _prefs.remove(_outDirKey);
    }
  }

  void updateSystemInstall(bool install) {
    state = state.copyWith(systemInstall: install);
    _prefs.setBool(_systemInstallKey, install);
  }

  void updateAutoApply(bool apply) {
    state = state.copyWith(autoApplyCursor: apply);
    _prefs.setBool(_autoApplyKey, apply);
  }

  void updatePrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
    _prefs.setInt(_colorKey, color.value);
  }

  void updateThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setInt(_themeModeKey, mode.index);
  }

  void updateShowedOnboarding(bool showed) {
    state = state.copyWith(showedOnboarding: showed);
    _prefs.setBool(_onboardingKey, showed);
  }
}
