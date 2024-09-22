import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

class BatteryPage extends StatefulWidget {
  @override
  _BatteryPageState createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  bool _isBackgroundServiceRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startBackgroundService() async {
    // Request permission to run in background
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Battery Monitoring",
      notificationText: "Monitoring battery in the background",
      notificationImportance: AndroidNotificationImportance.high, // Corrected line
      enableWifiLock: true,
    );

    bool hasPermission = await FlutterBackground.initialize(androidConfig: androidConfig);

    if (hasPermission) {
      FlutterBackground.enableBackgroundExecution();
      _startLoggingBattery();
      setState(() {
        _isBackgroundServiceRunning = true;
      });
    }
  }

  void _startLoggingBattery() {
    // Simulate logging the battery percentage every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      print("Background Task: Checking battery level at ${DateTime.now()}");
      // Add your battery check logic here
    });
  }

  void _stopBackgroundService() {
    FlutterBackground.disableBackgroundExecution();
    _timer?.cancel();
    setState(() {
      _isBackgroundServiceRunning = false;
    });
    print("Background Service Stopped");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Battery Monitoring'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isBackgroundServiceRunning
                  ? 'Background Service Running'
                  : 'Background Service Stopped',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Enable Background Service'),
              value: _isBackgroundServiceRunning,
              onChanged: (value) {
                if (value) {
                  _startBackgroundService();
                } else {
                  _stopBackgroundService();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
