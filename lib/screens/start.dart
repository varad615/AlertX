import 'package:alertx/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF3045D3),
        ),
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your image here
            Image.asset(
              'assets/images/logotxt.png', // Replace with your image URL or use AssetImage for local assets
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Stay Safe | Stay Alert',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3482F9)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Color(0xFF3045D3), // Set the button color to #3045D3
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Set border radius
                ),
                elevation: 0, // Remove the elevation shadow
                shadowColor:
                Colors.transparent, // Ensure shadow color is transparent
              ),
              onPressed: () {
                // Navigate to the login screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text(
                'Start',
                style:
                TextStyle(color: Colors.white), // Set text color to white
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Randitya Singh Jakhar',
              style: TextStyle(fontSize: 16, color: Color(0xFF3482F9)),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Start(),
  ));
}
