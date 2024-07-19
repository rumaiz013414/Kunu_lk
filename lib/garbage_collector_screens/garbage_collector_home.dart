import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'garbage_collector_profile/garbage_profile_details.dart';
import 'garbage_collection_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GarbageCollectorHomePage extends StatefulWidget {
  @override
  _GarbageCollectorHomePageState createState() =>
      _GarbageCollectorHomePageState();
}

class _GarbageCollectorHomePageState extends State<GarbageCollectorHomePage> {
  int _selectedIndex = 0;
  Position? _currentPosition;
  late final User user;

  static List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    GarbageCollectionRoutes(),
    GarbageCollectorProfileSection(),
  ];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await _determinePosition();
    setState(() {
      _currentPosition = position;
    });
    _updateGarbageCollectorLocation(position);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _updateGarbageCollectorLocation(Position position) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('garbage_collectors')
          .doc(user.uid)
          .update({
        'location': GeoPoint(position.latitude, position.longitude),
      });

      _assignClosestRoutes(user.uid, position);
    }
  }

  Future<void> _assignClosestRoutes(String userId, Position position) async {
    final routesSnapshot =
        await FirebaseFirestore.instance.collection('garbage_routes').get();
    List<QueryDocumentSnapshot> routes = routesSnapshot.docs;

    routes.sort((a, b) {
      GeoPoint startA = a['start_point'];
      GeoPoint startB = b['start_point'];
      double distanceA = Geolocator.distanceBetween(position.latitude,
          position.longitude, startA.latitude, startA.longitude);
      double distanceB = Geolocator.distanceBetween(position.latitude,
          position.longitude, startB.latitude, startB.longitude);
      return distanceA.compareTo(distanceB);
    });

    Set<String> wasteTypes = Set();
    List<String> closestRoutes = [];

    for (var route in routes) {
      if (wasteTypes.length == 3) break;
      if (!wasteTypes.contains(route['waste_type'])) {
        wasteTypes.add(route['waste_type']);
        closestRoutes.add(route.id);
      }
    }

    await FirebaseFirestore.instance
        .collection('garbage_collectors')
        .doc(userId)
        .update({
      'assigned_routes': closestRoutes,
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
      appBar: AppBar(title: Text('Garbage Collector Home')),
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
            icon: Icon(Icons.delete),
            label: 'Collections',
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
