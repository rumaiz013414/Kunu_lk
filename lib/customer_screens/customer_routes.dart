import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerRoutesPage extends StatefulWidget {
  @override
  _CustomerRoutesPageState createState() => _CustomerRoutesPageState();
}

class _CustomerRoutesPageState extends State<CustomerRoutesPage> {
  GoogleMapController? _controller;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _isLoading = false;
  LatLng? _customerLocation;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _fetchRoutes();
  }

  Future<void> _checkLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _customerLocation = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
          markerId: MarkerId('customer'),
          position: _customerLocation!,
          infoWindow: InfoWindow(
            title: 'Your Location',
          ),
        ));
      });
      _controller?.animateCamera(CameraUpdate.newLatLng(_customerLocation!));
    }
  }

  Future<void> _fetchRoutes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('garbage_routes').get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var routePoints = (data['route_points'] as List)
            .map((point) => LatLng(point['latitude'], point['longitude']))
            .toList();
        var wasteType = data['waste_type'];

        Color routeColor;
        BitmapDescriptor routeIcon;
        switch (wasteType) {
          case 'Electronics':
            routeColor = Colors.red;
            routeIcon = BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet);
            break;
          case 'Plastics':
            routeColor = Colors.blue;
            routeIcon =
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
            break;
          case 'Paper':
            routeColor = Colors.green;
            routeIcon = BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen);
            break;
          default:
            routeColor = Colors.grey;
            routeIcon = BitmapDescriptor.defaultMarker;
            break;
        }

        // Create markers for each route point
        for (var point in routePoints) {
          _markers.add(Marker(
            markerId:
                MarkerId('${doc.id}_${point.latitude}_${point.longitude}'),
            position: point,
            icon: routeIcon,
            infoWindow: InfoWindow(
              title: '$wasteType Route Point',
            ),
          ));
        }

        // Create a polyline for the route
        _polylines.add(Polyline(
          polylineId: PolylineId(doc.id),
          points: routePoints,
          color: routeColor,
          width: 5,
        ));
      }

      setState(() {
        _findClosestRoute();
      });

      // Adjust the camera to fit all markers and polylines
      _fitCameraToBounds();
    } catch (e) {
      print("Error fetching routes: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fitCameraToBounds() {
    if (_markers.isEmpty) return;

    LatLngBounds bounds =
        _getLatLngBounds(_markers.map((m) => m.position).toList());
    _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _findClosestRoute() {
    if (_customerLocation == null || _polylines.isEmpty) return;

    double minDistance = 100; // 100 meters
    Polyline? closestRoute;

    for (var polyline in _polylines) {
      for (var point in polyline.points) {
        double dist = Geolocator.distanceBetween(
          _customerLocation!.latitude,
          _customerLocation!.longitude,
          point.latitude,
          point.longitude,
        );
        if (dist < minDistance) {
          minDistance = dist;
          closestRoute = polyline;
        }
      }
    }

    if (closestRoute != null) {
      _markers.add(Marker(
        markerId: MarkerId('closest_route'),
        position: closestRoute.points.first,
        infoWindow: InfoWindow(
          title: 'Closest Route',
        ),
      ));
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(
        _getLatLngBounds(closestRoute.points),
        50,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found the closest route within 100 meters')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No route found within 100 meters')),
      );
    }
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double x0 = points[0].latitude;
    double x1 = points[0].latitude;
    double y0 = points[0].longitude;
    double y1 = points[0].longitude;

    for (LatLng point in points) {
      if (point.latitude > x1) x1 = point.latitude;
      if (point.latitude < x0) x0 = point.latitude;
      if (point.longitude > y1) y1 = point.longitude;
      if (point.longitude < y0) y0 = point.longitude;
    }

    return LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    // Adjust the camera to fit all markers and polylines when the map is created
    _fitCameraToBounds();
  }

  Future<void> _saveLocation() async {
    if (_customerLocation == null) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'saved_location': GeoPoint(
              _customerLocation!.latitude, _customerLocation!.longitude),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location saved successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Garbage Collection Points and Routes'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default to San Francisco
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (_customerLocation != null) {
                _controller
                    ?.animateCamera(CameraUpdate.newLatLng(_customerLocation!));
              }
            },
            child: Icon(Icons.my_location),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _saveLocation,
            child: Icon(Icons.save),
          ),
        ],
      ),
    );
  }
}
