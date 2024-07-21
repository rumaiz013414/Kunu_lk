import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const kGoogleApiKey = "AIzaSyBmwKB0_BzuuI4gTjWsYruUKBWTWy7Cozw";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class SelectRoutePointsPage extends StatefulWidget {
  @override
  _SelectRoutePointsPageState createState() => _SelectRoutePointsPageState();
}

class _SelectRoutePointsPageState extends State<SelectRoutePointsPage> {
  GoogleMapController? _controller;
  List<LatLng> _routePoints = [];
  final TextEditingController _searchController = TextEditingController();
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
      _controller?.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)));
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
        if (data.containsKey('current_location')) {
          var location = data['current_location'];
          var lat = location['latitude'];
          var lng = location['longitude'];

          markers.add(Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: doc.id,
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
    } catch (e) {
      print("Error fetching customer locations: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _handleSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        mode: Mode.overlay,
        language: "en",
        components: [Component(Component.country, "us")],
      );

      if (p != null) {
        PlacesDetailsResponse detail =
            await _places.getDetailsByPlaceId(p.placeId!);
        final lat = detail.result.geometry!.location.lat;
        final lng = detail.result.geometry!.location.lng;
        _controller?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      }
    } catch (e) {
      print("Error occurred during search: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  readOnly: true,
                  onTap: _handleSearch,
                  decoration: InputDecoration(
                    hintText: 'Search location',
                    suffixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                  onTap: _onTap,
                  markers: _markers.union({
                    ..._routePoints.map((point) => Marker(
                          markerId: MarkerId(point.toString()),
                          position: point,
                        )),
                  }),
                  polylines: _polylines,
                ),
              ),
            ],
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
