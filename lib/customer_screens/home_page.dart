import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<String> subscribedRoutes;

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
                return ListTile(
                  title: Text('Route ID: ${subscribedRoutes[index]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
