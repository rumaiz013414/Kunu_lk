import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> subscribedRoutes;

  HomePage({required this.subscribedRoutes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Subscribed Routes:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: subscribedRoutes.length,
              itemBuilder: (context, index) {
                final route = subscribedRoutes[index];
                return ListTile(
                  title: Text('Route ID: ${route['id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start: ${route['start_point']}'),
                      Text('End: ${route['end_point']}'),
                      Text('Start Time: ${route['start_time']}'),
                      Text('End Time: ${route['end_time']}'),
                      Text('Waste Type: ${route['waste_type']}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
