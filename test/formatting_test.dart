import 'package:flutter_test/flutter_test.dart';
import 'package:miterpal/util/formatting.dart';

void main() {
  group('roundToHalf', () {
    test('rounds to nearest 0.5', () {
      expect(roundToHalf(35.37), 35.5);
      expect(roundToHalf(7.19), 7.0);
      expect(roundToHalf(28.88), 29.0);
      expect(roundToHalf(28.74), 28.5);
    });
  });

  group('formatAngle', () {
    test('rounded mode shows whole numbers without a decimal', () {
      expect(formatAngle(7.19), '7°');
      expect(formatAngle(45.0), '45°');
    });

    test('rounded mode keeps the half when present', () {
      expect(formatAngle(35.37), '35.5°');
    });

    test('exact mode shows four decimals', () {
      expect(formatAngle(35.3701, exact: true), '35.3701°');
    });

    test('normalizes negative zero', () {
      expect(formatAngle(-0.001), '0°');
    });
  });
}
