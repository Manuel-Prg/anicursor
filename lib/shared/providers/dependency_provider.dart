import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DependencyStatus { checking, ok, missing }

enum PackageManager {
  apt('Apt', 'apt-get', ['install', '-y', 'imagemagick', 'x11-apps'], 'sudo apt install imagemagick x11-apps'),
  dnf('Dnf', 'dnf', ['install', '-y', 'ImageMagick', 'xcursorgen'], 'sudo dnf install ImageMagick xcursorgen'),
  pacman('Pacman', 'pacman', ['-S', '--noconfirm', 'imagemagick', 'xorg-xcursorgen'], 'sudo pacman -S imagemagick xorg-xcursorgen'),
  unknown('Desconocido', '', [], '');

  final String name;
  final String command;
  final List<String> args;
  final String displayCommand;

  const PackageManager(this.name, this.command, this.args, this.displayCommand);
}

class DependencyState {
  final DependencyStatus status;
  final bool isMagickMissing;
  final bool isXcursorMissing;
  final bool isInstalling;
  final PackageManager packageManager;

  const DependencyState({
    this.status = DependencyStatus.checking,
    this.isMagickMissing = false,
    this.isXcursorMissing = false,
    this.isInstalling = false,
    this.packageManager = PackageManager.unknown,
  });

  DependencyState copyWith({
    DependencyStatus? status,
    bool? isMagickMissing,
    bool? isXcursorMissing,
    bool? isInstalling,
    PackageManager? packageManager,
  }) {
    return DependencyState(
      status: status ?? this.status,
      isMagickMissing: isMagickMissing ?? this.isMagickMissing,
      isXcursorMissing: isXcursorMissing ?? this.isXcursorMissing,
      isInstalling: isInstalling ?? this.isInstalling,
      packageManager: packageManager ?? this.packageManager,
    );
  }
}

class DependencyNotifier extends Notifier<DependencyState> {
  @override
  DependencyState build() {
    Future.microtask(checkDependencies);
    return const DependencyState();
  }

  Future<PackageManager> _detectPackageManager() async {
    try {
      final dnfCheck = await Process.run('which', ['dnf']);
      if (dnfCheck.exitCode == 0) return PackageManager.dnf;

      final aptCheck = await Process.run('which', ['apt-get']);
      if (aptCheck.exitCode == 0) return PackageManager.apt;

      final pacmanCheck = await Process.run('which', ['pacman']);
      if (pacmanCheck.exitCode == 0) return PackageManager.pacman;
    } catch (_) {}
    return PackageManager.unknown;
  }

  Future<void> checkDependencies() async {
    state = state.copyWith(status: DependencyStatus.checking);

    final pm = await _detectPackageManager();

    // Revisa existencia de binarios
    final magickRes = await Process.run('which', ['convert']);
    final isMagickMissing = magickRes.exitCode != 0;

    final xcursorRes = await Process.run('which', ['xcursorgen']);
    final isXcursorMissing = xcursorRes.exitCode != 0;

    if (isMagickMissing || isXcursorMissing) {
      state = state.copyWith(
        status: DependencyStatus.missing,
        isMagickMissing: isMagickMissing,
        isXcursorMissing: isXcursorMissing,
        isInstalling: false,
        packageManager: pm,
      );
    } else {
      state = state.copyWith(
        status: DependencyStatus.ok,
        isInstalling: false,
        packageManager: pm,
      );
    }
  }

  /// Retorna false si falla la instalación automática (ej. no está en Debian)
  Future<bool> installDependencies() async {
    if (state.packageManager == PackageManager.unknown) {
      return false;
    }
    state = state.copyWith(isInstalling: true);
    try {
      final res = await Process.run('pkexec', [
        state.packageManager.command,
        ...state.packageManager.args,
      ]);

      if (res.exitCode == 0) {
        await checkDependencies();
        return state.status == DependencyStatus.ok;
      }
    } catch (_) {}

    state = state.copyWith(isInstalling: false);
    return false;
  }
}

final dependencyProvider =
    NotifierProvider<DependencyNotifier, DependencyState>(() {
      return DependencyNotifier();
    });
