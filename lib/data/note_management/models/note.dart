import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  Note({
    required this.title,
    required this.content,
    required this.directoryId,
    required this.id,
  });

  final String title;
  final String content;
  final String directoryId; // Associated NoteDirectory ID
  final String id;

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "content": content,
      "directoryId": directoryId,
    };
  }

  factory Note.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return Note(
      title: data["title"],
      content: data["content"],
      directoryId: data["directoryId"],
      id: snapshot.id,
    );
  }
}
