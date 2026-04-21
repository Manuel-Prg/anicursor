import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/app/router.dart';
import 'package:ani_to_xcursor/shared/theme/app_theme.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).current;
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AniCursor',
      theme: AppTheme.light(primaryColor: settings.primaryColor),
      darkTheme: AppTheme.dark(primaryColor: settings.primaryColor),
      themeMode: settings.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
