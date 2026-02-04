class Grievance {
  final String title;
  final String description;
  final DateTime timestamp;

  Grievance({required this.title, required this.description, required this.timestamp});

  // This helper converts our data into a format Firestore understands (JSON)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp,
    };
  }
}