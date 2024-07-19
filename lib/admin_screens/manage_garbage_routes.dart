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
  LatLng? _startPoint;
  LatLng? _endPoint;

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
        _startPoint = result['start'];
        _endPoint = result['end'];
      });
    }
  }

  void _createRoute() async {
    if (_formKey.currentState!.validate() &&
        _startPoint != null &&
        _endPoint != null) {
      String startTime = _startTimeController.text.trim();
      String endTime = _endTimeController.text.trim();
      String wasteType = _selectedWasteType!;

      try {
        await FirebaseFirestore.instance.collection('garbage_routes').add({
          'start_point':
              GeoPoint(_startPoint!.latitude, _startPoint!.longitude),
          'end_point': GeoPoint(_endPoint!.latitude, _endPoint!.longitude),
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
          _startPoint = null;
          _endPoint = null;
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
    if (_formKey.currentState!.validate() &&
        _startPoint != null &&
        _endPoint != null) {
      String startTime = _startTimeController.text.trim();
      String endTime = _endTimeController.text.trim();
      String wasteType = _selectedWasteType!;

      try {
        await FirebaseFirestore.instance
            .collection('garbage_routes')
            .doc(routeId)
            .update({
          'start_point':
              GeoPoint(_startPoint!.latitude, _startPoint!.longitude),
          'end_point': GeoPoint(_endPoint!.latitude, _endPoint!.longitude),
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
          _startPoint = null;
          _endPoint = null;
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
      _startPoint =
          LatLng(route['start_point'].latitude, route['start_point'].longitude);
      _endPoint =
          LatLng(route['end_point'].latitude, route['end_point'].longitude);
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
        child: Padding(
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
                    ),
                    if (_startPoint != null && _endPoint != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Start Point: (${_startPoint!.latitude}, ${_startPoint!.longitude})'),
                          Text(
                              'End Point: (${_endPoint!.latitude}, ${_endPoint!.longitude})'),
                        ],
                      ),
                    TextFormField(
                      controller: _startTimeController,
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'Start Time'),
                      onTap: () => _selectTime(context, _startTimeController),
                    ),
                    TextFormField(
                      controller: _endTimeController,
                      readOnly: true,
                      decoration: InputDecoration(labelText: 'End Time'),
                      onTap: () => _selectTime(context, _endTimeController),
                    ),
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
                      onPressed: () => _createRoute(),
                      child: Text('Create Route'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Existing Routes',
                style: Theme.of(context).textTheme.titleLarge,
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
                      return ListTile(
                        title: Text(
                            'Route: (${doc['start_point'].latitude}, ${doc['start_point'].longitude}) to (${doc['end_point'].latitude}, ${doc['end_point'].longitude})'),
                        subtitle: Text(
                            'Time: ${doc['start_time']} - ${doc['end_time']}\nWaste Type: ${doc['waste_type']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editRoute(doc);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteRoute(doc.id);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
