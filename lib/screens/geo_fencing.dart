import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_layer/flutter_map_marker_layer.dart'; // Update: Add this for marker support
import 'package:latlong2/latlong.dart'; // Needed for LatLng in flutter_map

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Function to get the current location of the user
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Location permissions are permanently denied. Please enable them in settings.')),
      );
      return;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });
  }

  // Function to show the map with the user's current location
  void _showMap() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetching location...')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  builder: (ctx) => Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _currentPosition != null
                ? Text(
              'Latitude: ${_currentPosition!.latitude}\nLongitude: ${_currentPosition!.longitude}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            )
                : Text(
              'Fetching location...',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showMap,
              child: Text('Start Geofencing'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _stopGeofencing,
              child: Text('Stop Geofencing'),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder function for stopping geofencing
  void _stopGeofencing() {
    // TODO: Add geofencing stop logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Geofencing stopped.')),
    );
  }
}
