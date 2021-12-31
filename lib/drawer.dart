import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paint_redesigned/constants/const.dart';
import 'package:provider/provider.dart';
import 'package:paint_redesigned/utils/utils.dart';
import 'models/toolbar.dart';

class EndDrawer extends StatefulWidget {
  const EndDrawer({Key? key}) : super(key: key);

  @override
  State<EndDrawer> createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
    if (!kIsWeb) {
      drawerBackgroundColor = Colors.transparent;
    } else {
      drawerBackgroundColor = Colors.grey[850]!;
    }
  }

  late Animation _animation;
  late Color drawerBackgroundColor;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        color: drawerBackgroundColor,
        child:
            Consumer<Toolbar>(builder: (context, Toolbar tool, Widget? child) {
          return AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return Transform.translate(
                  offset: Offset(_animation.value, 0),
                  child: IndexedStack(
                    index: tool.activeTool == Tool.size ? 0 : 1,
                    children: [
                      SizeDrawer(
                        onSizeTap: (size) {
                          tool.aspectRatio = size;
                        },
                      ),
                      ColorDrawer()
                    ],
                  ),
                );
              });
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
  late TextEditingController _colorController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _colorController = TextEditingController();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _colorController.text = _toolbarProvider.color.toHex();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _colorController.dispose();
    super.dispose();
  }

  late Toolbar _toolbarProvider;
  @override
  Widget build(BuildContext context) {
    final _length = aspectRatios.length;
    final _values = aspectRatios.values;
    final _keys = aspectRatios.keys;

    _toolbarProvider = Provider.of<Toolbar>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          DrawerSubTitle("Canvas Aspect Ratio"),
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DrawerSubTitle("Background Color"),
                ColorField(
                  controller: _colorController,
                  onTap: () {},
                  onChange: (newColor) {
                    try {
                      if (newColor.isNotEmpty)
                        _toolbarProvider.color = newColor.hexToColor();
                    } catch (e) {
                      print(e);
                    }
                  },
                )
              ],
            ),
          ),
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
                      _colorController.text = color.toHex();
                    },
                    color: canvasBackgroundColors[i],
                    isSelected: isSelectedColor,
                  );
                })
            ],
          ),
        ],
      ),
    );
  }
}

class DrawerSubTitle extends StatelessWidget {
  final String text;
  const DrawerSubTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class ColorField extends StatefulWidget {
  TextEditingController controller;
  final Function? onTap;
  final Function(String)? onChange;
  ColorField({Key? key, required this.controller, this.onTap, this.onChange})
      : super(key: key);

  @override
  _ColorFieldState createState() => _ColorFieldState();
}

class _ColorFieldState extends State<ColorField> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 40,
        width: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.white),
        alignment: Alignment.center,
        child: TextField(
          textAlign: TextAlign.center,
          onChanged: (x) => widget.onChange!(x),
          onTap: () => widget.onTap!(),
          textAlignVertical: TextAlignVertical.center,
          controller: widget.controller,
          style: TextStyle(fontSize: 18),
          maxLength: 9,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ));
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
            onTap: () => onTap!(color),
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
                decoration: BoxDecoration(
                    color: isSelected ? Colors.teal : Colors.white,
                    boxShadow: [
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
    return Column(
      children: [
        DrawerSubTitle("Colors"),
      ],
    );
  }
}
