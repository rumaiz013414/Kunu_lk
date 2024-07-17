import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerHomeScreen extends StatefulWidget {
  final String customerId;

  const CustomerHomeScreen({Key? key, required this.customerId})
      : super(key: key);

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<String> _selectedRoutes = [];

  @override
  void initState() {
    super.initState();
    _fetchSelectedRoutes();
  }

  void _fetchSelectedRoutes() async {
    try {
      // Assuming 'customer_subscriptions' is your Firestore collection
      var snapshot = await FirebaseFirestore.instance
          .collection('customer_subscriptions')
          .doc(widget.customerId) // Assuming customer ID is used as document ID
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          // Update _selectedRoutes with the routes selected by the customer
          _selectedRoutes = List<String>.from(data['selected_routes']);
        });
      } else {
        print('Subscription data not found for customer ${widget.customerId}');
      }
    } catch (e) {
      print('Error fetching subscription data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _selectedRoutes.isEmpty
            ? Center(
                child: Text('No routes selected'),
              )
            : ListView.builder(
                itemCount: _selectedRoutes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Route ID: ${_selectedRoutes[index]}'),
                    // Add more details if needed
                  );
                },
              ),
      ),
    );
  }
}
