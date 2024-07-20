import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './edit_garbage_collector.dart';

class ViewGarbageCollectorsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _deleteGarbageCollector(String collectorId) {
    _firestore.collection('users').doc(collectorId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Garbage Collectors')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('role', isEqualTo: 'garbage_collector')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No garbage collectors available.'));
          }

          final collectors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: collectors.length,
            itemBuilder: (context, index) {
              final collector = collectors[index];
              final collectorId = collector.id;
              final collectorData = collector.data() as Map<String, dynamic>;
              final collectorName = collectorData['name'] ?? 'Unknown';
              final collectorEmail = collectorData['email'] ?? 'Unknown';

              return ListTile(
                title: Text(collectorName),
                subtitle: Text(collectorEmail),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditGarbageCollectorPage(
                                collectorId: collectorId,
                                collectorData: collectorData),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteGarbageCollector(collectorId);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
