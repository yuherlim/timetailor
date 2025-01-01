import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String title;
  final String content;
  final String id;
  final String? imageUrl;
  final String? pdfUrl;
  final String userId;
  final DateTime? createdAt; // Nullable during creation

  Note({
    required this.title,
    required this.content,
    required this.id,
    this.imageUrl,
    this.pdfUrl,
    required this.userId,
    this.createdAt, // Nullable to allow Firestore to populate it
  });

  Note copyWith({
    String? title,
    String? content,
    String? id,
    String? imageUrl,
    String? pdfUrl,
    String? userId,
    DateTime? createdAt,
  }) {
    return Note(
      title: title ?? this.title,
      content: content ?? this.content,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "content": content,
      "imageUrl": imageUrl,
      "pdfUrl": pdfUrl,
      "userId": userId,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory Note.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return Note(
      title: data["title"],
      content: data["content"],
      id: snapshot.id,
      imageUrl: data["imageUrl"],
      pdfUrl: data["pdfUrl"],
      userId: data["userId"],
      createdAt: data["createdAt"] != null
          ? (data["createdAt"] as Timestamp).toDate()
          : null, // Handle null gracefully
    );
  }
}
