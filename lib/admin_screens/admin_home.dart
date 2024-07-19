import 'package:flutter/material.dart';
import './manage_garbage_routes.dart';
import './view_customers.dart'; // Placeholder for the manage customers page
import './view_garbage_collectors.dart'; // Placeholder for the manage garbage collectors page

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  void _logout(BuildContext context) {
    // Implement your logout functionality here
    // For example, you might want to clear user data and navigate to the login page
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Adjust this to your login route
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
      body: Center(
        child: Text('Welcome, Admin!'),
      ),
    );
  }
}
