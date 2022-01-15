import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paint_redesigned/constants/const.dart';
import 'package:paint_redesigned/models/models.dart';
import 'package:paint_redesigned/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:paint_redesigned/utils/utils.dart';

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
      case Tool.canvas:
        return 0;
      case Tool.brush:
      case Tool.eraser:
        return 1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _explorer = Provider.of<CanvasNotifier>(context, listen: false);
    return Container(
        width: explorerWidth,
        color: drawerBackgroundColor,
        child: Consumer<ToolController>(
            builder: (context, ToolController tool, Widget? child) {
          if (tool.activeTool == Tool.canvas) {
            _tween.begin = -100.0;
          } else {
            _tween.begin = 100.0;
          }
          _controller.reset();
          _controller.forward();
          return AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return Transform.translate(
                  offset: Offset(_animation.value, 0.0),
                  child: IndexedStack(
                    index: index(tool.activeTool),
                    children: [
                      CanvasToolExplorer(
                        onSizeChange: (size) {
                          _explorer.aspectRatio = size;
                        },
                      ),
                      const PaintToolExplorer()
                    ],
                  ),
                );
              });
        }));
  }
}

class CanvasToolExplorer extends StatefulWidget {
  const CanvasToolExplorer({Key? key, this.onSizeChange}) : super(key: key);
  final Function(String)? onSizeChange;

  @override
  _CanvasToolExplorerState createState() => _CanvasToolExplorerState();
}

