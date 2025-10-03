import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/entry.dart';

class AddEntryScreen extends StatefulWidget {
  final Entry? entry;
  const AddEntryScreen({Key? key, this.entry}) : super(key: key);

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    _type = widget.entry?.type ?? "Health"; // default
    _valueCtrl = TextEditingController(text: widget.entry?.value ?? "");
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Entry" : "Add Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: [
                  "Health",
                  "Vitamins & Supplements",
                  "Lifestyle",
                  "Social",
                  "Mind & Spirit",
                  "Substances/Drugs",
                  "Optional/Special Cases"
                ].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextFormField(
                controller: _valueCtrl,
                decoration: const InputDecoration(labelText: "Details"),
                validator: (val) =>
                (val == null || val.trim().isEmpty) ? "Please enter details" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(isEditing ? "Update" : "Save"),
                onPressed: () async {
                  if (_formKey.currentState?.validate() != true) return;

                  final entry = Entry(
                    id: widget.entry?.id,
                    type: _type,
                    value: _valueCtrl.text.trim(),
                    timestamp: DateTime.now(),
                  );

                  if (isEditing) {
                    await DatabaseHelper.instance.updateEntry(entry);
                  } else {
                    await DatabaseHelper.instance.insertEntry(entry);
                  }

                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
