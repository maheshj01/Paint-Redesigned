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
      {Color selectedColor = Colors.teal}) {
    return Consumer<ToolController>(
        builder: (context, ToolController _tool, Widget? child) {
      bool isSelected = _tool.activeTool == tool;
      return IconButton(
          splashRadius: splashRadius,
          tooltip: tool.name,
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
                  IconButton(
                    splashRadius: splashRadius,
                    tooltip: 'Undo',
                    onPressed: () => widget.onToolChange!(Tool.undo),
                    icon: const Icon(
                      Icons.undo,
                    ),
                  ),
                  IconButton(
                    splashRadius: splashRadius,
                    tooltip: 'Redo',
                    onPressed: () => widget.onToolChange!(Tool.redo),
                    icon: const Icon(
                      Icons.redo,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                flex: 6,
                child: Row(
                  children: [
                    _toolIcon(Tool.canvas, Icons.crop),
                    _toolIcon(Tool.brush, Icons.brush,
                        selectedColor: _brushProvider.color),
                    _toolIcon(Tool.eraser, FontAwesomeIcons.eraser),
                  ],
                )),
            _toolIcon(Tool.download, Icons.download),
            const SizedBox(
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
