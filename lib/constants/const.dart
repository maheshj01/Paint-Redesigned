import 'package:flutter/material.dart';

List<NavigationRailDestination> tabs = const <NavigationRailDestination>[
  NavigationRailDestination(
    icon: Icon(Icons.design_services),
    selectedIcon: Icon(Icons.design_services),
    label: Text('Canvas'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.architecture),
    selectedIcon: Icon(Icons.architecture),
    label: Text('Create'),
  ),
];

typedef Ratio = double;

const Map<String, Ratio> aspectRatios = {
  "4:3": 1.33,
  "5:3": 1.66,
  "16:9": 1.77,
  "3:4": 0.75,
  "1:1": 1.0,
  "5:4": 1.25,
};

const double aspectRatioCardSize = 100;

const List<Color> canvasBackgroundColors = [
  Colors.blueAccent,
  Colors.greenAccent,
  Colors.pinkAccent,
  Colors.white,
  Colors.orangeAccent,
  Colors.deepPurpleAccent,
  Colors.redAccent,
];
