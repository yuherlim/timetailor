import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String title;
  final String content;
  final String id;
  final String? imageUrl;
  final String? pdfUrl;

  Note({
    required this.title,
    required this.content,
    required this.id,
    this.imageUrl,
    this.pdfUrl,
  });

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     "title": title,
  //     "content": content,
  //     "imageUrl": imageUrl,
  //     "pdfUrl": pdfUrl,
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
  //     imageUrl: data["imageUrl"],
  //     pdfUrl: data["pdfUrl"],
  //   );
  // }
}
