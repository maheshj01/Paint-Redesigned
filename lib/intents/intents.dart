import 'package:flutter/material.dart';

class UndoIntent extends Intent {
  const UndoIntent({this.description, required this.action});

  /// undo the last action
  final Function()? action;

  /// description about the action
  final String? description;
}

class RedoIntent extends Intent {
  const RedoIntent({this.description, required this.action});

  /// undo the last action
  final Function()? action;

  /// description about the action
  final String? description;
}

class BrushIntent extends Intent {
  const BrushIntent({this.description, required this.action});

  /// undo the last action
  final Function()? action;

  /// description about the action
  final String? description;
}

class CanvasIntent extends Intent {
  const CanvasIntent({this.description, required this.action});

  /// undo the last action
  final Function()? action;

  /// description about the action
  final String? description;
}

class EraserIntent extends Intent {
  const EraserIntent({this.description, required this.action});

  /// undo the last action
  final Function()? action;

  /// description about the action
  final String? description;
}

class DownloadIntent extends Intent {
  const DownloadIntent({this.description, required this.action});

  /// undo the last action
  final Function()? action;

  /// description about the action
  final String? description;
}
