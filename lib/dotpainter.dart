import 'dart:ui';
import 'package:flutter/material.dart';

/// Dots to show on the Cnavas to help
/// draw shapes
class DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red //Color.fromRGBO(97, 190, 162, 1.0)
      ..strokeWidth = 100.0
      ..imageFilter = ImageFilter.blur()
      ..style = PaintingStyle.fill;
    // for (int i = 0; i < size.width; i + 10) {
    // }
    // while (i < size.width) {
    // canvas.drawPoints(PointMode.points, [Offset(c.dx + 20, 45)], paint);
    //   i += 20;
    // }
    // var rect = Offset(0.0, 0.0) & size;
    // var rect = Offset.zero & size;
    canvas.drawArc(new Rect.fromLTWH(0.0, 0.0, size.width / 2, size.height / 2),
        0.175, 0.349, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
