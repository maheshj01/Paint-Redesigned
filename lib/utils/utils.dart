import 'package:flutter/material.dart';

// TODO: improve color conversion logic

extension ColorExtension on Color {
  String toHex() {
    return value.toRadixString(16).padLeft(8, '0');
  }
}

extension StringExtension on String {
  String capitalize() {
    final titleCase = RegExp(r'\b\w');
    return replaceAllMapped(
        titleCase, (match) => match.group(0)!.toUpperCase());
  }

  Color hexToColor() {
    return Color(int.parse('0x' + this));
  }
}
