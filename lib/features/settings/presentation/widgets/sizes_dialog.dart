import 'package:flutter/material.dart';

class SizesDialog extends StatefulWidget {
  final List<int> initialSizes;
  final ValueChanged<List<int>> onSaved;

  const SizesDialog({super.key, required this.initialSizes, required this.onSaved});

  @override
  State<SizesDialog> createState() => _SizesDialogState();
}

class _SizesDialogState extends State<SizesDialog> {
  late List<int> _sizes;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sizes = widget.initialSizes;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar Tamaños'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            children: _sizes.map((s) {
              return Chip(
                label: Text('${s}px'),
                onDeleted: () {
                  if (_sizes.length > 1) {
                    setState(() => _sizes.remove(s));
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Añadir tamaño',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final val = int.tryParse(_controller.text);
                  if (val != null && val > 0 && !_sizes.contains(val)) {
                    setState(() => _sizes.add(val));
                    _sizes.sort();
                    _controller.clear();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSaved(_sizes);
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
