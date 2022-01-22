import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paint_redesigned/canvas.dart';

enum Tool {
  /// undo the change
  undo,

  /// redo the change
  redo,

  /// brush mode
  brush,

  /// interacting with canvas
  canvas,

  /// erase mode
  eraser,

  /// text mode
  text,

  /// doenload canvas as image
  download
}

typedef Weight = int;

final Map<Tool, Weight> toolWeight = {
  Tool.undo: 1,
  Tool.redo: 2,
  Tool.brush: 3,
  Tool.canvas: 4,
  Tool.eraser: 5,
  Tool.text: 6,
  Tool.download: 7
};

enum AnimateDirection {left,right}

class ToolController extends ChangeNotifier {
  Tool _activeTool = Tool.canvas;
  CanvasController canvasController = CanvasController();

  /// stores cursor to show the canvas Area
  SystemMouseCursor _cursor = SystemMouseCursors.precise;

  SystemMouseCursor get cursor => _cursor;

  AnimateDirection _animateDirection = AnimateDirection.left;

  AnimateDirection get animateDirection => _animateDirection;

  set animateDirection(AnimateDirection value) {
    _animateDirection = value;
    notifyListeners();
  }

  set cursor(SystemMouseCursor value) {
    if (_cursor == value) return;
    _cursor = value;
    notifyListeners();
  }

  set activeTool(Tool tool) {
    if (_activeTool == tool) return;
    toolWeight[_activeTool]! > toolWeight[tool]!
        ? _animateDirection = AnimateDirection.left
        : _animateDirection = AnimateDirection.right;
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
