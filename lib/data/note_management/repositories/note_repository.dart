import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class NoteRepository {
  static Future<String> uploadFile(File file, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload file: $e");
    }
  }

  static Future<String> getDownloadURL(String path) async {
    return await FirebaseStorage.instance.ref(path).getDownloadURL();
  }
}
