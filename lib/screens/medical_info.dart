import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalInfoPage extends StatefulWidget {
  @override
  _MedicalInfoPageState createState() => _MedicalInfoPageState();
}

class _MedicalInfoPageState extends State<MedicalInfoPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _doctorPhoneController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();

  String? _selectedBloodGroup; // Initial value can be null
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

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
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _doctorNameController.text = data['doctor_name'] ?? '';
        _doctorPhoneController.text = data['doctor_phone'] ?? '';
        _allergiesController.text = data['allergies'] ?? '';
        _conditionController.text = data['condition'] ?? '';
        _medicationController.text = data['medication'] ?? '';
        _selectedBloodGroup = data['blood_group'] ?? _bloodGroups.first; // Set a default if null
        setState(() {});
      }
    }
  }

  Future<void> _updateMedicalInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('profile').doc('medicalinfo').update({
        'doctor_name': _doctorNameController.text,
        'doctor_phone': _doctorPhoneController.text,
        'blood_group': _selectedBloodGroup,
        'allergies': _allergiesController.text,
        'condition': _conditionController.text,
        'medication': _medicationController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medical info updated successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _doctorNameController,
                decoration: InputDecoration(labelText: "Doctor's Name"),
              ),
              TextField(
                controller: _doctorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Doctor's Phone Number"),
              ),
              DropdownButtonFormField<String>(
                value: _bloodGroups.contains(_selectedBloodGroup) ? _selectedBloodGroup : null, // Check if the value is in the list
                decoration: InputDecoration(labelText: 'Blood Group'),
                items: _bloodGroups.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodGroup = newValue;
                  });
                },
              ),
              TextField(
                controller: _allergiesController,
                decoration: InputDecoration(labelText: 'Allergies'),
              ),
              TextField(
                controller: _conditionController,
                decoration: InputDecoration(labelText: 'My Condition'),
              ),
              TextField(
                controller: _medicationController,
                decoration: InputDecoration(labelText: 'My Medication'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateMedicalInfo,
                child: Text('Update Medical Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
