import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String name;
  final DateTime startTime;
  final int duration; // Duration in minutes
  final DateTime endTime;
  final bool completed;
  final List<String?> linkedNote; // Linked Note ID (nullable)
  final double yTop;
  final double yBottom;

  Task({
    required this.id,
    required this.name,
    required this.startTime,
    required this.duration,
    required this.endTime,
    required this.completed,
    required this.linkedNote,
    required this.yTop,
    required this.yBottom,
  });

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     "name": name,
  //     "startTime": Timestamp.fromDate(startTime),
  //     "duration": duration,
  //     "endTime": Timestamp.fromDate(endTime),
  //     "completed": completed,
  //     "linkedNote": linkedNote,
  //     "yTop": yTop,
  //     "yBottom": yBottom,
  //   };
  // }

  // factory Task.fromFirestore(
  //     DocumentSnapshot<Map<String, dynamic>> snapshot,
  //     SnapshotOptions? options) {
  //   final data = snapshot.data()!;
  //   return Task(
  //     name: data["name"],
  //     startTime: data["startTime"],
  //     duration: data["duration"],
  //     completed: data["completed"],
  //     linkedNote: data["linkedNote"],
  //     id: snapshot.id,
  //   );
  // }
}

// Helper function to round DateTime to the nearest 5-minute interval
DateTime roundToFiveMinuteInterval(DateTime time) {
  final minutes = (time.minute / 5).round() * 5;
  return DateTime(time.year, time.month, time.day, time.hour, minutes);
}

final List<Task> tasks = [
  Task(
    id: 'task1',
    name: 'Team Meeting',
    startTime: roundToFiveMinuteInterval(DateTime.now()),
    duration: 60,
    endTime:
        roundToFiveMinuteInterval(DateTime.now().add(Duration(minutes: 60))),
    completed: false,
    linkedNote: ['note1', 'note2'],
    yTop: 100.0,
    yBottom: 160.0,
  ),
  Task(
    id: 'task2',
    name: 'Write Project Report',
    startTime:
        roundToFiveMinuteInterval(DateTime.now().add(Duration(hours: 1))),
    duration: 30,
    endTime: roundToFiveMinuteInterval(
        DateTime.now().add(Duration(hours: 1, minutes: 30))),
    completed: false,
    linkedNote: ['note3'],
    yTop: 170.0,
    yBottom: 200.0,
  ),
  Task(
    id: 'task3',
    name: 'Workout',
    startTime:
        roundToFiveMinuteInterval(DateTime.now().add(Duration(hours: 3))),
    duration: 45,
    endTime: roundToFiveMinuteInterval(
        DateTime.now().add(Duration(hours: 3, minutes: 45))),
    completed: true,
    linkedNote: [],
    yTop: 210.0,
    yBottom: 255.0,
  ),
  Task(
    id: 'task4',
    name: 'Prepare Presentation',
    startTime:
        roundToFiveMinuteInterval(DateTime.now().add(Duration(hours: 4))),
    duration: 90,
    endTime: roundToFiveMinuteInterval(
        DateTime.now().add(Duration(hours: 5, minutes: 30))),
    completed: false,
    linkedNote: ['note4'],
    yTop: 270.0,
    yBottom: 360.0,
  ),
];
