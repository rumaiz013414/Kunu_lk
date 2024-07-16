import 'package:flutter/material.dart';
import './create_garbage_route.dart';
import './view_customers.dart'; // Placeholder for the manage customers page
import './view_garbage_collectors.dart'; // Placeholder for the manage garbage collectors page

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.route),
              title: Text('Add Routes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateGarbageRoutePage()),
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
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome, Admin!'),
      ),
    );
  }
}
