import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  Task({
    required this.name,
    required this.duration,
    required this.completed,
    required this.linkedNote,
    required this.id,
  });

  final String name;
  final int duration; // Duration in minutes
  final bool completed;
  final String? linkedNote; // Linked Note ID (nullable)
  final String id;

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "duration": duration,
      "completed": completed,
      "linkedNote": linkedNote,
    };
  }

  factory Task.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return Task(
      name: data["name"],
      duration: data["duration"],
      completed: data["completed"],
      linkedNote: data["linkedNote"],
      id: snapshot.id,
    );
  }
}
