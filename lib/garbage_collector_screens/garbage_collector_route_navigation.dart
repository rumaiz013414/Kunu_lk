import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GarbageCollectorRouteNavigationPage extends StatefulWidget {
  final List<LatLng> routePoints;

  GarbageCollectorRouteNavigationPage({required this.routePoints});

  @override
  _GarbageCollectorRouteNavigationPageState createState() =>
      _GarbageCollectorRouteNavigationPageState();
}

class _GarbageCollectorRouteNavigationPageState
    extends State<GarbageCollectorRouteNavigationPage> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  List<LatLng> _customerLocations = [];

  @override
  void initState() {
    super.initState();
    _setRoute();
    _fetchCustomerLocations();
  }

  void _setRoute() {
    if (widget.routePoints.isNotEmpty) {
      final routePoints = widget.routePoints;

      final bounds = _createLatLngBounds(routePoints);

      final polyline = Polyline(
        polylineId: PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 5,
      );

      final markers = routePoints.map((point) {
        return Marker(
          markerId: MarkerId('${point.latitude},${point.longitude}'),
          position: point,
        );
      }).toSet();

      setState(() {
        _polylines.add(polyline);
        _markers.addAll(markers);
      });

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      });
    }
  }

  LatLngBounds _createLatLngBounds(List<LatLng> points) {
    double x0, x1, y0, y1;
    x0 = x1 = points[0].latitude;
    y0 = y1 = points[0].longitude;

    for (LatLng point in points) {
      if (point.latitude > x1) x1 = point.latitude;
      if (point.latitude < x0) x0 = point.latitude;
      if (point.longitude > y1) y1 = point.longitude;
      if (point.longitude < y0) y0 = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }

  void _fetchCustomerLocations() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<LatLng> locations = snapshot.docs.map((doc) {
        GeoPoint point = doc['current_location'];
        return LatLng(point.latitude, point.longitude);
      }).toList();

      setState(() {
        _customerLocations = locations;
        _setCustomerMarkers();
      });
    } catch (e) {
      print('Error fetching customer locations: $e');
    }
  }

  void _setCustomerMarkers() {
    final markers = _customerLocations.map((point) {
      return Marker(
        markerId: MarkerId('customer_${point.latitude},${point.longitude}'),
        position: point,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
    }).toSet();

    setState(() {
      _markers.addAll(markers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Garbage Collection Route'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: widget.routePoints.isNotEmpty
              ? widget.routePoints[0]
              : LatLng(0, 0),
          zoom: 14.0,
        ),
        polylines: _polylines,
        markers: _markers,
      ),
    );
  }
}
