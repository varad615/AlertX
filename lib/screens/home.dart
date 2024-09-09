import 'package:alertx/screens/contact.dart';
import 'package:alertx/screens/medical_info_view.dart';
import 'package:alertx/screens/profile.dart';
import 'package:alertx/screens/setting.dart';
import 'package:alertx/screens/sos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:direct_sms/direct_sms.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var directSms = DirectSms();

  Future<void> _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  _sendSms({required String number, required String message}) async {
    final permission = Permission.sms.request();
    if (await permission.isGranted) {
      directSms.sendSms(message: message, phone: number);
    }
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
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final latitude = position.latitude;
    final longitude = position.longitude;
    print('Latitude: $latitude, Longitude: $longitude');
    final mapsLink = 'https://www.google.com/maps?q=$latitude,$longitude';
    Share.share(
        'Sharing my location with you \n Latitude: $latitude \n Longitude: $longitude \n My location $mapsLink');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SOS Button at the top center
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoudSoundPage()),
                      );
                      // Handle SOS button press
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.sos,
                            size: 150,
                            color: Colors.white,
                          ),
                          Text(
                            'Click button in emergency',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 20), // add some space between the SOS button and the gesture boxes
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            // Request permission for making phone calls
                            final permission = await Permission.phone.request();

                            // Check if the permission is granted
                            if (permission.isGranted) {
                              final firestore = FirebaseFirestore.instance;
                              final _auth = FirebaseAuth.instance;
                              final userId = _auth.currentUser!.uid;

                              final contactDoc = await firestore
                                  .collection('users')
                                  .doc(userId)
                                  .collection('contact')
                                  .doc('contacts')
                                  .get();

                              if (contactDoc.exists) {
                                final contactData = contactDoc.data();

                                // Loop through the contacts to find the first available contact number
                                for (int i = 1; i <= 5; i++) {
                                  String contactKey = 'contact_$i';
                                  if (contactData!.containsKey(contactKey)) {
                                    String? contactNumber = contactData[contactKey];
                                    if (contactNumber != null && contactNumber.isNotEmpty) {
                                      print('Calling Contact $i: $contactNumber');

                                      // Make a direct phone call to the contact number
                                      await FlutterPhoneDirectCaller.callNumber(contactNumber);
                                      return; // Exit the function after calling the first available contact
                                    }
                                  }
                                }

                                // If no contact is found, show a SnackBar and redirect to the contact page
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
                            } else {
                              // If permission is denied, show a SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Phone call permission denied. Please enable it in settings.'),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red, width: 2.0), // Add a blue border
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MdiIcons.phone,
                                  size: 50,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Call Emergency Contact',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10), // add some space between the gesture boxes
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ViewMedicalInfoPage()),
                            );
                            // Handle gesture box 2 press
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue, width: 2.0), // Add a blue border
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MdiIcons.medicalBag,
                                  size: 50,
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Medical \n Information',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10), // add some space between the rows of gesture boxes
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileScreen()),
                            );
                            // Handle gesture box 2 press
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 2.0), // Add a blue border
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MdiIcons.account,
                                  size: 50,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10), // add some space between the gesture boxes
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsPage()),
                            );
                            // Handle gesture box 2 press
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 2.0), // Add a blue border
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MdiIcons.cog,
                                  size: 50,
                                  color: Colors.black,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Setting',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}
