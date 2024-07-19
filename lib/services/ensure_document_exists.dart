import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> ensureCollectorDocumentExists(User user) async {
  final docRef =
      FirebaseFirestore.instance.collection('garbage_collectors').doc(user.uid);

  final doc = await docRef.get();
  if (!doc.exists) {
    await docRef.set({
      'collector_city': '',
      'collector_postal_code': '',
      'created_at': Timestamp.now(),
      'email': user.email,
      'name': '',
      'nic_no': '',
      'phone_number': '',
      'postal_code': '',
      'profilePicture': '',
      'role': 'garbage_collector',
      'vehicle_details': '',
      'verified': false,
      'location': GeoPoint(0, 0), // Default location
      'assigned_routes': [],
    });
  }
}
