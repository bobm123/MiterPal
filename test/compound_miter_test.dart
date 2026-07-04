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
}
