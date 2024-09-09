import 'package:flutter/material.dart';

import 'package:direct_sms/direct_sms.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var directSms = DirectSms();

  @override
  void initState() {
    super.initState();
  }

  _sendSms({required String number, required String message}) async {
    final permission = Permission.sms.request();
    if (await permission.isGranted) {
      directSms.sendSms(message: message, phone: number);
    }
  }

  @override
  Widget build(BuildContext context) {
    var phoneController = TextEditingController();
    var messageController = TextEditingController();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    label: Text("Phone Number"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    label: Text("Message"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      _sendSms(
                        message: messageController.text,
                        number: phoneController.text.trim(),
                      );
                    },
                    child: const Text("Send"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}