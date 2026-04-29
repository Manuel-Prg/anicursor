import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ani_to_xcursor/features/converter/presentation/converter_provider.dart';
import 'package:ani_to_xcursor/shared/providers/settings_provider.dart';
import 'package:ani_to_xcursor/features/home/presentation/widgets/onboarding_dialog.dart';

class HomeState {
  const HomeState();
}

class HomeActions {
  final Ref _ref;

  HomeActions(this._ref);

  Future<void> selectFolderAndConvert(BuildContext context) async {
    final result = await FilePicker.getDirectoryPath();
    if (result != null) {
      _ref.read(cursorThemeProvider.notifier).scanDirectory(result);
      if (context.mounted) context.push('/converter');
    }
  }

  void handleOnboarding(BuildContext context) {
    final settings = _ref.read(settingsProvider).current;
    if (settings.showedOnboarding == true) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted &&
          _ref.read(settingsProvider).current.showedOnboarding != true) {
        _ref.read(settingsProvider.notifier).updateShowedOnboarding(true);
        OnboardingDialog.show(context);
      }
    });
  }
}

final homeStateProvider = Provider<HomeState>((ref) {
  return const HomeState();
});

final homeActionsProvider = Provider<HomeActions>((ref) {
  return HomeActions(ref);
});
