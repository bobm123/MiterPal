import 'dart:math' as math;

/// How the corners of the workpiece are joined.
enum JointMode {
  /// Flat frame lying in one plane; only N matters.
  pictureFrame,

  /// Sides meet in symmetric miters that bisect each corner (the classic
  /// compound-miter box).
  miteredBox,

  /// Each side's end is cut as a single plane flush against the neighboring
  /// side's face.
  buttJointBox,

  /// Stave construction with a fixed-angle bevel cutter (router/shaper bit):
  /// the bit angle is given and the side lean S is the result.
  fixedBevelBit,
}

/// Display names for [JointMode].
extension JointModeLabel on JointMode {
  String get label => switch (this) {
        JointMode.pictureFrame => 'Picture Frame',
        JointMode.miteredBox => 'Mitered Box',
        JointMode.buttJointBox => 'Butt Joint Box',
        JointMode.fixedBevelBit => 'Fixed Bevel Bit',
      };
}

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
    this.feasible = true,
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

  /// False when no geometry satisfies the inputs (only possible in
  /// [JointMode.fixedBevelBit], when the bit angle exceeds 180/n).
  final bool feasible;
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

/// Computes the saw settings for a flat picture frame with [n] sides.
///
/// The pieces lie in one plane, so there is no blade tilt and the miter is
/// half the corner angle: M = 180/n (45 for a rectangular frame). The
/// dihedral is 180 (adjacent pieces are coplanar).
///
/// Throws [ArgumentError] if [n] is less than 3.
MiterResult computePictureFrame(int n) {
  if (n < 3) {
    throw ArgumentError.value(n, 'n', 'must be >= 3');
  }
  final double miter = 180.0 / n;
  return MiterResult(
    n: n,
    sideAngle: 0.0,
    dihedral: 180.0,
    bladeTilt: 0.0,
    miter: miter,
    miterComplement: 90.0 - miter,
    lean: LeanDirection.vertical,
  );
}

/// Computes the saw settings for an [n]-sided box whose sides lean
/// [sideAngleDeg] degrees from vertical and meet in butt joints: each piece's
/// end is cut as a single plane that sits flush against the neighboring
/// side's face.
///
/// Derived with the same board-flat convention as [computeCompoundMiter],
/// except the cut plane is the neighbor's face plane instead of the corner
/// bisector. The table miter comes out identical to the mitered box; only
/// the blade tilt differs:
///
///   tilt = asin(cos^2(S) * cos(2*alpha) + sin^2(S)),  alpha = 180/n
///
/// A negative tilt (only possible for N = 3) means the blade tilts to the
/// opposite side of vertical.
///
/// Throws [ArgumentError] if [n] is less than 3.
MiterResult computeButtJoint(int n, double sideAngleDeg) {
  if (n < 3) {
    throw ArgumentError.value(n, 'n', 'must be >= 3');
  }

  final double s = _radians(sideAngleDeg);
  final double alpha = _radians(180.0 / n);

  final double cosS = math.cos(s);
  final double sinS = math.sin(s);
  final double sinA = math.sin(alpha);

  // Dihedral angle D is a property of the panels, not the joint, so it is
  // the same as the mitered case.
  double cosD = 2.0 * cosS * cosS * sinA * sinA - 1.0;
  cosD = cosD.clamp(-1.0, 1.0).toDouble();
  final double d = math.acos(cosD);

  // Blade tilt: component of the neighbor's face normal out of this board's
  // face, expressed in the board-flat frame.
  double c = cosS * cosS * math.cos(2.0 * alpha) + sinS * sinS;
  c = c.clamp(-1.0, 1.0).toDouble();
  final double b = math.asin(c);

  // Table miter is identical to the mitered box. Sign follows the sign of S.
  final double m = math.atan(sinS * math.tan(alpha));
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

/// Computes the resulting geometry for stave construction with a fixed-angle
/// bevel cutter (router or shaper bit) of [bitAngleDeg] degrees from vertical.
///
/// This is the mitered-box relation solved the other way around: the bevel is
/// fixed by the cutter, so the side lean S is forced:
///
///   S = acos(sin(B) / sin(alpha)),  alpha = 180/n
///
/// Staves are ripped along their long edges, so there is no table miter.
/// The mirror solution -S is equally valid (splay out or slope in). A joint
/// can only close when B <= 180/n; otherwise the returned result has
/// [MiterResult.feasible] set to false.
///
/// Throws [ArgumentError] if [n] is less than 3.
MiterResult computeFixedBevelBit(int n, double bitAngleDeg) {
  if (n < 3) {
    throw ArgumentError.value(n, 'n', 'must be >= 3');
  }

  final double alpha = _radians(180.0 / n);
  final double ratio =
      math.sin(_radians(bitAngleDeg)) / math.sin(alpha);
  final double dihedral = 180.0 - 2.0 * bitAngleDeg; // from B = 90 - D/2

  if (ratio > 1.0) {
    // Bit is steeper than 180/n: the ring cannot close for this many sides.
    return MiterResult(
      n: n,
      sideAngle: 0.0,
      dihedral: dihedral,
      bladeTilt: bitAngleDeg,
      miter: 0.0,
      miterComplement: 90.0,
      lean: LeanDirection.vertical,
      feasible: false,
    );
  }

  final double s = _degrees(math.acos(ratio.clamp(-1.0, 1.0).toDouble()));

  return MiterResult(
    n: n,
    sideAngle: s,
    dihedral: dihedral,
    bladeTilt: bitAngleDeg,
    miter: 0.0,
    miterComplement: 90.0,
    lean: s > 1e-9 ? LeanDirection.outward : LeanDirection.vertical,
  );
}

/// Computes the result for the given [mode]. [bitAngleDeg] is only used by
/// [JointMode.fixedBevelBit].
MiterResult computeForMode(JointMode mode, int n, double sideAngleDeg,
        [double bitAngleDeg = 30.0]) =>
    switch (mode) {
      JointMode.pictureFrame => computePictureFrame(n),
      JointMode.miteredBox => computeCompoundMiter(n, sideAngleDeg),
      JointMode.buttJointBox => computeButtJoint(n, sideAngleDeg),
      JointMode.fixedBevelBit => computeFixedBevelBit(n, bitAngleDeg),
    };
