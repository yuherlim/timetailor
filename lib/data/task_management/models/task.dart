import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final int duration; // Duration in minutes
  final DateTime endTime;
  final bool isCompleted;
  final List<String> linkedNote; // Linked Note ID (nullable)

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.endTime,
    required this.isCompleted,
    required this.linkedNote,
  });

  Task copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    DateTime? startTime,
    int? duration,
    DateTime? endTime,
    bool? isCompleted,
    List<String>? linkedNote,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      linkedNote: linkedNote ?? this.linkedNote,
    );
  }

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     "name": name,
  //     "description": description,
  //     "date": Timestamp.fromDate(date),
  //     "startTime": Timestamp.fromDate(startTime),
  //     "duration": duration,
  //     "endTime": Timestamp.fromDate(endTime),
  //     "isCompleted": isCompleted,
  //     "linkedNote": linkedNote,
  //   };
  // }

  // factory Task.fromFirestore(
  //     DocumentSnapshot<Map<String, dynamic>> snapshot,
  //     SnapshotOptions? options) {
  //   final data = snapshot.data()!;
  //   return Task(
  //     name: data["name"],
  //     description: data["description"],
  //     date: data["date"],
  //     startTime: data["startTime"],
  //     duration: data["duration"],
  //     endTime: data["endTime"],
  //     isCompleted: data["isCompleted"],
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
    description: "Team Meeting with the team.",
    date:
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    startTime: roundToFiveMinuteInterval(DateTime.now()),
    duration: 60,
    endTime: roundToFiveMinuteInterval(
        DateTime.now().add(const Duration(minutes: 60))),
    isCompleted: false,
    linkedNote: ['note1', 'note2'],
  ),
  Task(
    id: 'task2',
    name: 'Write Project Report',
    description: "",
    date:
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    startTime:
        roundToFiveMinuteInterval(DateTime.now().add(const Duration(hours: 1))),
    duration: 30,
    endTime: roundToFiveMinuteInterval(
        DateTime.now().add(const Duration(hours: 1, minutes: 30))),
    isCompleted: false,
    linkedNote: ['note3'],
  ),
  Task(
    id: 'task3',
    name: 'Workout this is a very long sentence, testing testing,t testing',
    description: "",
    date: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 1),
    startTime:
        roundToFiveMinuteInterval(DateTime.now().add(const Duration(hours: 3))),
    duration: 45,
    endTime: roundToFiveMinuteInterval(
        DateTime.now().add(const Duration(hours: 3, minutes: 45))),
    isCompleted: true,
    linkedNote: [],
  ),
  Task(
    id: 'task4',
    name: 'Prepare Presentation',
    description: "",
    date: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 1),
    startTime:
        roundToFiveMinuteInterval(DateTime.now().add(const Duration(hours: 4))),
    duration: 90,
    endTime: roundToFiveMinuteInterval(
        DateTime.now().add(const Duration(hours: 5, minutes: 30))),
    isCompleted: false,
    linkedNote: ['note4'],
  ),
  Task(
    id: 'task5',
    name: 'Mini text testing',
    description: "",
    date:
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    startTime:
        roundToFiveMinuteInterval(DateTime.now().add(const Duration(hours: 2))),
    duration: 5,
    endTime: roundToFiveMinuteInterval(
        DateTime.now().add(const Duration(hours: 2, minutes: 5))),
    isCompleted: false,
    linkedNote: ['note4'],
  ),
  Task(
    id: 'task6',
    name: 'Text testing',
    description: "",
    date:
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    startTime: roundToFiveMinuteInterval(
        DateTime.now().add(const Duration(hours: 2, minutes: 5))),
    duration: 10,
    endTime: roundToFiveMinuteInterval(
        DateTime.now().add(const Duration(hours: 2, minutes: 15))),
    isCompleted: false,
    linkedNote: ['note4'],
  ),
];
