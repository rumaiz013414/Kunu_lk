import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../garbage_collector_screens/garbage_collector_home.dart';
import '../customer_screens/customer_home.dart';
import '../authentication_screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          User? user = snapshot.data;
          if (user != null) {
            // Ensure the collector's document exists
            ensureCollectorDocumentExists(user);

            return FutureBuilder<String?>(
              future: getUserRole(user),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (roleSnapshot.hasData) {
                  String? role = roleSnapshot.data;

                  if (role == 'customer') {
                    return CustomerHomePage();
                  } else if (role == 'garbage_collector') {
                    return GarbageCollectorHomePage();
                  } else {
                    return Center(child: Text('Unknown role'));
                  }
                } else if (roleSnapshot.hasError) {
                  return Center(child: Text('Error: ${roleSnapshot.error}'));
                }

                return Center(child: Text('No role assigned'));
              },
            );
          }
        }

        return LoginPage();
      },
    );
  }

  Future<void> ensureCollectorDocumentExists(User user) async {
    final docRef = FirebaseFirestore.instance
        .collection('garbage_collectors')
        .doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'collector_city': '',
        'collector_postal_code': '',
        'created_at': Timestamp.now(),
        'email': user.email,
        'name': '',
        'nic_no': '',
        'phone_number': '',
        'postal_code': '',
        'profilePicture': '',
        'role': 'garbage_collector',
        'vehicle_details': '',
        'verified': false,
        'location': GeoPoint(0, 0), // Default location
        'assigned_routes': [],
      });
    }
  }

  Future<String?> getUserRole(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }
}
