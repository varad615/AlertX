// import 'package:alertx/screens/contact.dart';
// import 'package:alertx/screens/profile.dart';
import 'package:alertx/screens/contact.dart';
import 'package:alertx/screens/demo.dart';
import 'package:alertx/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

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
                    onPressed: () {
                      // Handle second button press
                    },
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
            MaterialPageRoute(builder: (context) => ContactPage()),
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
