import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/features/installed_themes/domain/models/installed_theme.dart';
import 'package:ani_to_xcursor/features/installed_themes/presentation/installed_themes_provider.dart';
import 'package:ani_to_xcursor/features/home/presentation/widgets/animated_theme_card.dart';

class InstalledThemesPage extends ConsumerStatefulWidget {
  const InstalledThemesPage({super.key});

  @override
  ConsumerState<InstalledThemesPage> createState() =>
      _InstalledThemesPageState();
}

class _InstalledThemesPageState extends ConsumerState<InstalledThemesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(installedThemesProvider);
    final themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Temas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(installedThemesProvider.notifier).refresh(),
            tooltip: 'Actualizar lista',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar tema...',
              leading: const Icon(
                Icons.search,
                size: 20,
                color: Colors.white38,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
              backgroundColor: WidgetStatePropertyAll(
                themeData.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
              ),
              elevation: const WidgetStatePropertyAll(0),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),

          Expanded(
            child: themeState.when(
              data: (themes) {
                final filteredThemes = themes.where((t) {
                  final query = _searchQuery.toLowerCase();
                  return t.name.toLowerCase().contains(query) ||
                      (t.displayName?.toLowerCase().contains(query) ?? false);
                }).toList();

                if (filteredThemes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mouse_outlined,
                          size: 64,
                          color: themeData.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No se detectaron temas instalados'
                              : 'No se encontraron temas que coincidan con "$_searchQuery"',
                          style: TextStyle(
                            color: themeData.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisExtent: 200,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: filteredThemes.length,
                  itemBuilder: (context, index) {
                    final item = filteredThemes[index];
                    return AnimatedThemeCard(
                      theme: item,
                      onApply: () => _applyTheme(context, ref, item),
                      onDelete: () => _confirmDelete(context, ref, item),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTheme(
    BuildContext context,
    WidgetRef ref,
    InstalledTheme theme,
  ) async {
    final success = await ref
        .read(installedThemesProvider.notifier)
        .apply(theme);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                success
                    ? 'Tema ${theme.displayName} aplicado con éxito'
                    : 'Fallo al aplicar el tema',
              ),
            ],
          ),
          backgroundColor: success
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    InstalledTheme theme,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar tema?'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${theme.displayName}" de forma permanente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(installedThemesProvider.notifier).delete(theme);
    }
  }
}
