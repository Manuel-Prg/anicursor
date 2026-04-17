import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/conversion_section.dart';
import '../widgets/installation_section.dart';
import '../widgets/sandboxed_environments_section.dart';
import '../widgets/appearance_section.dart';
import '../widgets/maintenance_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          ConversionSection(),
          SizedBox(height: 32),
          InstallationSection(),
          SizedBox(height: 32),
          SandboxedEnvironmentsSection(),
          SizedBox(height: 32),
          AppearanceSection(),
          SizedBox(height: 32),
          MaintenanceSection(),
        ],
      ),
    );
  }
}
