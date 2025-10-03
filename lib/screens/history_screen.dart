import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/entry.dart';
import 'add_entry_screen.dart';
import 'package:intl/intl.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  IconData _getCategoryIcon(String type) {
    switch (type) {
      case "Health":
        return Icons.local_hospital; // 🏥
      case "Vitamins & Supplements":
        return Icons.medication; // 💊
      case "Lifestyle":
        return Icons.self_improvement; // 🌱
      case "Social":
        return Icons.people; // 👥
      case "Mind & Spirit":
        return Icons.spa; // 🧘
      case "Substances/Drugs":
        return Icons.smoking_rooms; // 🚬
      case "Optional/Special Cases":
        return Icons.star; // ⭐
      default:
        return Icons.note; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: FutureBuilder<List<Entry>>(
        future: DatabaseHelper.instance.getEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(child: Text("No entries yet."));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              return ListTile(
                leading: Icon(_getCategoryIcon(e.type), color: Colors.teal),
                title: Text("${e.type}: ${e.value}"),
                subtitle: Text(
                  DateFormat.yMMMd().add_jm().format(e.timestamp.toLocal()),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    IconButton(
                      tooltip: "Edit",
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEntryScreen(entry: e),
                          ),
                        );
                        setState(() {}); // refresh after edit
                      },
                    ),
                    // Delete button with confirmation
                    IconButton(
                      tooltip: "Delete",
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text(
                                "Are you sure you want to delete this entry?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text("Delete"),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && e.id != null) {
                          await DatabaseHelper.instance.deleteEntry(e.id!);
                          setState(() {}); // refresh after delete
                        }
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
