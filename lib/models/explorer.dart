import 'package:flutter/material.dart';
import 'package:paint_redesigned/constants/const.dart';
import 'package:paint_redesigned/models/color.dart';

/// Model class to maintain state of the explorer
class Explorer extends ChangeNotifier {
  List<Color> _recents = [];
  String _aspectRatio = "1:1";
  Color _color = Colors.white;
  String get aspectRatio => _aspectRatio;

  set aspectRatio(String value) {
    _aspectRatio = value;
    notifyListeners();
  }

  Color get color => _color;

  set color(Color value) {
    _color = value;
    print('length of recents: ${_recents.length}');
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

class CanvasColor extends ColorExplorer {
  CanvasColor() {
    activeColor = Colors.white;
  }

  @override
  set activeColor(Color value) {
    super.activeColor = value;
  }

  @override
  void onChange(Color p1) {
    // TODO: implement onChange
    super.onChange(p1);
  }
}
