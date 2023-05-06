import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InputForm extends StatefulWidget {
  const InputForm({Key? key}) : super(key: key);

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final TextEditingController congregationNameController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('수동 입력 화면')),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: congregationNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '회중 이름',
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await Dio().post(
                        "${dotenv.env['API_URL']!}/api/attendance-scan?congregation_name=${congregationNameController.text}");
                  } catch (e) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text('출석 등록에 실패하였습니다.\n다시 시도해주세요.'),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('확인')),
                              ],
                            ));
                    return;
                  }
                  try {
                    final attendanceRes = await Dio().get(
                        "${dotenv.env['API_URL']!}/api/attendance?congregation_name=${congregationNameController.text}");

                    if (attendanceRes.data['is_scan'] == false) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title:
                                    const Text('출석 등록에 실패하였습니다.\n다시 시도해주세요.'),
                                actions: [
                                  TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('확인')),
                                ],
                              ));
                      return;
                    }

                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(
                                  '출석 등록 되었습니다.\n${attendanceRes.data['names']}'),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('확인')),
                              ],
                            ));
                  } catch (e) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text(
                                  '출석 등록 확인에 실패하였습니다.\n올바로 등록되지 않았을 수 있습니다. 다시 시도해주세요.'),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('확인')),
                              ],
                            ));
                  }
                },
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
