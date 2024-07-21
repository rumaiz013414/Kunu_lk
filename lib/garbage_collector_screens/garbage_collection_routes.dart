import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'garbage_collector_route_navigation.dart';

class GarbageCollectionRoutes extends StatefulWidget {
  @override
  _GarbageCollectionRoutesState createState() =>
      _GarbageCollectionRoutesState();
}

class _GarbageCollectionRoutesState extends State<GarbageCollectionRoutes> {
  // Map to store completion status of routes
  Map<String, bool> _routeCompletionStatus = {};

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

          List<DocumentSnapshot> completedRoutes = [];
          List<DocumentSnapshot> uncompletedRoutes = [];

          snapshot.data!.docs.forEach((doc) {
            String routeId = doc.id;
            final docData = doc.data() as Map<String, dynamic>?;
            bool isCompleted =
                (docData != null && docData.containsKey('completed'))
                    ? doc['completed']
                    : false;
            _routeCompletionStatus[routeId] = isCompleted;

            if (isCompleted) {
              completedRoutes.add(doc);
            } else {
              uncompletedRoutes.add(doc);
            }
          });

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Uncompleted Routes',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              ...uncompletedRoutes.map((doc) => buildRouteTile(doc)).toList(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Completed Routes',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              ...completedRoutes.map((doc) => buildRouteTile(doc)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget buildRouteTile(DocumentSnapshot doc) {
    String routeId = doc.id;
    List<LatLng> routePoints = (doc['route_points'] as List)
        .map((point) => LatLng(point['latitude'], point['longitude']))
        .toList();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.route, color: Theme.of(context).primaryColor),
        title: Text('Route: ${routePoints.length} points',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Time: ${doc['start_time']} - ${doc['end_time']}\nWaste Type: ${doc['waste_type']}'),
        trailing: Checkbox(
          value: _routeCompletionStatus[routeId],
          onChanged: (bool? value) {
            setState(() {
              _routeCompletionStatus[routeId] = value!;
              // Update the completion status in Firestore
              FirebaseFirestore.instance
                  .collection('garbage_routes')
                  .doc(routeId)
                  .update({'completed': value});
            });
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GarbageCollectorRouteNavigationPage(routePoints: routePoints),
            ),
          );
        },
      ),
    );
  }
}
