import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/route_details.dart';
import 'payment_portal.dart';

class SubscribeScreen extends StatefulWidget {
  @override
  _SubscribeScreenState createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final List<String> _selectedRoutes = [];
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  Map<String, Map<String, dynamic>> _routeDetails = {};
  final String _apiKey = "AIzaSyBmwKB0_BzuuI4gTjWsYruUKBWTWy7Cozw";

  void _toggleRouteSelection(String routeId, GeoPoint start, GeoPoint end) {
    setState(() {
      if (_selectedRoutes.contains(routeId)) {
        _selectedRoutes.remove(routeId);
        _removeMarkersAndPolyline(routeId);
      } else {
        if (_selectedRoutes.length < 3) {
          _selectedRoutes.add(routeId);
          _addMarkersAndPolyline(routeId, start, end);
          _fetchAndStoreRouteDetails(routeId, start, end);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You can only select up to 3 routes')),
          );
        }
      }
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(
          start.latitude < end.latitude ? start.latitude : end.latitude,
          start.longitude < end.longitude ? start.longitude : end.longitude,
        ),
        northeast: LatLng(
          start.latitude > end.latitude ? start.latitude : end.latitude,
          start.longitude > end.longitude ? start.longitude : end.longitude,
        ),
      ),
      50,
    ));
  }

  void _addMarkersAndPolyline(String routeId, GeoPoint start, GeoPoint end) {
    _markers.add(Marker(
      markerId: MarkerId('start_$routeId'),
      position: LatLng(start.latitude, start.longitude),
      infoWindow: InfoWindow(title: 'Start: Route $routeId'),
    ));

    _markers.add(Marker(
      markerId: MarkerId('end_$routeId'),
      position: LatLng(end.latitude, end.longitude),
      infoWindow: InfoWindow(title: 'End: Route $routeId'),
    ));

    _polylines.add(Polyline(
      polylineId: PolylineId(routeId),
      points: [
        LatLng(start.latitude, start.longitude),
        LatLng(end.latitude, end.longitude),
      ],
      color: Colors.blue,
      width: 5,
    ));
  }

  void _removeMarkersAndPolyline(String routeId) {
    _markers.removeWhere((marker) =>
        marker.markerId.value == 'start_$routeId' ||
        marker.markerId.value == 'end_$routeId');
    _polylines.removeWhere((polyline) => polyline.polylineId.value == routeId);
    _routeDetails.remove(routeId);
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

  Future<void> _fetchAndStoreRouteDetails(
      String routeId, GeoPoint start, GeoPoint end) async {
    Map<String, dynamic> routeDetails =
        await getRouteDetails(start, end, _apiKey);

    setState(() {
      _routeDetails[routeId] = routeDetails;
    });
  }

  void _subscribe(BuildContext context) async {
    if (_selectedRoutes.length == 3) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'subscribed_routes': _selectedRoutes});
      }

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PaymentPortal(selectedRoutes: _selectedRoutes)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select exactly 3 routes')),
      );
    }
  }

  void _findClosestRoutes() async {
    Position position = await _determinePosition();

    FirebaseFirestore.instance
        .collection('garbage_routes')
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<QueryDocumentSnapshot> routes = querySnapshot.docs;
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

      setState(() {
        _selectedRoutes.clear();
        _selectedRoutes.addAll(closestRoutes);
      });
    });
  }

  void _addRouteMarkers() {
    FirebaseFirestore.instance
        .collection('garbage_routes')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        GeoPoint start = doc['start_point'];
        GeoPoint end = doc['end_point'];

        _markers.add(Marker(
          markerId: MarkerId('start_${doc.id}'),
          position: LatLng(start.latitude, start.longitude),
          infoWindow: InfoWindow(title: 'Start: ${doc['waste_type']}'),
        ));

        _markers.add(Marker(
          markerId: MarkerId('end_${doc.id}'),
          position: LatLng(end.latitude, end.longitude),
          infoWindow: InfoWindow(title: 'End: ${doc['waste_type']}'),
        ));

        _polylines.add(Polyline(
          polylineId: PolylineId(doc.id),
          points: [
            LatLng(start.latitude, start.longitude),
            LatLng(end.latitude, end.longitude),
          ],
          color: Colors.blue,
          width: 5,
        ));
      });

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _currentPosition = position;

        _markers.add(Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ));
    });
    _addRouteMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscribe to Service'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_currentPosition != null) {
                  _mapController?.animateCamera(CameraUpdate.newLatLng(
                    LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                  ));
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('garbage_routes')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No routes available');
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final route = snapshot.data!.docs[index];
                            final routeData =
                                route.data() as Map<String, dynamic>;
                            final routeId = route.id;

                            String startAddress = _routeDetails[routeId]
                                    ?['start_address'] ??
                                'Fetching...';
                            String endAddress = _routeDetails[routeId]
                                    ?['end_address'] ??
                                'Fetching...';
                            List<dynamic> steps =
                                _routeDetails[routeId]?['steps'] ?? [];

                            return ListTile(
                              title: Text(
                                  'ID: $routeId\nStart: $startAddress - End: $endAddress'),
                              subtitle: routeData.containsKey('start_time') &&
                                      routeData.containsKey('end_time')
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Time: ${routeData['start_time']} - ${routeData['end_time']}'),
                                        Text(
                                            'Waste: ${routeData['waste_type']}'),
                                        ...steps
                                            .map((step) => Text(step))
                                            .toList(),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Time: Not specified'),
                                        Text(
                                            'Waste: ${routeData['waste_type']}'),
                                        ...steps
                                            .map((step) => Text(step))
                                            .toList(),
                                      ],
                                    ),
                              trailing: Checkbox(
                                value: _selectedRoutes.contains(routeId),
                                onChanged: (value) => _toggleRouteSelection(
                                    routeId,
                                    routeData['start_point'],
                                    routeData['end_point']),
                              ),
                              onTap: () => _toggleRouteSelection(
                                  routeId,
                                  routeData['start_point'],
                                  routeData['end_point']),
                              selected: _selectedRoutes.contains(routeId),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _subscribe(context),
                    child: Text('Subscribe'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
