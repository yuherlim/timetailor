import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetailor/data/user_management/models/user.dart';

class UserRepository {
  // Firestore collection reference with converters for the User class
  static final ref =
      FirebaseFirestore.instance.collection("users").withConverter<User>(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, _) => user.toFirestore(),
          );

  // Add a new user
  static Future<void> addUser(User user) async {
    await ref.doc(user.id).set(user);
  }

  // Get all users once
  static Future<QuerySnapshot<User>> getUsersOnce() {
    return ref.orderBy("name", descending: false).get();
  }

  // Get a user by ID
  static Future<User?> getUserById(String userId) async {
    final doc = await ref.doc(userId).get();
    return doc.data(); // Automatically converted to a User object
  }

  // Update user details
  static Future<void> updateUser(User user) async {
    await ref.doc(user.id).update({
      "name": user.name,
      "email": user.email,
    });
  }

  // Delete a user
  static Future<void> deleteUser(String userId) async {
    await ref.doc(userId).delete();
  }
}
