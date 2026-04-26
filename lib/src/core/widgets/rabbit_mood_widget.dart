import 'dart:math';
import 'package:flutter/material.dart';

class RabbitMoodWidget extends StatelessWidget {
  const RabbitMoodWidget({super.key, required this.moodScore, this.size = 36.0});
  final int moodScore;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RabbitPainter(moodScore.clamp(1, 5))),
    );
  }
}

class _RabbitPainter extends CustomPainter {
  const _RabbitPainter(this.mood);
  final int mood;

  static const _faceColor  = Color(0xFFFFFBF8);
  static const _borderColor = Color(0xFFFFCEDF);
  static const _earInner    = Color(0xFFFFB3CC);
  static const _noseColor   = Color(0xFFFF7AA2);
  static const _inkColor    = Color(0xFF1E1A1D);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.60;
    final fr = size.width * 0.355;

    _drawEars(canvas, cx, cy, fr);
    _drawFace(canvas, cx, cy, fr);
    if (mood >= 4) _drawBlush(canvas, cx, cy, fr);
    _drawNose(canvas, cx, cy, fr);
    _drawEyes(canvas, cx, cy, fr);
    _drawMouth(canvas, cx, cy, fr);
  }

  void _drawEars(Canvas canvas, double cx, double cy, double fr) {
    final white  = Paint()..color = _faceColor;
    final border = Paint()
      ..color = _borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = fr * 0.09;
    final inner = Paint()..color = _earInner;

    for (final side in [-1.0, 1.0]) {
      final ex = cx + side * fr * 0.40;
      final ey = cy - fr * 0.92;
      canvas.save();
      canvas.translate(ex, ey);
      canvas.rotate(side * 0.18);
      final rect  = Rect.fromCenter(center: Offset.zero, width: fr * 0.46, height: fr * 1.05);
      final inner2 = Rect.fromCenter(center: const Offset(0, 4), width: fr * 0.25, height: fr * 0.72);
      canvas.drawOval(rect, white);
      canvas.drawOval(rect, border);
      canvas.drawOval(inner2, inner);
      canvas.restore();
    }
  }

  void _drawFace(Canvas canvas, double cx, double cy, double fr) {
    canvas.drawCircle(Offset(cx, cy), fr, Paint()..color = _faceColor);
    canvas.drawCircle(Offset(cx, cy), fr, Paint()
      ..color = _borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = fr * 0.09);
  }

  void _drawBlush(Canvas canvas, double cx, double cy, double fr) {
    final p = Paint()..color = _earInner.withAlpha(mood == 5 ? 90 : 60);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - fr * 0.60, cy + fr * 0.27), width: fr * 0.50, height: fr * 0.26), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + fr * 0.60, cy + fr * 0.27), width: fr * 0.50, height: fr * 0.26), p);
  }

  void _drawNose(Canvas canvas, double cx, double cy, double fr) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + fr * 0.12), width: fr * 0.19, height: fr * 0.13),
      Paint()..color = _noseColor,
    );
  }

  void _drawEyes(Canvas canvas, double cx, double cy, double fr) {
    final ey = cy - fr * 0.17;
    final lx = cx - fr * 0.33;
    final rx = cx + fr * 0.33;
    final er = fr * 0.15;
    final stroke = Paint()
      ..color = _inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = fr * 0.10
      ..strokeCap = StrokeCap.round;

    switch (mood) {
      case 1: // sad T_T + teardrop
        final path = Path()
          ..moveTo(lx - er, ey - er * 0.2)
          ..quadraticBezierTo(lx, ey + er * 0.85, lx + er, ey - er * 0.2)
          ..moveTo(rx - er, ey - er * 0.2)
          ..quadraticBezierTo(rx, ey + er * 0.85, rx + er, ey - er * 0.2);
        canvas.drawPath(path, stroke);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(lx, ey + er * 1.8), width: er * 0.55, height: er * 0.9),
          Paint()..color = const Color(0xFF8AAEE8).withAlpha(190),
        );
      case 2: // ─ ─ flat
        canvas.drawLine(Offset(lx - er, ey), Offset(lx + er, ey), stroke);
        canvas.drawLine(Offset(rx - er, ey), Offset(rx + er, ey), stroke);
      case 3: // ^ ^ happy
        final path = Path()
          ..moveTo(lx - er, ey + er * 0.2)
          ..quadraticBezierTo(lx, ey - er * 0.9, lx + er, ey + er * 0.2)
          ..moveTo(rx - er, ey + er * 0.2)
          ..quadraticBezierTo(rx, ey - er * 0.9, rx + er, ey + er * 0.2);
        canvas.drawPath(path, stroke);
      case 4: // ♡ heart eyes
        _drawHeart(canvas, Offset(lx, ey), er * 1.1, const Color(0xFFFF5A8A));
        _drawHeart(canvas, Offset(rx, ey), er * 1.1, const Color(0xFFFF5A8A));
      case 5: // ★ star eyes
        _drawStar(canvas, Offset(lx, ey), er * 1.05, const Color(0xFFF0B060));
        _drawStar(canvas, Offset(rx, ey), er * 1.05, const Color(0xFFF0B060));
    }
  }

  // Two-circle + triangle heart
  void _drawHeart(Canvas canvas, Offset c, double size, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(Offset(c.dx - size * 0.50, c.dy - size * 0.08), size * 0.55, p);
    canvas.drawCircle(Offset(c.dx + size * 0.50, c.dy - size * 0.08), size * 0.55, p);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - size * 1.0, c.dy + size * 0.22)
        ..lineTo(c.dx, c.dy + size * 1.08)
        ..lineTo(c.dx + size * 1.0, c.dy + size * 0.22)
        ..close(),
      p,
    );
  }

  void _drawStar(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()..color = color;
    final ir = r * 0.40;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? r : ir;
      final angle  = i * pi / 5 - pi / 2;
      final x = c.dx + radius * cos(angle);
      final y = c.dy + radius * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawMouth(Canvas canvas, double cx, double cy, double fr) {
    final stroke = Paint()
      ..color = _inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = fr * 0.08
      ..strokeCap = StrokeCap.round;
    final my = cy + fr * 0.38;
    final mw = fr * 0.29;

    switch (mood) {
      case 1: // frown
        canvas.drawPath(
          Path()
            ..moveTo(cx - mw, my + mw * 0.45)
            ..quadraticBezierTo(cx, my - mw * 0.25, cx + mw, my + mw * 0.45),
          stroke,
        );
      case 2: // flat
        canvas.drawLine(Offset(cx - mw * 0.7, my), Offset(cx + mw * 0.7, my), stroke);
      case 3: // small smile
        canvas.drawPath(
          Path()
            ..moveTo(cx - mw, my)
            ..quadraticBezierTo(cx, my + mw * 0.65, cx + mw, my),
          stroke,
        );
      case 4: // bigger smile
        canvas.drawPath(
          Path()
            ..moveTo(cx - mw * 1.1, my - mw * 0.05)
            ..quadraticBezierTo(cx, my + mw, cx + mw * 1.1, my - mw * 0.05),
          stroke,
        );
      case 5: // big smile + pink fill
        final smilePath = Path()
          ..moveTo(cx - mw * 1.2, my - mw * 0.1)
          ..quadraticBezierTo(cx, my + mw * 1.2, cx + mw * 1.2, my - mw * 0.1);
        // filled arc
        canvas.drawPath(
          Path()
            ..moveTo(cx - mw * 1.2, my - mw * 0.1)
            ..quadraticBezierTo(cx, my + mw * 1.2, cx + mw * 1.2, my - mw * 0.1)
            ..close(),
          Paint()..color = const Color(0xFFFF7AA2).withAlpha(70),
        );
        canvas.drawPath(smilePath, stroke);
    }
  }

  @override
  bool shouldRepaint(_RabbitPainter old) => old.mood != mood;
}
