import 'package:flutter/material.dart';

enum Tool { size, color, eraser, text, brush }

class Toolbar extends ChangeNotifier {
  Tool _activeTool = Tool.size;
  String _aspectRatio = "1:1";
  Color _color = Colors.white;

  Tool get activeTool => _activeTool;

  set activeTool(Tool value) {
    _activeTool = value;
    notifyListeners();
  }

  String get aspectRatio => _aspectRatio;

  set aspectRatio(String value) {
    _aspectRatio = value;
    notifyListeners();
  }

  Color get color => _color;

  set color(Color value) {
    _color = value;
    notifyListeners();
  }
}
