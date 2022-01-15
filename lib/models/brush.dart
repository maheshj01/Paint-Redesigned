import 'package:flutter/material.dart';
import 'package:paint_redesigned/constants/constants.dart';

class BrushNotifier extends ChangeNotifier {
  List<Color> _recents = [];

  Color _color = Colors.black;

  /// default paint size
  double _size = 4.0;

  /// default eraser size
  double _eraserSize = 4.0;

  List<Color> get recents => _recents;

  Color get color => _color;

  double get size => _size;

  double get eraserSize => _eraserSize;

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

  set size(double value) {
    _size = value;
    notifyListeners();
  }

  set eraserSize(double value) {
    _eraserSize = value;
    notifyListeners();
  }

  set recents(List<Color> colors) {
    _recents = colors;
    notifyListeners();
  }

  void addRecent(Color color) {
    _recents.add(color);
    notifyListeners();
  }

  void clearRecents() {
    _recents.clear();
    notifyListeners();
  }
}
