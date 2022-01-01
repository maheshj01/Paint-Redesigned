import 'package:flutter/material.dart';

enum Tool { size, color, eraser, text, brush }

class Toolbar extends ChangeNotifier {
  Tool _activeTool = Tool.size;
  Tool get activeTool => _activeTool;

  set activeTool(Tool value) {
    _activeTool = value;
    notifyListeners();
  }
}
