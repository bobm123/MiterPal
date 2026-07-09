import 'package:flutter_test/flutter_test.dart';
import 'package:miterpal/models/compound_miter.dart';

void main() {
  group('computeCompoundMiter', () {
    test('upright square box (N=4, S=0): the classic 45/0 case', () {
      final MiterResult r = computeCompoundMiter(4, 0);
      expect(r.dihedral, closeTo(90.0, 1e-6));
      expect(r.bladeTilt, closeTo(45.0, 1e-6));
      expect(r.miter, closeTo(0.0, 1e-6));
      expect(r.miterComplement, closeTo(90.0, 1e-6));
      expect(r.lean, LeanDirection.vertical);
    });

    test("Jansson's pentagon example (N=5, S=10)", () {
      final MiterResult r = computeCompoundMiter(5, 10);
      expect(r.dihedral, closeTo(109.26, 0.01));
      expect(r.bladeTilt, closeTo(35.37, 0.01));
      expect(r.miter, closeTo(7.19, 0.01));
      expect(r.miterComplement, closeTo(82.81, 0.01));
      expect(r.lean, LeanDirection.outward);
    });

    test('hexagon, S=20', () {
      final MiterResult r = computeCompoundMiter(6, 20);
      expect(r.dihedral, closeTo(124.0, 0.1));
      expect(r.bladeTilt, closeTo(28.0, 0.1));
      expect(r.miter, closeTo(11.2, 0.1));
    });

    test('hexagonal planter worked example (N=6, S=15)', () {
      final MiterResult r = computeCompoundMiter(6, 15);
      expect(r.dihedral, closeTo(122.25, 0.05));
      expect(r.bladeTilt, closeTo(28.88, 0.05));
      expect(r.miter, closeTo(8.50, 0.05));
      expect(r.miterComplement, closeTo(81.50, 0.05));
    });

    test('sign symmetry: +S and -S share joint geometry, opposite miter', () {
      final MiterResult out = computeCompoundMiter(5, 10);
      final MiterResult inn = computeCompoundMiter(5, -10);
      expect(inn.dihedral, closeTo(out.dihedral, 1e-9));
      expect(inn.bladeTilt, closeTo(out.bladeTilt, 1e-9));
      expect(inn.miter, closeTo(-out.miter, 1e-9));
      expect(inn.lean, LeanDirection.inward);
    });

    test('throws for N < 3', () {
      expect(() => computeCompoundMiter(2, 0), throwsArgumentError);
    });
  });

  group('computePictureFrame', () {
    test('rectangular frame is the classic 45', () {
      final MiterResult r = computePictureFrame(4);
      expect(r.miter, closeTo(45.0, 1e-9));
      expect(r.miterComplement, closeTo(45.0, 1e-9));
      expect(r.bladeTilt, closeTo(0.0, 1e-9));
      expect(r.dihedral, closeTo(180.0, 1e-9));
    });

    test('hexagonal frame: 30 degree miter', () {
      final MiterResult r = computePictureFrame(6);
      expect(r.miter, closeTo(30.0, 1e-9));
      expect(r.miterComplement, closeTo(60.0, 1e-9));
    });

    test('throws for N < 3', () {
      expect(() => computePictureFrame(2), throwsArgumentError);
    });
  });

  group('computeButtJoint', () {
    test('upright square box is a plain square crosscut', () {
      final MiterResult r = computeButtJoint(4, 0);
      expect(r.bladeTilt, closeTo(0.0, 1e-6));
      expect(r.miter, closeTo(0.0, 1e-6));
      expect(r.dihedral, closeTo(90.0, 1e-6));
    });

    test('upright hexagon: 30 degree bevel, no miter', () {
      final MiterResult r = computeButtJoint(6, 0);
      expect(r.bladeTilt, closeTo(30.0, 1e-6));
      expect(r.miter, closeTo(0.0, 1e-6));
    });

    test('upright octagon: the classic 45 degree bevel', () {
      final MiterResult r = computeButtJoint(8, 0);
      expect(r.bladeTilt, closeTo(45.0, 1e-6));
    });

    test('upright triangle tilts the other way (negative bevel)', () {
      final MiterResult r = computeButtJoint(3, 0);
      expect(r.bladeTilt, closeTo(-30.0, 1e-6));
    });

    test('square box, S=10: worked values', () {
      final MiterResult r = computeButtJoint(4, 10);
      // c = cos^2(10)*cos(90) + sin^2(10) = sin^2(10) -> asin = 1.728 deg
      expect(r.bladeTilt, closeTo(1.728, 0.001));
      expect(r.miter, closeTo(9.851, 0.001));
    });

    test('pentagon, S=10: worked values', () {
      final MiterResult r = computeButtJoint(5, 10);
      expect(r.bladeTilt, closeTo(19.26, 0.01));
    });

    test('table miter and dihedral match the mitered box', () {
      final MiterResult butt = computeButtJoint(5, 10);
      final MiterResult mitered = computeCompoundMiter(5, 10);
      expect(butt.miter, closeTo(mitered.miter, 1e-9));
      expect(butt.dihedral, closeTo(mitered.dihedral, 1e-9));
    });

    test('throws for N < 3', () {
      expect(() => computeButtJoint(2, 0), throwsArgumentError);
    });
  });

  group('computeFixedBevelBit', () {
    test('45 degree bit with 4 sides: the classic vertical square box', () {
      final MiterResult r = computeFixedBevelBit(4, 45);
      expect(r.feasible, isTrue);
      expect(r.sideAngle, closeTo(0.0, 1e-6));
      expect(r.dihedral, closeTo(90.0, 1e-6));
    });

    test('15 degree bit with 6 sides: strongly splayed stave ring', () {
      final MiterResult r = computeFixedBevelBit(6, 15);
      expect(r.feasible, isTrue);
      // S = acos(sin(15)/sin(30))
      expect(r.sideAngle, closeTo(58.83, 0.01));
      expect(r.dihedral, closeTo(150.0, 1e-6));
      expect(r.lean, LeanDirection.outward);
    });

    test('inverse of the mitered box: feed B back in, get S out', () {
      final MiterResult mitered = computeCompoundMiter(5, 10);
      final MiterResult r = computeFixedBevelBit(5, mitered.bladeTilt);
      expect(r.sideAngle, closeTo(10.0, 1e-6));
    });

    test('zero-degree bit: flat ring (picture-frame limit)', () {
      final MiterResult r = computeFixedBevelBit(4, 0);
      expect(r.sideAngle, closeTo(90.0, 1e-6));
    });

    test('bit steeper than 180/N cannot close: infeasible', () {
      expect(computeFixedBevelBit(4, 50).feasible, isFalse);
      expect(computeFixedBevelBit(6, 31).feasible, isFalse);
      expect(computeFixedBevelBit(6, 30).feasible, isTrue);
    });

    test('throws for N < 3', () {
      expect(() => computeFixedBevelBit(2, 20), throwsArgumentError);
    });
  });

  group('computeForMode', () {
    test('dispatches to the right calculation', () {
      expect(computeForMode(JointMode.pictureFrame, 4, 10).miter,
          closeTo(45.0, 1e-9));
      expect(computeForMode(JointMode.miteredBox, 4, 0).bladeTilt,
          closeTo(45.0, 1e-6));
      expect(computeForMode(JointMode.buttJointBox, 4, 0).bladeTilt,
          closeTo(0.0, 1e-6));
      expect(computeForMode(JointMode.fixedBevelBit, 6, 0, 15).sideAngle,
          closeTo(58.83, 0.01));
    });
  });
}
