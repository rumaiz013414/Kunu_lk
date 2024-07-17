import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _controller?.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)));
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
      body: Column(
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
                target: LatLng(37.7749, -122.4194), // Default to San Francisco
                zoom: 12,
              ),
              onTap: _onTap,
              markers: {
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
