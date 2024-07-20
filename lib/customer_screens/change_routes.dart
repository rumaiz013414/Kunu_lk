import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

        _polylines.add(Polyline(
          polylineId: PolylineId(doc.id),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ));
      }

      setState(() {
        _findClosestRoute();
      });
    } catch (e) {
      print("Error fetching routes: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _findClosestRoute() {
    if (_customerLocation == null || _polylines.isEmpty) return;

    double minDistance = 200; // 200 meters
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
        SnackBar(content: Text('Found the closest route within 200 meters')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No route found within 200 meters')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Garbage Collection Routes'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default to San Francisco
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
