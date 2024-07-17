import 'package:flutter/material.dart';
import './customer_home.dart'; // Import the new home screen

class PaymentPortal extends StatelessWidget {
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
              onPressed: () {
                // Simulate successful payment
                bool paymentSuccess = true; // Replace with your payment logic

                if (paymentSuccess) {
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
