import 'dart:async';
import 'package:attendance_qr_scanner/constant/colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  StreamSubscription? subscription;
  ConnectivityResult? networkStatus;
  bool isShowDialog = false;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkStatus = result;
      });
    });
  }

  @override
  dispose() {
    subscription?.cancel();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.resumeCamera();

    this.controller = controller;
    controller.scannedDataStream.listen((Barcode scanData) {
      if (scanData.code != null) {
        controller.pauseCamera();
        final ScaffoldFeatureController res =
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 2000),
          content: Align(
              alignment: const Alignment(0, 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check,
                      color: MainColors.greenAccent, size: 40),
                  Text(
                    scanData.code!,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              )),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
        ));
        res.closed.then((value) {
          controller.resumeCamera();
        });
      }
    });
  }

  Future<void> _onPermissionSet(QRViewController ctrl, bool permission) async {
    if (!permission && !isShowDialog) {
      setState(() async {
        isShowDialog = true;
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('카메라 권한이 없습니다.'),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          openAppSettings();
                        },
                        child: const Text('설정화면으로 이동')),
                  ],
                ));
        isShowDialog = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final scanAreaRadius =
        (screenWidth > screenHeight ? screenHeight : screenWidth) / 1.4;

    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            // cameraFacing: CameraFacing.front,
            overlay: QrScannerOverlayShape(
                borderColor: MainColors.greenAccent[700]!,
                borderRadius: 5,
                borderLength: 40,
                borderWidth: 10,
                cutOutSize: scanAreaRadius),
            onPermissionSet: _onPermissionSet,
          ),
          Align(
              alignment: const Alignment(0, -0.65),
              child: networkStatus == ConnectivityResult.none
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off,
                            size: 40, color: Colors.redAccent.withOpacity(0.5)),
                        const Text('인터넷 연결을 확인해주세요.',
                            style: TextStyle(
                                fontSize: 20, color: Colors.redAccent)),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code,
                            size: 40, color: Colors.white.withOpacity(0.5)),
                        const Text(
                          'QR코드를 스캔해주세요.',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ],
                    )),

          // Positioned(
          //     top: kToolbarHeight + 20, child: Text(networkStatus.toString())),
        ],
      ),
    );
  }
}
