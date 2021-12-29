import 'package:flutter/material.dart';

class Point extends ChangeNotifier {
  final Offset? position;
  final Paint? paint;
  List<Point?> _points = [];

  set points(List<Point?> p) {
    _points = p;
    notifyListeners();
  }

  List<Point?> get points => _points;

  Point({this.position, this.paint});
}