class _CanvasToolExplorerState extends State<CanvasToolExplorer> {
  late TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    _colorController = TextEditingController();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _colorController.text = _canvasNotifier.color.toHex();
    });
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  final isExpandedNotifier = ValueNotifier(false);

  late CanvasNotifier _canvasNotifier;
  Color selectedColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    final _length = aspectRatios.length;
    final _values = aspectRatios.values;
    final _keys = aspectRatios.keys;

    _canvasNotifier = Provider.of<CanvasNotifier>(context, listen: true);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const DrawerSubTitle("Aspect Ratio"),
          Wrap(
            children: [
              for (var i = 0; i < _length; i++)
                Consumer<CanvasNotifier>(
                    builder: (context, CanvasNotifier _tool, Widget? child) {
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
              right: maxPadding,
              top: maxPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const DrawerSubTitle("Active Color"),
                Row(
                  children: [
                    ColorCard(
                        color: _canvasNotifier.color,
                        size: 35,
                        isSelected: false),
                    ColorField(
                      controller: _colorController,
                      onTap: () {},
                      onChange: (newColor) {
                        try {
                          if (newColor.isNotEmpty) {
                            _canvasNotifier.color = newColor.hexToColor();
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          const DrawerSubTitle('Recents'),
          Consumer<CanvasNotifier>(
              builder: (context, CanvasNotifier _tool, Widget? child) {
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
                      margin: const EdgeInsets.symmetric(horizontal: 4),
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
          ColorSelector(
            selectedColor: _canvasNotifier.color,
            title: 'Background',
            colors: canvasBackgroundColors,
            isExpanded: false,
            onColorSelected: (_color) {
              _colorController.text = _color.toHex();
              _canvasNotifier.color = _color;
            },
          )
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
        padding: const EdgeInsets.all(maxPadding),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}

class ColorField extends StatefulWidget {
  const ColorField(
      {Key? key, required this.controller, this.onTap, this.onChange})
      : super(key: key);
  final TextEditingController controller;
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
      this.size = 48.0,
      this.child,
      this.onTap})
      : super(key: key);
  final Function(Color)? onTap;
  final Color color;
  final double size;
  final bool isSelected;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // TODO: add tick animation
    return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.4, end: 1.0),
        duration: const Duration(milliseconds: 2000),
        builder: (context, double value, Widget? child) {
          return Opacity(
            opacity: value,
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: () => onTap!(color),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: child != null
                        ? child
                        : isSelected
                            ? Icon(
                                Icons.check,
                                color: color == Colors.white
                                    ? Colors.black
                                    : Colors.white,
                              )
                            : null,
                  ),
                )),
          );
        });
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        offset: const Offset(2, 2),
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

class PaintToolExplorer extends StatefulWidget {
  const PaintToolExplorer({Key? key}) : super(key: key);

  @override
  _PaintToolExplorerState createState() => _PaintToolExplorerState();
}

class _PaintToolExplorerState extends State<PaintToolExplorer> {
  late BrushNotifier _brush;
  late TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    _colorController = TextEditingController();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _colorController.text = _brush.color.toHex();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _tool = Provider.of<ToolController>(context, listen: true);
    _brush = Provider.of<BrushNotifier>(context, listen: false);

    return Consumer<BrushNotifier>(
        builder: (context, BrushNotifier _brushNotifier, Widget? child) {
      final length = _brushNotifier.recents.length > noOfRecentColors
          ? noOfRecentColors
          : _brushNotifier.recents.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BrushSizer(
            sliderMax: 20,
            sliderMin: 1.0,
            isEraser: _tool.activeTool == Tool.eraser ? true : false,
            sliderValue: _tool.activeTool == Tool.eraser
                ? _brushNotifier.eraserSize
                : _brushNotifier.size,
            onChange: (value) {
              if (_tool.activeTool == Tool.eraser) {
                _brushNotifier.eraserSize = value;
              } else {
                _brushNotifier.size = value;
              }
            },
          ),
          _tool.activeTool == Tool.brush
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: maxPadding,
                        top: maxPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const DrawerSubTitle("Active Color"),
                          Row(
                            children: [
                              ColorCard(
                                  color: _brushNotifier.color,
                                  size: 35,
                                  isSelected: false),
                              ColorField(
                                controller: _colorController,
                                onTap: () {},
                                onChange: (newColor) {
                                  try {
                                    if (newColor.isNotEmpty) {
                                      _brushNotifier.color =
                                          newColor.hexToColor();
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const DrawerSubTitle('Recents'),
                    SizedBox(
                      height: length == 0 ? 0 : 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: length,
                        itemBuilder: (context, index) {
                          final recents = _brushNotifier.recents;
                          return InkWell(
                            onTap: () {
                              final _recentColor = recents[index];
                              _brushNotifier.color = _recentColor;
                              _colorController.text = _recentColor.toHex();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: recents[index],
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                      // width: 200,
                    ),
                    ColorSelector(
                      selectedColor: _brushNotifier.color,
                      title: 'Colors',
                      colors: const [Colors.black, ...Colors.accents],
                      isExpanded: false,
                      onColorSelected: (_color) {
                        _brushNotifier.color = _color;
                        _colorController.text = _color.toHex();
                      },
                    )
                  ],
                )
              : const SizedBox()
        ],
      );
    });
  }
}

class BrushSizer extends StatelessWidget {
  const BrushSizer(
      {Key? key,
      this.sliderMax = 10.0,
      this.sliderMin = 1.0,
      required this.sliderValue,
      this.isEraser = false,
      this.onChange})
      : super(key: key);
  final double sliderMin;
  final double sliderMax;
  final double sliderValue;
  final bool isEraser;
  final Function(double)? onChange;
  @override
  Widget build(BuildContext context) {
    final circleSize = sliderValue.clamp(4.0, 30.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: maxPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DrawerSubTitle(
                  '${isEraser ? 'Eraser' : 'Brush'} Size: ${sliderValue.toInt().toString()}'),
              Container(
                height: circleSize,
                width: circleSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 30,
              )
            ],
          ),
        ),
        Slider.adaptive(
            value: sliderValue,
            min: sliderMin,
            max: sliderMax,
            label: 'Size',
            onChanged: (value) => onChange!(value)),
      ],
    );
  }
}
