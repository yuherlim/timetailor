import 'package:cloud_firestore/cloud_firestore.dart';

class DaySchedule {
  DaySchedule({
    required this.date,
    required this.tasks,
    required this.userId,
    required this.id,
  });

  final DateTime date;
  final List<String> tasks; // List of Task IDs
  final String userId; // Associated User ID
  final String id;

  Map<String, dynamic> toFirestore() {
    return {
      "date": date.toIso8601String(),
      "tasks": tasks,
      "userId": userId,
    };
  }

  factory DaySchedule.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return DaySchedule(
      date: DateTime.parse(data["date"]),
      tasks: List<String>.from(data["tasks"]),
      userId: data["userId"],
      id: snapshot.id,
    );
  }
}
