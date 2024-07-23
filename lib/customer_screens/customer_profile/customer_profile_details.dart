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
      body: SingleChildScrollView(
        child: Padding(
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

                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          elevation: 4,
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ListTile(
                                  leading: Icon(Icons.email),
                                  title: Text('Email'),
                                  subtitle: Text(userData['email'] ?? 'N/A'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.person),
                                  title: Text('Name'),
                                  subtitle: Text(userData['name'] ?? 'N/A'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.phone),
                                  title: Text('Phone'),
                                  subtitle:
                                      Text(userData['phone_number'] ?? 'N/A'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.home),
                                  title: Text('Address'),
                                  subtitle: Text(userData['address'] ?? 'N/A'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.post_add),
                                  title: Text('Postal Code'),
                                  subtitle:
                                      Text(userData['postal_code'] ?? 'N/A'),
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
      ),
    );
  }
}
