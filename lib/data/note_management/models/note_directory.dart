import 'package:cloud_firestore/cloud_firestore.dart';

class NoteDirectory {
  NoteDirectory({
    required this.name,
    required this.notes,
    required this.userId,
    required this.id,
  });

  final String name;
  final List<String> notes; // List of Note IDs
  final String userId; // Associated User ID
  final String id;

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "notes": notes,
      "userId": userId,
    };
  }

  factory NoteDirectory.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return NoteDirectory(
      name: data["name"],
      notes: List<String>.from(data["notes"]),
      userId: data["userId"],
      id: snapshot.id,
    );
  }
}
