import 'package:cloud_firestore/cloud_firestore.dart';

class TaskHistory {
  TaskHistory({
    required this.taskId,
    required this.timestamp,
    required this.userId,
    required this.id,
  });

  final String taskId; // Completed Task ID
  final DateTime timestamp;
  final String userId; // Associated User ID
  final String id;

  Map<String, dynamic> toFirestore() {
    return {
      "taskId": taskId,
      "timestamp": timestamp.toIso8601String(),
      "userId": userId,
    };
  }

  factory TaskHistory.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return TaskHistory(
      taskId: data["taskId"],
      timestamp: DateTime.parse(data["timestamp"]),
      userId: data["userId"],
      id: snapshot.id,
    );
  }
}
