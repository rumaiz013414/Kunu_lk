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

  String name = '';
  String address = '';
  String phoneNumber = '';
  String postalCode = '';
  String nic = '';

  void saveCustomerInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestore.collection('users').doc(widget.user.uid).update({
          'name': name,
          'address': address,
          'phone_number': phoneNumber,
          'postal_code': postalCode,
          'nic_no': nic,
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
          child: Column(
            children: [
              TextFormField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(hintText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
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
