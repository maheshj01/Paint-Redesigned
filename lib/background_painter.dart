import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final width = size.width;
    final height = size.height;
    const count = 4;
    final step = size.width / count;
    for (int i = 0; i <= count; i++) {
      final x = step * i;
      canvas.drawLine(Offset(x, 0.0), Offset(x, height), paint);
    }
    for (int i = 0; i <= count; i++) {
      final y = step * i;
      canvas.drawLine(Offset(0.0, y), Offset(width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;
    const countX = 4;
    const countY = 4;
    final step = size.width / countX;
    for (int i = 0; i <= countX; i++) {
      final x = step * i;
      for (int j = 0; j <= countY; j++) {
        final y = step * j;
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class LinesPainter extends CustomPainter {
  Axis direction;
  LinesPainter(this.direction);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;
    final width = size.width;
    final height = size.height;
    const count = 10;
    final step = size.width / count;

    for (int i = 0; i <= count; i++) {
      if (direction == Axis.horizontal) {
        final y = step * i;
        canvas.drawLine(Offset(0.0, y), Offset(width, y), paint);
      } else {
        final x = step * i;
        canvas.drawLine(Offset(x, 0.0), Offset(x, height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(LinesPainter oldDelegate) => true;
}