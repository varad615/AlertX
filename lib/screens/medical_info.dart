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
  final TextEditingController _conditionController = TextEditingController();

  String? _selectedBloodGroup;
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  // Dynamic list controllers for allergies and medications
  List<TextEditingController> _allergiesControllers = [];
  List<TextEditingController> _medicationsControllers = [];

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
        _conditionController.text = data['condition'] ?? '';
        _selectedBloodGroup = data['blood_group'] ?? _bloodGroups.first;

        // Populate the allergies list
        List<dynamic> allergies = data['allergies'] ?? [];
        _allergiesControllers = allergies
            .map((allergy) => TextEditingController(text: allergy))
            .toList();

        // Populate the medications list
        List<dynamic> medications = data['medication'] ?? [];
        _medicationsControllers = medications
            .map((medication) => TextEditingController(text: medication))
            .toList();

        // Ensure at least one controller exists for both allergies and medications
        if (_allergiesControllers.isEmpty) {
          _allergiesControllers.add(TextEditingController());
        }
        if (_medicationsControllers.isEmpty) {
          _medicationsControllers.add(TextEditingController());
        }

        setState(() {});
      }
    }
  }

  Future<void> _updateMedicalInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Convert controllers to a list of strings
      List<String> allergies =
          _allergiesControllers.map((controller) => controller.text).toList();
      List<String> medications =
          _medicationsControllers.map((controller) => controller.text).toList();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('medicalinfo')
          .update({
        'doctor_name': _doctorNameController.text,
        'doctor_phone': _doctorPhoneController.text,
        'blood_group': _selectedBloodGroup,
        'allergies': allergies,
        'condition': _conditionController.text,
        'medication': medications,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medical info updated successfully!')));
    }
  }

  // Add/Remove allergy fields
  void _addAllergyField() {
    setState(() {
      _allergiesControllers.add(TextEditingController());
    });
  }

  void _removeAllergyField(int index) {
    if (_allergiesControllers.length > 1) {
      setState(() {
        _allergiesControllers.removeAt(index);
      });
    }
  }

  // Add/Remove medication fields
  void _addMedicationField() {
    setState(() {
      _medicationsControllers.add(TextEditingController());
    });
  }

  void _removeMedicationField(int index) {
    if (_medicationsControllers.length > 1) {
      setState(() {
        _medicationsControllers.removeAt(index);
      });
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
              // Doctor Info
              Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _doctorNameController,
                        decoration: InputDecoration(
                          labelText: "Doctor's Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _doctorPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Doctor's Phone Number",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _bloodGroups.contains(_selectedBloodGroup)
                            ? _selectedBloodGroup
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Blood Group',
                          border: OutlineInputBorder(),
                        ),
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
                    ],
                  ),
                ),
              ),

              // Allergies Section
              Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('Allergies:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _allergiesControllers.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              SizedBox(height: 10), // Top spacing
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _allergiesControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Allergy',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  if (_allergiesControllers.length > 1)
                                    IconButton(
                                      icon: Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _removeAllergyField(index),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      TextButton.icon(
                        onPressed: _addAllergyField,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text('Add More',
                            style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Medications Section
              Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('Medications:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _medicationsControllers.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              SizedBox(height: 10), // Top spacing
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          _medicationsControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Medication',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  if (_medicationsControllers.length > 1)
                                    IconButton(
                                      icon: Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _removeMedicationField(index),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      TextButton.icon(
                        onPressed: _addMedicationField,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text('Add More',
                            style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Condition Section
              Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _conditionController,
                    decoration: InputDecoration(
                      labelText: 'My Condition',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Update Button
              ElevatedButton(
                onPressed: _updateMedicalInfo,
                child: Text('Update Medical Info',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: Size(double.infinity, 50), // Full-width button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
