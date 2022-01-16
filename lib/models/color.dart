import 'package:flutter/material.dart';

// TODO: To better design model class
abstract class ColorExplorer {
  late Color activeColor;

  List<Color> recentColors = [];

  void onChange(Color color) {
    if (!recentColors.contains(color)) {
      recentColors.insert(0, color);
    }
  }
}
