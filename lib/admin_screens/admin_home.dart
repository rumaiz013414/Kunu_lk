import 'package:flutter/material.dart';
import './manage_garbage_routes.dart';
import 'manage_customers.dart';
import 'manage_garbage_collectors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _garbageRoutesStream;
  late Stream<QuerySnapshot> _customersStream;
  late Stream<QuerySnapshot> _garbageCollectorsStream;

  @override
  void initState() {
    super.initState();
    _garbageRoutesStream = _firestore.collection('garbage_routes').snapshots();
    _customersStream = _firestore
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .snapshots();
    _garbageCollectorsStream = _firestore
        .collection('users')
        .where('role', isEqualTo: 'garbage_collector')
        .snapshots();
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.route),
              title: Text('Manage Routes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ManageGarbageRoutesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Manage Customers'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewCustomersPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Manage Garbage Collectors'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewGarbageCollectorsPage()),
                );
              },
            ),
            Divider(), // Optional divider to separate the logout option
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _garbageRoutesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final garbageRoutesCount = snapshot.data?.docs.length ?? 0;

              return ListTile(
                leading: Icon(Icons.route),
                title: Text('number of Garbage Routes'),
                trailing: Text('$garbageRoutesCount'),
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _customersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final customersCount = snapshot.data?.docs.length ?? 0;

              return ListTile(
                leading: Icon(Icons.people),
                title: Text('Number of Customers'),
                trailing: Text('$customersCount'),
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _garbageCollectorsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final garbageCollectorsCount = snapshot.data?.docs.length ?? 0;

              return ListTile(
                leading: Icon(Icons.person),
                title: Text('Number of Garbage Collectors'),
                trailing: Text('$garbageCollectorsCount'),
              );
            },
          ),
        ],
      ),
    );
  }
}
