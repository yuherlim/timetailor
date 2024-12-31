import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timetailor/data/note_management/models/note.dart';

class NoteRepository {
  // Firestore collection reference with converters for the Note class
  final ref =
      FirebaseFirestore.instance.collection("notes").withConverter<Note>(
            fromFirestore: Note.fromFirestore,
            toFirestore: (Note note, _) => note.toFirestore(),
          );

  // Add a new note
  Future<void> addNote(Note note) async {
    await ref.doc(note.id).set(note);
  }

  // Get all notes once
  Future<QuerySnapshot<Note>> getNotesOnce() {
    return ref.orderBy("title", descending: false).get();
  }

  // Get a note by ID
  Future<Note?> getNoteById(String noteId) async {
    final doc = await ref.doc(noteId).get();
    return doc.data(); // Automatically converted to a Note object
  }

  // Get notes for a specific user
  Future<List<Note>> getNotesByUserId(String userId) async {
    final querySnapshot = await ref.where("userId", isEqualTo: userId).get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // Update note details
  Future<void> updateNote(Note note) async {
    await ref.doc(note.id).update({
      "title": note.title,
      "content": note.content,
      "imageUrl": note.imageUrl,
      "pdfUrl": note.pdfUrl,
      "userId": note.userId,
    });
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    await ref.doc(noteId).delete();
  }

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadFile(String filePath, String fileName) async {
    try {
      final fileRef = storage.ref().child('uploads/$fileName');
      final uploadTask = fileRef.putFile(File(filePath));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload file: $e");
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception("Failed to delete file: $e");
    }
  }
}
