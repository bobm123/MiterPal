import 'dart:math' as math;

/// Direction the sides of the box lean, derived from the sign of the side angle.
enum LeanDirection {
  /// Top wider than the bottom (S > 0) — bowl, planter.
  outward,

  /// Top narrower than the bottom (S < 0) — truncated pyramid, hopper.
  inward,

  /// Sides perfectly upright (S == 0).
  vertical,
}

/// The result of a compound-miter calculation. All angles are in degrees.
///
/// Mirrors `scripts/compound_miter.py` / `docs/compound-miter-angles.md`.
class MiterResult {
  const MiterResult({
    required this.n,
    required this.sideAngle,
    required this.dihedral,
    required this.bladeTilt,
    required this.miter,
    required this.miterComplement,
    required this.lean,
  });

  /// Number of sides.
  final int n;

  /// Side angle S, measured from vertical.
  final double sideAngle;

  /// Dihedral angle D between adjacent sides.
  final double dihedral;

  /// Blade tilt / bevel B, measured from vertical.
  final double bladeTilt;

  /// Miter angle M on the saw table (referenced from the fence; 0 = crosscut).
  final double miter;

  /// Miter complement M' = 90 - M, for saws that read from the blade.
  final double miterComplement;

  /// Which way the box leans, from the sign of [sideAngle].
  final LeanDirection lean;
}

double _radians(double degrees) => degrees * math.pi / 180.0;
double _degrees(double radians) => radians * 180.0 / math.pi;

/// Computes the compound-miter saw settings for an [n]-sided box whose sides
/// lean [sideAngleDeg] degrees from vertical.
///
/// Positive [sideAngleDeg] splays the box outward, negative slopes it inward.
/// Throws [ArgumentError] if [n] is less than 3.
MiterResult computeCompoundMiter(int n, double sideAngleDeg) {
  if (n < 3) {
    throw ArgumentError.value(n, 'n', 'must be >= 3');
  }

  final double s = _radians(sideAngleDeg);
  final double alpha = _radians(180.0 / n); // half-segment angle

  final double cosS = math.cos(s);
  final double sinA = math.sin(alpha);

  // Dihedral angle D between adjacent sides.
  double cosD = 2.0 * cosS * cosS * sinA * sinA - 1.0;
  cosD = cosD.clamp(-1.0, 1.0).toDouble(); // guard against floating-point drift
  final double d = math.acos(cosD);

  // Blade tilt / bevel B from vertical: a symmetric miter splits the dihedral.
  final double b = _radians(90.0) - d / 2.0;

  // Miter angle M on the saw table. Sign follows the sign of S.
  final double m = math.atan(math.sin(s) * math.tan(alpha));

  // Miter complement.
  final double mPrime = _radians(90.0) - m;

  final LeanDirection lean = sideAngleDeg > 0
      ? LeanDirection.outward
      : sideAngleDeg < 0
          ? LeanDirection.inward
          : LeanDirection.vertical;

  return MiterResult(
    n: n,
    sideAngle: sideAngleDeg,
    dihedral: _degrees(d),
    bladeTilt: _degrees(b),
    miter: _degrees(m),
    miterComplement: _degrees(mPrime),
    lean: lean,
  );
}
