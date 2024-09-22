import 'package:alertx/screens/geo_fence_service.dart';
import 'package:alertx/screens/geo_fencing.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class SavedLocationScreen extends StatefulWidget {
  @override
  _SavedLocationScreenState createState() => _SavedLocationScreenState();
}

class _SavedLocationScreenState extends State<SavedLocationScreen> {
  double? latitude;
  double? longitude;
  double? radius;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  // Function to load saved location data from SharedPreferences
  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      latitude = prefs.getDouble('latitude');
      longitude = prefs.getDouble('longitude');
      radius = prefs.getDouble('radius');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Location Data'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: latitude != null && longitude != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Latitude: $latitude',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Longitude: $longitude',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Radius: ${radius ?? 50} meters', // Default to 50 if not set
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              )
                  : Text(
                'Marker not set',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
          Spacer(), // Pushes the button to the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Define the action for the Set Marker button
                // Example: Navigator.pop(context) to return to the map screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GeofencePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), backgroundColor: Colors.blue, // Button color
              ),
              child: Text(
                'Set Marker',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
