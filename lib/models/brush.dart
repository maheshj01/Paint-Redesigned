import 'package:flutter/material.dart';

class BrushNotifier extends ChangeNotifier {
  List<Color> _recents = [];

  Color _color = Colors.black;

  double _size = 4.0;

  List<Color> get recents => _recents;

  Color get color => _color;

  double get size => _size;

  set color(Color value) {
    _color = value;
    notifyListeners();
  }

  set size(double value) {
    _size = value;
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
