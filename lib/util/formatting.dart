/// Rounds [value] to the nearest 0.5.
double roundToHalf(double value) => (value * 2).round() / 2.0;

/// Formats an angle in degrees for display.
///
/// When [exact] is false (default), the value is rounded to the nearest 0.5°
/// (what a typical miter saw can realistically be set to) and shown with at
/// most one decimal place. When [exact] is true, the full value is shown to
/// four decimal places.
String formatAngle(double degrees, {bool exact = false}) {
  if (exact) {
    return '${degrees.toStringAsFixed(4)}°';
  }
  double rounded = roundToHalf(degrees);
  if (rounded == 0) {
    rounded = 0.0; // normalize -0.0
  }
  final String text = rounded == rounded.roundToDouble()
      ? rounded.toStringAsFixed(0)
      : rounded.toStringAsFixed(1);
  return '$text°';
}
