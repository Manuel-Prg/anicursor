class InstalledTheme {
  final String name;
  final String path;
  final int cursorCount;
  final int totalSize;
  final bool isSystem;
  final String? displayName;
  final String? previewPath;

  const InstalledTheme({
    required this.name,
    required this.path,
    required this.cursorCount,
    required this.totalSize,
    required this.isSystem,
    this.displayName,
    this.previewPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstalledTheme &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          cursorCount == other.cursorCount &&
          totalSize == other.totalSize;

  @override
  int get hashCode => name.hashCode ^ cursorCount.hashCode ^ totalSize.hashCode;

  InstalledTheme copyWith({
    String? name,
    String? path,
    int? cursorCount,
    int? totalSize,
    bool? isSystem,
    String? displayName,
    String? previewPath,
  }) {
    return InstalledTheme(
      name: name ?? this.name,
      path: path ?? this.path,
      cursorCount: cursorCount ?? this.cursorCount,
      totalSize: totalSize ?? this.totalSize,
      isSystem: isSystem ?? this.isSystem,
      displayName: displayName ?? this.displayName,
      previewPath: previewPath ?? this.previewPath,
    );
  }
}
