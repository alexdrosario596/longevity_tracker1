import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(LongevityApp());
}

class LongevityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Longevity Tracker',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: DashboardScreen(),
    );
  }
}
