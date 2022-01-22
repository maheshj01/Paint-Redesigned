import 'package:flutter/material.dart';
import 'package:paint_redesigned/constants/const.dart';

/// Model class to maintain state of the explorer
enum CanvasBackground {plain,dots, vlines, hlines, grid, image}
class CanvasNotifier extends ChangeNotifier {
  List<Color> _recents = [];

  String _aspectRatio = "1:1";

  Color _color = Colors.white;

  String get aspectRatio => _aspectRatio;

  CanvasBackground _background = CanvasBackground.plain;

  CanvasBackground get background => _background;

  set background(CanvasBackground value) {
    if(_background==value) return;
    _background = value;
    notifyListeners();
  }

  set aspectRatio(String value) {
    _aspectRatio = value;
    notifyListeners();
  }

  Color get color => _color;

  set color(Color value) {
    if (_color == value) return;
    _color = value;
    if (!_recents.contains(value)) {
      _recents.insert(0, value);
    } else {
      _recents.remove(value);
      _recents.insert(0, value);
    }
    if (_recents.length > noOfRecentColors) {
      _recents.removeLast();
    }
    notifyListeners();
  }

  List<Color> get recents => _recents;

  set recents(List<Color> value) {
    _recents = value;
    notifyListeners();
  }
}
