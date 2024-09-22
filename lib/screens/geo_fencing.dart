import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  LatLng? _tapLocation;
  double _selectedRadius = 50; // Default radius value
  bool _showCurrentLocationMarker = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation(); // Load saved location when the app starts
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('latitude');
    final longitude = prefs.getDouble('longitude');
    final radius = prefs.getDouble('radius') ?? 50.0; // Default to 50 if not set

    if (latitude != null && longitude != null) {
      setState(() {
        _tapLocation = LatLng(latitude, longitude);
        _selectedRadius = radius;
      });
    }
  }

  Future<void> _saveLocation(LatLng point, double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', point.latitude);
    await prefs.setDouble('longitude', point.longitude);
    await prefs.setDouble('radius', radius);
    print('Location saved: ${point.latitude}, ${point.longitude}, radius: $radius');
  }

  Future<void> _removeSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('latitude');
    await prefs.remove('longitude');
    await prefs.remove('radius');
    setState(() {
      _tapLocation = null;
    });
    print('Saved location removed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Map Example'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(51.509364, -0.128928),
          initialZoom: 9.2,
          onTap: _handleTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            maxNativeZoom: 19,
          ),
          if (_showCurrentLocationMarker && _currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 80,
                  height: 80,
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          if (_tapLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _tapLocation!,
                  width: 80,
                  height: 80,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _showCurrentLocationMarker = true;
      _mapController.move(_currentLocation!, 15.0);
    });
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _tapLocation = point;
    });
    print('Tapped at: ${point.latitude}, ${point.longitude}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _removeSavedLocation(); // Remove the saved location
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Remove Marker'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_tapLocation != null) {
                  _saveLocation(_tapLocation!, _selectedRadius); // Save location
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Set Marker'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<double>(
              value: _selectedRadius,
              items: [50.0, 100.0, 150.0, 200.0] // Use double values
                  .map((radius) => DropdownMenuItem<double>(
                value: radius,
                child: Text('Radius: $radius meters'),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRadius = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Set Radius',
                border: OutlineInputBorder(),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
