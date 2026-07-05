import 'package:flutter/material.dart';

import '../state/calculator_controller.dart';

/// Settings for how results are displayed and the app's appearance.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, _) {
          return ListView(
            children: <Widget>[
              const _SectionHeader('Results'),
              SwitchListTile(
                secondary: const Icon(Icons.tune),
                title: const Text('Show advanced (D and M\')'),
                subtitle: const Text('Dihedral angle and miter complement'),
                value: controller.showAdvanced,
                onChanged: controller.setShowAdvanced,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.straighten),
                title: const Text('Exact precision'),
                subtitle: Text(
                  controller.exactPrecision
                      ? 'Showing 4 decimal places'
                      : 'Rounded to nearest 0.5°',
                ),
                value: controller.exactPrecision,
                onChanged: controller.setExactPrecision,
              ),
              const Divider(),
              const _SectionHeader('Appearance'),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Theme'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SegmentedButton<ThemeMode>(
                    segments: const <ButtonSegment<ThemeMode>>[
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: <ThemeMode>{controller.themeMode},
                    onSelectionChanged: (Set<ThemeMode> selection) =>
                        controller.setThemeMode(selection.first),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.labelLarge
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}
