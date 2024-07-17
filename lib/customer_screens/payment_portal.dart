import 'package:flutter/material.dart';

class PaymentPortal extends StatelessWidget {
  final List<String> selectedRoutes;

  PaymentPortal({required this.selectedRoutes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Portal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Selected Routes:'),
            ...selectedRoutes.map((routeId) => Text('Route ID: $routeId')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement payment functionality here
                print('Proceed to payment');
              },
              child: Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
