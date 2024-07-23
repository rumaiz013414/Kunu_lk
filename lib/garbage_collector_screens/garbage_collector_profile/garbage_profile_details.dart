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
    return Scaffold(
      appBar: AppBar(
        title: Text('Garbage Collector Profile'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                          onTap: navigateToGarbageProfilePhotoPage,
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
                                  leading: Icon(Icons.directions_car),
                                  title: Text('Vehicle Details'),
                                  subtitle: Text(
                                      userData['vehicle_details'] ?? 'N/A'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.credit_card),
                                  title: Text('NIC'),
                                  subtitle: Text(userData['nic_no'] ?? 'N/A'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.location_city),
                                  title: Text('City'),
                                  subtitle:
                                      Text(userData['collector_city'] ?? 'N/A'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.location_on),
                                  title: Text('Postal Code'),
                                  subtitle: Text(
                                      userData['collector_postal_code'] ??
                                          'N/A'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.home),
                                  title: Text('Address'),
                                  subtitle: Text(
                                      userData['collector_address'] ?? 'N/A'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: navigateToEditProfilePage,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            child: Text('Edit Details',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: logout,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            child:
                                Text('Logout', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
