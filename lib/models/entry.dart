class Entry {
  final int? id;
  final String type; // sleep, diet, exercise
  final String value; // e.g. "7 hours", "2000 calories", "Running 30min"
  final DateTime timestamp;

  Entry({this.id, required this.type, required this.value, required this.timestamp});

  // Convert Entry -> Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert Map -> Entry
  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'],
      type: map['type'],
      value: map['value'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
