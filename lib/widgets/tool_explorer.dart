import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paint_redesigned/constants/const.dart';
import 'package:paint_redesigned/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:paint_redesigned/utils/utils.dart';
import '../models/models.dart';

class ToolExplorer extends StatefulWidget {
  const ToolExplorer({Key? key}) : super(key: key);

  @override
  State<ToolExplorer> createState() => _ToolExplorerState();
}

class _ToolExplorerState extends State<ToolExplorer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Tween _tween;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _tween = Tween<double>(begin: 100.0, end: 0.0);

    _animation = _tween.animate(
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

  int index(Tool _tool) {
    switch (_tool) {
      case Tool.size:
        return 0;
      case Tool.brush:
        return 1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _explorer = Provider.of<Explorer>(context, listen: false);
    return Container(
        width: 300,
        color: drawerBackgroundColor,
        child:
            Consumer<Toolbar>(builder: (context, Toolbar tool, Widget? child) {
          _controller.reset();
          _controller.forward();
          return AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return Transform.translate(
                  offset: Offset(_animation.value, 0.0),
                  // offset: Offset(_animation.value, 0)
                  child: IndexedStack(
                    index: index(tool.activeTool),
                    children: [
                      SizeDrawer(
                        onSizeTap: (size) {
                          _explorer.aspectRatio = size;
                        },
                      ),
                      const ColorDrawer()
                    ],
                  ),
                );
              });
        }));
  }
}

class SizeDrawer extends StatefulWidget {
  const SizeDrawer({Key? key, this.onSizeTap}) : super(key: key);
  final Function(String)? onSizeTap;

  @override
  _SizeDrawerState createState() => _SizeDrawerState();
}

class _SizeDrawerState extends State<SizeDrawer> {
  late TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    _colorController = TextEditingController();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _colorController.text = _toolbarProvider.color.toHex();
    });
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  final isExpandedNotifier = ValueNotifier(false);

  late Explorer _toolbarProvider;
  @override
  Widget build(BuildContext context) {
    final _length = aspectRatios.length;
    final _values = aspectRatios.values;
    final _keys = aspectRatios.keys;

    _toolbarProvider = Provider.of<Explorer>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const DrawerSubTitle("Canvas Aspect Ratio"),
          Wrap(
            children: [
              for (var i = 0; i < _length; i++)
                Consumer<Explorer>(
                    builder: (context, Explorer _tool, Widget? child) {
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
            padding: const EdgeInsets.only(
              right: 16.0,
              top: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const DrawerSubTitle("Active Color"),
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
         const DrawerSubTitle('Recents'),
          Consumer<Explorer>(builder: (context, Explorer _tool, Widget? child) {
            final length = _tool.recents.length > noOfRecentColors
                ? noOfRecentColors
                : _tool.recents.length;
            return SizedBox(
              height: length == 0 ? 0 : 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: length,
                itemBuilder: (context, index) {
                  final recents = _tool.recents;
                  return InkWell(
                    onTap: () {
                      final _recentColor = recents[index];
                      _tool.color = _recentColor;
                      _colorController.text = _recentColor.toHex();
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      margin:const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: recents[index],
                        shape: BoxShape.circle,
                        // borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  );
                },
              ),
              // width: 200,
            );
          }),
          Consumer<Explorer>(builder: (context, Explorer _tool, Widget? child) {
            return ColorSelector(
              selectedColor: _tool.color,
              title: 'Background',
              colors: canvasBackgroundColors,
              isExpanded: false,
              onColorSelected: (_color) {
                _colorController.text = _color.toHex();
              },
            );
          }),
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
        padding:const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: Colors.black),
        ),
      ),
    );
  }
}

class ColorField extends StatefulWidget {
  ColorField({Key? key, required this.controller, this.onTap, this.onChange})
      : super(key: key);
  TextEditingController controller;
  final Function? onTap;
  final Function(String)? onChange;

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
          style: const TextStyle(fontSize: 18),
          maxLength: 9,
          decoration: const InputDecoration(
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
      {Key? key,
      required this.color,
      required this.isSelected,
      this.child,
      this.onTap})
      : super(key: key);
  final Function(Color)? onTap;
  final Color color;
  final bool isSelected;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // TODO: add tick animation

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Consumer<Explorer>(
        builder: (context, Explorer tool, Widget? child) {
          final bool isChecked = tool.color == color;
          // if (isChecked && child == null) {}
          return InkWell(
            onTap: () => onTap!(color),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: child != null
                  ? child
                  : isChecked
                      ? Icon(
                          Icons.check,
                          color: color == Colors.white
                              ? Colors.black
                              : Colors.white,
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
 const AspecRatioCard(
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
    return SizedBox(
        height: aspectRatioCardSize,
        width: aspectRatioCardSize,
        child: Container(
          padding:const EdgeInsets.symmetric(horizontal: 8),
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
                        offset:const Offset(2, 2),
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
        ColorSelector(
          selectedColor: Colors.blueAccent,
          title: 'Colors',
          colors: Colors.accents,
          isExpanded: false,
          onColorSelected: (_color) {
            // _colorController.text = _color.toHex();
          },
        )
      ],
    );
  }
}
