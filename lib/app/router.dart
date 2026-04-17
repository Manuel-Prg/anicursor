import 'package:go_router/go_router.dart';
import 'package:ani_to_xcursor/features/home/presentation/pages/home_page.dart';
import 'package:ani_to_xcursor/features/converter/presentation/pages/converter_page.dart';
import 'package:ani_to_xcursor/features/preview/presentation/pages/preview_page.dart';
import 'package:ani_to_xcursor/features/settings/presentation/pages/settings_page.dart';

final appRouter = GoRouter(
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
  ],
);
