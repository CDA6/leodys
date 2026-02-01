import 'dart:math';
import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';

class DysAnalogClock extends StatelessWidget {
  final DateTime time;
  final double size;


  const DysAnalogClock({super.key, required this.time, this.size = 250});

  @override
  Widget build(BuildContext context) {
    final String font = context.fontFamily;
    final double fontSize = context.baseFontSize;
    return CustomPaint(
      size: Size(size, size),
      painter: _ClockPainter(time, font ,fontSize),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime time;
  final double fontSize;
  final String font;

  _ClockPainter(
      this.time,
      this.font,
      this.fontSize
      );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Dessin du cadran
    final paintCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paintCircle);

    final paintOutline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, paintOutline);

    // 2. Dessin des chiffres (Haute lisibilité)
    final textStyle = TextStyle(
      color: Colors.black,
      fontFamily: font,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final textOffset = Offset(
        center.dx + (radius - 30) * cos(angle),
        center.dy + (radius - 30) * sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(text: '$i', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, textOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    // 3. Aiguille des HEURES (Courte et large - Bleue)
    final hourAngle = (time.hour % 12 + time.minute / 60) * 30 * pi / 180 - pi / 2;
    _drawHand(canvas, center, hourAngle, radius * 0.5, 8, Colors.blue.shade900);

    // 4. Aiguille des MINUTES (Longue et fine - Rouge)
    final minuteAngle = (time.minute + time.second / 60) * 6 * pi / 180 - pi / 2;
    _drawHand(canvas, center, minuteAngle, radius * 0.8, 5, Color(0xFFE51A1A));

    // Point central
    canvas.drawCircle(center, 6, Paint()..color = Colors.black);
  }

  void _drawHand(Canvas canvas, Offset center, double angle, double length, double width, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width;

    final endPoint = Offset(
      center.dx + length * cos(angle),
      center.dy + length * sin(angle),
    );

    canvas.drawLine(center, endPoint, paint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) => oldDelegate.time != time;
}