import 'package:flutter/material.dart';

import '../state/calculator_controller.dart';
import '../widgets/cut_checklist.dart';
import '../widgets/input_controls.dart';
import '../widgets/polygon_diagram.dart';
import '../widgets/result_display.dart';
import 'saved_projects_screen.dart';
import 'settings_screen.dart';

/// The main screen: inputs at the top, live results and diagram below.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key, required this.controller});

  final CalculatorController controller;

  Future<void> _save(BuildContext context) async {
    final TextEditingController nameController = TextEditingController(
      text: '${controller.n}-side @ ${controller.sideAngle}°',
    );
    final String? name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Save project'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (String v) => Navigator.of(context).pop(v),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      controller.saveProject(name.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved "$name"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MiterPal'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Save project',
            onPressed: () => _save(context),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            tooltip: 'Saved projects',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SavedProjectsScreen(controller: controller),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SettingsScreen(controller: controller),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SidesStepper(
                      value: controller.n,
                      minValue: CalculatorController.minSides,
                      onChanged: controller.setN,
                    ),
                    const SizedBox(height: 8),
                    SideAngleField(
                      value: controller.sideAngle,
                      onChanged: controller.setSideAngle,
                    ),
                    const SizedBox(height: 16),
                    ResultDisplay(
                      result: controller.result,
                      exact: controller.exactPrecision,
                      showAdvanced: controller.showAdvanced,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: PolygonDiagram(
                          n: controller.n,
                          sideAngle: controller.sideAngle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const CutChecklist(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

