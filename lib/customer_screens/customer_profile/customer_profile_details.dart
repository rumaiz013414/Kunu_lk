import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_profile_photo.dart';
import 'edit_customer_profile.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
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
                      SizedBox(height: 20),
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email: ${userData['email']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Name: ${userData['name']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Phone: ${userData['phone_number']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Address: ${userData['address']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Postal Code: ${userData['postal_code']}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: navigateToEditProfilePage,
                icon: Icon(Icons.edit),
                label: Text('Edit Details'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: logout,
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.red,
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
