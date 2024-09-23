import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> _selectContact(TextEditingController nameController, TextEditingController numberController) async {
    if (await Permission.contacts.request().isGranted) {
      final Contact? contact = await ContactsService.openDeviceContactPicker();

      if (contact != null && contact.phones != null && contact.phones!.isNotEmpty) {
        setState(() {
          nameController.text = contact.displayName ?? '';
          numberController.text = contact.phones!.first.value ?? '';
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission to access contacts is denied')),
      );
    }
  }

  void _removeContact(TextEditingController nameController, TextEditingController numberController) {
    setState(() {
      nameController.clear();
      numberController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Information'),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildContactCard(
                'Contact 1 Name', _contact1nameController, _contact1Controller
              ),
              _buildContactCard(
                'Contact 2 Name', _contact2nameController, _contact2Controller
              ),
              _buildContactCard(
                'Contact 3 Name', _contact3nameController, _contact3Controller
              ),
              _buildContactCard(
                'Contact 4 Name', _contact4nameController, _contact4Controller
              ),
              _buildContactCard(
                'Contact 5 Name', _contact5nameController, _contact5Controller
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _setContacts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3045D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text('Set Contacts', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(String labelText, TextEditingController nameController, TextEditingController numberController) {
    final bool isContactSelected = nameController.text.isNotEmpty && numberController.text.isNotEmpty;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: isContactSelected
                      ? TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: labelText,
                          ),
                        )
                      : Text(
                          'No contact selected',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                ),
                IconButton(
                  icon: Icon(Icons.contact_page),
                  onPressed: () => _selectContact(nameController, numberController),
                ),
              ],
            ),
            if (isContactSelected)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      numberController.text.isEmpty ? 'Contact Number' : numberController.text,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => _removeContact(nameController, numberController),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
