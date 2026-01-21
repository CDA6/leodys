import 'package:flutter/material.dart';
import '../domain/entity/body_part_entity.dart';

class SkeletonPainter extends CustomPainter {
  final List<BodyPoint> points;
  final bool isFrontCamera;

  SkeletonPainter({required this.points, required this.isFrontCamera});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paintLine = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    double previewW = size.width;
    double previewH = size.height;

    // Calcul ratio et centrage
    double scale;
    double offsetX = 0;
    double offsetY = 0;

    if (previewW < previewH) {
      scale = previewW;
      offsetX = 0;
      offsetY = (previewH - scale) / 2;
    } else {
      scale = previewH;
      offsetY = 0;
      offsetX = (previewW - scale) / 2;
    }

    Offset getPos(BodyPoint p) {
      double x = p.x * scale + offsetX;
      double y = p.y * scale + offsetY;

      // Effet miroir uniquement pour le mode selfie
      if (isFrontCamera) {
        x = previewW - x;
      }
      return Offset(x, y);
    }

    final connections = [
      ["Epaule G", "Epaule D"],
      ["Epaule G", "Coude G"], ["Coude G", "Poignet G"],
      ["Epaule D", "Coude D"], ["Coude D", "Poignet D"],
      ["Epaule G", "Hanche G"], ["Epaule D", "Hanche D"],
      ["Hanche G", "Hanche D"],
      ["Hanche G", "Genou G"], ["Genou G", "Cheville G"],
      ["Hanche D", "Genou D"], ["Genou D", "Cheville D"]
    ];

    // Tracer lignes
    for (var pair in connections) {
      try {
        var p1 = points.firstWhere((p) => p.label == pair[0]);
        var p2 = points.firstWhere((p) => p.label == pair[1]);
        canvas.drawLine(getPos(p1), getPos(p2), paintLine);
      } catch (e) {}
    }

    // Tracer points avec code couleur DYS
    for (var p in points) {
      Offset pos = getPos(p);

      Color pointColor = Colors.greenAccent;
      Color bgColor;
      Color textColor = Colors.white;

      if (p.label == "Nez") {
        bgColor = Colors.yellow.withOpacity(0.9);
        textColor = Colors.black;
        pointColor = Colors.yellow;
      } else {
        switch (p.side) {
          case BodySide.left:
            bgColor = Colors.blue.withOpacity(0.8); // Gauche = Bleu
            break;
          case BodySide.right:
            bgColor = Colors.red.withOpacity(0.8); // Droite = Rouge
            break;
          default:
            bgColor = Colors.black54;
        }
      }

      canvas.drawCircle(pos, 6.0, Paint()..color = pointColor..style = PaintingStyle.fill);

      final textSpan = TextSpan(
        text: p.label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: bgColor,
        ),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx + 8, pos.dy - 8));
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) => true;
}