import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../../customer_screens/customer_home_routes.dart'; // Import your home screens for different roles
import '../../garbage_collector_screens/garbage_collector_home.dart';
import '../../admin_screens/admin_home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  String email = '';
  String password = '';

  void loginUser() async {
    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email and password fields cannot be empty.')),
        );
      }
      return;
    }

    try {
      User? user =
          await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        if (!user.emailVerified) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please verify your email first.')),
            );
          }
          return;
        }
        navigateBasedOnUserRole(user);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid e-mail or password')),
        );
      }
    }
  }

  void navigateBasedOnUserRole(User user) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final String? role = userDoc['role'];
        print("User role: $role"); // Debug log

        if (role != null) {
          if (mounted) {
            switch (role) {
              case 'customer':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerHomePage()),
                );
                break;
              case 'garbage_collector':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GarbageCollectorHomePage()),
                );
                break;
              case 'admin':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminHome()),
                );
                break;
              default:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unknown role: $role')),
                );
                break;
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Role is null')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User document does not exist')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get user role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
            ElevatedButton(
              onPressed: loginUser,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/reset');
              },
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
