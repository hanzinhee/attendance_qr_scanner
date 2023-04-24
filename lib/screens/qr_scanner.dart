import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Either the permission was already granted before or the user just granted it.
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.flipCamera();

    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // if (!p) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('카메라 권환이 없습니다.')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final scanAreaRadius =
        (screenWidth > screenHeight ? screenHeight : screenWidth) / 1.5;
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
            borderColor: Colors.limeAccent,
            borderRadius: 5,
            borderLength: 40,
            borderWidth: 10,
            cutOutSize: scanAreaRadius),
      ),
    );
  }
}
