import 'package:flutter/material.dart';
enum Tool { size, color, eraser, text, brush }

class Toolbar extends ChangeNotifier {
  Tool _activeTool = Tool.brush;

  Tool get activeTool => _activeTool;
  set activeTool(Tool value) {
    _activeTool = value;
    notifyListeners();
  }

  String _aspectRatio = "1:1";

  String get aspectRatio => _aspectRatio;
  set aspectRatio(String value) {
    _aspectRatio = value;
    notifyListeners();
  }

}
