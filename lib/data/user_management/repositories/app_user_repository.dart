import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetailor/data/user_management/models/app_user.dart';

class AppUserRepository {
  // Firestore collection reference with converters for the User class
  final ref =
      FirebaseFirestore.instance.collection("users").withConverter<AppUser>(
            fromFirestore: AppUser.fromFirestore,
            toFirestore: (AppUser user, _) => user.toFirestore(),
          );

  // Add a new user
  Future<void> addUser(AppUser user) async {
    await ref.doc(user.id).set(user);
  }

  // Get all users once
  Future<QuerySnapshot<AppUser>> getUsersOnce() {
    return ref.orderBy("name", descending: false).get();
  }

  // Get a user by ID
  Future<AppUser?> getUserById(String userId) async {
    final doc = await ref.doc(userId).get();
    return doc.data(); // Automatically converted to a User object
  }

  // Update user details
  Future<void> updateUser(AppUser user) async {
    await ref.doc(user.id).update({
      "name": user.name,
      "email": user.email,
    });
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    await ref.doc(userId).delete();
  }
}
