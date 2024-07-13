import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'authentication_screens/login_page.dart';
import 'authentication_screens/registration_page.dart';
import 'authentication_screens/password_reset_page.dart';
import 'customer_screens/customer_home.dart';
import 'garbage_collector_screens/garbage_collector_home.dart';
import 'admin_screens/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/reset': (context) => PasswordResetPage(),
        '/customerHome': (context) => CustomerHome(),
        '/garbageCollectorHome': (context) => GarbageCollectorHome(),
        '/adminHome': (context) => AdminHome(),
      },
    );
  }
}
