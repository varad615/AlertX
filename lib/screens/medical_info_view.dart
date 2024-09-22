import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this package in pubspec.yaml

class ViewMedicalInfoPage extends StatefulWidget {
  @override
  _ViewMedicalInfoPageState createState() => _ViewMedicalInfoPageState();
}

class _ViewMedicalInfoPageState extends State<ViewMedicalInfoPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _medicalInfo; // Store fetched data here

  @override
  void initState() {
    super.initState();
    _fetchMedicalInfo();
  }

  Future<void> _fetchMedicalInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('medicalinfo')
          .get();

      if (doc.exists) {
        setState(() {
          _medicalInfo = doc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  // Function to launch phone dialer
  void _callDoctor(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _medicalInfo == null
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  _buildInfoCard('Doctor\'s Name', _medicalInfo?['doctor_name']),
                  _buildDoctorPhoneCard(_medicalInfo?['doctor_phone']),
                  _buildInfoCard('Blood Group', _medicalInfo?['blood_group']),
                  _buildArrayInfoCard('Allergies', _medicalInfo?['allergies']),
                  _buildInfoCard('Condition', _medicalInfo?['condition']),
                  _buildArrayInfoCard('Medications', _medicalInfo?['medication']),
                ],
              ),
      ),
    );
  }

  // Card widget for doctor's phone number with a call button if data is available
  Widget _buildDoctorPhoneCard(String? phoneNumber) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0, // No elevation
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue, width: 2), // Blue border
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Doctor's Phone Number",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              phoneNumber?.isNotEmpty == true ? phoneNumber! : 'No information added',
              style: TextStyle(fontSize: 14),
            ),
            if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () => _callDoctor(phoneNumber),
                icon: Icon(Icons.call),
                label: Text('Call Doctor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Generic card builder for string fields
  Widget _buildInfoCard(String title, String? value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0, // No elevation
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue, width: 2), // Blue border
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value?.isNotEmpty == true ? value! : 'No information added'),
      ),
    );
  }

  // Card builder for array fields like allergies and medications
  Widget _buildArrayInfoCard(String title, List<dynamic>? values) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0, // No elevation
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue, width: 2), // Blue border
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            if (values == null || values.isEmpty)
              Text('No information added', style: TextStyle(fontSize: 14))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: values
                    .map((value) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            value.toString(),
                            style: TextStyle(fontSize: 14),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
