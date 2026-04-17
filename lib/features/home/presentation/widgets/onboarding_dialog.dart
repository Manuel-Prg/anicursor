import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';

class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const OnboardingDialog(),
    );
  }

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Bienvenido a AniCursor',
      description: 'Convierte tus cursores favoritos de Windows (.ani) a Linux en segundos con total fidelidad.',
      icon: Icons.mouse_rounded,
      color: Colors.pinkAccent,
    ),
    OnboardingStep(
      title: 'Arrastra y Suelta',
      description: 'Solo tienes que arrastrar una carpeta con archivos .ani a la pantalla principal para empezar.',
      icon: Icons.auto_fix_high_rounded,
      color: Colors.blueAccent,
    ),
    OnboardingStep(
      title: 'Gestión Inteligente',
      description: 'Detección automática de cursores instalados, aplicación directa en GNOME/KDE y exportación compartible.',
      icon: Icons.layers_outlined,
      color: Colors.orangeAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: step.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step.icon, size: 80, color: step.color),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step.description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white60),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? theme.colorScheme.primary : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _finish(context),
                  child: const Text('Omitir'),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    return FilledButton(
                      onPressed: () {
                        if (_currentPage < _steps.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finish(context, ref);
                        }
                      },
                      child: Text(_currentPage < _steps.length - 1 ? 'Siguiente' : 'Comenzar'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _finish(BuildContext context, [WidgetRef? ref]) {
    Navigator.pop(context);
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingStep({required this.title, required this.description, required this.icon, required this.color});
}
