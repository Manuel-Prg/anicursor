import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ani_to_xcursor/features/home/presentation/pages/home_page.dart';
import 'package:ani_to_xcursor/features/converter/presentation/pages/converter_page.dart';
import 'package:ani_to_xcursor/features/preview/presentation/pages/preview_page.dart';
import 'package:ani_to_xcursor/features/settings/presentation/pages/settings_page.dart';
import 'package:ani_to_xcursor/features/installed_themes/presentation/pages/installed_themes_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/converter',
        name: 'converter',
        builder: (context, state) => const ConverterPage(),
      ),
      GoRoute(
        path: '/preview',
        name: 'preview',
        builder: (context, state) => const PreviewPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/installed-themes',
        name: 'installed-themes',
        builder: (context, state) => const InstalledThemesPage(),
      ),
    ],
  );
});
