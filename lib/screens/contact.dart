import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _contact1nameController = TextEditingController();
  final _contact1Controller = TextEditingController();
  final _contact2nameController = TextEditingController();
  final _contact2Controller = TextEditingController();
  final _contact3nameController = TextEditingController();
  final _contact3Controller = TextEditingController();
  final _contact4nameController = TextEditingController();
  final _contact4Controller = TextEditingController();
  final _contact5nameController = TextEditingController();
  final _contact5Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContactData();
  }

  Future<void> _fetchContactData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        final contactDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('contact')
            .doc('contacts')
            .get();

        if (contactDoc.exists) {
          final contactData = contactDoc.data();
          _contact1nameController.text = contactData?['contact_1_name'] ?? '';
          _contact1Controller.text = contactData?['contact_1'] ?? '';
          _contact2nameController.text = contactData?['contact_2_name'] ?? '';
          _contact2Controller.text = contactData?['contact_2'] ?? '';
          _contact3nameController.text = contactData?['contact_3_name'] ?? '';
          _contact3Controller.text = contactData?['contact_3'] ?? '';
          _contact4nameController.text = contactData?['contact_4_name'] ?? '';
          _contact4Controller.text = contactData?['contact_4'] ?? '';
          _contact5nameController.text = contactData?['contact_5_name'] ?? '';
          _contact5Controller.text = contactData?['contact_5'] ?? '';
        }
      } catch (e) {
        print('Error fetching contact data: $e');
      }
    }
  }

  Future<void> _setContacts() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('contact')
            .doc('contacts')
            .update({
          'contact_1_name': _contact1nameController.text,
          'contact_1': _contact1Controller.text,
          'contact_2_name': _contact2nameController.text,
          'contact_2': _contact2Controller.text,
          'contact_3_name': _contact3nameController.text,
          'contact_3': _contact3Controller.text,
          'contact_4_name': _contact4nameController.text,
          'contact_4': _contact4Controller.text,
          'contact_5_name': _contact5nameController.text,
          'contact_5': _contact5Controller.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contacts updated successfully')),
        );
      } catch (e) {
        print('Error updating contact data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating contacts')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Information'),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0), // Add padding only to left and right
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _contact1nameController,
                        decoration: InputDecoration(
                          labelText: 'Contact 1 Name',
                        ),
                      ),
                      TextFormField(
                        controller: _contact1Controller,
                        decoration: InputDecoration(
                          labelText: 'Contact 1 Number',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _contact2nameController,
                        decoration: InputDecoration(
                          labelText: 'Contact 2 Name',
                        ),
                      ),
                      TextFormField(
                        controller: _contact2Controller,
                        decoration: InputDecoration(
                          labelText: 'Contact 2 Number',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _contact3nameController,
                        decoration: InputDecoration(
                          labelText: 'Contact 3 Name',
                        ),
                      ),
                      TextFormField(
                        controller: _contact3Controller,
                        decoration: InputDecoration(
                          labelText: 'Contact 3 Number',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _contact4nameController,
                        decoration: InputDecoration(
                          labelText: 'Contact 4 Name',
                        ),
                      ),
                      TextFormField(
                        controller: _contact4Controller,
                        decoration: InputDecoration(
                          labelText: 'Contact 4 Number',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _contact5nameController,
                        decoration: InputDecoration(
                          labelText: 'Contact 5 Name',
                        ),
                      ),
                      TextFormField(
                        controller: _contact5Controller,
                        decoration: InputDecoration(
                          labelText: 'Contact 5 Number',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _setContacts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3045D3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),elevation: 0,shadowColor: Colors.transparent
                  ),
                  child: Text('Set Contacts', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
