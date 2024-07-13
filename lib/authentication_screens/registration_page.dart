import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../customer_screens/customer_home.dart';
import '../garbage_collector_screens/garbage_collector_home.dart';
import '../admin_screens/admin_home.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String email = '';
  String password = '';
  String role = 'customer';

  void registerUser() async {
    try {
      User? user =
          await _authService.registerWithEmailAndPassword(email, password);
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          'verified': false,
          'created_at': FieldValue.serverTimestamp(),
        });

        await user.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Registration successful. Please verify your email.')),
        );

        // Navigate to the appropriate home screen based on role
        switch (role) {
          case 'customer':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CustomerHome()),
            );
            break;
          case 'garbage_collector':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GarbageCollectorHome()),
            );
            break;
          case 'admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminHome()),
            );
            break;
          default:
            // Navigate to default page or handle error case
            break;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                email = value;
              },
              decoration: InputDecoration(hintText: 'Email'),
            ),
            TextField(
              onChanged: (value) {
                password = value;
              },
              decoration: InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: role,
              items: <String>['customer', 'garbage_collector', 'admin']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  role = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: registerUser,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
