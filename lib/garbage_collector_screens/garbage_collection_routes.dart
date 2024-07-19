import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GarbageCollectionRoutes extends StatefulWidget {
  @override
  _GarbageCollectionRoutesState createState() =>
      _GarbageCollectionRoutesState();
}

class _GarbageCollectionRoutesState extends State<GarbageCollectionRoutes> {
  late final User user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assigned Routes'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('garbage_collectors')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading routes: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No routes assigned'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final assignedRoutes =
              data?['assigned_routes'] as List<dynamic>? ?? [];

          if (assignedRoutes.isEmpty) {
            return Center(child: Text('No routes assigned'));
          }

          return ListView.builder(
            itemCount: assignedRoutes.length,
            itemBuilder: (context, index) {
              final routeId = assignedRoutes[index];
              return ListTile(
                title: Text('Route ID: $routeId'),
                // Optionally, fetch and display more route details here
              );
            },
          );
        },
      ),
    );
  }
}
