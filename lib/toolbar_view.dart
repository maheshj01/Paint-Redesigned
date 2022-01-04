import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  Widget _toolIcon(Tool tool, IconData icon) {
    return Consumer<Toolbar>(builder: (context, Toolbar _tool, Widget? child) {
      bool isSelected = _tool.activeTool == tool;
      return IconButton(
          tooltip: tool.name,
          onPressed: () => widget.onToolChange!(tool),
          icon: Icon(
            icon,
            color: isSelected ? Colors.teal : Colors.grey,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

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
                  tooltip: 'Undo',
                  onPressed: () => widget.onToolChange!(Tool.undo),
                  icon: const Icon(
                    Icons.undo,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  tooltip: 'Redo',
                  onPressed: () => widget.onToolChange!(Tool.redo),
                  icon: const Icon(Icons.redo, color: Colors.blue),
                )
              ],
            ),
          ),
          Expanded(
              flex: 6,
              child: Row(
                children: [
                  _toolIcon(Tool.canvas, Icons.crop),
                  _toolIcon(Tool.brush, Icons.brush),
                  _toolIcon(Tool.eraser, Icons.radio_button_checked),
                ],
              )),
          _toolIcon(Tool.eraser, Icons.download),
          const SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }
}
