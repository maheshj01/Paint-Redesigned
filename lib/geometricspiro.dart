import 'package:flutter/material.dart';
import 'dart:math' as math;

class GeometricSpiro extends StatefulWidget {
  @override
  _GeometricSpiroState createState() => _GeometricSpiroState();
}

class _GeometricSpiroState extends State<GeometricSpiro>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Color> animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(
    //     seconds: 10,
    //   ),
    // )..repeat();
    // animation = ColorTween(
    //   begin: Colors.green[200],
    //   end: Colors.brown,
    // ).animate(_animationController)
    //   ..addStatusListener((status) {
    //     if (status == AnimationStatus.completed) {
    //       _animationController.reverse().whenComplete(() {
    //         _animationController.reset();
    //         _animationController.forward();
    //       });
    //     }
    //   });

    // _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 10 * math.pi),
            duration: Duration(seconds: 50),
            builder: (BuildContext context, double angle, _) {
              return Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  painter: CanvasPainter(),
                  child: Container(),
                ),
              );
            }));
  }
}

class CanvasPainter extends CustomPainter {
  CanvasPainter({this.animation});
  Animation<Color> animation;
  @override
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = Paint()
      ..color = Color.fromRGBO(97, 190, 162, 1.0)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
    final c = size.center(Offset.zero);
    int sides = 80;
    double radius = 400;
    canvas.drawCircle(c, radius, paint);
    canvas.drawLine(
        Offset(c.dx - radius, c.dy), Offset(c.dx + radius, c.dy), paint);
    canvas.drawLine(
        Offset(c.dx, c.dy - radius), Offset(c.dx, c.dy + radius), paint);
    double angle = 200 * math.tan(math.pi / 6);
    // double kAngle = 100 * math.tan(math.pi / 4);

    int pToggle = 1;
    int kToggle = -1;
    for (int i = 0; i < sides; i++) {
      if (i % 2 == 0) {
        canvas.drawLine(Offset(c.dx + pToggle * radius, c.dy),
            Offset(c.dx, c.dy + kToggle * angle), paint);
        // canvas.drawLine(Offset(c.dx + pToggle * radius, c.dy),
        //     Offset(c.dx, c.dy + pToggle * kAngle), paint);

        pToggle = pToggle * -1;
      } else {
        canvas.drawLine(Offset(c.dx, c.dy + kToggle * radius),
            Offset(c.dx + kToggle * angle, c.dy), paint);
        kToggle = kToggle * -1;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  // TODO: implement shouldRepaint

}
