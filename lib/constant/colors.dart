import 'package:flutter/material.dart';

class MainColors {
  static const MaterialColor green =
      MaterialColor(_greenPrimaryValue, <int, Color>{
    50: Color(0xFFE0F6EC),
    100: Color(0xFFB3E9CF),
    200: Color(0xFF80DAB0),
    300: Color(0xFF4DCB90),
    400: Color(0xFF26C078),
    500: Color(_greenPrimaryValue),
    600: Color(0xFF00AE58),
    700: Color(0xFF00A54E),
    800: Color(0xFF009D44),
    900: Color(0xFF008D33),
  });
  static const int _greenPrimaryValue = 0xFF00B560;

  static const MaterialColor greenAccent =
      MaterialColor(_greenAccentValue, <int, Color>{
    100: Color(0xFFB9FFCD),
    200: Color(_greenAccentValue),
    400: Color(0xFF53FF84),
    700: Color(0xFF3AFF71),
  });
  static const int _greenAccentValue = 0xFF86FFA8;

  static const Color qrScannerLightGreen = Color(0xFF0FFF83);
}
