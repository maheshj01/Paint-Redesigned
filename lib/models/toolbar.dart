import 'package:flutter/material.dart';

enum Tool { canvas, color, eraser, text, brush, undo, redo }

class Toolbar extends ChangeNotifier {
  Tool _activeTool = Tool.canvas;
  Tool get activeTool => _activeTool;

  set activeTool(Tool value) {
    _activeTool = value;
    notifyListeners();
  }
}
