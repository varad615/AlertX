import 'package:alertx/screens/contact.dart';
import 'package:alertx/screens/medical_info_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:direct_sms/direct_sms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class LoudSoundPage extends StatefulWidget {
  @override
  _LoudSoundPageState createState() => _LoudSoundPageState();
}

class _LoudSoundPageState extends State<LoudSoundPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _playSoundInLoop(); // Play the sound in a loop when the page opens
  }

  // Function to play the sound in a loop
  Future<void> _playSoundInLoop() async {
    await _audioPlayer
        .setReleaseMode(ReleaseMode.loop); // Set the audio to loop continuously
    await _audioPlayer.play(
      AssetSource('sound/sos.mp3'), // Ensure this path matches your asset
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  // Function to stop the sound
  Future<void> _stopSound() async {
    await _audioPlayer.stop();
  }

  // Function to get user's current location
  Future<Position> _getCurrentLocation(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Show SnackBar if permission is denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Location permissions are required to access your location.'),
          ),
        );
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Show SnackBar if permission is permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Function to send SMS with location
  Future<void> _sendSMS(String phoneNumber) async {
    PermissionStatus status = await Permission.sms.status;

    if (status.isGranted) {
      try {
        Position position = await _getCurrentLocation(context);
        String message =
            'Emergency! Here is my current location: Latitude: ${position.latitude}, Longitude: ${position.longitude}';
        DirectSms().sendSms(phone: phoneNumber, message: message);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SMS: $e'),
          ),
        );
      }
    } else {
      // Request SMS permission if not granted
      if (await Permission.sms.request().isGranted) {
        // Permission granted, try sending SMS again
        _sendSMS(phoneNumber);
      } else {
        // Permission denied, show SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS permission is required to send messages'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer
        .dispose(); // Dispose of the audio player when the widget is removed
    super.dispose();
  }

  // Functions to handle tap events
  void _callEmergencyContact() {}
  void _viewMedicalInfo() {}
  void _viewAllergies() {}
  void _viewMedication() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Icon at the top center
            Icon(
              MdiIcons.bellRing,
              size: 200, // Adjust size as needed
              color: Color(0xFFFF0000),
            ),
            SizedBox(height: 20), // Space between icon and button

            // Stop Sound Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: _stopSound, // Stops the sound when pressed
                child: Text('Stop Sound'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFFFF0000), // Red button to indicate stop action
                  foregroundColor: Colors.white,
                  minimumSize: Size(
                      double.infinity, 70), // Full width and increased height
                  padding: EdgeInsets.symmetric(
                      vertical: 15), // Increase padding for height
                  textStyle: TextStyle(fontSize: 20), // Increase font size
                ),
              ),
            ),
            SizedBox(height: 20), // Space between buttons

            // Call Emergency Contact Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Call Emergency Contact Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
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

                          // Loop through the contacts to find the first available contact number
                          for (int i = 1; i <= 5; i++) {
                            String contactKey = 'contact_$i';
                            if (contactData!.containsKey(contactKey)) {
                              String? contactNumber = contactData[contactKey];
                              if (contactNumber != null &&
                                  contactNumber.isNotEmpty) {
                                print('Calling Contact $i: $contactNumber');
                                PermissionStatus status =
                                    await Permission.phone.status;
                                if (status.isGranted) {
                                  try {
                                    await FlutterPhoneDirectCaller.callNumber(
                                        contactNumber);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Phone permissions are required to access your location.'),
                                      ),
                                    );
                                  }
                                } else {
                                  if (await Permission.phone
                                      .request()
                                      .isGranted) {
                                    _makePhoneCall(contactNumber);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Phone call permission is required to make calls'),
                                      ),
                                    );
                                  }
                                }

                                // Make a direct phone call to the contact number
                                await FlutterPhoneDirectCaller.callNumber(
                                    contactNumber);
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
                            MaterialPageRoute(
                                builder: (context) => ContactPage()),
                          );
                        } else {
                          print('Contact data not found');
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(
                              0xFFFFA000), // Background color of the button
                          borderRadius:
                              BorderRadius.circular(8), // Border radius
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              16.0), // Padding inside the container
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.phone,
                                color: Colors.white, // Icon color
                                size: 30, // Icon size
                              ),
                              SizedBox(
                                  width: 10), // Space between icon and text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Call Emergency Contact',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18, // Main text font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            4), // Space between lines of text
                                    Text(
                                      'Call your contact',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize:
                                            14, // Description text font size
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Space between the two buttons
                  // New Button - Share Location
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
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

                          // Loop through the contacts to find the first available contact number
                          for (int i = 1; i <= 5; i++) {
                            String contactKey = 'contact_$i';
                            if (contactData!.containsKey(contactKey)) {
                              String? contactNumber = contactData[contactKey];
                              if (contactNumber != null &&
                                  contactNumber.isNotEmpty) {
                                print(
                                    'Sending SMS to Contact $i: $contactNumber');

                                // Send an SMS to the contact number
                                await _sendSMS(contactNumber);
                                return;
                              }
                            }
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No contact set'),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContactPage()),
                          );
                        } else {
                          print('Contact data not found');
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF007BFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.message,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Send Emergency SMS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Send SMS with your location',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewMedicalInfoPage()),
                  );
                }, // Handle the tap event
                child: Container(
                  width: double.infinity, // Full width
                  decoration: BoxDecoration(
                    color: Colors.blue, // Background color of the button
                    borderRadius: BorderRadius.circular(8), // Border radius
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        16.0), // Padding inside the container
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          MdiIcons.medicalBag,
                          color: Colors.white, // Icon color
                          size: 30, // Icon size
                        ),
                        SizedBox(width: 10), // Space between icon and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Health Info',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18, // Main text font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                  height: 4), // Space between lines of text
                              Text(
                                'Doctor, Allergies, Medications, and Condition',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14, // Description text font size
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Space between buttons

            // Row with two GestureDetectors side by side
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      PermissionStatus status = await Permission.phone.status;
                      if (status.isGranted) {
                        try {
                          _makePhoneCall('100'); // Firefighter emergency number
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to make call: $e'),
                            ),
                          );
                        }
                      } else {
                        if (await Permission.phone.request().isGranted) {
                          _makePhoneCall('100');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Phone call permission is required to make calls'),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 60) /
                          2, // Adjust width for side-by-side
                      decoration: BoxDecoration(
                        color: Color(0xFF3045D3), // Background color
                        borderRadius: BorderRadius.circular(8), // Border radius
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            16.0), // Padding inside the container
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center the content vertically
                          children: [
                            Icon(
                              MdiIcons.policeBadge,
                              color: Colors.white, // Icon color
                              size: 40, // Icon size
                            ),
                            SizedBox(height: 10), // Space between icon and text
                            Text(
                              'Call Police', // Text to display below the icon
                              style: TextStyle(
                                color: Colors.white, // Text color
                                fontSize: 18, // Main text font size
                                fontWeight: FontWeight.bold, // Text weight
                              ),
                              textAlign:
                                  TextAlign.center, // Center align the text
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      PermissionStatus status = await Permission.phone.status;
                      if (status.isGranted) {
                        try {
                          _makePhoneCall('101'); // Firefighter emergency number
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to make call: $e'),
                            ),
                          );
                        }
                      } else {
                        if (await Permission.phone.request().isGranted) {
                          _makePhoneCall('101');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Phone call permission is required to make calls'),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 60) /
                          2, // Adjust width for side-by-side
                      decoration: BoxDecoration(
                        color: Color(0xFF3045D3), // Background color
                        borderRadius: BorderRadius.circular(8), // Border radius
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            16.0), // Padding inside the container
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center the content vertically
                          children: [
                            Icon(
                              MdiIcons.fireTruck,
                              color: Colors.white, // Icon color
                              size: 40, // Icon size
                            ),
                            SizedBox(height: 10), // Space between icon and text
                            Text(
                              'Call Firefigher', // Text to display below the icon
                              style: TextStyle(
                                color: Colors.white, // Text color
                                fontSize: 18, // Main text font size
                                fontWeight: FontWeight.bold, // Text weight
                              ),
                              textAlign:
                                  TextAlign.center, // Center align the text
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20), // Space between rows

            // Centered GestureDetector below the row
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    PermissionStatus status = await Permission.phone.status;
                    if (status.isGranted) {
                      try {
                        _makePhoneCall('102'); // Firefighter emergency number
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to make call: $e'),
                          ),
                        );
                      }
                    } else {
                      if (await Permission.phone.request().isGranted) {
                        _makePhoneCall('102');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Phone call permission is required to make calls'),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 60) /
                        2, // Adjust width for side-by-side
                    decoration: BoxDecoration(
                      color: Color(0xFF3045D3), // Background color
                      borderRadius: BorderRadius.circular(8), // Border radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          16.0), // Padding inside the container
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the content vertically
                        children: [
                          Icon(
                            MdiIcons.ambulance, // Icon to display
                            color: Colors.white, // Icon color
                            size: 40, // Icon size
                          ),
                          SizedBox(height: 10), // Space between icon and text
                          Text(
                            'Call Ambulance', // Text to display below the icon
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18, // Main text font size
                              fontWeight: FontWeight.bold, // Text weight
                            ),
                            textAlign:
                                TextAlign.center, // Center align the text
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            SizedBox(height: 20), // Space between rows
          ],
        ),
      ),
    );
  }
}
