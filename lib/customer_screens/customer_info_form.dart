import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerInfoFormPage extends StatefulWidget {
  final User user;

  CustomerInfoFormPage({required this.user});

  @override
  _CustomerInfoFormPageState createState() => _CustomerInfoFormPageState();
}

class _CustomerInfoFormPageState extends State<CustomerInfoFormPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isTermsAccepted = false;

  String firstName = '';
  String lastName = '';
  String address = '';
  String phoneNumber = '';
  String postalCode = '';
  String nic = '';
  String city = '';

  void saveCustomerInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_isTermsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You must accept the terms and conditions.')),
        );
        return;
      }

      try {
        await _firestore.collection('users').doc(widget.user.uid).update({
          'first_name': firstName,
          'last_name': lastName,
          'address': address,
          'phone_number': phoneNumber,
          'postal_code': postalCode,
          'nic_no': nic,
          'city': city,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Information saved successfully.')),
        );

        Navigator.pushReplacementNamed(context, '/customerHome');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save information. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Enter Your Information')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                onChanged: (value) {
                  firstName = value;
                },
                decoration: InputDecoration(hintText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  lastName = value;
                },
                decoration: InputDecoration(hintText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  address = value;
                },
                decoration: InputDecoration(hintText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  phoneNumber = value;
                },
                decoration: InputDecoration(hintText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  postalCode = value;
                },
                decoration: InputDecoration(hintText: 'Postal Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your postal code';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  nic = value;
                },
                decoration: InputDecoration(hintText: 'NIC No.'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your NIC number';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  city = value;
                },
                decoration: InputDecoration(hintText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: Text("I accept the terms and conditions"),
                value: _isTermsAccepted,
                onChanged: (newValue) {
                  setState(() {
                    _isTermsAccepted = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveCustomerInfo,
                child: Text('Save Information'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
