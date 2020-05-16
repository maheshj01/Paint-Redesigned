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

class _WhiteBoardState extends State<WhiteBoard> {
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Color pickerColor = Colors.black;
  BlendMode blendMode = BlendMode.softLight;
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
          setState(() {
            pickerColor = Colors.red;
          });
        },
      ),
      body: Stack(
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
                              blendMode: blendMode),
                          child: Container(),
                        );
                }),
          ),
          Container(
            child: CustomPaint(
              painter: DotPainter(),
            ),
          )
        ],
      ),
    );
  }
}

class WhiteBoardPainter extends CustomPainter {
  WhiteBoardPainter({this.offsetList, this.blendMode, this.color});
  Animation<Color> animation;
  List<Offset> offsetList;
  BlendMode blendMode;
  Color color;
  @override
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = Paint()
      ..color = color //Color.fromRGBO(97, 190, 162, 1.0)
      ..strokeWidth = 100.0
      ..strokeJoin = StrokeJoin.round
      ..blendMode = blendMode
      ..imageFilter = ImageFilter.blur()
      ..style = PaintingStyle.fill;
    // final c = size.center(Offset.zero);

    for (var i = 0; i < offsetList.length - 1; i++) {
      if (offsetList[i] != null && offsetList[i + 1] != null) {
        canvas.drawLine(
            Offset(offsetList[i].dx, offsetList[i].dy - kToolbarHeight),
            Offset(offsetList[i + 1].dx, offsetList[i + 1].dy - kToolbarHeight),
            paint);
        // } else if (offsetList[i] != null && offsetList[i + 1] == null) {
        //   canvas.drawPoints(
        //       PointMode.points,
        //       [Offset(offsetList[i].dx, offsetList[i].dy - kToolbarHeight)],
        //       paint);
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
