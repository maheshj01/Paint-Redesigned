import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class WhiteBoard extends StatefulWidget {
  @override
  _WhiteBoardState createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard> {
  Color color = Colors.black;
  BlendMode blendMode = BlendMode.softLight;
  @override
  Widget build(BuildContext context) {
    List<Offset> localList = [];
    // List<Offset> oldList = [];
    return Scaffold(
      appBar: AppBarWidget(
        onEraserTapped: () {
          setState(() {
            blendMode = BlendMode.clear;
          });
        },
        onPenTapped: () {
          setState(() {
            color = Colors.red;
          });
        },
      ),
      body: GestureDetector(
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
            builder:
                (BuildContext context, AsyncSnapshot<List<Offset>> snapshot) {
              return snapshot.data == null
                  ? Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Container(child: Text('Tap to Start')),
                    )
                  : CustomPaint(
                      painter: WhiteBoardPainter(
                          offsetList: snapshot.data,
                          color: color,
                          blendMode: blendMode),
                      child: Container(),
                    );
            }),
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

class AppBarWidget extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final Widget leading;
  Function onPenTapped;
  Function onEraserTapped;
  final BuildContext context;
  final List<Widget> actions;

  AppBarWidget(
      {Key key,
      this.title,
      this.leading,
      this.context,
      this.actions,
      this.onEraserTapped,
      this.onPenTapped})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Offset>>(
        stream: offSetController.offsetController.stream,
        builder: (BuildContext context, AsyncSnapshot<List<Offset>> snapshot) {
          return Container(
            color: Colors.blueAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.undo,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          List<Offset> newList = [];
                          if (snapshot.data != null) {
                            List<Offset> offsetList = [];
                            offsetList = snapshot.data;
                            for (int i = 0; i < offsetList.length - 1; i++) {
                              newList.add(offsetList[i]);
                            }
                          }
                          offSetController.offsetController.sink.add(newList);
                          print('undo');
                        }),
                    IconButton(
                        icon: Icon(
                          Icons.redo,
                          color: Colors.white,
                        ),
                        onPressed: () {}),
                  ],
                ),
                Wrap(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.brush,
                          color: Colors.white,
                        ),
                        onPressed: onPenTapped),
                    IconButton(
                        icon: Icon(
                          Icons.radio_button_checked,
                          color: Colors.white,
                        ),
                        onPressed: onEraserTapped),
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
