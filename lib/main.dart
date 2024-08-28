import 'package:alertx/screens/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that Flutter is ready before initializing Firebase
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,title: 'Welcome Page', home: MainPage());
  }
}
