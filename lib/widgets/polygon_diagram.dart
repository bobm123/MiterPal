import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A live diagram of the box: a top-down view of the regular N-gon plus a
/// side elevation showing how far the walls lean from vertical.
class PolygonDiagram extends StatelessWidget {
  const PolygonDiagram({
    super.key,
    required this.n,
    required this.sideAngle,
    this.showLean = true,
  });

  final int n;
  final double sideAngle;

  /// Whether to draw the side-elevation lean panel. Off for flat modes
  /// (picture frames), where lean has no meaning.
  final bool showLean;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 160,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _PolygonPainter(
                      n: n,
                      stroke: scheme.primary,
                      fill: scheme.primary.withValues(alpha: 0.08),
                      spoke: scheme.outlineVariant,
                    ),
                  ),
                ),
                Text('Top view ($n sides)',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (showLean)
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _LeanPainter(
                        sideAngle: sideAngle,
                        wall: scheme.primary,
                        reference: scheme.outlineVariant,
                        ground: scheme.outline,
                      ),
                    ),
                  ),
                  Text('Side lean (${sideAngle.toStringAsFixed(1)}°)',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PolygonPainter extends CustomPainter {
  _PolygonPainter({
    required this.n,
    required this.stroke,
    required this.fill,
    required this.spoke,
  });

  final int n;
  final Color stroke;
  final Color fill;
  final Color spoke;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2 * 0.82;

    // Orientation: odd N sits point-up (already flat-bottomed); even N is
    // rotated by half a segment so it rests on a horizontal edge (N=4 = square,
    // not a diamond).
    final double rotation = n.isEven ? math.pi / n : 0.0;

    final List<Offset> vertices = <Offset>[];
    for (int i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + rotation + 2 * math.pi * i / n;
      vertices.add(center +
          Offset(radius * math.cos(angle), radius * math.sin(angle)));
    }

    final Path path = Path()..addPolygon(vertices, true);
    canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);

    // Spokes from the center to each vertex hint at the segment geometry.
    final Paint spokePaint = Paint()
      ..color = spoke
      ..strokeWidth = 1;
    for (final Offset v in vertices) {
      canvas.drawLine(center, v, spokePaint);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PolygonPainter old) =>
      old.n != n || old.stroke != stroke || old.fill != fill;
}

class _LeanPainter extends CustomPainter {
  _LeanPainter({
    required this.sideAngle,
    required this.wall,
    required this.reference,
    required this.ground,
  });

  final double sideAngle;
  final Color wall;
  final Color reference;
  final Color ground;

  @override
  void paint(Canvas canvas, Size size) {
    final double baseY = size.height * 0.85;
    final double wallHeight = size.height * 0.7;
    final Offset foot = Offset(size.width / 2, baseY);

    // Ground line.
    canvas.drawLine(
      Offset(size.width * 0.15, baseY),
      Offset(size.width * 0.85, baseY),
      Paint()
        ..color = ground
        ..strokeWidth = 1.5,
    );

    // Vertical reference (dashed-ish via short segments).
    final Paint refPaint = Paint()
      ..color = reference
      ..strokeWidth = 1;
    final Offset top = Offset(foot.dx, foot.dy - wallHeight);
    for (double y = foot.dy; y > top.dy; y -= 8) {
      canvas.drawLine(Offset(foot.dx, y), Offset(foot.dx, y - 4), refPaint);
    }

    // The leaning wall. Positive S tilts the top outward (to the right here).
    final double theta = sideAngle * math.pi / 180.0;
    final Offset wallTop = Offset(
      foot.dx + wallHeight * math.sin(theta),
      foot.dy - wallHeight * math.cos(theta),
    );
    canvas.drawLine(
      foot,
    