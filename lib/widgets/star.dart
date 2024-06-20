import 'package:flutter/material.dart';

class StarPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final bool filled;

  StarPainter({required this.color, required this.borderColor, required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    Path starPath = Path();
    starPath.moveTo(w / 2, 0);
    starPath.lineTo(w * 0.6, h * 0.35);
    starPath.lineTo(w, h * 0.35);
    starPath.lineTo(w * 0.7, h * 0.6);
    starPath.lineTo(w * 0.8, h);
    starPath.lineTo(w / 2, h * 0.75);
    starPath.lineTo(w * 0.2, h);
    starPath.lineTo(w * 0.3, h * 0.6);
    starPath.lineTo(0, h * 0.35);
    starPath.lineTo(w * 0.4, h * 0.35);
    starPath.close();

    Paint starPaint = Paint()..color = color;
    Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (filled) {
      canvas.drawPath(starPath, starPaint);
    }
    canvas.drawPath(starPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
