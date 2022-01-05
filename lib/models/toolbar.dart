import 'package:flutter/material.dart';

enum Tool { canvas, color, eraser, text, brush, undo, redo, download }

class Toolbar extends ChangeNotifier {
  Tool _activeTool = Tool.canvas;
  Tool get activeTool => _activeTool;

  set activeTool(Tool value) {
    if (_activeTool == value) return;
    _activeTool = value;
    notifyListeners();
  }
}
