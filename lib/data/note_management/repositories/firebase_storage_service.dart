import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {

  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  static Future<String> uploadFile(File file, String path) async {
    try {
      final storageRef = _firebaseStorage.ref().child(path);
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload file: $e");
    }
  }

  static Future<String> getDownloadURL(String path) async {
    return await _firebaseStorage.ref(path).getDownloadURL();
  }
}
