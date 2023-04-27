import 'package:flutter/material.dart';

class MainColors {
  static const MaterialColor green =
      MaterialColor(_greenPrimaryValue, <int, Color>{
    50: Color(0xFFEFF1EA),
    100: Color(0xFFD7DCCB),
    200: Color(0xFFBCC4A8),
    300: Color(0xFFA1AC85),
    400: Color(0xFF8C9B6B),
    500: Color(_greenPrimaryValue),
    600: Color(0xFF70814A),
    700: Color(0xFF657640),
    800: Color(0xFF5B6C37),
    900: Color(0xFF485927),
  });
  static const int _greenPrimaryValue = 0xFF788951;

  static const MaterialColor greenAccent =
      MaterialColor(_greenAccentValue, <int, Color>{
    100: Color(0xFFDDFFA0),
    200: Color(_greenAccentValue),
    400: Color(0xFFB9FF3A),
    700: Color(0xFFB0FF20),
  });
  static const int _greenAccentValue = 0xFFCBFF6D;
}
