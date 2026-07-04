import 'compound_miter.dart';

/// A saved calculation: a name plus the inputs needed to reproduce it.
class SavedProject {
  const SavedProject({
    required this.name,
    required this.n,
    required this.sideAngle,
    this.mode = JointMode.miteredBox,
  });

  final String name;
  final int n;
  final double sideAngle;
  final JointMode mode;

  Map<String, dynamic> toJson() => {
        'name': name,
        'n': n,
        'sideAngle': sideAngle,
        'mode': mode.name,
      };

  factory SavedProject.fromJson(Map<String, dynamic> json) => SavedProject(
        name: json['name'] as String,
        n: json['n'] as int,
        sideAngle: (json['sideAngle'] as num).toDouble(),
        // Projects saved before joint modes existed have no 'mode' key;
        // treat them as the original mitered box.
        mode: JointMode.values.asNameMap()[json['mode'] as String?] ??
            JointMode.miteredBox,
      );
}
