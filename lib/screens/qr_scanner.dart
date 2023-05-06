import 'dart:async';
import 'package:attendance_qr_scanner/constant/colors.dart';
import 'package:attendance_qr_scanner/screens/input_form.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  bool isShowPermissionDialog = false;
  bool isOnSuccess = false;
  bool isOnError = false;

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

  Widget? get feedbackIcon {
    if (isOnSuccess) {
      return const Icon(Icons.check, color: MainColors.greenAccent, size: 150);
    } else if (isOnError) {
      return const Icon(Icons.close, color: Colors.redAccent, size: 150);
    } else {
      return null;
    }
  }

  Color get qrScannerBorderColor {
    if (isOnSuccess) {
      return MainColors.greenAccent;
    } else if (isOnError) {
      return Colors.redAccent;
    } else {
      return Colors.white;
    }
  }

  void onQRViewCreated(QRViewController controller) {
    controller.resumeCamera();
    this.controller = controller;
    controller.scannedDataStream.listen(onScannedData);
  }

  Future<void> onPermissionSet(QRViewController ctrl, bool permission) async {
    if (!permission && !isShowPermissionDialog) {
      setState(() async {
        isShowPermissionDialog = true;
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
        isShowPermissionDialog = false;
      });
    }
  }

  Future<void> onScannedData(Barcode scanData) async {
    controller!.pauseCamera();
    var congregationName = scanData.code;
    if (!await qrcodeValidator(congregationName ?? '')) {
      showErrorSnackBar('올바르지 않은 QR코드입니다.');
      return;
    }

    try {
      await Dio().post(
          "${dotenv.env['API_URL']!}/api/attendance-scan?congregation_name=$congregationName");
    } catch (e) {
      showErrorSnackBar('출석 등록에 실패하였습니다.\n다시 시도해주세요.');
      return;
    }

    try {
      final attendanceRes = await Dio().get(
          "${dotenv.env['API_URL']!}/api/attendance?congregation_name=$congregationName");

      if (attendanceRes.data['is_scan'] == false) {
        showErrorSnackBar('출석 등록에 실패하였습니다.\n다시 시도해주세요.');
        return;
      }
      congregationName = '$congregationName\n${attendanceRes.data['names']}';
      showOkSnackBar(congregationName);
    } catch (e) {
      showErrorSnackBar('출석 등록 확인에 실패하였습니다.\n올바로 등록되지 않았을 수 있습니다. 다시 시도해주세요.');
    }
  }

  Future<bool> qrcodeValidator(String congregationName) async {
    try {
      final res = await Dio().get(
          "${dotenv.env['API_URL']!}/api/attendance?congregation_name=$congregationName");
      if (res.statusCode == 200) return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }

  void showOkSnackBar(text) {
    setState(() {
      isOnSuccess = true;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 1000),
          content: Align(
              alignment: const Alignment(0, 0.7),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              )),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
        ))
        .closed
        .then((value) {
      controller!.resumeCamera();
      setState(() {
        isOnSuccess = false;
      });
    });
  }

  void showErrorSnackBar(text) {
    setState(() {
      isOnError = true;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 1000),
          content: Align(
              alignment: const Alignment(0, 0.7),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21, color: Colors.redAccent),
              )),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
        ))
        .closed
        .then((value) {
      controller!.resumeCamera();
      setState(() {
        isOnError = false;
      });
    });
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
            onQRViewCreated: onQRViewCreated,
            cameraFacing: CameraFacing.front,
            overlay: QrScannerOverlayShape(
                borderColor: qrScannerBorderColor,
                borderRadius: 5,
                borderLength: 40,
                borderWidth: 10,
                cutOutSize: scanAreaRadius),
            onPermissionSet: onPermissionSet,
          ),
          Align(
              alignment: const Alignment(0, -0.65),
              child: networkStatus == ConnectivityResult.none
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off,
                            size: 40, color: Colors.redAccent.withOpacity(0.5)),
                        const SizedBox(width: 5),
                        const Text('인터넷 연결을 확인해주세요.',
                            style: TextStyle(
                                fontSize: 20, color: Colors.redAccent)),
                      ],
                    )
                  : InkWell(
                      onDoubleTap: () async {
                        final navi = Navigator.of(context);
                        final res = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('직접 입력 화면으로 이동하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text('아니오')),
                                    TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text('예')),
                                  ],
                                ));
                        if (res == false) return;
                        navi.push(MaterialPageRoute(
                            builder: (context) => const InputForm()));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code,
                              size: 40, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(width: 5),
                          const Text(
                            'QR코드를 스캔해주세요.',
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),
                        ],
                      ),
                    )),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: feedbackIcon,
            ),
          ),
          if (controller != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        controller!.flipCamera();
                      });
                    },
                    icon: Icon(
                      Icons.flip_camera_ios,
                      size: 30,
                      color: Colors.white.withOpacity(0.5),
                    )),
              ),
            )
        ],
      ),
    );
  }
}
