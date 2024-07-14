import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GarbageCollectorInfoFormPage extends StatefulWidget {
  final User user;

  GarbageCollectorInfoFormPage({required this.user});

  @override
  _GarbageCollectorInfoFormPageState createState() =>
      _GarbageCollectorInfoFormPageState();
}

class _GarbageCollectorInfoFormPageState
    extends State<GarbageCollectorInfoFormPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String phoneNumber = '';
  String vehicleDetails = '';
  String nic = '';

  void saveGarbageCollectorInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestore.collection('users').doc(widget.user.uid).update({
          'name': name,
          'phone_number': phoneNumber,
          'vehicle_details': vehicleDetails,
          'nic_no': nic,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Information saved successfully.')),
        );

        Navigator.pushReplacementNamed(context, '/garbageCollectorHome');
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
                  vehicleDetails = value;
                },
                decoration: InputDecoration(hintText: 'Vehicle Details'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle details';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  nic = value;
                },
                decoration: InputDecoration(hintText: 'NIC No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your NIC number';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: saveGarbageCollectorInfo,
                child: Text('Save Information'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
