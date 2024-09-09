import 'package:alertx/screens/contact.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactViewPage extends StatefulWidget {
  @override
  _ContactViewPageState createState() => _ContactViewPageState();
}

class _ContactViewPageState extends State<ContactViewPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _contact1name = '';
  late String _contact1 = '';
  late String _contact2name = '';
  late String _contact2 = '';
  late String _contact3name = '';
  late String _contact3 = '';
  late String _contact4name = '';
  late String _contact4 = '';
  late String _contact5name = '';
  late String _contact5 = '';

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
  Future<void> _makePhoneCall(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Information'),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            left: 10.0, right: 10.0), // Add padding only to left and right
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: 5,

                itemBuilder: (context, index) {
                  String contactName = '';
                  String contactNumber = '';

                  switch (index) {
                    case 0:
                      contactName = _contact1name;
                      contactNumber = _contact1;
                      break;
                    case 1:
                      contactName = _contact2name;
                      contactNumber = _contact2;
                      break;
                    case 2:
                      contactName = _contact3name;
                      contactNumber = _contact3;
                      break;
                    case 3:
                      contactName = _contact4name;
                      contactNumber = _contact4;
                      break;
                    case 4:
                      contactName = _contact5name;
                      contactNumber = _contact5;
                      break;
                  }

                  if (contactNumber.isNotEmpty) {
                    return ListTile(
                      title: Text('Contact ${index + 1}'),
                      subtitle:
                          Text('Name: $contactName \n Number: $contactNumber'),
                      leading: Icon(Icons.contacts_rounded),
                      trailing: IconButton(

                          onPressed: () {
                            _makePhoneCall(contactNumber);
                          },
                          icon: Icon(MdiIcons.phone)),

                    );
                  } else {
                    return Container(); // Return an empty container if contact is null
                  }
                },

              ),
            ],
          ),
        ),
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
          'Add Contact',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),    );
  }
}
