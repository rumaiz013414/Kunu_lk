import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_garbage_profile.dart'; // Import the edit profile screen
import 'garbage_profile_photo.dart'; // Import the profile photo screen

class GarbageCollectorProfileSection extends StatefulWidget {
  @override
  _GarbageCollectorProfileSectionState createState() =>
      _GarbageCollectorProfileSectionState();
}

class _GarbageCollectorProfileSectionState
    extends State<GarbageCollectorProfileSection> {
  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void navigateToGarbageProfilePhotoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GarbageProfilePhotoPage()),
    );
  }

  void navigateToEditProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditGarbageProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Text('User data not found');
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                children: [
                  GestureDetector(
                    onTap:
                        navigateToGarbageProfilePhotoPage, // Navigate to the profile photo screen
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: userData['profilePicture'] != null
                          ? NetworkImage(userData['profilePicture'])
                          : null,
                      child: userData['profilePicture'] == null
                          ? Icon(Icons.person, size: 75)
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Email: ${userData['email']}'),
                  Text('Name: ${userData['name']}'),
                  Text('Phone: ${userData['phone_number']}'),
                  Text('Vehicle Details: ${userData['vehicle_details']}'),
                  Text('NIC: ${userData['nic_no']}'),
                  Text('City: ${userData['collector_city']}'),
                  Text('Postal Code: ${userData['collector_postal_code']}'),
                  Text('Address: ${userData['collector_address']}'),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: navigateToEditProfilePage,
            child: Text('Edit Details'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: logout,
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
