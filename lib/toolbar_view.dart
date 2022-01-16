import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'constants/constants.dart';
import 'models/models.dart';

class ToolBarView extends StatefulWidget {
  final void Function(Tool)? onToolChange;
  const ToolBarView({
    this.onToolChange,
    Key? key,
  }) : super(key: key);

  @override
  _ToolBarViewState createState() => _ToolBarViewState();
}

class _ToolBarViewState extends State<ToolBarView> {
  Widget _toolIcon(Tool tool, IconData icon,
      {Color selectedColor = Colors.teal, String? tooltip}) {
    return Consumer<ToolController>(
        builder: (context, ToolController _tool, Widget? child) {
      bool isSelected = _tool.activeTool == tool;
      return IconButton(
          splashRadius: splashRadius,
          tooltip: tooltip ?? tool.name,
          onPressed: () => widget.onToolChange!(tool),
          icon: FaIcon(
            icon,
            color: isSelected ? selectedColor : Colors.grey,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final _brushProvider = Provider.of<BrushNotifier>(context, listen: true);
    final platformKey = Platform.isMacOS ? 'CMD' : 'CTRL';
    return Container(
      height: 60,
      width: _size.width * 0.5,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(5, 5),
              spreadRadius: 4,
            )
          ]),
      child: Material(
        borderRadius: BorderRadius.circular(40),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  const SizedBox(
                    width: 50,
                  ),
                  _toolIcon(
                    Tool.undo,
                    Icons.undo,
                    tooltip: 'Undo ($platformKey+Z)',
                  ),
                  _toolIcon(
                    Tool.redo,
                    Icons.redo,
                    tooltip: 'Redo ($platformKey+Y)',
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 6,
                child: Row(
                  children: [
                    _toolIcon(Tool.brush, Icons.brush,
                        selectedColor: _brushProvider.color,
                        tooltip: 'Brush ($platformKey+B)'),
                    _toolIcon(
                      Tool.canvas,
                      Icons.crop,
                      selectedColor: _brushProvider.color,
                      tooltip: 'Canvas ($platformKey+C)',
                    ),
                    _toolIcon(Tool.eraser, FontAwesomeIcons.eraser,
                        selectedColor: _brushProvider.color,
                        tooltip: 'Eraser ($platformKey+E)'),
                  ],
                )),
            _toolIcon(Tool.download, Icons.download,
                tooltip: 'Download ($platformKey+S)'),
            const SizedBox(
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
