import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:paint_redesigned/constants/const.dart';
import 'package:provider/provider.dart';

import 'models/toolbar.dart';

class EndDrawer extends Drawer {
  const EndDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        child:
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
    Widget drawerSubTitle(String text) {
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
          child: Text(
            "$text",
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: Colors.white),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          drawerSubTitle("Canvas Aspect Ratio"),
          Wrap(
            children: [
              for (var i = 0; i < _length; i++)
                Consumer<Toolbar>(
                    builder: (context, Toolbar _tool, Widget? child) {
                  bool isSelectedAspectRatio =
                      _tool.aspectRatio == _keys.elementAt(i);
                  return AspecRatioCard(
                    onTap: (key) {
                      _tool.aspectRatio = key;
                    },
                    aspectRatioKey: _keys.elementAt(i),
                    aspectRatioValue: _values.elementAt(i),
                    isSelected: isSelectedAspectRatio,
                  );
                })
            ],
          ),
          drawerSubTitle("Background Color"),
          Wrap(
            spacing: 2,
            runSpacing: 8,
            children: [
              for (var i = 0; i < canvasBackgroundColors.length; i++)
                Consumer<Toolbar>(
                    builder: (context, Toolbar _tool, Widget? child) {
                  bool isSelectedColor =
                      _tool.color == canvasBackgroundColors[i];
                  return ColorCard(
                    onTap: (color) {
                      _tool.color = color;
                    },
                    color: canvasBackgroundColors[i],
                    isSelected: isSelectedColor,
                  );
                })
            ],
          ),
          SizedBox(width: 100, child: TextField())
        ],
      ),
    );
  }
}

class ColorCard extends StatelessWidget {
  const ColorCard(
      {Key? key, required this.color, required this.isSelected, this.onTap})
      : super(key: key);
  final Function(Color)? onTap;
  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // TODO: add tick animation

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Consumer<Toolbar>(
        builder: (context, Toolbar tool, Widget? child) {
          return InkWell(
            onTap: () {
              tool.color = color;
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: tool.color == color
                  ? Icon(
                      Icons.check,
                      color:
                          color == Colors.white ? Colors.black : Colors.white,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// Card Layout for Aspect Ratio of Canvas
class AspecRatioCard extends StatelessWidget {
  AspecRatioCard(
      {Key? key,
      required this.aspectRatioKey,
      required this.aspectRatioValue,
      this.onTap,
      required this.isSelected})
      : super(key: key);

  final double aspectRatioValue;
  final String aspectRatioKey;
  final bool isSelected;
  final Function(String)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: aspectRatioCardSize,
        width: aspectRatioCardSize,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: InkWell(
            onTap: () => onTap!(aspectRatioKey),
            child: AspectRatio(
              aspectRatio: aspectRatioValue,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    offset: Offset(2, 2),
                    color: isSelected
                        ? Colors.teal.withOpacity(0.5)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  )
                ]),
                alignment: Alignment.center,
                child: Text(
                  aspectRatioKey,
                ),
              ),
            ),
          ),
        ));
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
