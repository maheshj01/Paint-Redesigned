import 'dart:async';

import 'package:canvas/appbar.dart';
import 'package:canvas/cursor.dart';
import 'package:canvas/dotpainter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import 'point.dart';

class WhiteBoard extends StatefulWidget {
  @override
  _WhiteBoardState createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this)
          ..addListener(() => setState(() {}));
    animation = Tween(begin: -200.0, end: 0.0).animate(_controller);
    paint = Paint();
    WidgetsBinding.instance!.addPostFrameCallback((x) {
      points.controller.sink.add([]);
    });
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void onPenTapped() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
      return;
    }
    _controller.forward();
    return;
  }

  double? paintSize() {
    if (_sliderValue < 3)
      return _sliderValue * 3;
    else if (_sliderValue < 8) return _sliderValue * 2;
    if (_sliderValue <= 10) return _sliderValue * 1.5;
  }

  Widget _topPaintBar() {
    return Align(
      alignment: Alignment.topRight,
      child: Transform.translate(
        offset: Offset(
          0,
          animation.value,
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Pointer Size:  '),
              Text(_sliderValue.toInt().toString()),
              Slider(
                  value: _sliderValue,
                  min: _sliderMin,
                  max: _sliderMax,
                  label: 'Size',
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  }),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: Container(
                  height: paintSize(),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color pickerColor = Colors.black;
  BlendMode blendMode = BlendMode.softLight;
  double _sliderMin = 1.0;
  double _sliderMax = 10.0;
  double _sliderValue = 3;
  late AnimationController _controller;
  late Animation<double> animation;
  Paint? paint;
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<Point>(context, listen: false);
    return Scaffold(
      appBar: AppBarWidget(
          selectedColor: pickerColor,
          onColorTapped: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                    title: const Text('Pick a color!'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: changeColor,
                        labelTypes: [ColorLabelType.hex],
                        pickerAreaHeightPercent: 0.8,
                      ),
                    )));
          },
          onEraserTapped: () {
            List<Point?> localList = store.points;
            setState(() {
              localList.clear();
            });
            points.controller.sink.add(localList);
            store.points = localList;
          },
          onPenTapped: onPenTapped),
      body: GestureDetector(
        onTap: () {
          if (_controller.status == AnimationStatus.completed) {
            _controller.reverse();
            return;
          }
        },
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onPanStart: (startDetails) {
                List<Point?> localList = store.points;
                final renderBox = context.findRenderObject() as RenderBox;
                final localPosition =
                    renderBox.globalToLocal(startDetails.globalPosition);

                localList.add(Point(
                    paint: Paint()
                      ..color = pickerColor
                      ..strokeWidth = _sliderValue,
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
                      ..color = pickerColor
                      ..strokeWidth = _sliderValue,
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
                  initialData: [],
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
            ),
            CustomPaint(
              painter: DotPainter(),
            ),
            _topPaintBar()
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
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
    // TODO: implement paint

    /// draw Background dots for accuracy
    drawBackgroundPoints(canvas, size);

    pen.style = PaintingStyle.fill;
    // final c = size.center(Offset.zero);

    for (var i = 0; i < points!.length - 1; i++) {
      if (points![i] != null &&
          points![i]?.position != null &&
          points![i + 1]?.position != null) {
        canvas.drawLine(
            Offset(points![i]!.position!.dx,
                points![i]!.position!.dy - kToolbarHeight),
            Offset(points![i + 1]!.position!.dx,
                points![i + 1]!.position!.dy - kToolbarHeight),
            points![i]!.paint!);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  // TODO: implement shouldRepaint

}

class PointController {
  final StreamController<List<Point?>> controller =
      StreamController<List<Point?>>.broadcast();
  void dispose() {
    controller.close();
  }
}

PointController points = PointController();
