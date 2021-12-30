import 'package:flutter/material.dart';
import 'package:paint_redesigned/constants/const.dart';
import 'package:provider/provider.dart';

import 'models/toolbar.dart';

class EndDrawer extends Drawer {
  const EndDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(child:
        Consumer<Toolbar>(builder: (context, Toolbar tool, Widget? child) {
      return IndexedStack(
        index: tool.activeTool == Tool.size ? 0 : 1,
        children: [
          SizeDrawer(
            onSizeTap: (size) {
              tool.aspectRatio = size;
            },
          ),
          ColorDrawer()
        ],
      );
    }));
  }
}

class SizeDrawer extends StatefulWidget {
  final Function(String)? onSizeTap;
  SizeDrawer({Key? key, this.onSizeTap}) : super(key: key);

  @override
  _SizeDrawerState createState() => _SizeDrawerState();
}

class _SizeDrawerState extends State<SizeDrawer> {
  @override
  Widget build(BuildContext context) {
    final _length = aspectRatios.length;
    final _values = aspectRatios.values;
    final _keys = aspectRatios.keys;
    double aspectRatioSize = 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            "Canvas Size",
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        Wrap(
          children: [
            for (var i = 0; i < _length; i++)
              Consumer<Toolbar>(
                  builder: (context, Toolbar _tool, Widget? child) {
                bool isSelectedAspectRatio =
                    _tool.aspectRatio == _keys.elementAt(i);
                return GestureDetector(
                  onTap: () {
                    _tool.aspectRatio = _keys.elementAt(i);
                  },
                  child: Container(
                    height: aspectRatioSize,
                    width: aspectRatioSize,
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: AspectRatio(
                        aspectRatio: _values.elementAt(i),
                        child: Container(
                          margin: EdgeInsets.all(5),
                          decoration:
                              BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                              offset: Offset(2, 2),
                              color: isSelectedAspectRatio
                                  ? Colors.teal.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                            )
                          ]),
                          alignment: Alignment.center,
                          child: Text(_keys.elementAt(i)),
                        ),
                      ),
                    ),
                  ),
                );
              })
          ],
        ),
      ],
    );
  }
}

class ColorDrawer extends StatefulWidget {
  const ColorDrawer({Key? key}) : super(key: key);

  @override
  _ColorDrawerState createState() => _ColorDrawerState();
}

class _ColorDrawerState extends State<ColorDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
    );
  }
}
