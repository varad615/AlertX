import 'package:alertx/screens/demo.dart';
import 'package:alertx/screens/home.dart';
import 'package:alertx/screens/start.dart';
// import 'package:alertx/screens/home.dart';
// import 'package:alertx/screens/start.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return Start();
          }
        },
      ),
    );
  }
}
