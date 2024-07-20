import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './edit_customer.dart';

class ViewCustomersPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _deleteCustomer(String customerId) {
    _firestore.collection('users').doc(customerId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Customers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('role', isEqualTo: 'customer')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No customers available.'));
          }

          final customers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              final customerId = customer.id;
              final customerData = customer.data() as Map<String, dynamic>;
              final customerName = customerData['name'] ?? 'Unknown';
              final customerEmail = customerData['email'] ?? 'Unknown';

              return ListTile(
                title: Text(customerName),
                subtitle: Text(customerEmail),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCustomerPage(
                                customerId: customerId,
                                customerData: customerData),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteCustomer(customerId);
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
