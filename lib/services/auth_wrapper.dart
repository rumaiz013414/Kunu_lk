import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../garbage_collector_screens/garbage_collector_home.dart';
import '../customer_screens/customer_home.dart';
import '../admin_screens/admin_home.dart';
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
                  } else if (role == 'admin') {
                    return AdminHome();
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

  Future<String?> getUserRole(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) {
        print('User document does not exist for uid: ${user.uid}');
        return null;
      }
      final data = doc.data();
      if (data == null || !data.containsKey('role')) {
        print('No role found in user document for uid: ${user.uid}');
        return null;
      }
      return data['role'] as String?;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }
}
