import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/features/installed_themes/domain/models/installed_theme.dart';
import 'package:ani_to_xcursor/features/installed_themes/presentation/installed_themes_provider.dart';
import 'package:ani_to_xcursor/features/home/presentation/widgets/animated_theme_card.dart';
import 'package:ani_to_xcursor/shared/utils/snackbar_utils.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar tema...',
              hintStyle: WidgetStatePropertyAll(
                themeData.textTheme.bodyLarge?.copyWith(
                  color: themeData.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
              leading: Icon(
                Icons.search_rounded,
                size: 22,
                color: themeData.colorScheme.primary.withValues(alpha: 0.5),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
              backgroundColor: WidgetStatePropertyAll(
                themeData.colorScheme.surfaceContainer.withValues(alpha: 0.5),
              ),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: themeData.colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

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
      SnackBarUtils.show(
        context,
        success
            ? 'Tema ${theme.displayName} aplicado con éxito'
            : 'Fallo al aplicar el tema',
        isError: !success,
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
