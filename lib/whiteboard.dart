import 'dart:async';

import 'package:paint_redesigned/cursor.dart';
import 'package:paint_redesigned/dotpainter.dart';
import 'package:flutter/material.dart';
import 'package:paint_redesigned/models/brush.dart';
import 'package:provider/provider.dart';

import 'point.dart';

class WhiteBoard extends StatefulWidget {
  const WhiteBoard({Key? key}) : super(key: key);

  @override
  _WhiteBoardState createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((x) {
      points.controller.sink.add([]);
    });
  }

  BlendMode blendMode = BlendMode.softLight;
  Paint? paint;
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<Point>(context, listen: false);
    return Stack(
      children: <Widget>[
        Consumer<BrushNotifier>(
            builder: (context, BrushNotifier brush, Widget? child) {
          return GestureDetector(
            onPanStart: (startDetails) {
              List<Point?> localList = store.points;
              final renderBox = context.findRenderObject() as RenderBox;
              final localPosition =
                  renderBox.globalToLocal(startDetails.globalPosition);

              localList.add(Point(
                  paint: Paint()
                    ..color = brush.color
                    ..strokeWidth = brush.size,
                  position: localPosition));
              points.controller.sink.add(localList);
              store.points = localList;
            },
            onPanUpdate: (updateDetails) {
              List<Point?> localList = store.points;
              final renderBox = context.findRenderObject() as RenderBox;
              final localPosition =
                  renderBox.globalToLocal(updateDetails.globalPosition);
              localList.add(Point(
                  paint: Paint()
                    ..color = brush.color
                    ..strokeWidth = brush.size,
                  position: localPosition));
              points.controller.sink.add(localList);
              store.points = localList;
            },
            onPanEnd: (downDetails) {
              List<Point?> localList = store.points;
              localList.add(null);
              points.controller.sink.add(localList);
              store.points = localList;
            },
            child: StreamBuilder<List<Point?>>(
                initialData: const [],
                stream: points.controller.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Point?>> snapshot) {
                  return Cursor(
                    cursorStyle: Cursor.crosshair,
                    child: CustomPaint(
                      painter: WhiteBoardPainter(
                          points: snapshot.data, blendMode: blendMode),
                      child: Container(),
                    ),
                  );
                }),
          );
        }),
        CustomPaint(
          painter: DotPainter(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class WhiteBoardPainter extends CustomPainter {
  WhiteBoardPainter({
    this.points,
    this.blendMode,
  });
  Animation<Color>? animation;
  List<Point?>? points;
  BlendMode? blendMode;
  final double _dotsDx = 40;
  final double _dotsDy = 40;
  Paint pen = Paint();

  void drawBackgroundPoints(Canvas canvas, Size size) {
    pen
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 1.0;
    for (double dx = 0; dx <= size.width; dx = dx + _dotsDx) {
      for (double dy = 0; dy <= size.height; dy = dy + _dotsDy) {
        canvas.drawCircle(Offset(dx, dy), 2, pen);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    /// draw Background dots for accuracy
    drawBackgroundPoints(canvas, size);

    pen.style = PaintingStyle.fill;
    // final c = size.center(Offset.zero);

    for (var i = 0; i < points!.length - 1; i++) {
      if (points![i] != null &&
          points![i]?.position != null &&
          points![i + 1]?.position != null) {
        canvas.drawLine(
            Offset(points![i]!.position!.dx, points![i]!.position!.dy),
            Offset(points![i + 1]!.position!.dx, points![i + 1]!.position!.dy),
            points![i]!.paint!);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class PointController {
  final StreamController<List<Point?>> controller =
      StreamController<List<Point?>>.broadcast();
  void dispose() {
    controller.close();
  }
}

PointController points = PointController();
