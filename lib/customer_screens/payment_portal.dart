import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './customer_home.dart'; // Import the new home screen

class PaymentPortal extends StatelessWidget {
  final List<String> selectedRoutes;

  PaymentPortal({required this.selectedRoutes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Portal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Payment options and details go here.'),
            ElevatedButton(
              onPressed: () async {
                // Simulate successful payment
                bool paymentSuccess = true; // Replace with your payment logic

                if (paymentSuccess) {
                  // Save selected routes to Firestore
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'subscribed_routes': selectedRoutes});
                  }

                  // Navigate to the new home screen after successful payment
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerHomePage()),
                  );
                } else {
                  // Handle payment failure scenario
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Payment failed. Please try again.')),
                  );
                }
              },
              child: Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
