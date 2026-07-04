import 'package:flutter/material.dart';

import '../models/saved_project.dart';
import '../state/calculator_controller.dart';
import '../util/formatting.dart';

/// Lists saved calculations. Tap one to load it back into the calculator.
class SavedProjectsScreen extends StatelessWidget {
  const SavedProjectsScreen({super.key, required this.controller});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved projects')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, _) {
          final List<SavedProject> saved = controller.saved;
          if (saved.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No saved projects yet.\nSave one from the calculator with '
                  'the bookmark button.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: saved.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int i) {
              final SavedProject p = saved[i];
              return ListTile(
                leading: const Icon(Icons.crop_square),
                title: Text(p.name),
                subtitle: Text(
                  '${p.n} sides · S = ${formatAngle(p.sideAngle, exact: true)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => controller.deleteProject(p),
                ),
                onTap: () {
                  controller.loadProject(p);
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      ),
    );
  }
}
