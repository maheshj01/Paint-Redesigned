import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paint_redesigned/canvas.dart';

enum Tool {
  /// interacting with canvas
  canvas,

  /// erase mode
  eraser,

  /// text mode
  text,

  /// brush mode
  brush,

  /// undo the change
  undo,

  /// redo the change
  redo,

  /// doenload canvas as image
  download
}

class ToolController extends ChangeNotifier {
  Tool _activeTool = Tool.canvas;
  CanvasController canvasController = CanvasController();

  /// stores cursor to show the canvas Area
  SystemMouseCursor _cursor = SystemMouseCursors.precise;

  SystemMouseCursor get cursor => _cursor;

  set cursor(SystemMouseCursor value) {
    if (_cursor == value) return;
    _cursor = value;
    notifyListeners();
  }

  set activeTool(Tool tool) {
    if (_activeTool == tool) return;

    _activeTool = tool;

    switch (tool) {
      case Tool.canvas:
        _cursor = SystemMouseCursors.precise;
        canvasController.isEraseMode = false;
        notifyListeners();
        break;
      case Tool.brush:
        _cursor = SystemMouseCursors.precise;
        notifyListeners();
        break;
      case Tool.eraser:
        _cursor = SystemMouseCursors.grab;
        canvasController.isEraseMode = true;
        notifyListeners();
        break;
      case Tool.undo:
      case Tool.redo:
      default:
    }
  }

  Tool get activeTool => _activeTool;

  void onBrushColorChange(Color color) {
    // brushNotifier.color = color;
    notifyListeners();
  }

  void onCanvasColorChange(Color color) {
    // canvasNotifier.color = color;
    notifyListeners();
  }
}
