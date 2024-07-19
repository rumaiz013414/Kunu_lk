import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarbageCollectionRoutes extends StatefulWidget {
  @override
  _GarbageCollectionRoutesState createState() =>
      _GarbageCollectionRoutesState();
}

class _GarbageCollectionRoutesState extends State<GarbageCollectionRoutes> {
  late final User user;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _loadCustomerLocations(String routeId) async {
    final customersSnapshot = await FirebaseFirestore.instance
        .collection('routes')
        .doc(routeId)
        .collection('customers')
        .get();

    final markers = customersSnapshot.docs.map((doc) {
      final data = doc.data();
      final latLng = LatLng(data['latitude'], data['longitude']);
      return Marker(
        markerId: MarkerId(doc.id),
        position: latLng,
        infoWindow: InfoWindow(title: data['name']),
      );
    }).toSet();

    setState(() {
      _markers = markers;
    });

    if (markers.isNotEmpty) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList(markers.map((m) => m.position).toList()),
          50,
        ),
      );
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0 = list[0].latitude;
    double x1 = list[0].latitude;
    double y0 = list[0].longitude;
    double y1 = list[0].longitude;
    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assigned Routes'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('garbage_collectors')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading routes: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No routes assigned'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final assignedRoutes =
              data?['assigned_routes'] as List<dynamic>? ?? [];

          if (assignedRoutes.isEmpty) {
            return Center(child: Text('No routes assigned'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: assignedRoutes.length,
                  itemBuilder: (context, index) {
                    final routeId = assignedRoutes[index];
                    return ListTile(
                      title: Text('Route ID: $routeId'),
                      onTap: () {
                        _loadCustomerLocations(routeId);
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target:
                        LatLng(37.7749, -122.4194), // Default to San Francisco
                    zoom: 12,
                  ),
                  markers: _markers,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
