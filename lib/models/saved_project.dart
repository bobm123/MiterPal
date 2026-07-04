/// A saved calculation: a name plus the two inputs needed to reproduce it.
class SavedProject {
  const SavedProject({
    required this.name,
    required this.n,
    required this.sideAngle,
  });

  final String name;
  final int n;
  final double sideAngle;

  Map<String, dynamic> toJson() => {
        'name': name,
        'n': n,
        'sideAngle': sideAngle,
      };

  factory SavedProject.fromJson(Map<String, dynamic> json) => SavedProject(
        name: json['name'] as String,
        n: json['n'] as int,
        sideAngle: (json['sideAngle'] as num).toDouble(),
      );
}
