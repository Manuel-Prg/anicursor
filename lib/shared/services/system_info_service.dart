import 'dart:io';

enum DesktopEnvironment { gnome, kde, xfce, mate, cinnamon, other }

enum SessionType { x11, wayland, unknown }

class SystemInfoService {
  static DesktopEnvironment get desktopEnvironment {
    final desktop =
        Platform.environment['XDG_CURRENT_DESKTOP']?.toLowerCase() ?? '';
    if (desktop.contains('gnome')) return DesktopEnvironment.gnome;
    if (desktop.contains('kde')) return DesktopEnvironment.kde;
    if (desktop.contains('xfce')) return DesktopEnvironment.xfce;
    if (desktop.contains('mate')) return DesktopEnvironment.mate;
    if (desktop.contains('cinnamon')) return DesktopEnvironment.cinnamon;
    return DesktopEnvironment.other;
  }

  static SessionType get sessionType {
    final session =
        Platform.environment['XDG_SESSION_TYPE']?.toLowerCase() ?? '';
    if (session == 'x11') return SessionType.x11;
    if (session == 'wayland') return SessionType.wayland;
    return SessionType.unknown;
  }

  static String get desktopName {
    return Platform.environment['XDG_CURRENT_DESKTOP'] ?? 'Unknown';
  }

  static Future<LinuxDistro> getLinuxDistro() {
    return LinuxDistro.detect();
  }
}

class LinuxDistro {
  final String id;
  final String name;
  final String prettyName;
  final List<String> idLike;

  const LinuxDistro({
    required this.id,
    required this.name,
    required this.prettyName,
    required this.idLike,
  });

  factory LinuxDistro.unknown() {
    return const LinuxDistro(
      id: 'unknown',
      name: 'Desconocido',
      prettyName: 'GNU/Linux',
      idLike: [],
    );
  }

  static Future<LinuxDistro> detect() async {
    try {
      File file = File('/etc/os-release');
      if (!await file.exists()) {
        file = File('/usr/lib/os-release');
        if (!await file.exists()) {
          return LinuxDistro.unknown();
        }
      }

      final lines = await file.readAsLines();
      String id = 'unknown';
      String name = 'Desconocido';
      String prettyName = 'GNU/Linux';
      List<String> idLike = [];

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;

        final parts = line.split('=');
        if (parts.length < 2) continue;

        final key = parts[0].trim();
        String value = parts.sublist(1).join('=').trim();

        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }

        switch (key) {
          case 'ID':
            id = value.toLowerCase();
            break;
          case 'NAME':
            name = value;
            break;
          case 'PRETTY_NAME':
            prettyName = value;
            break;
          case 'ID_LIKE':
            idLike = value
                .toLowerCase()
                .split(' ')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            break;
        }
      }

      return LinuxDistro(
        id: id,
        name: name,
        prettyName: prettyName,
        idLike: idLike,
      );
    } catch (_) {
      return LinuxDistro.unknown();
    }
  }

  bool isLike(String distroId) {
    final lowerId = distroId.toLowerCase();
    return id == lowerId || idLike.contains(lowerId);
  }
}
