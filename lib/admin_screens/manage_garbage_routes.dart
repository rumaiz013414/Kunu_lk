import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import './select_route_points.dart';

class ManageGarbageRoutesPage extends StatefulWidget {
  @override
  _ManageGarbageRoutesPageState createState() =>
      _ManageGarbageRoutesPageState();
}

class _ManageGarbageRoutesPageState extends State<ManageGarbageRoutesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  String? _selectedWasteType;
  List<LatLng> _routePoints = [];

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final time =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      controller.text = DateFormat('HH:mm').format(time);
    }
  }

  Future<void> _selectRoutePoints() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectRoutePointsPage()),
    );

    if (result != null) {
      setState(() {
        _routePoints = List<LatLng>.from(result['route_points']);
      });
    }
  }

  void _createRoute() async {
    if (_formKey.currentState!.validate() && _routePoints.isNotEmpty) {
      String startTime = _startTimeController.text.trim();
      String endTime = _endTimeController.text.trim();
      String wasteType = _selectedWasteType!;

      try {
        await FirebaseFirestore.instance.collection('garbage_routes').add({
          'route_points': _routePoints
              .map((point) =>
                  {'latitude': point.latitude, 'longitude': point.longitude})
              .toList(),
          'start_time': startTime,
          'end_time': endTime,
          'waste_type': wasteType,
          'created_at': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route created successfully')),
        );

        // Clear the form fields
        _startTimeController.clear();
        _endTimeController.clear();
        setState(() {
          _selectedWasteType = null;
          _routePoints = [];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please fill all fields and select route points')),
      );
    }
  }

  void _updateRoute(String routeId) async {
    if (_formKey.currentState!.validate() && _routePoints.isNotEmpty) {
      String startTime = _startTimeController.text.trim();
      String endTime = _endTimeController.text.trim();
      String wasteType = _selectedWasteType!;

      try {
        await FirebaseFirestore.instance
            .collection('garbage_routes')
            .doc(routeId)
            .update({
          'route_points': _routePoints
              .map((point) =>
                  {'latitude': point.latitude, 'longitude': point.longitude})
              .toList(),
          'start_time': startTime,
          'end_time': endTime,
          'waste_type': wasteType,
          'updated_at': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route updated successfully')),
        );

        // Clear the form fields
        _startTimeController.clear();
        _endTimeController.clear();
        setState(() {
          _selectedWasteType = null;
          _routePoints = [];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please fill all fields and select route points')),
      );
    }
  }

  void _deleteRoute(String routeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('garbage_routes')
          .doc(routeId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _editRoute(DocumentSnapshot route) {
    setState(() {
      _routePoints = (route['route_points'] as List)
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList();
      _startTimeController.text = route['start_time'];
      _endTimeController.text = route['end_time'];
      _selectedWasteType = route['waste_type'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Garbage Collection Routes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _selectRoutePoints,
                    child: Text('Select Route Points'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.orange, // Change button color here
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      foregroundColor: Colors.white, // Change text color here
                    ),
                  ),
                  if (_routePoints.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selected Route Points:'),
                          ..._routePoints.map((point) => Text(
                              '(${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})')),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: _startTimeController,
                    readOnly: true,
                    decoration:
                        InputDecoration(labelText: 'Estimated Start Time'),
                    onTap: () => _selectTime(context, _startTimeController),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _endTimeController,
                    readOnly: true,
                    decoration:
                        InputDecoration(labelText: 'Estimated End Time'),
                    onTap: () => _selectTime(context, _endTimeController),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedWasteType,
                    decoration: InputDecoration(labelText: 'Waste Type'),
                    items: [
                      DropdownMenuItem(
                        value: 'Electronics',
                        child: Text('Electronics'),
                      ),
                      DropdownMenuItem(
                        value: 'Plastics',
                        child: Text('Plastics'),
                      ),
                      DropdownMenuItem(
                        value: 'Paper',
                        child: Text('Paper'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedWasteType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a waste type';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createRoute,
                    child: Text('Create Route'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Change button color here
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      foregroundColor: Colors.white, // Change text color here
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Available Routes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('garbage_routes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4.0,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(
                            'Route: (${doc['route_points'][0]['latitude']}, ${doc['route_points'][0]['longitude']}) to (${doc['route_points'].last['latitude']}, ${doc['route_points'].last['longitude']})'),
                        subtitle: Text(
                            'Time: ${doc['start_time']} - ${doc['end_time']}\nWaste Type: ${doc['waste_type']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.blue, // Change icon color here
                              onPressed: () {
                                _editRoute(doc);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red, // Change icon color here
                              onPressed: () {
                                _deleteRoute(doc.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
