import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

const kGoogleApiKey = "AIzaSyBmwKB0_BzuuI4gTjWsYruUKBWTWy7Cozw";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class SelectRoutePointsPage extends StatefulWidget {
  @override
  _SelectRoutePointsPageState createState() => _SelectRoutePointsPageState();
}

class _SelectRoutePointsPageState extends State<SelectRoutePointsPage> {
  GoogleMapController? _controller;
  LatLng? _startPoint;
  LatLng? _endPoint;
  bool _selectingStart = true;
  final TextEditingController _searchController = TextEditingController();
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _fetchCustomerLocations(); // Fetch customer locations on init
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
      if (_selectingStart) {
        _startPoint = position;
      } else {
        _endPoint = position;
        _showRoute();
      }
      _selectingStart = !_selectingStart;
    });
  }

  void _saveRoutePoints() {
    if (_startPoint != null && _endPoint != null) {
      Navigator.pop(context, {'start': _startPoint, 'end': _endPoint});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both start and end points')),
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

  Future<void> _showRoute() async {
    if (_startPoint != null && _endPoint != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String url = 'https://maps.googleapis.com/maps/api/directions/json?'
            'origin=${_startPoint!.latitude},${_startPoint!.longitude}&'
            'destination=${_endPoint!.latitude},${_endPoint!.longitude}&'
            'key=$kGoogleApiKey';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final route = json['routes'][0]['overview_polyline']['points'];
          final polyline = Polyline(
            polylineId: PolylineId('route'),
            points: _decodePolyline(route),
            color: Colors.blue,
            width: 5,
          );

          setState(() {
            _polylines = {polyline};
          });

          _controller?.animateCamera(
            CameraUpdate.newLatLngBounds(
              _createLatLngBounds(_startPoint!, _endPoint!),
              50,
            ),
          );
        } else {
          print("Failed to load route: ${response.statusCode}");
        }
      } catch (e) {
        print("Error occurred while fetching route: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng((lat / 1E5), (lng / 1E5)));
    }

    return points;
  }

  LatLngBounds _createLatLngBounds(LatLng start, LatLng end) {
    return LatLngBounds(
      southwest: LatLng(
        start.latitude < end.latitude ? start.latitude : end.latitude,
        start.longitude < end.longitude ? start.longitude : end.longitude,
      ),
      northeast: LatLng(
        start.latitude > end.latitude ? start.latitude : end.latitude,
        start.longitude > end.longitude ? start.longitude : end.longitude,
      ),
    );
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
                    if (_startPoint != null)
                      Marker(
                        markerId: MarkerId('start'),
                        position: _startPoint!,
                        infoWindow: InfoWindow(title: 'Start Point'),
                      ),
                    if (_endPoint != null)
                      Marker(
                        markerId: MarkerId('end'),
                        position: _endPoint!,
                        infoWindow: InfoWindow(title: 'End Point'),
                      ),
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
