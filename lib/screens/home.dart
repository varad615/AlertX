import 'package:alertx/screens/contact.dart';
import 'package:alertx/screens/demo.dart';
import 'package:alertx/screens/edit_contact.dart';
import 'package:alertx/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever');
      return;
    }
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final latitude = position.latitude;
    final longitude = position.longitude;
    print('Latitude: $latitude, Longitude: $longitude');
    final mapsLink = 'https://www.google.com/maps?q=$latitude,$longitude';
    Share.share('Sharing my location with you \n Latitude: $latitude \n Longitude: $longitude \n My location $mapsLink');
    // Share the latitude and longitude
    // _shareLocation(latitude, longitude);
  }

  // Future<void> _shareLocation(double latitude, double longitude) async {
  //   // You can use a package like `share` to share the location
  //   // or implement your own sharing logic
  //   final locationText = 'Latitude: $latitude, Longitude: $longitude';
  //   await Share.share(locationText);
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SOS Button at the top center
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.sos, size: 150, color: Colors.red),
                  onPressed: () {
                    // Handle SOS button press
                  },
                ),
                Text(
                  'Click button in emergency',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Row with 2 buttons side by side
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF3045D3),
                  child: IconButton(
                    icon: Icon(
                      MdiIcons.mapMarker,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Handle first button press
                      _getCurrentLocation();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF3045D3),
                  child: IconButton(
                    icon: Icon(
                      MdiIcons.whatsapp,
                      size: 30,
                      color: Colors.white,
                    ),
                      onPressed: () async {
                        final firestore = FirebaseFirestore.instance;
                        final userId = _auth.currentUser!.uid;

                        final contactDoc = await firestore
                            .collection('users')
                            .doc(userId)
                            .collection('contact')
                            .doc('contacts')
                            .get();

                        if (contactDoc.exists) {
                          final contactData = contactDoc.data();

                          for (int i = 1; i <= 5; i++) {
                            String contactKey = 'contact_$i';
                            if (contactData!.containsKey(contactKey)) {
                              String? contactNumber = contactData[contactKey];
                              if (contactNumber != null && contactNumber.isNotEmpty) {
                                print('Contact $i: $contactNumber');
                                String urllaunch = 'whatsapp://send?phone=$contactNumber&text=Hi, I need some help';
                                await launchUrl(Uri.parse(urllaunch));
                                return; // Exit the function if a contact is found
                              }
                            }
                          }

                          // If no contact is found, show a SnackBar and redirect to contact page
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No contact set'),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ContactPage()),
                          );
                        } else {
                          print('Contact data not found');
                        }
                      }
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Row with 3 buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF3045D3),
                  child: IconButton(
                    icon: Icon(
                      MdiIcons.policeBadge,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _callNumber('100'); // Police emergency number
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF3045D3),
                  child: IconButton(
                    icon: Icon(
                      MdiIcons.fireTruck,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _callNumber('101'); // Fire Brigade emergency number
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF3045D3),
                  child: IconButton(
                    icon: Icon(
                      MdiIcons.ambulance,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _callNumber('102'); // Ambulance emergency number
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactViewPage()),
          );
        },
        backgroundColor: Color(0xFF3045D3),
        label: Text(
          'Contact',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.contacts,
          color: Colors.white,
        ),
      ),
    );
  }
}
