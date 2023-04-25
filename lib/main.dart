import 'package:attendance_qr_scanner/constant/colors.dart';
import 'package:attendance_qr_scanner/screens/qr_scanner.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: MainColors.green, useMaterial3: true),
      home: const QRScanner(),
    );
  }
}
