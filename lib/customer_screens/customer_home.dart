import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer_profile/customer_profile_details.dart';
import './subscribe_screen.dart';
import './home_page.dart'; // Ensure you have the HomePage widget created

class CustomerHomePage extends StatefulWidget {
  final int initialIndex;

  const CustomerHomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;
  List<String> _subscribedRouteIds = [];
  List<Map<String, dynamic>> _subscribedRoutes = [];
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _fetchSubscribedRoutes();
  }

  void _fetchSubscribedRoutes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        _subscribedRouteIds =
            List<String>.from(userDoc.data()?['subscribed_routes'] ?? []);
        _fetchRouteDetails();
      }
    }
  }

  void _fetchRouteDetails() async {
    List<Map<String, dynamic>> routes = [];
    for (String routeId in _subscribedRouteIds) {
      final routeDoc = await FirebaseFirestore.instance
          .collection('garbage_routes')
          .doc(routeId)
          .get();
      if (routeDoc.exists) {
        var routeData = routeDoc.data()!;
        routeData['id'] = routeDoc.id; // Add route ID to the route data
        routes.add(routeData);
      }
    }
    setState(() {
      _subscribedRoutes = routes;
      _widgetOptions = <Widget>[
        HomePage(subscribedRoutes: _subscribedRoutes),
        SubscribeScreen(),
        CustomerProfileDetails(),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.isEmpty
            ? CircularProgressIndicator()
            : _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Subscribe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
