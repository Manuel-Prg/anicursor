// Just in case, though the enum is here

class CursorFrame {
  final String imagePath;
  final int delay;
  final int hotspotX;
  final int hotspotY;
  final int width;
  final int height;

  const CursorFrame({
    required this.imagePath,
    required this.delay,
    required this.hotspotX,
    required this.hotspotY,
    required this.width,
    required this.height,
  });
}

class CursorFile {
  final String windowsName;
  final String linuxName;
  final String aniPath;
  final List<String> aliases;
  final ConversionStatus status;
  final List<CursorFrame> framesData;

  const CursorFile({
    required this.windowsName,
    required this.linuxName,
    required this.aniPath,
    this.aliases = const [],
    this.status = ConversionStatus.pending,
    this.framesData = const [],
  });

  CursorFile copyWith({
    String? windowsName,
    String? linuxName,
    String? aniPath,
    List<String>? aliases,
    ConversionStatus? status,
    List<CursorFrame>? framesData,
  }) {
    return CursorFile(
      windowsName: windowsName ?? this.windowsName,
      linuxName: linuxName ?? this.linuxName,
      aniPath: aniPath ?? this.aniPath,
      aliases: aliases ?? this.aliases,
      status: status ?? this.status,
      framesData: framesData ?? this.framesData,
    );
  }
}

enum ConversionStatus { pending, converting, done, error }
