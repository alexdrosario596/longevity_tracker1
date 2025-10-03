import 'package:flutter/material.dart';
import 'add_entry_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Longevity Tracker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Add Entry"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddEntryScreen()));
              },
            ),
            ElevatedButton(
              child: Text("View History"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
