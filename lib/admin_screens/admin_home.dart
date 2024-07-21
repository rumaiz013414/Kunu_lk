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
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.yellow[700], // Darker yellow for AppBar
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.yellow[100], // Subtle yellow background for the Drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.yellow[200], // Light yellow for DrawerHeader
                ),
                child: Text(
                  'Home',
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
              ),
              ListTile(
                leading: Icon(Icons.route, color: Colors.yellow[800]),
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
                leading: Icon(Icons.people, color: Colors.yellow[800]),
                title: Text('Manage Customers'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewCustomersPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.yellow[800]),
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
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout'),
                onTap: () {
                  _logout(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.yellow[50], // Very subtle yellow background for the body
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: Icon(Icons.route, color: Colors.yellow[800]),
                    title: Text('Number of Garbage Routes'),
                    trailing: Text('$garbageRoutesCount'),
                  ),
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

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: Icon(Icons.people, color: Colors.yellow[800]),
                    title: Text('Number of Customers'),
                    trailing: Text('$customersCount'),
                  ),
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

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: Icon(Icons.person, color: Colors.yellow[800]),
                    title: Text('Number of Garbage Collectors'),
                    trailing: Text('$garbageCollectorsCount'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
