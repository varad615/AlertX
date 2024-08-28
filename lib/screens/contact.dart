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

  final _contact1Controller = TextEditingController();
  final _contact2Controller = TextEditingController();
  final _contact3Controller = TextEditingController();
  final _contact4Controller = TextEditingController();
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
          _contact1Controller.text = contactData?['contact_1'] ?? '';
          _contact2Controller.text = contactData?['contact_2'] ?? '';
          _contact3Controller.text = contactData?['contact_3'] ?? '';
          _contact4Controller.text = contactData?['contact_4'] ?? '';
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
          'contact_1': _contact1Controller.text,
          'contact_2': _contact2Controller.text,
          'contact_3': _contact3Controller.text,
          'contact_4': _contact4Controller.text,
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _contact1Controller,
              decoration: InputDecoration(
                labelText: 'Contact 1',
              ),
            ),
            TextFormField(
              controller: _contact2Controller,
              decoration: InputDecoration(
                labelText: 'Contact 2',
              ),
            ),
            TextFormField(
              controller: _contact3Controller,
              decoration: InputDecoration(
                labelText: 'Contact 3',
              ),
            ),
            TextFormField(
              controller: _contact4Controller,
              decoration: InputDecoration(
                labelText: 'Contact 4',
              ),
            ),
            TextFormField(
              controller: _contact5Controller,
              decoration: InputDecoration(
                labelText: 'Contact 5',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setContacts,
              child: Text('Set Contacts'),
            ),
          ],
        ),
      ),
    );
  }
}
