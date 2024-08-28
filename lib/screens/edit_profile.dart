import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _insuranceNoController = TextEditingController();
  final TextEditingController _medicalIdController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() async {
    _user = _auth.currentUser;
    setState(() {}); // Call setState to rebuild the widget tree
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('data')
          .update({
        'name': _nameController.text,
        'phone_number': _phoneNumberController.text,
        'dob': _dobController.text,
        'insurance_no': _insuranceNoController.text,
        'medical_id': _medicalIdController.text,
      });
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
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
                if (streamSnapshot.hasError) {
                  return Center(child: Text('Error: ${streamSnapshot.error}'));
                }
                if (!streamSnapshot.hasData || !streamSnapshot.data!.exists) {
                  return Center(child: Text('No user data found'));
                }

                final userData = streamSnapshot.data!;
                _nameController.text = userData['name'] ?? '';
                _phoneNumberController.text = userData['phone_number'] ?? '';
                _dobController.text = userData['dob'] ?? '';
                _insuranceNoController.text = userData['insurance_no'] ?? '';
                _medicalIdController.text = userData['medical_id'] ?? '';

                return SingleChildScrollView(
                  // Wrap with SingleChildScrollView
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _dobController,
                              decoration: InputDecoration(
                                labelText: 'Date of Birth',
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _insuranceNoController,
                          decoration: InputDecoration(
                            labelText: 'Insurance Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _medicalIdController,
                          decoration: InputDecoration(
                            labelText: 'Medical ID',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xFF3045D3), // Button background color
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12), // Border radius
                              ),
                              elevation: 0, // Remove shadow
                              shadowColor:
                                  Colors.transparent, // No shadow color
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Update Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ), // Button text color
                              ),
                            ),
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
