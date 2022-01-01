import 'package:flutter/material.dart';
import 'package:paint_redesigned/constants/constants.dart';
import 'package:paint_redesigned/models/explorer.dart';
import 'package:paint_redesigned/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ColorSelector extends StatefulWidget {
  /// currently selected color
  final Color selectedColor;

  final List<Color> colors;

  final bool isExpanded;

  final String title;

  int? collapsedColorsLength;

  final Function(Color)? onColorSelected;

  ColorSelector(
      {Key? key,
      required this.selectedColor,
      required this.colors,
      this.isExpanded = false,
      this.title = 'Colors',
      this.collapsedColorsLength = visibleColors,
      this.onColorSelected})
      : assert(colors.contains(selectedColor),
            'Selected color must be in the list of colors'),
        super(key: key);
  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  @override
  void didUpdateWidget(covariant ColorSelector oldWidget) {
    // TODO: implement didUpdateWidget
    if (oldWidget.selectedColor != widget.selectedColor ||
        oldWidget.colors != widget.colors ||
        oldWidget.isExpanded != widget.isExpanded) {
      super.didUpdateWidget(oldWidget);
    }
  }

  late ValueNotifier<bool> isExpandedNotifier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isExpandedNotifier = ValueNotifier<bool>(widget.isExpanded);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    isExpandedNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: isExpandedNotifier,
        builder: (BuildContext context, bool isExpanded, Widget? child) {
          final colorsLength =
              isExpanded ? widget.colors.length : widget.collapsedColorsLength;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DrawerSubTitle(widget.title),
                  ],
                ),
              ),
              Wrap(
                spacing: 2,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < colorsLength! + 1; i++)
                    Consumer<Explorer>(
                        builder: (context, Explorer _tool, Widget? child) {
                      if (i == colorsLength) {
                        return InkWell(
                          enableFeedback: true,
                          onTap: () {
                            isExpandedNotifier.value = !isExpanded;
                          },
                          child: Container(
                              height: 48,
                              width: 48,
                              margin: EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 26,
                                color: isExpanded ? Colors.teal : Colors.black,
                              )),
                        );
                      }

                      bool isSelectedColor =
                          widget.selectedColor == widget.colors[i];
                      return ColorCard(
                        onTap: (color) {
                          // TODO:  Remove this tight coupling
                          _tool.color = color;
                          widget.onColorSelected!(widget.selectedColor);
                        },
                        color: widget.colors[i],
                        isSelected: isSelectedColor,
                      );
                    })
                ],
              ),
            ],
          );
        });
  }
}
