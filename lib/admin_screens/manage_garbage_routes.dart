import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'edit_route.dart';

class ManageGarbageRoutesPage extends StatefulWidget {
  @override
  _ManageGarbageRoutesPageState createState() =>
      _ManageGarbageRoutesPageState();
}

class _ManageGarbageRoutesPageState extends State<ManageGarbageRoutesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _endPointController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  String? _selectedWasteType;

  @override
  void dispose() {
    _startPointController.dispose();
    _endPointController.dispose();
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

  void _createRoute() async {
    if (_formKey.currentState!.validate()) {
      String startPoint = _startPointController.text.trim();
      String endPoint = _endPointController.text.trim();
      String startTime = _startTimeController.text.trim();
      String endTime = _endTimeController.text.trim();
      String wasteType = _selectedWasteType!;

      try {
        await FirebaseFirestore.instance.collection('garbage_routes').add({
          'start_point': startPoint,
          'end_point': endPoint,
          'start_time': startTime,
          'end_time': endTime,
          'waste_type': wasteType,
          'created_at': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route created successfully')),
        );

        // Clear the form fields
        _startPointController.clear();
        _endPointController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
        setState(() {
          _selectedWasteType = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
        SnackBar(content: Text('Error deleting route: ${e.toString()}')),
      );
    }
  }

  void _navigateToEditRoutePage(DocumentSnapshot route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRoutePage(
          routeId: route.id,
          routeData: route.data() as Map<String, dynamic>,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Garbage Collection Routes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _startPointController,
                    decoration: InputDecoration(labelText: 'Start Point'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a start point';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _endPointController,
                    decoration: InputDecoration(labelText: 'End Point'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an end point';
                      }
                      return null;
                    },
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
                    onPressed: _createRoute,
                    child: Text('Create Route'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('garbage_routes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                      final routeData = route.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(
                            'ID: ${route.id}\nStart: ${routeData['start_point']} - End: ${routeData['end_point']}'),
                        subtitle: routeData.containsKey('start_time') &&
                                routeData.containsKey('end_time')
                            ? Text(
                                'Time: ${routeData['start_time']} - ${routeData['end_time']}\nWaste: ${routeData['waste_type']}')
                            : Text(
                                'Time: Not specified\nWaste: ${routeData['waste_type']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _navigateToEditRoutePage(route),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteRoute(route.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
