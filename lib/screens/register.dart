import 'package:alertx/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _insuranceNoController = TextEditingController();
  final TextEditingController _medicalIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // Confirm password controller

  bool _obscurePassword = true; // For toggling password visibility
  bool _obscureConfirmPassword = true; // For toggling confirm password visibility

  DateTime? _selectedDate;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final User? user = _auth.currentUser;
        await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('profile')
            .doc('data')
            .set({
          'name': _nameController.text,
          'phone_number': _phoneNumberController.text,
          'dob': _dobController.text,
          'insurance_no': _insuranceNoController.text,
          'medical_id': _medicalIdController.text,
        });

        // Initialize the contact collection with empty fields
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('contact')
            .doc('contacts')
            .set({
          'contact_1': '',
          'contact_1_name': '',
          'contact_2': '',
          'contact_2_name': '',
          'contact_3': '',
          'contact_3_name': '',
          'contact_4': '',
          'contact_4_name': '',
          'contact_5': '',
          'contact_5_name': '',
        });

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('medicalinfo')
            .set({
          'allergies': '',
          'blood_group': '',
          'condition': '',
          'doctor_name': '',
          'doctor_phone': '',
          'medication': '',
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        String errorMessage;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'This email address is already in use.';
              break;
            case 'invalid-email':
              errorMessage = 'This email address is invalid.';
              break;
            case 'weak-password':
              errorMessage = 'The password provided is too weak.';
              break;
            default:
              errorMessage = 'An error occurred. Please try again.';
          }
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Color(0xFF3045D3)), // Border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF3045D3)), // Focused border color
                    ),
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
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Color(0xFF3045D3)), // Border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF3045D3)), // Focused border color
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Color(0xFF3045D3)), // Border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF3045D3)), // Focused border color
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _dobController.text =
                        '${picked.day}/${picked.month}/${picked.year}';
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF3045D3)), // Border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF3045D3)), // Focused border color
                        ),
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
                    border: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Color(0xFF3045D3)), // Border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF3045D3)), // Focused border color
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _medicalIdController,
                  decoration: InputDecoration(
                    labelText: 'Medical ID',
                    border: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Color(0xFF3045D3)), // Border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF3045D3)), // Focused border color
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3045D3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3045D3)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3045D3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3045D3)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15), // Button text color
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Color(0xFF3045D3), // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12), // Border radius
                      ),
                      elevation: 0, // Remove shadow
                      shadowColor: Colors.transparent, // No shadow color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
