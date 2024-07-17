import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_portal.dart'; // Import your payment_portal.dart file here

class SubscribeScreen extends StatefulWidget {
  @override
  _SubscribeScreenState createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final List<String> _selectedRoutes = [];

  void _toggleRouteSelection(String routeId) {
    setState(() {
      if (_selectedRoutes.contains(routeId)) {
        _selectedRoutes.remove(routeId);
      } else {
        if (_selectedRoutes.length < 3) {
          _selectedRoutes.add(routeId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You can only select up to 3 routes')),
          );
        }
      }
    });
  }

  void _subscribe(BuildContext context) {
    if (_selectedRoutes.length == 3) {
      // Save the subscription details to Firestore or other backend service
      // For simplicity, we are printing it to the console
      print('Subscribed to routes:');
      _selectedRoutes.forEach((routeId) {
        print('Route ID: $routeId');
      });

      // Navigate to the payment portal
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentPortal()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select exactly 3 routes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscribe to Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                      final routeId = route.id;

                      return ListTile(
                        title: Text(
                            'ID: $routeId\nStart: ${routeData['start_point']} - End: ${routeData['end_point']}'),
                        subtitle: routeData.containsKey('start_time') &&
                                routeData.containsKey('end_time')
                            ? Text(
                                'Time: ${routeData['start_time']} - ${routeData['end_time']}\nWaste: ${routeData['waste_type']}')
                            : Text(
                                'Time: Not specified\nWaste: ${routeData['waste_type']}'),
                        trailing: Checkbox(
                          value: _selectedRoutes.contains(routeId),
                          onChanged: (value) => _toggleRouteSelection(routeId),
                        ),
                        onTap: () => _toggleRouteSelection(routeId),
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
    );
  }
}
