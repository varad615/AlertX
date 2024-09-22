import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NearbyMedicalStoresPage extends StatefulWidget {
  @override
  _NearbyMedicalStoresPageState createState() =>
      _NearbyMedicalStoresPageState();
}

class _NearbyMedicalStoresPageState extends State<NearbyMedicalStoresPage> {
  Position? _currentPosition;
  List<Map<String, dynamic>> _nearbyStores = [];

  // Your Google Places API Key
  final String apiKey = 'AIzaSyDABG0rnC9f-i_ALAFRtIFnEWZewK7t4vA';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

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

    // Check for location permissions
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
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });

    // Fetch nearby medical stores using Google Places API
    _fetchNearbyMedicalStores();
  }

  Future<void> _fetchNearbyMedicalStores() async {
    if (_currentPosition == null) return;

    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    final double radius = 1500; // Search radius in meters (1.5 km)
    final String type = 'pharmacy'; // Filter to show only medical stores

    final url =
        '$baseUrl?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=$radius&type=$type&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _nearbyStores = (data['results'] as List)
            .map((place) => {
          'name': place['name'],
          'latitude': place['geometry']['location']['lat'],
          'longitude': place['geometry']['location']['lng'],
          'rating': place['rating'], // Store rating if available
        })
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load nearby medical stores.')),
      );
    }
  }

  // Calculate distance between current location and the medical store
  String _calculateDistance(double storeLat, double storeLng) {
    if (_currentPosition == null) return '';

    final distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      storeLat,
      storeLng,
    );

    // Convert distance to kilometers if over 1000 meters
    final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(2);
    return distanceInMeters < 1000
        ? '${distanceInMeters.toStringAsFixed(0)} m'
        : '$distanceInKm km';
  }

  Future<void> _openDirections(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open directions.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Medical Stores'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _nearbyStores.length,
        itemBuilder: (context, index) {
          final store = _nearbyStores[index];
          final distance = _calculateDistance(
              store['latitude'], store['longitude']);
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey, width: 1), // Gray border
            ),
            color: Colors.white, // White background color
            shadowColor: Colors.transparent, // Remove shadow
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.local_pharmacy,
                    size: 40,
                    color: Color(0xFF343797),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (store['rating'] != null)
                          Text(
                            'Rating: ${store['rating']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        SizedBox(height: 5),
                        ElevatedButton.icon(
                          onPressed: () => _openDirections(
                              store['latitude'], store['longitude']),
                          icon: Icon(
                            Icons.directions,
                            color: Colors.white, // White icon color
                          ),
                          label: Text(
                            'Directions',
                            style: TextStyle(color: Colors.white), // White text color
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Blue button color
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    distance,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
