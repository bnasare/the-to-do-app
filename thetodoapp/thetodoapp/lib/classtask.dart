import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String title;
  final String description;
   bool completed;

  Task(this.title, this.description, {this.completed = false});

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      data['title'] ?? '',
      data['description'] ?? '',
      completed: data['completed'] ?? false,
    );
  }
}
