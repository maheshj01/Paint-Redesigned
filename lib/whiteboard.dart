import 'dart:async';
import 'dart:ui';

import 'package:canvas/appbar.dart';
import 'package:canvas/cursor.dart';
import 'package:canvas/dotpainter.dart';
import 'package:flutter/material.dart';

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
  double _sliderMin = 5.0;
  double _sliderMax = 50.0;
  double _sliderValue = 5.0;
  AnimationController _controller;
  Animation<double> animation;
  List<Offset> localList = [];
  List<List<Offset>> globalList = [];
  List<List<Offset>> removedList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        selectedColor: pickerColor,
        onUndo: () {
          localList = [];
          if (globalList.length > 0) {
            removedList.add(globalList.removeLast());
            for (int i = 0; i < globalList.length; i++) {
              for (int j = 0; j < globalList[i].length; j++) {
                localList.add(globalList[i][j]);
              }
            }
            print('localist = ${localList.length}');
            offSetController.offset.sink.add(localList);
          }
        },
        onRedo: () {
          for (int i = 0; i < removedList.length; i++) {
            for (int j = 0; j < removedList[i].length; j++) {
              localList.add(removedList[i][j]);
            }
          }
          print('localist = ${localList.length}');
          offSetController.offset.sink.add(localList);
        },
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
                  )));
        },
        onEraserTapped: () {
          setState(() {
            localList = [];
            globalList = [];
            removedList = [];
          });
          offSetController.offset.sink.add(localList);
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
                final renderBox = context.findRenderObject() as RenderBox;
                final localPosition =
                    renderBox.globalToLocal(startDetails.globalPosition);
                localList.add(localPosition);
                offSetController.offset.sink.add(localList);
              },
              onPanUpdate: (updateDetails) {
                final renderBox = context.findRenderObject() as RenderBox;
                final localPosition =
                    renderBox.globalToLocal(updateDetails.globalPosition);
                localList.add(localPosition);
                offSetController.offset.sink.add(localList);
              },
              onPanEnd: (downDetails) {
                localList.add(null);
                offSetController.offset.sink.add(localList);
                globalList.add(localList);
                print(globalList);
              },
              child: StreamBuilder<List<Offset>>(
                  stream: offSetController.offset.stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Offset>> snapshot) {
                    return snapshot.data == null
                        ? Container(
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: Container(child: Text('Tap to Start')),
                          )
                        : Cursor(
                            cursorStyle: Cursor.crosshair,
                            child: CustomPaint(
                              painter: WhiteBoardPainter(
                                  offsetList: snapshot.data,
                                  color: pickerColor,
                                  strokeWidth: _sliderValue,
                                  blendMode: blendMode),
                              child: Container(),
                            ),
                          );
                  }),
            ),
            CustomPaint(
              painter: DotPainter(),
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
                      Text('Pointer Size:  '),
                      Text(_sliderValue.toStringAsPrecision(2)),
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
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Container(
                          height: _sliderValue,
                          width: _sliderValue,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(_sliderValue)),
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
  final offset = StreamController<List<Offset>>.broadcast();

  void dispose() {
    offset.close();
  }
}

OffSetController offSetController = OffSetController();
