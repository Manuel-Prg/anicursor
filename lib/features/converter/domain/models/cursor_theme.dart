import 'package:ani_to_xcursor/features/converter/domain/models/cursor_file.dart';

class CursorTheme {
  final String name;
  final String inputDir;
  final String outputDir;
  final List<CursorFile> cursors;
  final ThemeStatus status;
  final int progress;

  const CursorTheme({
    required this.name,
    required this.inputDir,
    required this.outputDir,
    this.cursors = const [],
    this.status = ThemeStatus.idle,
    this.progress = 0,
  });

  CursorTheme copyWith({
    String? name,
    String? inputDir,
    String? outputDir,
    List<CursorFile>? cursors,
    ThemeStatus? status,
    int? progress,
  }) {
    return CursorTheme(
      name: name ?? this.name,
      inputDir: inputDir ?? this.inputDir,
      outputDir: outputDir ?? this.outputDir,
      cursors: cursors ?? this.cursors,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  int get total => cursors.length;
  int get done => cursors.where((c) => c.status == ConversionStatus.done).length;
  int get errors => cursors.where((c) => c.status == ConversionStatus.error).length;
}

enum ThemeStatus {
  idle,
  scanning,
  converting,
  done,
  error,
}