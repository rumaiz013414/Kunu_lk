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
  String collectorAddress = '';
  String collectorCity = '';
  String collectorPostalCode = '';

  void saveGarbageCollectorInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestore.collection('users').doc(widget.user.uid).update({
          'name': name,
          'phone_number': phoneNumber,
          'vehicle_details': vehicleDetails,
          'nic_no': nic,
          'collector_address': collectorAddress,
          'collector_city': collectorCity,
          'collector_postal_code': collectorPostalCode,
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
        title: Text('Enter Your Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Phone Number',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Vehicle Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onChanged: (value) {
                    vehicleDetails = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your vehicle details (License Plate No)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your vehicle details';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'NIC No',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onChanged: (value) {
                    nic = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your NIC number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your NIC number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onChanged: (value) {
                    collectorAddress = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your address',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'City',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onChanged: (value) {
                    collectorCity = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your city',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Postal Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onChanged: (value) {
                    collectorPostalCode = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your postal code',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your postal code';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: saveGarbageCollectorInfo,
                    child: Text('Save Information'),
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
