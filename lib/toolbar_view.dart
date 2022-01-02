import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';

class ToolBarView extends StatefulWidget {
  const ToolBarView({Key? key}) : super(key: key);

  @override
  _ToolBarViewState createState() => _ToolBarViewState();
}

class _ToolBarViewState extends State<ToolBarView> {
  Widget _toolIcon(Tool tool, IconData icon) {
    return Consumer<Toolbar>(builder: (context, Toolbar _tool, Widget? child) {
      bool isSelected = _tool.activeTool == tool;
      return IconButton(
          tooltip: tool.name,
          onPressed: () {
            _toolProvider.activeTool = tool;
          },
          icon: Icon(
            icon,
            color: isSelected ? Colors.teal : Colors.grey,
          ));
    });
  }

  late Toolbar _toolProvider;

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    _toolProvider = Provider.of<Toolbar>(context, listen: false);
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
                  onPressed: () {},
                  icon: const Icon(
                    Icons.undo,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  tooltip: 'Redo',
                  onPressed: () {},
                  icon: const Icon(Icons.redo, color: Colors.blue),
                )
              ],
            ),
          ),
          Expanded(
              flex: 7,
              child: Row(
                children: [
                  _toolIcon(Tool.size, Icons.crop),
                  _toolIcon(Tool.brush, Icons.brush),
                  _toolIcon(Tool.eraser, Icons.radio_button_checked),
                ],
              ))
        ],
      ),
    );
  }
}
