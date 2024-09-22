import 'package:battery_plus/battery_plus.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background Task Running: Checking battery level...");
    return Future.value(true);
  });
}