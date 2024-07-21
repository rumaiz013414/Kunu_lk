import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'garbage_collector_route_navigation.dart';

class GarbageCollectionRoutes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Assigned Routes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('garbage_routes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              List<LatLng> routePoints = (doc['route_points'] as List)
                  .map((point) => LatLng(point['latitude'], point['longitude']))
                  .toList();

              return ListTile(
                title: Text('Route: ${routePoints.length} points'),
                subtitle: Text(
                    'Time: ${doc['start_time']} - ${doc['end_time']}\nWaste Type: ${doc['waste_type']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GarbageCollectorRouteNavigationPage(
                          routePoints: routePoints),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
