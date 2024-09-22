import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:fl_location_platform_interface/fl_location_platform_interface.dart' as fl_location;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GeofencePage(),
    );
  }
}

class GeofencePage extends StatefulWidget {
  @override
  _GeofencePageState createState() => _GeofencePageState();
}

class _GeofencePageState extends State<GeofencePage> {
  final _geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: false,
    printDevLog: true,
  );

  final _geofenceList = <Geofence>[
    Geofence(
      id: 'my_geofence',
      latitude: 19.1053303,
      longitude: 73.0243563,
      radius: [
        GeofenceRadius(id: 'radius_3m', length: 3),
      ],
    ),
  ];

  geolocator.Position? _currentPosition;
  final List<String> _logs = [];
  late Timer _logTimer;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService.addLocationChangeListener(_onLocationChanged);
    _geofenceService.start(_geofenceList).catchError((error) {
      print('Error starting geofence service: $error');
    });
    _logTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {}); // Refresh the UI to show updated logs
    });
  }

  void _startLocationUpdates() {
    Timer.periodic(const Duration(seconds: 2), (Timer timer) async {
      try {
        geolocator.Position position = await geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.high);
        setState(() {
          _currentPosition = position;
        });
        _checkGeofence();
      } catch (e) {
        print('Location error: $e');
      }
    });
  }

  void _checkGeofence() {
    if (_currentPosition == null) return;

    final distance = geolocator.Geolocator.distanceBetween(
      _geofenceList[0].latitude,
      _geofenceList[0].longitude,
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    final isInsideGeofence = distance <= _geofenceList[0].radius[0].length;
    final status = isInsideGeofence ? 'inside' : 'outside';
    final logEntry = 'Current Location: (${_currentPosition!.latitude}, ${_currentPosition!.longitude})\n'
        'Geofence Center: (${_geofenceList[0].latitude}, ${_geofenceList[0].longitude})\n'
        'Distance: ${distance.toStringAsFixed(2)} meters\n'
        'Status: User is $status the geofence\n';

    setState(() {
      _logs.insert(0, logEntry); // Add new log entry at the top
      if (_logs.length > 10) {
        _logs.removeLast(); // Keep only the latest 10 logs
      }
    });

    if (!isInsideGeofence) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have exited the geofence area!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are inside the geofence area.'),
        ),
      );
    }
  }

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    print('Geofence status changed: $geofenceStatus');
    // if (geofenceStatus == GeofenceStatus.EXIT) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('You have exited the geofence area!'),
    //     ),
    //   );
    // } else if (geofenceStatus == GeofenceStatus.ENTER) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('You are inside the geofence area.'),
    //     ),
    //   );
    // }
  }

  void _onLocationChanged(Location location) {
    print('Location updated: ${location.toJson()}');
  }

  @override
  void dispose() {
    _geofenceService.stop();
    _geofenceService.removeGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService.removeLocationChangeListener(_onLocationChanged);
    _logTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentPosition != null)
            Text(
              'Current Location:\nLatitude: ${_currentPosition?.latitude}, Longitude: ${_currentPosition?.longitude}',
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),
          Text(
            'Geofence set at:\nLatitude: ${_geofenceList[0].latitude}\nLongitude: ${_geofenceList[0].longitude}\nRadius: ${_geofenceList[0].radius[0].length} meters',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _logs[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
