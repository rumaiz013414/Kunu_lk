import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditRoutePage extends StatefulWidget {
  final String routeId;
  final Map<String, dynamic> routeData;

  EditRoutePage({required this.routeId, required this.routeData});

  @override
  _EditRoutePageState createState() => _EditRoutePageState();
}

class _EditRoutePageState extends State<EditRoutePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _startPointController;
  late TextEditingController _endPointController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  String? _selectedWasteType;

  @override
  void initState() {
    super.initState();
    _startPointController =
        TextEditingController(text: widget.routeData['start_point']);
    _endPointController =
        TextEditingController(text: widget.routeData['end_point']);
    _startTimeController =
        TextEditingController(text: widget.routeData['start_time']);
    _endTimeController =
        TextEditingController(text: widget.routeData['end_time']);
    _selectedWasteType = widget.routeData['waste_type'];
  }

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

  void _updateRoute() async {
    if (_formKey.currentState!.validate()) {
      String startPoint = _startPointController.text.trim();
      String endPoint = _endPointController.text.trim();
      String startTime = _startTimeController.text.trim();
      String endTime = _endTimeController.text.trim();
      String wasteType = _selectedWasteType!;

      try {
        await FirebaseFirestore.instance
            .collection('garbage_routes')
            .doc(widget.routeId)
            .update({
          'start_point': startPoint,
          'end_point': endPoint,
          'start_time': startTime,
          'end_time': endTime,
          'waste_type': wasteType,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route updated successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Garbage Collection Route'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
                onPressed: _updateRoute,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
