import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  Note({
    required this.title,
    required this.content,
    required this.id,
  });

  final String title;
  final String content;
  final String id;

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     "title": title,
  //     "content": content,
  //   };
  // }

  // factory Note.fromFirestore(
  //     DocumentSnapshot<Map<String, dynamic>> snapshot,
  //     SnapshotOptions? options) {
  //   final data = snapshot.data()!;
  //   return Note(
  //     title: data["title"],
  //     content: data["content"],
  //     id: snapshot.id,
  //   );
  // }
}
