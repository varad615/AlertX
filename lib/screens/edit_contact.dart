import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactViewPage extends StatefulWidget {
  @override
  _ContactViewPageState createState() => _ContactViewPageState();
}

class _ContactViewPageState extends State<ContactViewPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final _contact1name = '';
  final _contact1 = '';
  final _contact2name = '';
  final _contact2 = '';
  final _contact3name = '';
  final _contact3 = '';
  final _contact4name = '';
  final _contact4 = '';
  final _contact5name = '';
  final _contact5 = '';

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
          setState(() {
            _contact1name = contactData?['contact_1_name'] ?? '';
            _contact1 = contactData?['contact_1'] ?? '';
            _contact2name = contactData?['contact_2_name'] ?? '';
            _contact2 = contactData?['contact_2'] ?? '';
            _contact3name = contactData?['contact_3_name'] ?? '';
            _contact3 = contactData?['contact_3'] ?? '';
            _contact4name = contactData?['contact_4_name'] ?? '';
            _contact4 = contactData?['contact_4'] ?? '';
            _contact5name = contactData?['contact_5_name'] ?? '';
            _contact5 = contactData?['contact_5'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching contact data: $e');
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
                      Text('Contact 1 Name: $_contact1name'),
                      Text('Contact 1 Number: $_contact1'),
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
                      Text('Contact 2 Name: $_contact2name'),
                      Text('Contact 2 Number: $_contact2'),
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
                      Text('Contact 3 Name: $_contact3name'),
                      Text('Contact 3 Number: $_contact3'),
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
                      Text('Contact 4 Name: $_contact4name'),
                      Text('Contact 4 Number: $_contact4'),
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
                      Text('Contact 5 Name: $_contact5name'),
                      Text('Contact 5 Number: $_contact5'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}