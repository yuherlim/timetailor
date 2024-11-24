import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    required this.name,
    required this.email,
    required this.daySchedules,
    required this.noteDirectories,
    required this.id,
  });

  final String name;
  final String email;
  final List<String> daySchedules; // List of DaySchedule IDs
  final List<String> noteDirectories; // List of NoteDirectory IDs
  final String id;

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "daySchedules": daySchedules,
      "noteDirectories": noteDirectories,
    };
  }

  factory User.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return User(
      name: data["name"],
      email: data["email"],
      daySchedules: List<String>.from(data["daySchedules"]),
      noteDirectories: List<String>.from(data["noteDirectories"]),
      id: snapshot.id,
    );
  }
}
