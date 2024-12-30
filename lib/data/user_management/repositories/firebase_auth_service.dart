import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:timetailor/data/user_management/models/user.dart';
import 'user_repository.dart';

class FirebaseAuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

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
      final user = User(
        id: userCredential.user!.uid,
        name: name,
        email: email,
      );
      await UserRepository.addUser(user);

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
      print('Error during registration: $e');
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
      print('Error during sign-in: $e');
      return 'An error occurred. Please try again.';
    }
  }

  // Sign out the current user
  Future<void> signOutUser() async {
    await _firebaseAuth.signOut();
  }

  // Get the currently signed-in user
  Future<User?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      return await UserRepository.getUserById(currentUser.uid);
    }
    return null;
  }
}
