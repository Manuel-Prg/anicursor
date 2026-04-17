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
}
