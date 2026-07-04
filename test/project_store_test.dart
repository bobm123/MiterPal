import 'package:flutter_test/flutter_test.dart';
import 'package:miterpal/models/compound_miter.dart';
import 'package:miterpal/models/saved_project.dart';
import 'package:miterpal/services/project_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('empty store returns an empty list', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProjectStore store = ProjectStore();
    expect(await store.load(), isEmpty);
  });

  test('round-trips saved projects through storage', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProjectStore store = ProjectStore();

    await store.save(const <SavedProject>[
      SavedProject(name: 'Hex planter', n: 6, sideAngle: 15),
      SavedProject(name: 'Inward hopper', n: 8, sideAngle: -12.5),
    ]);

    final List<SavedProject> loaded = await store.load();
    expect(loaded.length, 2);
    expect(loaded[0].name, 'Hex planter');
    expect(loaded[0].n, 6);
    expect(loaded[0].sideAngle, 15);
    expect(loaded[1].name, 'Inward hopper');
    expect(loaded[1].sideAngle, -12.5);
  });

  test('save replaces the previous contents', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProjectStore store = ProjectStore();

    await store.save(const <SavedProject>[
      SavedProject(name: 'First', n: 4, sideAngle: 0),
    ]);
    await store.save(const <SavedProject>[
      SavedProject(name: 'Second', n: 5, sideAngle: 10),
    ]);

    final List<SavedProject> loaded = await store.load();
    expect(loaded.length, 1);
    expect(loaded.single.name, 'Second');
  });

  test('joint mode survives a save/load round trip', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProjectStore store = ProjectStore();

    await store.save(const <SavedProject>[
      SavedProject(name: 'Frame', n: 4, sideAngle: 0,
          mode: JointMode.pictureFrame),
      SavedProject(name: 'Hopper', n: 6, sideAngle: -12,
          mode: JointMode.buttJointBox),
    ]);

    final List<SavedProject> loaded = await store.load();
    expect(loaded[0].mode, JointMode.pictureFrame);
    expect(loaded[1].mode, JointMode.buttJointBox);
  });

  test('legacy JSON without a mode defaults to mitered box', () {
    final SavedProject p = SavedProject.fromJson(<String, dynamic>{
      'name': 'Old project',
      'n': 5,
      'sideAngle': 12.5,
    });
    expect(p.mode, JointMode.miteredBox);
  });
}
