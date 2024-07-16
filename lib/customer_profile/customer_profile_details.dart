import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_profile_photo_page.dart';
import 'edit_customer_profile_page.dart';

class CustomerProfileDetails extends StatefulWidget {
  @override
  _CustomerProfileDetailsState createState() => _CustomerProfileDetailsState();
}

class _CustomerProfileDetailsState extends State<CustomerProfileDetails> {
  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void navigateToProfilePhotoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomerProfilePhotoPage()),
    );
  }

  void navigateToEditProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCustomerProfilePage()),
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
                    onTap: navigateToProfilePhotoPage,
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
                  Text('Address: ${userData['address']}'),
                  Text('Postal Code: ${userData['postal_code']}'),
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
