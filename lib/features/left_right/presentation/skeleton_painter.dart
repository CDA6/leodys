import 'package:flutter/material.dart';
import '../domain/entity/body_part_entity.dart';

class SkeletonPainter extends CustomPainter {
  final List<BodyPoint> points;
  final bool isFrontCamera;

  SkeletonPainter({required this.points, required this.isFrontCamera});

  @override
  void paint(Canvas canvas, Size size) {
    // opti : si y'a pas de squelette detecté, on dessine rien pour economiser
    if (points.isEmpty) return;

    double previewW = size.width;
    double previewH = size.height;

    // calcul du ratio d'affichage :
    // yolo renvoie des points entre 0.0 et 1.0 (pourcentages)
    // on doit convertir en pixels selon la taille de l'ecran du tel
    double scale;
    double offsetX = 0;
    double offsetY = 0;

    // on garde le ratio pour pas deformer le bonhomme
    if (previewW < previewH) {
      scale = previewW;
      offsetX = 0;
      offsetY = (previewH - scale) / 2;
    } else {
      scale = previewH;
      offsetY = 0;
      offsetX = (previewW - scale) / 2;
    }

    // fonction helper pour transformer un point (0.5, 0.5) en pixels (x, y)
    Offset getPos(BodyPoint p) {
      double x = p.x * scale + offsetX;
      double y = p.y * scale + offsetY;

      // effet miroir indispensable en selfie sinon c'est inversé
      if (isFrontCamera) {
        x = previewW - x;
      }
      return Offset(x, y);
    }

    // on boucle juste sur les points pour afficher les pastilles (code couleur dys)
    for (var p in points) {
      Offset pos = getPos(p);

      Color pointColor = Colors.greenAccent;
      Color bgColor;
      Color textColor = Colors.white;

      // logique visuelle dys
      // nez = point de repere central (jaune)
      // gauche = bleu / droite = rouge pour aider a la lateralisation
      if (p.label == "Nez") {
        bgColor = Colors.yellow.withValues(alpha: 0.9);
        textColor = Colors.black;
        pointColor = Colors.yellow;
      } else {
        switch (p.side) {
          case BodySide.left:
            bgColor = Colors.blue.withValues(alpha: 0.8); // gauche = bleu
            break;
          case BodySide.right:
            bgColor = Colors.red.withValues(alpha: 0.8); // droite = rouge
            break;
          default:
            bgColor = Colors.black54;
        }
      }

      // 1. dessine le rond de l'articulation
      canvas.drawCircle(pos, 6.0, Paint()..color = pointColor..style = PaintingStyle.fill);

      // 2. dessine le label (ex: "Main G") a coté du point
      final textSpan = TextSpan(
        text: p.label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: bgColor, // fond coloré pour lisibilité max
        ),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx + 8, pos.dy - 8));
    }
  }

  @override
  // on veut redessiner a chaque frame car le squelette bouge tout le temps
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) => true;
}