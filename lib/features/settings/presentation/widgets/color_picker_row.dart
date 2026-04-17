import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

const List<Color> _availableColors = [
  Color(0xFFE91E8C), // Pink
  Color(0xFF3F51B5), // Indigo
  Color(0xFF4CAF50), // Green
  Color(0xFFFF9800), // Orange
  Color(0xFF9C27B0), // Purple
  Color(0xFF00BCD4), // Cyan
];

class ColorPickerRow extends ConsumerWidget {
  const ColorPickerRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _availableColors.map((color) {
        final isSelected = settings.primaryColor.toARGB32() == color.toARGB32();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () => notifier.updatePrimaryColor(color),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
