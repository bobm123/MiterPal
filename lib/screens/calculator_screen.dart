import 'package:flutter/material.dart';

import '../models/compound_miter.dart';
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
      text: switch (controller.mode) {
        JointMode.pictureFrame => '${controller.n}-side frame',
        JointMode.fixedBevelBit =>
          '${controller.n}-side, ${controller.bitAngle}° bit',
        _ => '${controller.n}-side @ ${controller.sideAngle}°',
      },
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
          final MiterResult result = controller.result;
          final bool frame = controller.mode == JointMode.pictureFrame;
          final bool bitMode = controller.mode == JointMode.fixedBevelBit;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _ModeSelector(
                      value: controller.mode,
                      onChanged: controller.setMode,
                    ),
                    const SizedBox(height: 8),
                    SidesStepper(
                      value: controller.n,
                      minValue: CalculatorController.minSides,
                      onChanged: controller.setN,
                    ),
                    if (bitMode) ...<Widget>[
                      const SizedBox(height: 8),
                      SideAngleField(
                        label: 'Bit angle (B)',
                        hint: 'Bevel cutter angle from vertical',
                        value: controller.bitAngle,
                        onChanged: controller.setBitAngle,
                      ),
                    ] else if (!frame) ...<Widget>[
                      const SizedBox(height: 8),
                      SideAngleField(
                        value: controller.sideAngle,
                        onChanged: controller.setSideAngle,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ResultDisplay(
                      result: result,
                      mode: controller.mode,
                      exact: controller.exactPrecision,
                      showAdvanced: controller.showAdvanced,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: PolygonDiagram(
                          n: controller.n,
                          // In bit mode the lean is an output, so draw the
                          // computed value; otherwise draw the input.
                          sideAngle: frame ? 0 : result.sideAngle,
                          showLean: !frame,
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

/// Dropdown for the joint mode, styled to match the input cards.
///
/// Uses a controlled [DropdownButton] (not [DropdownMenu]) so the shown value
/// always tracks the controller — e.g. when a saved project changes the mode.
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.value, required this.onChanged});

  final JointMode value;
  final ValueChanged<JointMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('Joint type', style: theme.textTheme.labelLarge),
            ),
            DropdownButton<JointMode>(
              value: value,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
      