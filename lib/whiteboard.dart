import 'dart:async';
import 'dart:ui';

import 'package:canvas/appbar.dart';
import 'package:canvas/dotpainter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class WhiteBoard extends StatefulWidget {
  @override
  _WhiteBoardState createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this)
          ..addListener(() => setState(() {}));
    animation = Tween(begin: -200.0, end: 0.0).animate(_controller);
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Color pickerColor = Colors.black;
  BlendMode blendMode = BlendMode.softLight;
  double _sliderValue = 10.0;
  AnimationController _controller;
  Animation<double> animation;
  bool isShown = false;
  @override
  Widget build(BuildContext context) {
    List<Offset> localList = [];
    // List<Offset> oldList = [];
    return Scaffold(
      appBar: AppBarWidget(
        selectedColor: pickerColor,
        onColorTapped: () {
          showDialog(
              context: context,
              child: AlertDialog(
                  title: const Text('Pick a color!'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: pickerColor,
                      onColorChanged: changeColor,
                      showLabel: true,
                      pickerAreaHeightPercent: 0.8,
                    ),
                    // Use Material color picker:
                    //
                    // child: MaterialPicker(
                    //   pickerColor: pickerColor,
                    //   onColorChanged: changeColor,
                    //   showLabel: true, // only on portrait mode
                    // ),
                    //
                    // Use Block color picker:
                    //
                    // child: BlockPicker(
                    //   pickerColor: currentColor,
                    //   onColorChanged: changeColor,
                    // ),
                  )));
        },
        onEraserTapped: () {
          setState(() {
            blendMode = BlendMode.clear;
          });
        },
        onPenTapped: () {
          _controller.forward();
        },
      ),
      body: GestureDetector(
        onTap: () {
          if (_controller.status == AnimationStatus.completed) {
            _controller.reset();
            return;
          }
        },
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onPanStart: (startDetails) {
                // oldList = localList;
                final renderBox = context.findRenderObject() as RenderBox;
                final localPosition =
                    renderBox.globalToLocal(startDetails.globalPosition);
                localList.add(localPosition);
                offSetController.offsetController.sink.add(localList);
                // print(startDetails.globalPosition.dx);
              },
              onPanUpdate: (updateDetails) {
                final renderBox = context.findRenderObject() as RenderBox;
                final localPosition =
                    renderBox.globalToLocal(updateDetails.globalPosition);
                localList.add(localPosition);
                offSetController.offsetController.sink.add(localList);
              },
              onPanEnd: (downDetails) {
                localList.add(null);
                offSetController.offsetController.sink.add(localList);
              },
              child: StreamBuilder<List<Offset>>(
                  stream: offSetController.offsetController.stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Offset>> snapshot) {
                    return snapshot.data == null
                        ? Container(
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: Container(child: Text('Tap to Start')),
                          )
                        : CustomPaint(
                            painter: WhiteBoardPainter(
                                offsetList: snapshot.data,
                                color: pickerColor,
                                strokeWidth: _sliderValue,
                                blendMode: blendMode),
                            child: Container(),
                          );
                  }),
            ),
            Container(
              child: CustomPaint(
                painter: DotPainter(),
              ),
            ),
            Align(
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
                      Text('Pointer Size:'),
                      Text(_sliderValue.toStringAsPrecision(2)),
                      Slider(
                          value: _sliderValue,
                          min: 10,
                          max: 40,
                          label: 'Size',
                          onChanged: (value) {
                            setState(() {
                              _sliderValue = value;
                            });
                          }),
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Container(
                          height: _sliderValue,
                          width: _sliderValue,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.circular(_sliderValue * 20)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
}

class WhiteBoardPainter extends CustomPainter {
  WhiteBoardPainter(
      {this.offsetList, this.blendMode, this.color, this.strokeWidth});
  Animation<Color> animation;
  List<Offset> offsetList;
  BlendMode blendMode;
  double strokeWidth;
  Color color;
  @override
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    final double _dotsDx = 40;
    final double _dotsDy = 40;
    Paint paint = Paint();

    /// paint for the background dots
    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 1.0;

    /// draw Background dots for accuracy
    ///
    for (double dx = 0; dx <= size.width; dx = dx + _dotsDx) {
      for (double dy = 0; dy <= size.height; dy = dy + _dotsDy) {
        canvas.drawCircle(Offset(dx, dy), 2, paint);
      }
    }

    /// define paint for the brush
    ///
    paint
      ..color = color //Color.fromRGBO(97, 190, 162, 1.0)
      ..strokeWidth = strokeWidth
      // ..strokeJoin = StrokeJoin.round
      // ..blendMode = blendMode
      // ..imageFilter = ImageFilter.blur()
      ..style = PaintingStyle.fill;
    // final c = size.center(Offset.zero);

    for (var i = 0; i < offsetList.length - 1; i++) {
      if (offsetList[i] != null && offsetList[i + 1] != null) {
        canvas.drawLine(
            Offset(offsetList[i].dx, offsetList[i].dy - kToolbarHeight),
            Offset(offsetList[i + 1].dx, offsetList[i + 1].dy - kToolbarHeight),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  // TODO: implement shouldRepaint

}

class OffSetController {
  final offsetController = StreamController<List<Offset>>.broadcast();

  void dispose() {
    offsetController.close();
  }
}

OffSetController offSetController = OffSetController();
