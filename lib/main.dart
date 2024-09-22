import 'package:alertx/screens/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart'; // Import Workmanager

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background task code
    print("Background Task Running: Checking battery level...");
    // Simulate a battery check or log action here
    return Future.value(true); // Return true to indicate success
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that Flutter is ready before initializing Firebase
  await Firebase.initializeApp(); // Initialize Firebase
  Workmanager().initialize(
    callbackDispatcher, // The top-level function
    isInDebugMode: true, // Set this to false in production
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,title: 'Welcome Page', home: MainPage());
  }
}
