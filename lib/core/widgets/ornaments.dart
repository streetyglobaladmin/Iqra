import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

/// Overlapping 8-point star, used as a decorative corner ornament
/// (Home verse card, Prayer today card) — ported from ornament.jsx.
class StarMotif extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const StarMotif({
    super.key,
    this.size = 64,
    this.color = IqraTokens.gold,
    this.opacity = 0.18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarMotifPainter(color.withValues(alpha: opacity)),
      ),
    );
  }
}

class _StarMotifPainter extends CustomPainter {
  final Color color;
  _StarMotifPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    _drawStar(canvas, center, r, 0, paint);
    _drawStar(canvas, center, r, 22.5, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double r, double rotationDeg, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (rotationDeg + i * 45) * math.pi / 180;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarMotifPainter oldDelegate) => false;
}

/// Small horizontal gold-line ornament bracketed by dots — a section
/// divider inside heroes.
class Flourish extends StatelessWidget {
  final double width;
  final Color color;

  const Flourish({super.key, this.width = 80, this.color = IqraTokens.gold});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(),
          Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.5))),
          _dot(),
        ],
      ),
    );
  }

  Widget _dot() => Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// 8-point-star geometric tile pattern, painted at low opacity over dark
/// surfaces (Home V3 background).
class GeoPatternBackground extends StatelessWidget {
  final Color color;
  final double opacity;

  const GeoPatternBackground({
    super.key,
    this.color = IqraTokens.gold,
    this.opacity = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GeoPatternPainter(color.withValues(alpha: opacity)),
      child: const SizedBox.expand(),
    );
  }
}

class _GeoPatternPainter extends CustomPainter {
  final Color color;
  _GeoPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const tile = 48.0;
    for (double y = 0; y < size.height + tile; y += tile) {
      for (double x = 0; x < size.width + tile; x += tile) {
        final center = Offset(x, y);
        final path = Path();
        for (int i = 0; i < 8; i++) {
          final angle = i * 45 * math.pi / 180;
          final point = Offset(
            center.dx + (tile / 2.4) * math.cos(angle),
            center.dy + (tile / 2.4) * math.sin(angle),
          );
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GeoPatternPainter oldDelegate) => false;
}
