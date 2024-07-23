import 'package:flutter/material.dart';
import 'customer_profile/customer_profile_details.dart';
import 'customer_routes.dart';
import 'customer_home_page.dart';

class CustomerHomePage extends StatefulWidget {
  final int initialIndex;

  const CustomerHomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = [
    HomePage(subscribedRoutes: []), // Pass empty list initially
    CustomerRoutesPage(),
    CustomerProfileDetails(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9C4),
      // Banana yellow background color
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'Collection Routes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(
            255, 185, 162, 27), // Subtle banana yellow for selected item
        unselectedItemColor: Colors.black, // Unselected item color
        backgroundColor:
            Color(0xFFFDF6C4), // Light banana yellow for the background
        onTap: _onItemTapped,
      ),
    );
  }
}
