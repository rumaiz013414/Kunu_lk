import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../authentication_screens/login_page.dart';
import '../customer_screens/customer_home.dart'; // Import your home screens for different roles
import '../garbage_collector_screens/garbage_collector_home.dart';
import '../admin_screens/admin_home.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (userSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${userSnapshot.error}')),
                );
              }
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Scaffold(
                  body: Center(child: Text('User data not found')),
                );
              }

              final String role = userSnapshot.data!['role'];
              switch (role) {
                case 'customer':
                  return CustomerHomePage();
                case 'garbage_collector':
                  return GarbageCollectorHomePage();
                case 'admin':
                  return AdminHome();
                default:
                  return Scaffold(
                    body: Center(child: Text('Unknown role')),
                  );
              }
            },
          );
        } else {
          return LoginPage();
        }
      },
    );
  }
}
