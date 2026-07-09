import 'compound_miter.dart';

/// A saved calculation: a name plus the inputs needed to reproduce it.
class SavedProject {
  const SavedProject({
    required this.name,
    required this.n,
    required this.sideAngle,
    this.mode = JointMode.miteredBox,
    this.bitAngle = 30.0,
  });

  final String name;
  final int n;
  final double sideAngle;
  final JointMode mode;

  /// Cutter angle for [JointMode.fixedBevelBit]; unused by other modes.
  final double bitAngle;

  Map<String, dynamic> toJson() => {
        'name': name,
        'n': n,
        'sideAngle': sideAngle,
        'mode': mode.name,
        'bitAngle': bitAngle,
      };

  factory SavedProject.fromJson(Map<String, dynamic> json) => SavedProject(
        name: json['name'] as String,
        n: json['n'] as int,
        sideAngle: (json['sideAngle'] as num).toDouble(),
        // Projects saved before joint modes existed have no 'mode' key;
        // treat them as the original mitered box.
        mode: JointMode.values.asNameMap()[json['mode'] as String?] ??
            JointMode.miteredBox,
        bitAngle: (json['bitAngle'] as num?)?.toDouble() ?? 30.0,
      );
}
