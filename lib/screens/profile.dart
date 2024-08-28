import 'package:alertx/screens/edit_profile.dart';
import 'package:alertx/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    _user = _auth.currentUser;
    setState(() {}); // Call setState to rebuild the widget tree
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        // actions: [
        //   IconButton(
        //     onPressed: _logout,
        //     icon: Icon(Icons.logout),
        //     tooltip: 'Logout',
        //   ),
        // ],
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_user!.uid)
            .collection('profile')
            .doc('data')
            .snapshots(),
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final userData = streamSnapshot.data;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileField(
                  icon: Icons.person,
                  label: 'Name',
                  value: userData!['name'],
                ),
                ProfileField(
                  icon: Icons.email,
                  label: 'Email',
                  value: _user!.email!,
                ),
                ProfileField(
                  icon: Icons.phone,
                  label: 'Phone Number',
                  value: userData['phone_number'],
                ),
                ProfileField(
                  icon: Icons.cake,
                  label: 'Date of Birth',
                  value: userData['dob'],
                ),
                ProfileField(
                  icon: Icons.policy,
                  label: 'Insurance Number',
                  value: userData['insurance_no'],
                ),
                ProfileField(
                  icon: Icons.medical_services,
                  label: 'Medical ID',
                  value: userData['medical_id'],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 251, 30, 30), // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12), // Border radius
                      ),
                      elevation: 0, // Remove shadow
                      shadowColor: Colors.transparent, // No shadow color
                    ),
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfileScreen()),
          );
        },
        backgroundColor: Color(0xFF3045D3),
        label: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  ProfileField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
