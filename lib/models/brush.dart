import 'package:flutter/material.dart';

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
    _color = value;
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
