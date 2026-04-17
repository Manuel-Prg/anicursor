import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DependencyStatus { checking, ok, missing }

class DependencyState {
  final DependencyStatus status;
  final bool isMagickMissing;
  final bool isXcursorMissing;
  final bool isInstalling;

  const DependencyState({
    this.status = DependencyStatus.checking,
    this.isMagickMissing = false,
    this.isXcursorMissing = false,
    this.isInstalling = false,
  });

  DependencyState copyWith({
    DependencyStatus? status,
    bool? isMagickMissing,
    bool? isXcursorMissing,
    bool? isInstalling,
  }) {
    return DependencyState(
      status: status ?? this.status,
      isMagickMissing: isMagickMissing ?? this.isMagickMissing,
      isXcursorMissing: isXcursorMissing ?? this.isXcursorMissing,
      isInstalling: isInstalling ?? this.isInstalling,
    );
  }
}

class DependencyNotifier extends Notifier<DependencyState> {
  @override
  DependencyState build() {
    Future.microtask(checkDependencies);
    return const DependencyState();
  }

  Future<void> checkDependencies() async {
    state = state.copyWith(status: DependencyStatus.checking);

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
      );
    } else {
      state = state.copyWith(status: DependencyStatus.ok, isInstalling: false);
    }
  }

  /// Retorna false si falla la instalación automática (ej. no está en Debian)
  Future<bool> installDependencies() async {
    state = state.copyWith(isInstalling: true);
    try {
      final res = await Process.run('pkexec', [
        'apt-get',
        'install',
        '-y',
        'imagemagick',
        'x11-apps',
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
