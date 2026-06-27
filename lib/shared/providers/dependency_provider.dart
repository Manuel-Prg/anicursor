import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/shared/services/system_info_service.dart';

enum DependencyStatus { checking, ok, missing }

enum PackageManager {
  apt('Apt', 'apt-get', ['install', '-y', 'imagemagick', 'x11-apps'], 'sudo apt install imagemagick x11-apps'),
  dnf('Dnf', 'dnf', ['install', '-y', 'ImageMagick', 'xcursorgen'], 'sudo dnf install ImageMagick xcursorgen'),
  pacman('Pacman', 'pacman', ['-S', '--noconfirm', 'imagemagick', 'xorg-xcursorgen'], 'sudo pacman -S imagemagick xorg-xcursorgen'),
  zypper('Zypper', 'zypper', ['install', '-y', 'ImageMagick', 'xcursorgen'], 'sudo zypper install ImageMagick xcursorgen'),
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
  final String distroName;
  final String recommendedCommand;

  const DependencyState({
    this.status = DependencyStatus.checking,
    this.isMagickMissing = false,
    this.isXcursorMissing = false,
    this.isInstalling = false,
    this.packageManager = PackageManager.unknown,
    this.distroName = 'GNU/Linux',
    this.recommendedCommand = '',
  });

  DependencyState copyWith({
    DependencyStatus? status,
    bool? isMagickMissing,
    bool? isXcursorMissing,
    bool? isInstalling,
    PackageManager? packageManager,
    String? distroName,
    String? recommendedCommand,
  }) {
    return DependencyState(
      status: status ?? this.status,
      isMagickMissing: isMagickMissing ?? this.isMagickMissing,
      isXcursorMissing: isXcursorMissing ?? this.isXcursorMissing,
      isInstalling: isInstalling ?? this.isInstalling,
      packageManager: packageManager ?? this.packageManager,
      distroName: distroName ?? this.distroName,
      recommendedCommand: recommendedCommand ?? this.recommendedCommand,
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

      final zypperCheck = await Process.run('which', ['zypper']);
      if (zypperCheck.exitCode == 0) return PackageManager.zypper;
    } catch (_) {}
    return PackageManager.unknown;
  }

  String _getRecommendedCommand(LinuxDistro distro, PackageManager pm) {
    if (distro.isLike('ubuntu') || distro.isLike('debian')) {
      return 'sudo apt update && sudo apt install imagemagick x11-apps';
    } else if (distro.isLike('arch')) {
      return 'sudo pacman -S imagemagick xorg-xcursorgen';
    } else if (distro.isLike('fedora') || distro.isLike('rhel') || distro.isLike('centos')) {
      return 'sudo dnf install ImageMagick xcursorgen';
    } else if (distro.isLike('opensuse') || distro.isLike('suse')) {
      return 'sudo zypper install ImageMagick xcursorgen';
    } else if (distro.isLike('nixos')) {
      return 'nix-shell -p imagemagick xorg.xcursorgen';
    } else if (distro.isLike('gentoo')) {
      return 'sudo emerge media-gfx/imagemagick x11-apps/xcursorgen';
    } else if (distro.isLike('void')) {
      return 'sudo xbps-install -S imagemagick xcursorgen';
    } else if (distro.isLike('alpine')) {
      return 'apk add imagemagick xcursorgen';
    } else if (distro.isLike('solus')) {
      return 'sudo eopkg install imagemagick xcursorgen';
    }

    // Fallback en base al package manager binario detectado
    if (pm == PackageManager.apt) {
      return 'sudo apt update && sudo apt install imagemagick x11-apps';
    } else if (pm == PackageManager.dnf) {
      return 'sudo dnf install ImageMagick xcursorgen';
    } else if (pm == PackageManager.pacman) {
      return 'sudo pacman -S imagemagick xorg-xcursorgen';
    } else if (pm == PackageManager.zypper) {
      return 'sudo zypper install ImageMagick xcursorgen';
    }

    return 'Instalar imagemagick y xcursorgen usando el gestor de paquetes de tu sistema';
  }

  Future<void> checkDependencies() async {
    state = state.copyWith(status: DependencyStatus.checking);

    final pm = await _detectPackageManager();
    final distro = await SystemInfoService.getLinuxDistro();
    final recommendedCommand = _getRecommendedCommand(distro, pm);

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
        distroName: distro.prettyName,
        recommendedCommand: recommendedCommand,
      );
    } else {
      state = state.copyWith(
        status: DependencyStatus.ok,
        isInstalling: false,
        packageManager: pm,
        distroName: distro.prettyName,
        recommendedCommand: recommendedCommand,
      );
    }
  }

  /// Retorna false si falla la instalación automática
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
