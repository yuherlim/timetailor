import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:timetailor/data/note_management/repositories/note_repository.dart';
import 'package:timetailor/data/task_management/repositories/task_repository.dart';
import 'package:timetailor/data/user_management/models/app_user.dart';
import 'app_user_repository.dart';

class FirebaseAuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final AppUserRepository _appUserRepository;
  final NoteRepository _noteRepository;
  final TaskRepository _taskRepository;

  FirebaseAuthService({
    required AppUserRepository appUserRepository,
    required NoteRepository noteRepository,
    required TaskRepository taskRepository,
  })  : _appUserRepository = appUserRepository,
        _noteRepository = noteRepository,
        _taskRepository = taskRepository;

  // Register a user with Firebase Authentication and store user data in Firestore
  Future<String?> registerUser(
      String name, String email, String password) async {
    try {
      // Create user in Firebase Authentication
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user details to Firestore via UserRepository
      final user = AppUser(
        id: userCredential.user!.uid,
        name: name,
        email: email,
      );
      await _appUserRepository.addUser(user);

      return null; // Indicates success
    } on auth.FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (e.code == 'email-already-in-use') {
        return 'The email address is already in use by another account.';
      } else if (e.code == 'weak-password') {
        return 'The password is too weak. Please use a stronger password.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      }
      return 'An unknown error occurred: ${e.message}';
    } catch (e) {
      // Handle other exceptions
      return 'An error occurred. Please try again.';
    }
  }

  // Sign in a user
  Future<String?> signInUser(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Indicates success
    } on auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          return 'The email or password you entered is incorrect. Please try again.';
        default:
          return 'An unknown error occurred: ${e.message}';
      }
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Sign out the current user
  Future<void> signOutUser() async {
    await _firebaseAuth.signOut();
  }

  // Get the currently signed-in user
  Future<AppUser?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        return await _appUserRepository.getUserById(currentUser.uid);
      } catch (e) {
        debugPrint("Error fetching user: $e");
        return null; // Handle Firestore errors gracefully
      }
    }
    return null;
  }

  // Send a password reset email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; // Indicates success
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else if (e.code == 'user-not-found') {
        return 'There is no user corresponding to this email address.';
      }
      return 'An unknown error occurred: ${e.message}';
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // Delete the current user account
  Future<void> deleteAccount() async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception("No user is currently signed in.");
    }

    try {
      // Delete all notes associated with the user
      final notes = await _noteRepository.getNotesByUserId(currentUser.uid);
      await Future.wait(notes.map((note) async {
        if (note.imageUrl != null && note.imageUrl!.isNotEmpty) {
          await _noteRepository.deleteFile(note.imageUrl!);
        }
        if (note.pdfUrl != null && note.pdfUrl!.isNotEmpty) {
          await _noteRepository.deleteFile(note.pdfUrl!);
        }
        await _noteRepository.deleteNote(note.id);
      }));

      // Delete all tasks associated with the user
      final tasks = await _taskRepository.getTasksByUserId(currentUser.uid);
      await Future.wait(
          tasks.map((task) => _taskRepository.deleteTask(task.id)));

      // Remove user from Firestore
      await _appUserRepository.deleteUser(currentUser.uid);

      // Delete user from Firebase Authentication
      await currentUser.delete();
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            "This action requires a recent login. Please log in again to proceed.");
      }
      throw Exception("Failed to delete account: ${e.message}");
    }
  }
}
