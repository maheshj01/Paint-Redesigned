import 'package:flutter/material.dart';
import 'dart:math' as math;

class DonutsWidget extends StatefulWidget {
  @override
  _DonutsWidgetState createState() => _DonutsWidgetState();
}

class _DonutsWidgetState extends State<DonutsWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Color> animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 10,
      ),
    )..repeat();
    animation = ColorTween(
      begin: Colors.green[200],
      end: Colors.brown,
    ).animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse().whenComplete(() {
            _animationController.reset();
            _animationController.forward();
          });
        }
      });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 10 * math.pi),
            duration: Duration(seconds: 50),
            // curve: Curves.slowMiddle,
            // onEnd: ,
            builder: (BuildContext context, double angle, _) {
              return Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  painter: CanvasPainter(animation: animation),
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
    for (int i = 0; i < sides; i++) {
      paint..color = animation.value;
      double angle = (2 * math.pi) * i / 80;
      Offset center = Offset(100 * math.cos(angle), 100 * math.sin(angle));
      canvas.drawCircle(c + center, 100, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  // TODO: implement shouldRepaint

}

// import 'dart:async';
// import 'dart:math';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';

// // void main() => runApp(Container(color: Colors.pink[200], child: App()));

// final random = Random();

// final size = ui.window.physicalSize / ui.window.devicePixelRatio;

// const frequency = Duration(milliseconds: 50);

// final red = Paint()..color = Colors.red;
// final redStroke = Paint()
//   ..color = Colors.red

//   ..style = PaintingStyle.stroke;

// final black = Paint()..color = Colors.black;

// class Circle {
//   final Offset offset;
//   final double radius;
//   final Color color;

//   const Circle({this.offset, this.color = Colors.white, this.radius = 10});
// }

// class App extends StatefulWidget {
//   @override
//   _AppState createState() => _AppState();
// }

// class _AppState extends State<App> {
//   final StreamController<List<Circle>> _circleStreamer =
//       StreamController<List<Circle>>.broadcast();

//   Stream<List<Circle>> get _circle$ => _circleStreamer.stream;

//   Timer timer;

//   final points = <Offset>[Offset.zero];
//   final circles = <Circle>[];

//   Offset force = Offset(1, 1);

//   HSLColor color = HSLColor.fromColor(Colors.red);

//   Offset get randomPoint => size.topLeft(Offset.zero) * random.nextDouble();

//   @override
//   void initState() {
//     timer = Timer.periodic(
//       frequency,
//       (t) {
//         if (circles.isEmpty)
//           _circleStreamer.add(
//             circles
//               ..add(
//                 Circle(
//                   offset: randomPoint,
//                   radius: random.nextDouble() * 10,
//                   color: color.toColor().withOpacity(random.nextDouble()),
//                 ),
//               ),
//           );
//         int count = 0;
//         while (count < 29) {
//           final dx = circles.last.offset.dx;
//           final dy = circles.last.offset.dy;

//           if ((dx + force.dx > size.width) || (dx + force.dx < 0))
//             force = Offset(-force.dx, force.dy);
//           if ((dy + force.dy > size.height) || (dy + force.dy < 0))
//             force = Offset(force.dx, -force.dy);

//           final newPoint = size.bottomRight(Offset.zero) * 0.5 +
//               (size.bottomRight(Offset.zero) * 0.1)
//                   .scale(cos(circles.length / 59), cos(circles.length / 99));

//           final newCircle = Circle(
//             offset: newPoint,
//             radius:
//                 size.width / 20 + (size.height / 30 * sin(circles.length / 79)),
//             color: color.toColor(),
//           );

//           color = color
//               .withHue((color.hue + 0.2) % 360)
//               .withLightness(
//                   min(1.0, .1 + sin(circles.length / 49).abs() / 10));

//           _circleStreamer.add(circles..add(newCircle));

//           count++;
//         }
//       },
//     );
//     super.initState();
//   }

//   @override
//   void dispose() {
//     timer.cancel();
//     _circleStreamer.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         home: Stack(
//           children: [
//             StreamBuilder<List<Circle>>(
//               initialData: [],
//               stream: _circle$.map((event) => event.length > 299
//                   ? event.getRange(event.length - 299, event.length).toList()
//                   : event),
//               builder: (context, snapshot) {
//                 final circles = snapshot.data;
//                 return CustomPaint(
//                   size: size,
//                   painter: CirclePainter(circles: circles),
//                 );
//               },
//             ),
//           ],
//         ),
//         debugShowCheckedModeBanner: false,
//       );
// }

// class CirclePainter extends CustomPainter {
//   List<Circle> circles;

//   CirclePainter({this.circles});

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (int i = 0; i < circles.length - 1; i++) {
//       final c = circles[i];
//       final hsl = HSLColor.fromColor(c.color);
//       final paint = Paint()
//         ..color = c.color
//         ..shader = ui.Gradient.linear(
//           c.offset,
//           c.offset + Offset(0, c.radius),
//           [
//                         hsl.withLightness(max(0, min(1, hsl.lightness + 0.7))).toColor(),
//             c.color,

//           ],
//         );//..style = PaintingStyle.stroke;
//       canvas..drawCircle(c.offset, c.radius, paint)..rotate(pi / 10800);
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
