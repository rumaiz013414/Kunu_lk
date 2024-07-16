import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGarbageRoutePage extends StatefulWidget {
  @override
  _CreateGarbageRoutePageState createState() => _CreateGarbageRoutePageState();
}

class _CreateGarbageRoutePageState extends State<CreateGarbageRoutePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _endPointController = TextEditingController();

  void _createRoute() async {
    if (_formKey.currentState!.validate()) {
      String startPoint = _startPointController.text.trim();
      String endPoint = _endPointController.text.trim();

      try {
        await FirebaseFirestore.instance.collection('garbage_routes').add({
          'start_point': startPoint,
          'end_point': endPoint,
          'created_at': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route created successfully')),
        );

        // Clear the form fields
        _startPointController.clear();
        _endPointController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating route: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Garbage Collection Route'),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createRoute,
                child: Text('Create Route'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
