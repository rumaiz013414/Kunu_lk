import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectRoutePointsPage extends StatefulWidget {
  @override
  _SelectRoutePointsPageState createState() => _SelectRoutePointsPageState();
}

class _SelectRoutePointsPageState extends State<SelectRoutePointsPage> {
  GoogleMapController? _controller;
  List<LatLng> _routePoints = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _fetchCustomerLocations();
  }

  Future<void> _checkLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _controller?.animateCamera(CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude)));
        });
      }
    }
  }

  Future<void> _fetchCustomerLocations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      Set<Marker> markers = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('saved_location')) {
          var location = data['saved_location'];
          var lat = location.latitude;
          var lng = location.longitude;

          markers.add(Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: 'Customer: ${doc.id}',
              snippet: 'Lat: $lat, Lng: $lng',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ));
        }
      }

      setState(() {
        _markers = markers;
      });

      // Adjust the camera to fit all markers
      if (_markers.isNotEmpty) {
        LatLngBounds bounds =
            _getLatLngBounds(_markers.map((m) => m.position).toList());
        _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    } catch (e) {
      print("Error fetching customer locations: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _onTap(LatLng position) {
    setState(() {
      _routePoints.add(position);
      _updatePolyline();
    });
  }

  void _updatePolyline() {
    setState(() {
      _polylines = {
        Polyline(
          polylineId: PolylineId('custom_route'),
          points: _routePoints,
          color: Colors.blue,
          width: 5,
        ),
      };
    });
  }

  Future<void> _saveRoutePoints() async {
    if (_routePoints.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('routes').add({
          'points': _routePoints
              .map((point) =>
                  {'latitude': point.latitude, 'longitude': point.longitude})
              .toList(),
          'created_at': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context, {'route_points': _routePoints});
      } catch (e) {
        print("Error saving route: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save the route')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select points to draw the route')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Route Points'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveRoutePoints,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default to San Francisco
              zoom: 12,
            ),
            onTap: _onTap,
            markers: _markers.union({
              ..._routePoints.map((point) => Marker(
                    markerId: MarkerId(point.toString()),
                    position: point,
                  )),
            }),
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
