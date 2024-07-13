import 'package:flutter/material.dart';

class GarbageCollectorHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Garbage Collector Home')),
      body: Center(
        child: Text('Welcome, Garbage Collector!'),
      ),
    );
  }
}
